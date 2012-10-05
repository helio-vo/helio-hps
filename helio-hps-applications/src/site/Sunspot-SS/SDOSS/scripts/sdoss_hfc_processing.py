#!/usr/bin/env python

import os, sys, socket
import threading, subprocess
import urllib2
import argparse, csv
from datetime import datetime, timedelta
import time
import logging

Launch_time = time.time()


Hostname = socket.gethostname()

# IDL application local path
Idl_locbin = "/usr/local/bin/idl"

# Path definition
Current_path = os.getcwd()

# Time inputs
Today = datetime.today()
Input_timeformat = '%Y-%m-%dT%H:%M:%S'
Jsoc_timeformat = '%Y.%m.%d_%H:%M:%S'  

# Default values of input arguments
Def_starttime = (Today - timedelta(days=30)).strftime(Input_timeformat) #starttime
Def_endtime = Today.strftime(Input_timeformat) #endtime
Def_cadence = 45 #cadence in sec (if cadence <= 45 --> cadence = 45)
Def_output_directory = os.path.join(Current_path,"../products") #output directory
Def_data_directory = os.path.join(Current_path,"../data") #data directory
Def_sdoss_bin = os.path.join(Current_path,"../bin/sdoss_processing.sav") #Local sdoss idl (runtime) binary file
Def_processings = 1 #number of parallel processings

# history filename
Def_history_file=os.path.join(Current_path,"sdoss_hfc_history.txt")
 
def main():

	parser = argparse.ArgumentParser(description="Program to run sdoss code.",
					 add_help=True,conflict_handler='resolve')
	parser.add_argument('-s','--starttime',nargs='?', 
			    default=Def_starttime,
			    help="start date and time [default="+
			    Def_starttime+"]")
	parser.add_argument('-e','--endtime',nargs='?',
			    default=Def_endtime,
			    help="end date and time [default="+
			    Def_endtime+"]")
	parser.add_argument('-c','--cadence',nargs='?',default=Def_cadence,type=int,
			    help="cadence of observations in seconds [default="+str(Def_cadence)+"]")			
	parser.add_argument('-o','--output_directory',nargs='?',
			    default=Def_output_directory,
			    help="output directory [default="+Def_output_directory+"]")
	parser.add_argument('-d','--data_directory',nargs='?',
			    default=Def_data_directory,
			    help="data directory [default="+Def_data_directory+"]")
	parser.add_argument('-b','--sdoss_bin',nargs='?',
			    default=Def_sdoss_bin,
			    help="sdoss idl binary file [default="+Def_sdoss_bin+"]")	
	parser.add_argument('-p','--processings',nargs='?',
			    default=Def_processings, type=int,
			    help="number of parallel processing [default="+str(Def_processings)+"]")
	parser.add_argument('-h','--history_file',nargs='?',default=Def_history_file,
			    help="path to the sdoss history file [default="+Def_history_file+".")
	parser.add_argument('-Q','--Quicklook',action='store_true',
			    help="save quick-look images")
	parser.add_argument('-R','--Remove_data',action='store_true',
			    help="remove data files after processing.")
	parser.add_argument('-L','--Logfile',action='store_true',
			    help="create log file.")
	parser.add_argument('-V','--Verbose',action='store_true',
			    help="verbose mode")
						
	Namespace = parser.parse_args()
	starttime = datetime.strptime(Namespace.starttime,Input_timeformat)
	endtime = datetime.strptime(Namespace.endtime,Input_timeformat)
	cadence = Namespace.cadence
	output_directory = Namespace.output_directory
	sdoss_bin = Namespace.sdoss_bin
	data_directory = Namespace.data_directory
	nprocessing = Namespace.processings
	history_file = Namespace.history_file
	QUICKLOOK = Namespace.Quicklook
	REMOVE = Namespace.Remove_data
	LOG = Namespace.Logfile
	VERBOSE = Namespace.Verbose

	script_name = "sdoss_hfc_processing"
	if (LOG):
	# Default path for the log file
		log_filename = os.path.join(Current_path, script_name+'.log')
	else:
		log_filename = None
	
	# Setup the logging
	setup_logging(filename=log_filename,quiet = False, verbose = VERBOSE)	

	# Create a logger
	global log 
	log=logging.getLogger(script_name)
	log.info("Starting sdoss_hfc_processing on "+Hostname+" ("+Today.strftime(Input_timeformat)+")")

	# Check SSW_ONTOLOGY environment variable existence
	if not (os.environ.has_key("SSW_ONTOLOGY")):
		print "$SSW_ONTOLOGY environment variable must be defined!"
		sys.exit(1)	
		
	# Get list of HMI Ic T_REC_index and T_REC to process between starttime and endtime
	ds="hmi.ic_45s"
	ic_index, ic_dates = query_jsoc(ds,starttime,endtime,VERBOSE=VERBOSE)
	if (len(ic_index) == 0):
		log.warning("Empty hmi data set!")
		sys.exit(1)
	else:
		log.info("%i record(s) returned.",len(ic_index))

	# If not full cadence, extract images every cadence seconds.
	if (cadence > 45):
		log.info("Process an image every %i sec.",cadence)
		# Generage dates vector
		dateList = [starttime]
		while (max(dateList) < endtime):
			dateList.append(max(dateList) + timedelta(seconds=cadence))
		ic_indices = find_closest(ic_dates,dateList,dt_max=3600.0)

		new_ic_dates = [] ; new_ic_index = []
		for i,current_ind in enumerate(ic_indices):
			if (current_ind == -1): continue
			new_ic_dates.append(ic_dates[current_ind])	
			new_ic_index.append(ic_index[current_ind])
		ic_dates = list(new_ic_dates) ; ic_index = list(new_ic_index)
		del new_ic_dates ; del new_ic_index

	nfile = len(ic_index)
	if (nfile == 0):
		log.warning("Empty data set!")
		sys.exit(0)

	if (VERBOSE):
		log.info("%i pair(s) of hmi files to process.",nfile)

	# Generate the vso url of hmi files
	ds="hmi__Ic_45s"
	ic_url = get_vso_url(ds,ic_index) 
	ds="hmi__M_45s"
	m_url = get_vso_url(ds,ic_index)
 
	# Check if data files have been already processed or not from history file.
	# If they are, remove them from the list.
	if (os.path.isfile(history_file)):
		processed = check_history(history_file,ic_url,VERBOSE=VERBOSE)
		for current_url in processed:
			if (current_url in ic_url):
				i = ic_url.index(current_url)
				ic_url.pop(i) ; m_url.pop(i)
	
	#Initialize sdoss threads for the unprocessed files
	threadList = []
	for i,current_url in enumerate(ic_url):
		threadList.append(run_sdoss(i+1,[current_url,m_url[i]],
					    output_directory=output_directory,
					    data_directory=data_directory,
					    sdoss_bin=sdoss_bin,
					    QUICKLOOK=QUICKLOOK,
					    REMOVE_DATA=REMOVE,
			                    VERBOSE=VERBOSE))

	nthread = len(threadList) 
	if (nthread == 0):
		if (VERBOSE): log.warning("Empty processing list!")
		sys.exit(1)
	else:
		if (VERBOSE): log.info("%i processings to run.",nthread)
	

	# Run sdoss processings
	log.info("Running sdoss...")
	running = []
	npending = nthread 
	for current_thread in threadList:
		if (len(running) < nprocessing):
			current_thread.start()
			running.append(current_thread)
			npending-=1
			if (VERBOSE):	
				log.info("Thread [%i] has started. (%s)",current_thread.thread_id, str(datetime.today()))
				log.info("%i current running processing(s).",len(running))
				log.info("%i current pending processing(s).",npending)
			time.sleep(3)			
		
		i=0
		while(len(running) >= nprocessing):
			if (running[i].terminated):
				if (running[i].success):
					fw = open(history_file,'a')
					fw.write(running[i].fileList[0]+"\n")
					fw.close()
					if (VERBOSE):
						log.info("Thread [%i] has terminated successfuly. (%s)" \
								 ,running[i].thread_id, \
								 str(datetime.today()))
				else:
					if (VERBOSE):
						log.error("Thread [%s] has failed! (%s)" \
								  ,running[i].thread_id, \
								  str(datetime.today()))
				running.remove(running[i])
			i=(i+1)%nprocessing

	log.info("Running sdoss...done")
	log.info("Total elapsed time: %f min.",(time.time() - Launch_time)/60.0)

# Module used in Python 2.6 to compute datetime.total_seconds() module operation.
def total_sec(td):
	return (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10**6

# Module to get the list of hmi files indexes from JSOC 
def query_jsoc(ds,starttime,endtime,VERBOSE=False):	

	if (VERBOSE): log.info("Retrieving "+ds+" data list from jsoc server between "+ \
			     starttime.strftime(Input_timeformat)+" and "+ \
			     endtime.strftime(Input_timeformat)+" ...")
	
	# Define starttime and endtime (in jsoc cgi time format)
	stime = starttime - timedelta(seconds=20) #starttime - 20 sec.
	etime = endtime + timedelta(seconds=20) #endtime + 20 sec.
	stime = stime.strftime(Jsoc_timeformat)
	etime = etime.strftime(Jsoc_timeformat)
	
	# Load date set information from jsoc

	# jsoc/cgi server url of show_info function
	jsoc_url = "http://jsoc.stanford.edu/cgi-bin/ajax/show_info"
	
	# Build url 
	url = jsoc_url + "?ds="+ds+"["+stime+"-"+etime+"]&key=T_REC_index%2CT_REC"
	if (VERBOSE): log.info("Querying --> "+url)
	# Get T_REC_index and T_REC list
	f = urllib2.urlopen(url)

	T_REC_index=[] ; T_REC=[]
	for row in f.read().split("\n")[1:-1]:
		if (row):
			rs = row.split()
			T_REC_index.append(rs[0])
			T_REC.append(datetime.strptime(rs[1],Jsoc_timeformat+"_TAI"))
			
	return T_REC_index, T_REC

# Module to find in a first list of dates, the ones that are
# closest to the dates provided in a second reference list.
# Module returns the subscripts of closest dates of the first list.
def find_closest(input_datetime,ref_datetime,dt_max=-1):

	if (len(input_datetime) == 0) or \
	    (len(ref_datetime) == 0):
		return []
	
	subscripts = []
	for ref_date in ref_datetime:
		dt=[]
		for in_date in input_datetime:
			dt.append(abs(total_sec(ref_date - in_date)))
		if (float(min(dt)) > float(dt_max)):
			subscripts.append(-1)	
		else:
			subscripts.append(list(dt).index(min(dt)))
	
	return subscripts

# Module to generate the url of data set in vso server.
def get_vso_url(ds,t_rec_index,RICE=True):

	# VSO server url
	vso_url="http://vso2.tuc.noao.edu"

	url = vso_url + "/cgi-bin/drms_test/drms_export.cgi?series="+ds
	if (RICE): url+=";compress=rice"

	urlList=[]
	for current_index in t_rec_index:
		record = str(current_index)+"-"+str(current_index)
		current_url = url+";record="+record
		urlList.append(current_url)

	return urlList

def check_history(history_file,urlList,
		  VERBOSE=True):

	if not (os.path.isfile(history_file)):
		if (VERBOSE): log.warning(history_file+" does not exist!")
		return []

	# Read checklist file
	fr = open(history_file,'r')
	fileList = fr.read().split("\n")
	fr.close()

	processed = []
	for current_url in urlList:
		if (current_url in fileList):
			if (VERBOSE): log.info(current_url+" already processed.")
			processed.append(current_url)
		else:
			if (VERBOSE): log.info(current_url+" not processed.")

	return processed

def download_file(url,
		  data_directory=".",
		  filename="",
		  timeout=180,
		  VERBOSE=True):
	
	
	target = "" ; tries=3
	for i in range(tries):
		try:
			if (VERBOSE): log.info("Downloading "+url)
			connect = urllib2.urlopen(url,None,timeout)
		except urllib2.URLError,e:
			log.error("Can not reach %s: %s [%s]",url,e,tries-i)
			time.sleep(3)
			continue
		else:
			if not (filename):
				if (connect.info().has_key('Content-Disposition')):
					filename = connect.info()['Content-Disposition'].split('filename=')[1]
					if (filename.startswith("'")) or (filename.startswith("\"")):
						filename=filename[1:-1]
				else:
					filename=os.path.basename(url)
			target=os.path.join(data_directory,filename)
			if not (os.path.isfile(target)):
				fw = open(target,'wb')
				fw.write(connect.read())
				fw.close()
			else:
				log.info("%s already exists",target)
			break
	return target


# Class to run sdoss (using threading class functionality)
class run_sdoss(threading.Thread):

	def __init__(self,thread_id,fileList,
		     data_directory=Def_data_directory,
		     output_directory=Def_output_directory,
		     QUICKLOOK=True,
		     LOG=False,
		     REMOVE_DATA=False,
		     VERBOSE=False,
		     idl_bin=Idl_locbin,
		     sdoss_bin=Def_sdoss_bin):
		
		threading.Thread.__init__(self)
		self.terminated =False
		self.success=False
		self._stopevent = threading.Event()
	
		self.thread_id = thread_id
		self.fileList = fileList
		self.data_directory = data_directory
		self.output_directory = output_directory
		self.QUICKLOOK = QUICKLOOK
		self.REMOVE_DATA=REMOVE_DATA
		self.LOG=LOG
		self.VERBOSE=VERBOSE
		
		self.idl_bin=idl_bin
		self.sdoss_bin=sdoss_bin
				 
	def run(self):
		
		if not (os.path.exists(self.sdoss_bin)):
			log.error(self.sdoss_bin + " does not exist!")
			self.terminated = True
			return False			
		
		if (len(self.fileList) != 2):
			log.error("input fileList must have two elements!")
			self.terminated = True
			return False

		# If input files are urls then download data files.
		if (self.fileList[0].startswith("http:")) or \
		    (self.fileList[0].startswith("ftp:")):
			ic_url = self.fileList[0]
			ic_file = download_file(ic_url,
						data_directory=self.data_directory,
				                VERBOSE=self.VERBOSE)
			if (ic_file) and (self.VERBOSE): log.info(ic_file+" downloaded.")
		else:
			ic_url = None
			ic_file = self.fileList[0]
		if not (os.path.isfile(ic_file)):
			log.error(ic_file+" does not exist!")
			self.terminated = True
			return False

		if (self.fileList[1].startswith("http:")) or \
		    (self.fileList[1].startswith("ftp:")):
			m_url = self.fileList[1]
			m_file = download_file(m_url,
					       data_directory=self.data_directory,
			                       VERBOSE=self.VERBOSE)
			if (m_file) and (self.VERBOSE): log.info(m_file+" downloaded.")
		else:
			m_url = None
			m_file = self.fileList[1]
		if not (os.path.isfile(m_file)):
			log.error(m_file+" does not exist!")
			self.terminated = True
			return False
	
		idl_args = [ic_file,m_file,"data_dir="+self.data_directory,
			    "output_dir="+self.output_directory,
			    "feat_min_pix=9"]
		if (ic_url): idl_args.append("ic_url="+ic_url)
		if (m_url): idl_args.append("m_url="+m_url)
		idl_args.append("/CSV")
		if (self.QUICKLOOK): idl_args.append("/QUICKLOOK")
		if (self.LOG): idl_args.append("/LOG")
		if (self.VERBOSE): idl_args.append("/VERBOSE")			
	
		#build idl command line
		idl_cmd = [self.idl_bin]+["-queue","-quiet","-rt="+self.sdoss_bin,"-args"]
		idl_cmd.extend(idl_args)
		
		if (self.VERBOSE): log.info("Executing --> "+ " ".join(idl_cmd))
		idl_process = subprocess.Popen(idl_cmd, 
					       stdout=subprocess.PIPE,
					       stderr=subprocess.PIPE)
		output, errors = idl_process.communicate()
		if idl_process.wait() == 0:
			log.info("Sucessfully ran idl command %s, output: %s, errors: %s",
			       ' '.join(idl_cmd), str(output), str(errors))
			if (len(errors) == 0): self.success=True
		else:
			log.error("Error running idl command %s, output: %s, errors: %s",
			       ' '.join(idl_cmd), str(output), str(errors))

		if (self.REMOVE_DATA):
			os.remove(ic_file)
			os.remove(m_file)
			if (self.VERBOSE):
				log.info(ic_file+" deleted.")
				log.info(m_file+" deleted.")
		
		time.sleep(3)
		self.terminated = True	
		
	def stop(self):
		self._stopevent.set()
    	
	def setTerminated(self,terminated):
		self.terminated = terminated

# Module to setup logging 
def setup_logging(filename = None, quiet = False, verbose = False, debug = False):
	global logging
	if debug:
		logging.basicConfig(level = logging.DEBUG, format='%(levelname)-8s: %(message)s')
	elif verbose:
		logging.basicConfig(level = logging.INFO, format='%(levelname)-8s: %(message)s')
	else:
		logging.basicConfig(level = logging.CRITICAL, format='%(levelname)-8s: %(message)s')
	
	if quiet:
		logging.root.handlers[0].setLevel(logging.CRITICAL + 10)
	elif verbose:
		logging.root.handlers[0].setLevel(logging.INFO)
	else:
		logging.root.handlers[0].setLevel(logging.CRITICAL)
	
	if filename:
		import logging.handlers
		fh = logging.FileHandler(filename, delay=True)
		fh.setFormatter(logging.Formatter('%(asctime)s %(name)-12s %(levelname)-8s %(funcName)-12s %(message)s', datefmt='%Y-%m-%d %H:%M:%S'))
		if debug:
			fh.setLevel(logging.DEBUG)
		else:
			fh.setLevel(logging.INFO)
		
		logging.root.addHandler(fh)

if (__name__ == "__main__"):
	main()
