;+
; NAME:
;		sdo_ss_launcher
;
; PURPOSE:
;		Launch the SunSpot recogniton code for SDO/HMI data 
;		(developped by Serguei Zharkov in the frame of the 
;		HELIO project) in a given time range.
;		Data can be loaded from local disk, or 
;		downloaded from JSOC server using SSW/VSO routines.
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		SDOSS
;
; CALLING SEQUENCE:
;		IDL> sdo_ss_launcher,starttime,endtime
;
; INPUTS:
;		starttime - Scalar of string type containing the starting time (in ISO 8601 format) 
;				    of SDO/HMI data to process.
;		endtime	  - Scalar of string type containing the ending time (in ISO 8601 format) 
;				    of SDO/HMI data to process.
;
; OPTIONAL INPUTS:
;		sample		- Define the cadence of SDO/HMI images 
;					  (by default highest cadence -> 45 sec).
;       scf	  		- Scaling factor (either 1 or 4)
;                         1 : normal resolution is used
;                         4 : the images are rescaled 4 times down
;                           (SOHO/MDI resolution)		
;       write_fits 	- Write auxillary files
;                         = 1: Intensity with limb darkening removed
;                         = 2: as 1 plus detection results
;                         = 3: as 2 plus corresponding magnetogram
;		data_dir 	- The full path name of the directory where the
;					  SDO HMI fits files are saved. 
;				      Default is current one.
;		output_dir	- The full path name of directory where the output files produced by SDOSS code will be saved.
;					  Default is current one.
;		fnc			- Vector of string type providing the list of 
;					  input SDO/HMI Ic fits file(s) to process.
;		fnm			- Vector of string type providing the list of 
;					  input SDO/HMI M fits file(s) to process.
;					  if both fnc and fnm are provided
;
; KEYWORD PARAMETERS: 
;		/WRITE_PNG      - Create a png file of the HMI Continuum images with the results of detections. 
;		/CLEAN_DATA	    - Remove SDO data file from local disk after processing.
;						  (USE WITH CAUTION!)
;		/WRITE_CSV	    - Write detection results into csv format files 
;		/DOWNLOAD_DATA  - If set, download data from JSOC server if no file
;						  is found in the local disk.
;						  Downloaded files will be saved in data_dir directory.
;		/SILENT		    - Quiet mode.
;		
; OUTPUTS:
;		None.				
;
; OPTIONAL OUTPUTS:
;		None.		
;		
; COMMON BLOCKS:
;		None.		
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS/COMMENTS:
;		- The Solar SoftWare (SSW) with sdo, vso, and ontology packages must be loaded.
;		- SDOSS auxiliary IDL routines must be compiled.
;		- An internet access is required to download SDO/HMI data from JSOC.
;
;
; CALL:
;		sdo_ss_processing
;		vso_search
;		vso_get
;		jd2str
;		tim2jd
;
; EXAMPLE:
;		None.
;		
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 10-JUL-2011. 
;
;		18-JUL-2011, X.Bonnin:	Added CSV keyword.
;		03-JAN-2012, X.Bonnin:  Added fnc and fnm keywords.
;
;-

PRO sdo_ss_launcher,starttime,endtime,$
				    scf=scf,write_fits=write_fits,$
				    sample=sample, $
				    data_dir=data_dir,$
					fnc=fnc, fnm=fnm, $
				    output_dir=output_dir,$
				    WRITE_CSV=WRITE_CSV,CLEAN_DATA=CLEAN_DATA,$
				    DOWNLOAD_DATA=DOWNLOAD_DATA,$
				    WRITE_PNG=WRITE_PNG,SILENT=SILENT


;[1]:Initializing 
;[1]:============
launch_time = systime(/sec)
run_date = !stime
if (n_params() lt 2) then begin
	message,/INFO,'Call is:'
	print,'IDL>sdo_ss_launcher,starttime,endtime, $'
	print,'                    scf=scf,write_fits=write_fits,$'
	print,'                    sample=sample,$'
	print,'                    data_dir=data_dir,$'
	print,'                    fnc=fnc, fnm=fnm, $'
	print,'	                   output_dir=output_dir,$'
	print,'                    /WRITE_PNG,/WRITE_CSV,/CLEAN_DATA,$'
	print,'                    /DOWNLOAD_DATA,/SILENT'
	return
endif

WRITE_PNG = keyword_set(WRITE_PNG)
WRITE_CSV = keyword_set(WRITE_CSV)
CLEAN = keyword_set(CLEAN_DATA)
SILENT = keyword_set(SILENT)
DOWNLOAD = keyword_set(DOWNLOAD_DATA)

cd,current=current_dir
if (~keyword_set(data_dir)) then data_dir = current_dir
if (~keyword_set(output_dir)) then begin
	out_dir = 'products'
	if (~file_test(out_dir,/DIR)) then spawn,'mkdir '+out_dir
endif else out_dir = strtrim(output_dir[0],2)

if (not keyword_set(starttime)) then starttime = '2010-04-01T00:00:00'
if (not keyword_set(endtime)) then $
	endtime = (strsplit(anytim(!stime, /ccsds),'.',/EXTRACT))[0]
jstart = anytim2jd(starttime) & jstart = jstart.int + jstart.frac
jend = anytim2jd(endtime) & jend = jend.int + jend.frac
;[1]:============

;[2]:Preparing data set
;[2]:==================
if (~SILENT) then print,'Preparing data set...'
vso_c_flag = 0 & vso_m_flag = 0
;Continum data
if (not keyword_set(fnc)) then begin
	if (not DOWNLOAD) then begin
		message,/CONT,'No hmi ic fits file provided!'
		return
	endif
	print,'Loading SDO/HMI Ic meta-data from vso...' 
	metac = vso_search(starttime,endtime, $
					   instrument='hmi', $
					   physobs='intensity', $
					   sample=sample,/URL)
	if (size(metac,/TNAME) ne 'STRUCT') then begin
		message,/INFO,'Cannot retrieving meta-data!'
		return
	endif
	vso_c_flag = 1
	print,'Loading SDO/HMI Ic meta-data from vso:OK'
	fnc = data_dir + path_sep() + file_basename(metac.fileid)
	jdc = anytim2jd(metac.time.start) & jdc = jdc.int+jdc.frac
endif else begin
	read_sdo, fnc, inc, /nodata
	jdc=anytim2jd(inc.date_obs) & jdc=jdc.int+jdc.frac
endelse

;sort data by increasing date
is = sort(jdc)
fnc = fnc[is]
jdc = jdc[is]
if (keyword_set(metac)) then metac = metac(is)


;Magnetogram
if (not keyword_set(fnm)) then begin
	if (not DOWNLOAD) then begin
		message,/CONT,'No hmi m fits file provided!'
		return
	endif
	print,'Loading SDO/HMI M meta-data from vso...' 
	metam = vso_search(starttime,endtime, $
					   instrument='hmi', $
					   physobs='los_magnetic_field', $
					   sample=sample,/URL)
	if (size(metam,/TNAME) ne 'STRUCT') then begin
		message,/INFO,'Cannot retrieving meta-data!'
		return
	endif
	vso_m_flag = 1
	print,'Loading SDO/HMI M meta-data from vso:OK'
	fnm = data_dir + path_sep() + file_basename(metam.fileid)
	jdm = anytim2jd(metam.time.start) & jdm = jdm.int+jdm.frac
endif else begin
	read_sdo, fnm, inm, /nodata
	jdm=anytim2jd(inm.date_obs) & jdm=jdm.int+jdm.frac
endelse

nfnc = n_elements(fnc) & nfnm = n_elements(fnm)
print,strtrim(nfnc,2) + ' hmi ic fits file(s) found.'
print,strtrim(nfnm,2) + ' hmi m fits file(s) found.'
if (~SILENT) then print,'Preparing data set:OK'
;[2]:==================


;[3]:Launching detection
;[3]:=================== 
unprocessed = ''
for i=0l,nfnc-1l do begin
	iter = strtrim(nfnc-i,2)
	print,iter  +': Processing ' + fnc[i] + '...'
	if (not file_test(fnc[i])) then begin
		print,fnc[i] + ' has not been found.'
		if (DOWNLOAD) and (vso_c_flag) then begin
			jdc_i = jdc[i]
			inc_i = vso_get(metac(i),$
			     		    out_dir=data_dir, $
						    filenames=fnc_i, $
						    /RICE)
		endif else begin
			unprocessed = [unprocessed,fnc[i]]
			continue
		endelse		
	endif else begin
		print,fnc[i] + 'has been found'
		fnc_i = fnc[i]
		jdc_i = jdc[i]
	endelse

	if (jdc_i lt jstart) or (jdc_i gt jend) then begin
		print,'Date of observation is outside the time range!'
		unprocessed = [unprocessed,fnc[i]]
		continue
	endif

	jd = min(abs(jdc_i - jdm),im)
	if (jd gt 1) then begin
		print,'No corresponding magnetogram found.'
		unprocessed = [unprocessed,fnc[i]]
		continue
	endif
	fnm_i = fnm[im]
	jdm_i = jdm[im]
	
	if (not file_test(fnm_i)) then begin
		print,fnm_i+' has not been found.'
		if (DOWNLOAD) and (vso_m_flag) then begin
			inm_i = vso_get(metam(im),$
			     		    out_dir=data_dir, $
						    filenames=fnm_i, $
						    /RICE)
		endif else begin
			unprocessed = [unprocessed,fnm_i]
			continue
		endelse			
	endif	


	if (~SILENT) then print,'Running sunspot detection code...'
	sdo_ss_processing,fnc_i,fnm_i,$
	   				  write_fits=write_fits,scf=scf,$
					  outroot=output_dir+path_sep(),$
					  status_ic=inc_i,status_m=inm_i,$
					  WRITE_CSV=WRITE_CSV,WRITE_PNG=WRITE_PNG
	if (~SILENT) then print,'Running sunspot detection code:OK'
	
	if (CLEAN) then begin
		;Delete fits files after processing
		if (~SILENT) then print,'Cleaning input SDO/HMI fits files...'
		spawn,'rm -f '+fnc_i
		spawn,'rm -f '+fnm_i
		if (~SILENT) then print,'Cleaning input SDO/HMI fits files:OK'
	endif
	print,iter  +': Processing ' + fnc[i] + ':OK'
endfor

nunpro = n_elements(unprocessed)
if (nunpro gt 1) then begin
	print,strtrim(nunpro-1L,2)+ 'files have not been processed correctly!'
	openw,lun,output_dir+path_sep()+'sdo_ss_launcher.log',/GET_LUN
	for j=0L,nunpro-2L do printf,lun,strtrim(unprocessed[j+1L],2)+' has not been processed.'
	printf,lun,run_date
	close,lun
	free_lun,lun
	print,'Check '+output_dir+path_sep()+'sdo_ss_launcher.log for more details.'
endif

print,'Program has ended correctly'
print,'Elapsed time: '+strtrim(systime(/SEC)-launch_time,2)+' sec.'
print,''
END
