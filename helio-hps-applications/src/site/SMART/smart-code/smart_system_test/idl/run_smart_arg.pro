;Run this in the smart_system directory

pro run_smart_arg, date=date, filelist=filelist, test=test, debug=debug,mdidir=mdidir,runname=runname


;/Volumes/Data\ Disk/data/solmon
datapath='/Users/solmon/Sites/data/'
if keyword_set(test) then begin
	datapath='./data/mdi/test/'
	filelist=file_search(datapath+'smdi*')
	goto,skip_getfiles
endif

;GET DATE INFO
if n_elements(date) lt 1 then thisdate=time2file(systim(/utc),/date) $
	else thisdate=date

print,'THISDATE = '+strjoin(strtrim(thisdate,2),'-')
print,'THE TIME IS NOW '+systim(/utc)

;Skip get filelist if there is a filelist input
if n_elements(filelist) gt 0 then begin 
   logfile='smart_test_'+time2file(systim(/utc))+'.txt' 
   goto,skip_getfiles 
endif

if n_elements(thisdate) eq 1 then begin
	calc_date,thisdate,-1,prevdate
	calc_date,prevdate,-1,prevdate2

	;INITIALIZE LOG FILE
	logfile='smart_test_'+thisdate+'.txt'

	;FIND MDI FILES

	last3dir=[datapath+prevdate2+'/fits/smdi/', $
		datapath+prevdate+'/fits/smdi/', $
		datapath+thisdate+'/fits/smdi/']

;	filelist=[file_search(last3dir[0],'smdi_maglc_fd*'+prevdate2+'*.fts*'), $
;		file_search(last3dir[1],'smdi_maglc_fd*'+prevdate+'*.fts*'), $
;		file_search(last3dir[2],'smdi_maglc_fd*'+thisdate+'*.fts*')]
	filelist=[file_search(last3dir[1],'smdi_maglc_fd*'+prevdate+'*.fts*'),file_search(last3dir[2],'smdi_maglc_fd*'+thisdate+'*.fts*')]

	print,'FILELIST = '
	for i=0,n_elements(filelist)-1 do print,filelist[i]

endif else begin
	;INITIALIZE LOG FILE
	logfile='smart_test_'+thisdate[0]+'_'+thisdate[1]+'.txt'

;NEED TO CREATE LIST OF DIRECTORIES TO SEARCH
;THEN SEARCH ALL AND CONCAT FILES
	dates=datearr(thisdate[0], thisdate[1])
	
	filelist=file_search(datapath+dates[0]+'/fits/smdi/','smdi_maglc_fd*'+dates[0]+'*.fts*')
	for i=1,n_elements(dates)-1 do begin
		filelist=[filelist,file_search(datapath+dates[i]+'/fits/smdi/','smdi_maglc_fd*'+dates[i]+'*.fts*')]
	endfor

endelse

;Skip to here if filelist is input
skip_getfiles:

if keyword_set(debug) then print,'Skipped getfiles'


;GET UNIQ FILENAMES
nfiles=n_elements(filelist)
filenames=strarr(nfiles)
for i=0,n_elements(filelist)-1 do filenames[i]=(reverse(str_sep(filelist[i],'/')))[0]
ufilelist=uniq(filenames)
if keyword_set(debug) then print,'Unique files found', ufilelist

filelist=filelist[ufilelist]

;filelist=file_search(smart_paths(/mdi,/no_calib),'smdi*200910*.fts*')
;filelist=filelist[30:31]

;UNCOMMENT /CALIB FOR NON PLANNING DATA, set append to add to a log file
;Get Detections
smart_server, filelist=filelist, logfile=logfile, FRM_PARAMSET=FRM_PARAMSET, /calib,debug=debug;, /append

;Get list of .SAV files
readcol,smart_paths(/log,/no_calib)+logfile, filelist,form='(A)';'(A90)'
filelist=strtrim(filelist,2)
filelist=filelist[uniq(filelist)]

if n_elements(filelist) eq 1 and filelist[0] eq '' then goto,skip_nodata


;Write FITS files
;stop

;smart_sav2fits, filelist, smart_paths(/fits,/no_calib),/gzip

;Calculate PIL properties
;Also removes 2d maps from sav files 
smart_add_properties, filelist, /nl_prop, /plot,/png,/extent_prop,/noaa_prop;,/ps


;write database files
heliodb_meta,filelist,runname=runname,mdidir=mdidir
goto,skip_nodata
;;Track ARs
;;Also plots detections with catalog names
;smart_persistence3, timerange=[anytim(anytim(file2time(filelist[0]))-(3600.*24.*3.),/vms),systim(/utc)];, /plot ;,filelist=filelist

;;Create full disk plots
smart_disk_display, filelist=filelist

;;Create tracking plots
;run_track_id, file=(reverse(filelist))[0] ;reverse(filelist[0])

;;Write detection properties in to ASCII files
;smart_struct2ascii, file=filelist;, outfile=(reverse(strsplit(filelist,'/')))[0]+'.dat'

smart_write_ar_table, filelist

;;Write VO Events for each region detected
;smart_voevent, filelist, FRM_PARAMSET=FRM_PARAMSET, /no_sav

;;for i=0,n_elements(filelist)-1 do spawn,'gzip -f '+filelist[i]

;info=scope_traceback(/structure)
;stop

skip_nodata:

end
