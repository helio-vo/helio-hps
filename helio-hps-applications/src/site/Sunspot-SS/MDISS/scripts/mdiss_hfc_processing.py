#!/usr/bin/env python

import os, sys, re
import threading, subprocess
import urllib2
import argparse, csv
from datetime import datetime, timedelta
import time
sys.path.append("./../lib")
import stiltslib, VOTable

# MEDOC 
medoc_hqi = 'http://helio-hqi.ias.u-psud.fr/helio-soho/HelioQueryService'
medoc_table = 'soho_view'

# SDAC
sdac_ftp = "http://sohodata.nascom.nasa.gov/archive/soho/private/data/processed/mdi"

# HFC server
hfc_server = "voparis-helio.obspm.fr"
hfc_port = 8080
hfc_db = "hfc1test"
hfc_host = "helio-fc1.obspm.fr"
hfc_user = "guest"
hfc_pswd = "guest"

# IDL application local path
idl_locbin = "/usr/bin/env idl"

# Time inputs
today = datetime.today()
input_timeformat = '%Y-%m-%dT%H:%M:%S' 
sql_timeformat = '%Y-%m-%d %H:%M:%S.%f'
sql_timeformat1 = '%Y-%m-%d%H:%M:%S.%f'

# Default values of input arguments
s0 = (today - timedelta(days=30)).strftime(input_timeformat) #starttime
e0 = today.strftime(input_timeformat) #endtime
c0 = 0 #cadence in sec (=0 --> Full resolution)
o0 = "/data/helio/hfc/frc/mdiss" #output directory
d0 = "/poubelle/helio/hfc/frc/mdiss" #data directory
b0 = "/home/helio/hfc/frc/mdiss/bin/mdiss_processing.sav" #Local mdiss idl (runtime) binary file
p0 = 1 #number of parallel processings

def main():

	launch_time = time.time()

	parser = argparse.ArgumentParser()
	parser.add_argument('-s','--starttime',nargs='?', 
			    default=s0,
			    help="start date and time ["+
			    s0+"]")
	parser.add_argument('-e','--endtime',nargs='?',
			    default=e0,
			    help="end date and time ["+
			    e0+"]")
	parser.add_argument('-c','--cadence',nargs='?',default=c0,
			    help="cadence of observations in seconds")				
	parser.add_argument('-o','--output_directory',nargs='?',
			    default=o0,
			    help="output directory ["+o0+"]")
	parser.add_argument('-d','--data_directory',nargs='?',
			    default=d0,
			    help="data directory ["+d0+"]")
	parser.add_argument('-b','--mdiss_bin',nargs='?',
			    default=b0,
			    help="mdiss idl runtime binary file ["+b0+"]")	
	parser.add_argument('-p','--processing_number',nargs='?',
			    default=p0, type=int,
			    help="number of parallel processing ["+str(p0)+"]")
	parser.add_argument('-C','--Clean_data',action='store_true',
						help='Clean data files after processing')
	parser.add_argument('-L','--Logfile',action='store_true',
						help='Write log file')						
	parser.add_argument('-Q','--Quicklook',action='store_true',
			    help="save quick-look images")
	parser.add_argument('-U','--Unprocessed_only',action='store_true',
			    help="Only run mdiss on files which are not already processed in the HFC")
	parser.add_argument('-V','--Verbose',action='store_true',
			    help="verbose mode")
						
	Namespace = parser.parse_args()
	starttime = datetime.strptime(Namespace.starttime,input_timeformat)
	endtime = datetime.strptime(Namespace.endtime,input_timeformat)
	cadence = int(Namespace.cadence)
	output_directory = os.path.abspath(Namespace.output_directory)
	frc_bin = os.path.abspath(Namespace.mdiss_bin)
	data_directory = os.path.abspath(Namespace.data_directory)
	nprocessing = Namespace.processing_number
	LOG = Namespace.Logfile
	CLEAN = Namespace.Clean_data
	QCLK = Namespace.Quicklook
	UNPROC = Namespace.Unprocessed_only
	VERBOSE = Namespace.Verbose

	if (QCLK): 
		write_png=2
	else:
		write_png=0

	# Check input paths existence
	if not (os.path.isfile(frc_bin)):
		if (VERBOSE): print frc_bin+" does not exist!"
		sys.exit(1)

	#Get list of MDI Ic and M files to process between starttime and endtime
	fileList = get_mdi_filelist(starttime,endtime,cadence,VERBOSE=VERBOSE)
	if (len(fileList) == 0):
		if (VERBOSE): print "Empty mdi data set!"
		sys.exit(1)	
	else:
		if (VERBOSE): print str(len(fileList))+" files found."

	#Check HFC database to verify if files in the list have been already
	if (UNPROC):
		processed, unprocessed = check_hfc(fileList,VERBOSE=VERBOSE)
		fileList = list(unprocessed)
	
	#Initialize sdoss threads for the unprocessed files
	threadList = []
	for i,current_files in enumerate(fileList):
		threadList.append(run_mdiss(i+1,current_files,
					    	output_directory=output_directory,
					    	data_directory=data_directory,
					    	frc_bin=frc_bin, write_png=write_png,
					    	DOWNLOAD_DATA=True, CLEAN_DATA=CLEAN, 
					    	VERBOSE=VERBOSE,WRITE_LOG=LOG))

	nthread = len(threadList) 
	if (nthread == 0):
		if (VERBOSE): print "Empty processing list!"
		sys.exit(1)
	else:
		if (VERBOSE): print str(nthread)+" processings to run." 
	

	#Run mdiss processings
	running = []
	completed=[]
	npending = nthread 
	while (len(threadList) > 0):
		new_threadList = list(threadList)
		for current_thread in threadList:
			if ((len(running) < nprocessing) and
				(running.count(current_thread) == 0) and
				(completed.count(current_thread) == 0)):
					current_thread.start()
					running.append(current_thread)
					npending-=1
					if (VERBOSE):	
						print "thread ["+str(current_thread.thread_id)+"] has started."
						print str(len(running))+" current running processing(s)." 
						print str(npending)+" current pending processing(s)."
					time.sleep(3)
			else:
				if (current_thread.terminated):
					current_thread.stop()
					new_threadList.remove(current_thread)
					running.remove(current_thread)
					completed.append(current_thread)
					if (VERBOSE): print ("thread ["+
						str(current_thread.thread_id)+"] has terminated.")
		threadList = list(new_threadList)
			
	if (VERBOSE): 
		print "Program has ended correctly"
		print "Elapsed time: "+str(int((time.time() - launch_time)/60.0))+" min."	
	sys.exit(0)

# Module used in Python 2.6 to compute datetime.total_seconds() module operation.
def total_sec(td):
	return (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10**6

# Module to retrieve list of mdi files from MEDOC server
def get_mdi_filelist(starttime,endtime,cadence=0,VERBOSE=False):
	fileList = []

	if (VERBOSE): print ("Retrieving soho/mdi file list from medoc server between "+
						 starttime.strftime(input_timeformat)+" and "+
						 endtime.strftime(input_timeformat)+" ...")
		
	# Extend starttime and endtime 
	stime = starttime - timedelta(seconds=60) #starttime - 60 sec.
	etime = endtime + timedelta(seconds=60) #endtime + 60 sec.
	stime = stime.strftime(input_timeformat)
	etime = etime.strftime(input_timeformat)
	
	# Load date set information
	
	# Build url for ic data set
	url = medoc_hqi + "?FROM="+medoc_table
	url = url + "&STARTTIME="+stime+"&ENDTIME="+etime
	url = url + "&WHERE=instrument,MDI"
	# Query MEDOC database ...
	if (VERBOSE): print "Query --> "+url
	votable = VOTable.VOTable()
	votable.parse(urllib2.urlopen(url))
	rows = votable.getDataRows()
	cList = [] ; mList = []
	for row in rows:
	   col = votable.getData(row)
	   url = str(col[6])
	   basename = os.path.basename(url)
	   id = basename.split(".")[1]
	   if ("fd_Ic_" in col[6]):
	       if (int(id) < 3346): id = "00"+id
	       url = sdac_ftp + "/fd_Ic_6h_01d/fd_Ic_6h_01d."+id+"/"+basename #Use SDAC ftp server to download files instead of MEDOC which has a big lack of data!
	       cList.append([datetime.strptime(str(col[0]),sql_timeformat),url]) 
	   if ("fd_M_" in col[6]): 
	   	if (int(id) < 5844): id = "00"+id
	   	url = sdac_ftp + "/fd_M_96m_01d/fd_M_96m_01d."+id+"/"+basename #Use SDAC ftp server to download files instead of MEDOC which has a big lack of data!
		if (re.search('\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d+',str(col[0])) is not None):
			mList.append([datetime.strptime(str(col[0]),sql_timeformat),url])
		elif (re.search('\d{4}-\d{2}-\d{2}\d{2}:\d{2}:\d{2}.\d+',str(col[0])) is not None):
			mList.append([datetime.strptime(str(col[0]),sql_timeformat1),url])

	if (len(cList) == 0) or (len(mList) == 0): return fileList
	
	# Group continuum and magnetogram files by pair,
	# finding the nearest magnetogram file 
	time_step = endtime
	for citem in cList:
	
		if (cadence > 0):
			gap = abs(total_sec(citem[0] - time_step))
			if (gap < cadence): 
				continue
			else:
				time_step = citem[0]

		dt = [] 
		for mitem in mList:
			dt.append(abs(total_sec(citem[0] - mitem[0])))
        
		index = dt.index(min(dt))
		if (dt[index] > 86400.0): continue
		fileList.append([citem[1],mList[index][1]])
		
	return fileList

# Module to check file existence in the HFC
def check_hfc(fileList,
	      host=hfc_host,
	      database=hfc_db,
	      user=hfc_user,
	      password=hfc_pswd,
	      VERBOSE=False):

	hfc = stiltslib.connect(database,host,hfc_server,
							user=user,passwd=password,
							server_port=hfc_port)
	
	processed = []
	unprocessed = []
	for current_files in fileList:
		basename = [os.path.basename(current_files[0]),os.path.basename(current_files[1])]
		cmd = "SELECT filename FROM OBSERVATIONS WHERE (FILENAME=\""+basename[0]+"\")"
		resp = hfc.query(cmd,ofmt='votable',VERBOSE=VERBOSE)
		if ("<TD>"+basename[0]+"</TD>" in resp):
			processed.append(current_files)
			if (VERBOSE): print " and ".join(basename)+" already processed." 
		else:
			unprocessed.append(current_files)
			if (VERBOSE): print " and ".join(basename)+" not processed."

	return processed, unprocessed

# Class to run mdiss (using threading class functionality)
class run_mdiss(threading.Thread):

	def __init__(self,thread_id,fileList,
		     data_directory=d0,
		     output_directory=o0,
		     write_png=p0,
		     WRITE_LOG=True,
		     WRITE_CSV=True,
		     DOWNLOAD_DATA=False, 
		     CLEAN_DATA=False,
		     VERBOSE=True,
		     idl_bin=idl_locbin,
		     frc_bin=b0):
		
		threading.Thread.__init__(self)
		self.terminated = False
		self._stopevent = threading.Event()
	
		self.thread_id = thread_id
		self.fileList = fileList
		self.data_directory = data_directory
		self.output_directory = output_directory
		self.write_png = write_png
		self.DOWNLOAD_DATA=DOWNLOAD_DATA
		self.CLEAN_DATA=CLEAN_DATA
		self.WRITE_LOG=WRITE_LOG
		self.VERBOSE=VERBOSE
		
		self.idl_bin=idl_locbin
		self.frc_bin=frc_bin
				 
	def run(self):
		
		if not (os.path.exists(self.frc_bin)):
			if (self.VERBOSE): print self.frc_bin + " does not exist!"
			self.terminated = True
			return False			
		
		if (len(self.fileList) != 2):
			if (self.VERBOSE): print "Input fileList must contain both" + \
			 					 	 " the continuum and magnetogram files!"
			self.terminated = True
			return False
		
		# Check continuum files' existence, and download it if asked
		fnc = os.path.join(self.data_directory,os.path.basename(self.fileList[0]))
		if not (os.path.isfile(fnc)):
			if (self.VERBOSE): print fnc+" does not exist!"
			if (self.DOWNLOAD_DATA):
				wget_cmd = "wget -q -nc "+self.fileList[0]+' -P '+self.data_directory
				if (self.VERBOSE): 
					print "Downloading file..."
					print wget_cmd
					wget_process = subprocess.Popen(wget_cmd, 
					       				stdout=subprocess.PIPE,
					       				stderr=subprocess.PIPE,
					       				shell=True)
					wget_process.communicate(input=None)
					if (wget_process.wait() == 0):
						if (self.VERBOSE): print "Downloading file...done"
					else:
						if (self.VERBOSE): print "File can not be downloaded!"
		if not (os.path.isfile(fnc)): 
			self.terminated = True
			return False
		
		# Check magnetogram files' existence, and download it if asked
		fnm = os.path.join(self.data_directory,os.path.basename(self.fileList[1]))
		if not (os.path.isfile(fnm)):
			if (self.VERBOSE): print fnm+" does not exist!"
			if (self.DOWNLOAD_DATA):
				wget_cmd = "wget -q -nc "+self.fileList[1]+' -P '+self.data_directory
				if (self.VERBOSE): 
					print "Downloading file..."
					print wget_cmd
					wget_process = subprocess.Popen(wget_cmd, 
					       				stdout=subprocess.PIPE,
					       				stderr=subprocess.PIPE,
					       				shell=True)
					wget_process.communicate(input=None)
					if (wget_process.wait() == 0):
						if (self.VERBOSE): print "Donwloading file...done"
					else:
						if (self.VERBOSE): print "File can not be downloaded!"
				
		if not (os.path.isfile(fnm)): 
			self.terminated = True
			return False

		# Launching mdiss idl runtime program
		idl_args = [fnc,fnm,"data_dir="+self.data_directory,
			    "output_dir="+self.output_directory,"write_png="+str(self.write_png),
			    "urlc="+self.fileList[0],"urlm="+self.fileList[1],'feat_min_pix=4']
		idl_args.append("/WRITE_CSV")
		idl_args.append("/UNPROCESSED")
		if (self.WRITE_LOG): idl_args.append("/WRITE_LOG")
		if (self.VERBOSE): idl_args.append("/VERBOSE")			

		#build idl command line
		idl_cmd = [self.idl_bin,"-queue","-rt="+self.frc_bin,"-args"]
		idl_cmd.extend(idl_args)
		idl_cmd = " ".join(idl_cmd)
		
		if (self.VERBOSE): print idl_cmd
		idl_process = subprocess.Popen(idl_cmd, 
					       stdout=subprocess.PIPE,
					       stderr=subprocess.PIPE,
			                       shell=True)
		output, errors = idl_process.communicate()
		if idl_process.returncode == 0:
			if (self.VERBOSE): print ("Sucessfully ran idl, output: %s, errors: %s" %
			       				(str(output), str(errors)))
		else:
			print ("Error running idl, output: %s, errors: %s" %
			       (str(output), str(errors)))

		if (self.CLEAN_DATA):
			os.remove(fnc)
			os.remove(fnm)
			if (self.VERBOSE): print "data files have been deleted"
		
		time.sleep(3)
		self.terminated = True	
		
	def stop(self):
		self._stopevent.set()
    	
	def setTerminated(self,terminated):
		self.terminated = terminated

if (__name__ == "__main__"):
	main()
