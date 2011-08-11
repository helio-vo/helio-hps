;+
; NAME:
;		sdo_ss_launcher
;
; PURPOSE:
; 		Launch the SDO SunSpot recogniton code for SDO/HMI 
;		(developped by Serguei Zharkov from MSSL).
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
;		sample		- Define the cadence of SDO/HMI images (by default highest cadence -> 45 sec).
;       scf	  		- Scaling factor (either 1 or 4)
;                         1 : normal resolution is used
;                         4 : the images are rescaled 4 times down
;                           (SOHO resolution)		
;       write_fits 	- Write auxillary files
;                         = 1: Intensity with limb darkening removed
;                         = 2: as 1 plus detection results
;                         = 3: as 2 plus corresponding magnetogram
;
;		data_dir 	- The full path name of SDO HMI fits files directory. 
;				   	  (If /LOCAL_FILES keyword is not set, downloaded files will be copied in this directory.)
;				      (If data_dir is not provided, use the current one by default.)
;		output_dir	- The full path name of directory where the output files produced by SDOSS code will be saved.
;					  (If output_dir is not provided, use the current one by default.)
;
; KEYWORD PARAMETERS:
;		/LOCAL_FILES  - If set, read data from local directory specified by data_dir optional input parameter,
;				  		else download sdo data using VSO SSW routines. 
;		/PNG		  - Create a png file of the HMI Continuum images with the results of detections. 
;		/CLEAN		  - Remove SDO data file after processing.
;		/CSV		  - Write detection results into csv format files
;				 	    instead of xml files. 
;		/SILENT		  - Quiet mode.
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
;		The SolarSoft Ware (SSW) with sdo, vso, and ontology packages must be installed.
;		SDOSS auxiliary IDL routines must be compiled.
;		An internet access is required to download SDO/HMI data 
;		if /LOCAL_FILES keyword is not set.
;
;
; CALL:
;		sdo_ss_processing
;		vso_search
;		vso_get
;
; EXAMPLE:
;		None.
;		
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 10-JUL-2011. 
;
;		18-JUL-2011, X.Bonnin:	Added CSV keyword.
;
;-

PRO sdo_ss_launcher,starttime,endtime,$
				    scf=scf,write_fits=write_fits,$
				    sample=sample,$
				    data_dir=data_dir,$
				    output_dir=output_dir,$
				    CSV=CSV,CLEAN=CLEAN,$
				    LOCAL_FILES=LOCAL_FILES,$
				    PNG=PNG,SILENT=SILENT

;[1]:Initializing 
;[1]:============
launch_time = systime(/sec)
if (n_params() lt 2) then begin
	message,/INFO,'Call is:'
	print,'IDL>sdo_ss_launcher,starttime,endtime, $'
	print,'                    scf=scf,write_fits=write_fits,$'
	print,'                    sample=sample,$'
	print,'                    data_dir=data_dir,$'
	print,'					   output_dir=output_dir,$'
	print,'                    /PNG,/CSV,/CLEAN,$'
	print,'                    /LOCAL_FILES,$'
	print,'                    ,/SILENT'
	return
endif

tstart = strtrim(starttime[0],2)
tend = strtrim(endtime[0],2)
if (~valid_time(tstart)) then message,'Invalid format for the input parameter starttime!'	
if (~valid_time(tend)) then message,'Invalid format for the input parameter endtime!'

;Convert time range in julian days
jstart = strsplit(tstart,'-T:',/EXTRACT)
jstart = julday(jstart[1],jstart[2],jstart[0],jstart[3],jstart[4],jstart[5])
jend = strsplit(tend,'-T:',/EXTRACT)
jend = julday(jend[1],jend[2],jend[0],jend[3],jend[4],jend[5])

cd,current=current_dir
if (~keyword_set(data_dir)) then data_dir = current_dir
if (~keyword_set(output_dir)) then output_dir = current_dir

PNG = keyword_set(PNG)
CSV = keyword_set(CSV)
LOCAL = keyword_set(LOCAL_FILES)
CLEAN = keyword_set(CLEAN)
SILENT = keyword_set(SILENT)
;[1]:============


;[2]:Preparing sdo data  
;[2]:==================

if (~LOCAL) then begin	
	jstart_i = jstart
	jend_i = (jstart + 0.99999999d)<jend
    ;Retrieving sdo/hmi data information day by day 
    ;(to avoid vso tar compressed files downloading for 
    ;large data set) 
	while (jstart_i lt jend) do begin
		caldat,jstart_i,mm,dd,yy,hh,nn,ss
		tstart_i = string(yy,format='(i4.4)') + '-' + string(mm,format='(i2.2)') + '-' + string(dd,format='(i2.2)') $
		  + ' ' +string(hh,format='(i2.2)') + ':' + string(nn,format='(i2.2)') + ':' + string(ss,format='(f6.3)') 
		caldat,jend_i,mm,dd,yy,hh,nn,ss
		tend_i = string(yy,format='(i4.4)') + '-' + string(mm,format='(i2.2)') + '-' + string(dd,format='(i2.2)') $
		  + ' ' +string(hh,format='(i2.2)') + ':' + string(nn,format='(i2.2)') + ':' + string(ss,format='(f6.3)') 
	
		if (~SILENT) then print,'Retrieving SDO/HMI Ic data information from SDO-JSOC for '+tstart_i+' to '+tend_i
		hmi_ic_i = vso_search(tstart_i,tend_i,instr='hmi',physobs='intensity',sample=sample,/URL)
		if (~SILENT) then print,'Retrieving SDO/HMI M data information from SDO-JSOC for '+tstart_i+' to '+tend_i
		hmi_m_i  = vso_search(tstart_i,tend_i,instr='hmi',physobs='LOS_magnetic_field',sample=sample,/URL)
		
		if (n_elements(hmi_ic_i) eq 0) or (n_elements(hmi_m_i) eq 0) then begin
			if (~SILENT) then print,'No SDO/HMI data found between '+tstart_i+' and '+tend_i
			continue
		endif
		
		if not (keyword_set(hmi_ic)) then begin	
			hmi_ic = hmi_ic_i
			hmi_m  = hmi_m_i
		endif else begin
			hmi_ic = [hmi_ic,hmi_ic_i]
			hmi_m  = [hmi_m,hmi_m_i]
		endelse

		jstart_i = (jstart_i + 1.0d)<jend 
		jend_i = (jend_i + 1.0d)<jend
	endwhile

;	ssw_jsoc_time2data,tstart,tend,data,index,ds='hmi.Ic_45s',/URLS_ONLY ;Much longer than vso_search routine

	;Sort hmi continuum data files by increasing time
	s = sort(hmi_ic.time.start)
	hmi_ic = hmi_ic(s)
	hmi_m = hmi_m(s)
	nint = n_elements(hmi_ic)
	nmag = n_elements(hmi_m)
	
endif else begin
	;Looking for sdo/hmi fits files in data_dir 
	fits_int = file_search(data_dir + path_sep() + 'hmi.ic_45s.????.??.??_??_??_??_TAI.continuum.fits',count=nint)
	if (fits_int[0] eq '') then message,'No SDO/HMI continuum fits file in '+data_dir+'!' 
	fits_mag = file_search(data_dir + path_sep() + 'hmi.m_45s.????.??.??_??_??_??_TAI.magnetogram.fits',count=nmag)
	if (fits_mag[0] eq '') then message,'No SDO/HMI magnetogram fits file in '+data_dir+'!'
	
	;Extract corresponding observation times from file names
	time_int = strmid(file_basename(fits_int),11,19)
	time_mag = strmid(file_basename(fits_mag),10,19)
	
	;convert in ISO 8601 format and in julian days
	jd_int = dblarr(nint)
	for i=0L,nint-1L do begin
		time_int_i = strsplit(time_int[i],'._',/EXTRACT)
		jd_int[i] = julday(time_int_i[1],time_int_i[2],time_int_i[0],time_int_i[3],time_int_i[4],time_int_i[5])
		time_int[i] = strjoin(time_int_i[0:2],'-')+'T'+strjoin(time_int_i[3:5],':') 
	endfor
	jd_mag = dblarr(nmag)
	for i=0L,nmag-1L do begin
		time_mag_i = strsplit(time_mag[i],'._',/EXTRACT)
		jd_mag[i] = julday(time_mag_i[1],time_mag_i[2],time_mag_i[0],time_mag_i[3],time_mag_i[4],time_mag_i[5])
		time_mag[i] = strjoin(time_mag_i[0:2],'-')+'T'+strjoin(time_mag_i[3:5],':')
	endfor
	
	;Keep data recorded only between starttime and endtime
	;HMI continuum data
	where_trange = where(jd_int ge jstart and jd_int le jend,nint)
	if (where_trange[0] eq -1) then message,'No SDO/HMI continuum fits file found in the input time range!'
	fits_int = fits_int[where_trange]
	time_int = time_int[where_trange]
	jd_int = jd_int[where_trange]
	
	;HMI magnetogram data
	where_trange = where(jd_mag ge jstart and jd_mag le jend,nmag)
	if (where_trange[0] eq -1) then message,'No SDO/HMI magnetogram fits file found in the input time range!'
	fits_mag = fits_mag[where_trange]
	time_mag = time_mag[where_trange]
	jd_mag = jd_mag[where_trange]
	
	;Sort hmi continuum data files by increasing time
	s = sort(jd_int)
	fits_int = fits_int[s]
	time_int = time_int[s]
	jd_int = jd_int[s]
endelse

if (~SILENT) then begin
	print,strtrim(nint,2)+' SDO/HMI continuum fits file(s) found.'
	print,strtrim(nmag,2)+' SDO/HMI magnetogram fits file(s) found.'
endif
;[2]:=================


;[3]:Launch sdoss processing 
;[3]:=======================
for i=0L,nint-1L do begin	
	if (~LOCAL) then begin
	
		;Get SDO/HMI data from VSO 
		time_start_i = hmi_ic(i).time.start
		where_i = (where(time_start_i eq hmi_m.time.start))[0]
		if (where_i eq -1) then begin
			message,/INFO,'No corresponding SDO/HMI magnetogram for the time '+time_start_i
			continue
		endif

		fnc = "" & fnm = ""
		if (~SILENT) then print,'Downloading SDO/HMI Ic fits files for the time '+time_start_i
		status_ic = vso_get(hmi_ic(i),out_dir=data_dir,filenames=fnc,/RICE)
		if (~SILENT) then print,'Downloading SDO/HMI M fits files for the time '+time_start_i
		status_m = vso_get(hmi_m(i),out_dir=data_dir,filenames=fnm,/RICE)
		
	endif else begin
		;Get SDO/HMI data from VSO
		time_start_i = time_int[i]
		where_i = (where(time_start_i eq time_mag))[0]
		if (where_i eq -1) then begin
			message,/INFO,'No corresponding SDO/HMI magnetogram for the time '+time_start_i
			continue
		endif
		fnc = fits_int[i]
		fnm = fits_mag[where_i]
	endelse

	if (strlen(fnc) eq 0) then begin
		if (~SILENT) then print,'No SDO/HMI Ic fits file found for the time '+time_start_i
		continue
	endif
	if (strlen(fnm) eq 0) then begin
		if (~SILENT) then print,'No SDO/HMI M fits file found for the time '+time_start_i
		continue
	endif

	if (~SILENT) then print,'Launching sunspot detection'
	sdo_ss_processing,fnc,fnm,$
					  write_fits=write_fits,scf=scf,$
					  outroot=output_dir+path_sep(),$
					  status_ic=status_ic,status_m=status_m,$
					  CSV=CSV,PNG=PNG
					  				  
	if (CLEAN) then begin
		;Delete fits files after processing
		if (~SILENT) then print,'Cleaning input SDO/HMI fits files...'
		spawn,'rm -f '+fnc
		spawn,'rm -f '+fnm
		wait,1
	endif
endfor
;[3]:=======================


print,'Program has ended correctly'
print,'Elapsed time: '+strtrim(systime(/SEC)-launch_time,2)+' sec.'
print,''
END
