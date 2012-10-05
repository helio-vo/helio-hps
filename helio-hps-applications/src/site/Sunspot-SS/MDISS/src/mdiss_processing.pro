pro mdiss_processing,  fnc, fnm, inc=inc, inm=inm, $
                     starttime=starttime, endtime=endtime, $ 
                     fname=fname, output_dir=output_dir, $
                     write_png=write_png, feat_min_pix=feat_min_pix, $
                     feat_struct=feat_struct,obs_ic_struct=obs_ic_struct, $
                     obs_m_struct=obs_m_struct, urlc=urlc, urlm=urlm, $
                     frc_struct=frc_struct, oby_struct=oby_struct, $
                     MISSVALSCHECK=MISSVALSCHECK,NO_SHOW=NO_SHOW, $
                     UNPROCESSED=UNPROCESSED, CHECK=CHECK, $
                     VERBOSE=VERBOSE, WRITE_CSV=WRITE_CSV, $
                     WRITE_LOG=WRITE_LOG

;+
; NAME:
;		mdiss_processing
;
; PURPOSE:
;   	finds files, runs sunspot detection, writes output
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		MDISS
;
; CALLING SEQUENCE:
;		IDL>mdiss_processing,fnc, fnm, [inc=inc, [inm=inm]]
;
; INPUTS:
;       fnc          - List of MDI continuum files.
;       fnm          - List of MDI magnetogram files.
;
; OPTIONAL INPUTS:
;       inc          - Index of the input continnum files.
;       inm          - Index of the input magnetogram files.
;       starttime    - Scalar of string type containing the first date and time (ISO 8601 format) of data to process.
;       endtime      - Scalar of string type containing the last date and time (ISO 8601 format) of data to process.
;       fname        - Provide prefix for ASCII output files ('mdiss_'+version+'_' used as default)
;       feat_min_pix - Specify the minimal area of features to save in number of pixels.
;                      Default is 1.
;		output_dir   - Path of the directory where output files will be saved.
;					   Default is current one.	     
;		write_png    - Write output png image files:
;						 write_png = 0 --> no output png file. (Default.)
;						 write_png = 1 --> write only pre-processed continuum images 
;                                          (without detection results).
;						 write_png = 2 --> Like 1, but also write the corresponding magnetograms.
;						 write_png = 3 --> write pre-processed continuum images with 
;                                          detection results.
;						 write_png = 4 --> Like 1, but also write the corresponding magnetograms 
;                                          with detection results.
;       urlc         - Providing list of urls of the input continuum files 
;                      (to be included as a meta-data in the output csv file).
;       urlm         - Providing list of urls of the input magnetogram files 
;                      (to be included as a meta-data in the output csv file).
;       
;
; KEYWORD PARAMETERS:
;       /WRITE_CSV     - set it to write output csv format files.
;      	/NO_SHOW       - set it to suppress window output of the results
;       /UNPROCESSED   - set it to remove limb darkening (for level 1.8 data)
;       /CHECK         - used for debugging, provides graphic output of the results and stops after each files
;		/MISSVALCHECK  - set it do check magnetograms for MISSVALS (just set it)
;		/VERBOSE	   - Talkative mode.
;       /WRITE_LOG     - If set, write program exception messages in a ascii file.
;
; OUTPUTS:
;		None.				
;
; OPTIONAL OUTPUTS:
;	feat_struct    - Structure containing extracted feature parameters.
;       obs_ic_struct  - Structure containing meta-data for Ic observations.
;       obs_m_struct   - Structure containing meta-data for M observations.
;       oby_struct     - Structure containing observatory meta-data. 
;       frc_struct     - Structure containing frc meta-data.		
;		
; COMMON BLOCKS:
;		None.		
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS/COMMENTS:
;		None.
;
; CALL:
;       anytim
;		anytim2jd
;		mreadfits
;		mdiss_observations_entry
;       mdiss_sunspot_entry
;       hfc_write_csv
;       hqi_query
;
; EXAMPLE:
;		mdiss_processing, fnc, fnm, /unproc, /missvalscheck, /no_show, fname='TEST_'
;		
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin (LESIA)
;       (Adapted from mdiss_finding_observations.pro 
;        written by S.Zharkov (MSSL).)
;
;	Version 1.01
;		20-NOV-2011, X.Bonnin:	Added output_dir optional input.
;								Added FRC output file.
;							    Added /SILENT keyword.
;                               Added starttime and endtime optional inputs.
;   Version 1.02
;		10-JAN-2012, X.bonnin:	Added write_png optional input.
;   Version 1.03
;       30-JAN-2012, X.Bonnin:  Added feat_min_pix optional input.
;                               Added command line call.
;
version = '1.03'
;-
launch_time = systime(/SEC)
qte = string(39b)

args = strtrim(command_line_args(),2)
nargs = n_elements(args)
if (strtrim(args[0],2) ne '') then begin
	fnc = args[0]
	fnm = args[1]
	inputpar = ['inc','inm', $
                    'starttime','endtime','output_dir', $
                    'feat_min_pix','write_png','fname',$
                    'urlc','urlm']
        inputkey = ['/write_csv','/write_log', $
                    '/verbose','/unprocessed']
	for i=0l,n_elements(args)-1 do begin
		where_key = (where(strlowcase(args[i]) eq inputkey))[0]
		if (where_key ne -1) then begin
			flag = execute(strmid(inputkey[where_key],1)+'=1')
			continue
		endif
		value = strsplit(args[i],'=',/EXTRACT)
		if (n_elements(value) eq 2) then begin
			where_par = (where(strlowcase(value[0]) eq inputpar))[0]
			if (where_par ne -1) then begin
				flag = execute(value[0]+'='+qte+value[1]+qte)
			endif
		endif
	endfor
	
	;Command line execution options
	NO_SHOW = 1	
	set_plot,'Null'
	
	;If an error occurs, catch it
	CATCH, Error_status 
 
   ;This statement begins the error handler: 
   if (Error_status ne 0) then begin 
      print, 'Error index: ', Error_status 
      print, 'Error message: ', !ERROR_STATE.MSG 
      ; Handle the error by extending A: 
      return
   endif	
endif else begin
    if (n_params() lt 2) then begin
        print, '*****invalid number of parameters, returning'
        return
    endif
endelse

NO_SHOW = keyword_set(NO_SHOW)
MISSVALSCHECK = keyword_set(MISSVALSCHECK)
UNPROCESSED = keyword_set(UNPROCESSED)
CHECK = keyword_set(CHECK)
VERBOSE = keyword_set(VERBOSE)
CSV = keyword_set(WRITE_CSV)
LOG = keyword_set(WRITE_LOG)

if not (keyword_set(feat_min_pix)) then feat_min_pix = 1

if (not keyword_set(write_png)) then wpng = 0 else begin
	wpng = fix(write_png[0])
;	loadct,0,/SILENT
;	tvlct,r,g,b,/GET
    r = bindgen(256)
    g = bindgen(256)
    b = bindgen(256)
endelse


fnc = file_search(fnc,count=nfnc,/FOLD_CASE)
if (strtrim(fnc[0],2) eq '') then begin
	message,/CONT,'input continuum file list is empty!'
	return
endif 

fnm = file_search(fnm,count=nfnm,/FOLD_CASE)
if (strtrim(fnm[0],2) eq '') then begin
	message,/CONT,'Input magnetogram file list is empty!'
	return
endif

if not (keyword_set(urlc)) then urlc = strarr(nfnc) + 'NULL'
if not (keyword_set(urlm)) then urlm = strarr(nfnm) + 'NULL'

if (VERBOSE) then print,strtrim(nfnc,2)+' MDI Ic fits file(s) and '+strtrim(nfnm,2)+' MDI M fits file(s) to process.'

if not (keyword_set(output_dir)) then cd,current=output_dir

data_dir = file_dirname(fnc[0])

MISSVAL_THRESHOLD=300000l

if not (keyword_set(inm)) then begin
    mreadfits,fnm,inm, /noda, /silent 
    jdm=anytim2jd(inm.t_obs) & jdm=jdm.int+jdm.frac	
endif

if (keyword_set(starttime)) then begin
    jstart = anytim2jd(starttime) & jstart = jstart.int + jstart.frac
endif
if (keyword_set(endtime)) then begin
    jend = anytim2jd(endtime) & jend = jend.int + jend.frac
endif

;Get current date and time
run_date = (strsplit(anytim(!stime, /ccsds),'.',/EXTRACT))[0]

;Define output filenames
str_version = strjoin(strsplit(version,'.',/EXTRACT))
if not keyword_set(fname) then fname='mdiss_'+str_version

;Load HFC structures
if (VERBOSE) then print,'Loading HFC structures...'
mdiss_hfc_setup, oby_str, frc_stc, obs_stc, pp_info_stc, pp_out_stc, feat_stc
frc_stc.version = version
pp_info_stc.version = version
feat_stc.run_date = run_date
pp_out_stc.run_date = run_date
if (UNPROCESSED) then begin
    pp_out_stc.background=[1,0]
    pp_out_stc.standard=[1,0]
    pp_out_stc.limbdark=[1,0]
endif
if (VERBOSE) then print,'Loading HFC structures...done'

; *** Write frc output file for the current session ****
if (CSV) then begin
    if (VERBOSE) then print,'Writing FRC_INFO output file for the current session...'		
    frc_file=fname+'_soho_frc_info.csv'
    frc_path=output_dir + path_sep() + frc_file 
    hfc_write_csv,frc_stc,frc_path,error=error

; *** Write observatory output file for the current session ****	
    if (VERBOSE) then print,'Writing OBSERVATORY output file for the current session...'	
    oby_file=fname+'_soho_observatory.csv'
    oby_path=output_dir + path_sep() + oby_file 
    hfc_write_csv,oby_str,oby_path,error=error

    ; *** Write pp info output file for the current session ****	
    if (VERBOSE) then print,'Writing PP_INFO output file for the current session...'	
    pp_info_file=fname+'_soho_pp_info.csv'
    pp_info_path=output_dir + path_sep() + pp_info_file 
    hfc_write_csv,pp_info_stc,pp_info_path,error=error
endif
oby_struct = oby_str
frc_struct = frc_stc 

;*** now run the detection and extraction
;for i=0, nc-1 do begin

id_spot=0l


obs_ic_struct = replicate(obs_stc[0],nfnc)
obs_m_struct = replicate(obs_stc[1],nfnc)
feat_struct = feat_stc
processed = bytarr(nfnc)
for i=0l, nfnc-1 do begin

  iter = strtrim(nfnc - i,2)
  
  ; Check that continuum file exists
  if not (file_test(fnc[i])) then begin
    if (VERBOSE) then print,fnc_i+' does not exist!'
    continue
  endif
  
  ;Load MDI Ic fits file header
  if not (keyword_set(inc)) then $
     mreadfits, fnc[i], inc_i, /noda $
  else inc_i = inc[i]
  
; **** for given intensity image, find the nearest magnetogram
  jdc_i=anytim2jd(inc_i.date_obs) & jdc_i=jdc_i.int+jdc_i.frac	

  jd=abs(jdm-jdc_i)
  mn=min(jd, ind)

  if (keyword_set(starttime)) then begin
    if (jdc_i lt jstart) then continue
  endif
  if (keyword_set(endtime)) then begin
    if (jdc_i gt jend) then continue
  endif

  print, iter+' --> Processing files '+file_basename(fnc(i))+' and  '+file_basename(fnm(ind))
  print, iter+' --> MDI Ic: '+inc_i.date_obs+' - MDI M: '+inm(ind).t_obs
    
  date_obs_i = strjoin((strtrim(strsplit(inc_i.date_obs,'-:Z.',/EXTRACT),2))[0:4])	   

	if mn ge 1 then begin
  		print, '**** no adjacent magnetogram image found, stopping for time being...'
		continue        
  	end

 ;*** read the intensity image into object
    wl=obj_new('wlfitsfdobs', filename=fnc(i), header=hd, UNPROCESSED=UNPROCESSED)
    
 ;*** read-in the magnetogram    
    mg=obj_new('mgfitsfdobs', loc=fnm(ind))

 if (wpng gt 0) then begin
	print,'Writing continuum png image file...'
	imc = (bytscl((wl->getimage())>0,top=255,/NAN))
	png_file = file_basename(fnc(i),'.fits')+'.png'
	png_pathc = output_dir + path_sep() + png_file 
	write_png,png_pathc,imc,r,g,b
 endif
 if (wpng gt 1) then begin
	print,'Writing magnetogram png image file...'
	imm = bytscl(mg->getimage(),top=255,/NAN)
	png_file = file_basename(fnm(ind),'.fits')+'.png'
	png_pathm = output_dir + path_sep() + png_file 
	write_png,png_pathm,imm,r,g,b
 endif

; *** write observations output to file
    obs_stc_i = obs_stc
    ;MDI Ic entries
    obs_stc_i(0).filename = file_basename(fnc(i))
    obs_stc_i(0).loc_filename = fnc(i)
    obs_stc_i(0) = mdiss_observations_entry(inc_i, obs_stc_i(0),1)
    obs_stc_i(0).file_format = 'fits'
    obs_stc_i(0).url = urlc[i]
    obs_stc_i(0).qclk_fname = file_basename(png_pathc)
    ;MDI M entries
    obs_stc_i(1).filename = file_basename(fnm(ind))  
    obs_stc_i(1).loc_filename = fnm(ind)
    obs_stc_i(1) = mdiss_observations_entry(inm(ind), obs_stc_i(1),2)
    obs_stc_i(1).file_format = 'fits'
    obs_stc_i(1).url = urlm[ind]
    obs_stc_i(1).qclk_fname = file_basename(png_pathm)
 
    if (CSV) then begin
        print,'Writing observations output file...'
        obs_file=fname+'_'+date_obs_i+'_soho_init.csv'
        obs_path = output_dir + path_sep() + obs_file
	    hfc_write_csv,obs_stc_i,obs_path,error=error
    endif
    obs_ic_struct(i) = obs_stc_i(0)
    obs_m_struct(i) = obs_stc_i(1)

 ;*** check the number of missing value pixels in the image, reject if large   
  if fxpar(hd, 'missvals') gt MISSVAL_THRESHOLD then begin
	print, '**** MISSING VALUES overload...'
	continue
  endif  
  
  qs=wl->getQuietSunInt()
  if (qs lt 0.0d) then begin
	print, '**** MISSING VALUES overload...'
	continue
  endif


; *** run sunspot detection and generated sunspot object
    sp=obj_new('sunspotmgobs', wl, mg, /ONE, NO_SHOW=NO_SHOW, /SETMG, MISSVALSCHECK=MISSVALSCHECK)
	
; *** write observations output to file
    pp_out_stc_i = pp_out_stc

    ;Here, except intensity corrections, the prep image has the same charateristics than the original one
    ;Just copy meta-data from observations to pp_out structures
    pp_out_stc_i.pr_locfname = obs_stc_i.loc_filename ;Original file since prep file is not processed  
    pp_out_stc_i.org_fname = obs_stc_i.filename
    pp_out_stc_i.loc_file = obs_stc_i.filename 
    pp_out_stc_i.naxis1 = obs_stc_i.naxis1
    pp_out_stc_i.naxis2 = obs_stc_i.naxis2
    pp_out_stc_i.cdelt1 = obs_stc_i.cdelt1
    pp_out_stc_i.cdelt2 = obs_stc_i.cdelt2
    pp_out_stc_i.center_x = obs_stc_i.center_x
    pp_out_stc_i.center_y = obs_stc_i.center_y
    pp_out_stc_i.r_sun = obs_stc_i.r_sun
    pp_out_stc_i.bitpix = obs_stc_i.bitpix
    pp_out_stc_i.run_date=run_date
    nss=sp->n_spots()
    
    if (nss ne 0) then begin
      data=sp->dataarray()   
      pp_out_stc_i.qsun_int = data(0, 13) ;get quiet sun intensity
    endif

	if (CSV) then begin
    	print,'Writing pp output file...'
    	pp_out_file=fname+'_'+date_obs_i+'_soho_norm.csv'
    	pp_out_path = output_dir + path_sep() + pp_out_file
		hfc_write_csv,pp_out_stc_i,pp_out_path,error=error
	endif

; *** write feature output    
    if (nss gt 0) then begin
       
   
	    feat_stc_i = replicate(feat_stc,nss)
	    feat_file=fname+'_'+date_obs_i+'_soho_feat.csv'
	    feat_path=output_dir + path_sep() + feat_file
	    feat_stc_i=mdiss_sunspot_entry(sp, feat_stc_i)
	    if (size(feat_stc_i,/TNAME) ne 'STRUCT') then goto,skip_feat
	
	    where_ok = where(feat_stc_i.feat_area_pix ge feat_min_pix)
	    if (where_ok[0] eq -1) then goto,skip_feat 
	    feat_stc_j = feat_stc_i(where_ok)
	
	    feat_stc_j.run_date = run_date
	    feat_stc_j.feat_filename = feat_path  
	      
	    if (CSV) then begin
	        print,'Writing feature output file...'
	        hfc_write_csv,feat_stc_j,feat_path,error=error
	        print,'Writing feature output file...done'
	    endif
	    feat_struct = [feat_struct,feat_stc_j]
	
		  if (wpng gt 2) then begin
		  	print,'Writing continuum png image file with detection results...'		
			for k=0l,nss-1l do begin
				sk=sp->getspot(k)
				locs = sk->getlocs()
				ulocs = sk->getumbra()
				imc[locs] = max(imc,/NAN)
				if (ulocs[0] ne -1) then imc[ulocs] = min(imc,/NAN)
			endfor	
			png_file = file_basename(obs_stc_i(0).filename,'.fits')+'_mdiss_results.png'
			png_path = output_dir + path_sep() + png_file 
			write_png,png_path,imc,r,g,b
		  endif 
		  if (wpng gt 3) then begin
			print,'Writing magnetogram png image file with detection results...'		
			for k=0l,nss-1l do begin
				sk=sp->getspot(k)
				locs = sk->getlocs()
				ulocs = sk->getumbra()
				imm[locs] = max(imm,/NAN)
				if (ulocs[0] ne -1) then imm[ulocs] = min(imm,/NAN)
			endfor	
			png_file = file_basename(obs_stc_i(1).filename,'.fits')+'_mdiss_results.png'
			png_path = output_dir + path_sep() + png_file 
			write_png,png_path,imm,r,g,b
		  endif 
    endif else begin
skip_feat:        
        print,'No sunspot detected!'
    endelse
    if (CHECK) then stop
    
    processed[i] = 1b
 ; *** cleanup    
  obj_destroy, sp
  obj_destroy, wl
  obj_destroy, mg
  heap_gc;, /verb
endfor
if (n_elements(feat_struct) gt 1) then feat_struct = feat_struct(1:*)

if (LOG) then begin
    fnex='mdiss_processing.log'
    openw, lun_ex, output_dir + path_sep() + fnex, /get_lun,/APPEND
	for i=0l,nfnc-1l do begin
		if (processed[i]) then printf,lun_ex,fnc[i]+' has been processed' $
		else printf,lun_ex,fnc[i]+' has not been processed' 
	endfor
    close,lun_ex
    free_lun,lun_ex
endif

print,'Program has ended correctly'
print,'Elapsed time: '+strtrim(systime(/SEC) - launch_time,2)+' sec.'
end


