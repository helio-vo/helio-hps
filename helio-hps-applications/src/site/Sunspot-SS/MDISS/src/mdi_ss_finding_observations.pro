pro mdi_ss_finding_observations, inc, inm, fnc, fnm, no_show=no_show, $
                                 starttime=starttime, endtime=endtime, $ 
			                     unprocessed=unprocessed, fname=fname, $
				                 check=check, missvalscheck=missvalscheck, $
			                     output_dir=output_dir,SILENT=SILENT

;+
; NAME:
;		mdi_ss_finding_observations
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
;		IDL>mdi_ss_finding_observations,inc, inm, fnc, fnm
;
; INPUTS:
;       fnc           array of MDI continuum filenames
;       fnm           array of MDI magnetogram filenames
;       inc           array of continuum index structures (mreadfits, fnc, inc, /nodata)
;       inm           array of magnetogram index structures (mreadfits, fnc, inc, /nodata)
;
; OPTIONAL INPUTS:
;       starttime - Scalar of string type containing the first date and time (ISO 8601 format) of data to process.
;       endtime   - Scalar of string type containing the last date and time (ISO 8601 format) of data to process.
;	    
;
; KEYWORD PARAMETERS:
;       no_show       set it to suppress window output of the results
;       unprocessed   set it to remove limb darkening (for level 1.8 data)
;       fname         provide prefix for ASCII output files ('mdi_ss_'+version+'_' used as default)
;       check         used for debugging, provides graphic output of the results and stops after each files
;       missvalscheck set it do check magnetograms for MISSVALS (just set it)
;		output_dir    Full path of the directory where output files will be saved.
;						Default is current one.
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
;		None.
;
; CALL:
;       anytim
;		anytim2jd
;		mreadfits
;		mdi_ss_observations_entry
;       mdi_ss_sunspot_entry
;       hfc_write_csv
;
; EXAMPLE:
;		mdi_ss_finding_observations, fnc, fnm, inc, inm, /unproc, /missvalscheck, /no_show, fname='TEST_'
;		
; MODIFICATION HISTORY:
;		Written by:		S.Zharkov (MSSL).
;
;	Version 1.01
;		20-NOV-2011, X.Bonnin:	Added output_dir optional input.
;								Added FRC output file.
;							    Added /SILENT keyword.
;                               Added starttime and endtime optional inputs.
;
;-

launch_time = systime(/SEC)
if (n_params() lt 2) then begin
  print, '*****invalid number of parameters, returning'
  return
end

UNPROCESSED = keyword_set(UNPROCESSED)
SILENT = keyword_set(SILENT)

if (strtrim(fnc[0],2) eq '') then begin
	message,/CONT,'fnc input parameter is empty!'
	return
endif 

if (strtrim(fnm[0],2) eq '') then begin
	message,/CONT,'fnm input parameter is empty!'
	return
endif
nfnc = n_elements(fnc)
nfnm = n_elements(fnm)
if (~SILENT) then print,strtrim(nfnc,2)+' MDI Ic fits file(s) and '+strtrim(nfnm,2)+' MDI M fits file(s) to process.'

if not (keyword_set(output_dir)) then cd,current=output_dir

if not arg_present(inm) then begin
	if (~SILENT) then print,'Loading MDI M files headers...'
	mreadfits,fnm,inm, /noda
	if (~SILENT) then print,'Loading MDI M files headers OK'
endif
MISSVAL_THRESHOLD=300000l

jdm=anytim2jd(inm.t_obs) & jdm=jdm.int+jdm.frac
inm.t_obs = jd2str(jdm,format=2)+'Z'	

if (keyword_set(starttime)) then begin
    jstart = anytim2jd(starttime) & jstart = jstart.int + jstart.frac
endif
if (keyword_set(endtime)) then begin
    jend = anytim2jd(endtime) & jend = jend.int + jend.frac
endif

;Get current date and time
run_date = (strsplit(anytim(!stime, /ccsds),'.',/EXTRACT))[0]

;Define output filenames
;!!!! MUST BE CONSISTENT WITH THE VERSION NUMBER GIVEN IN THE MODIFICATION HISTORY!!!!
version = '1.01'
str_version = strjoin(strsplit(version,'.',/EXTRACT))
if not keyword_set(fname) then fname='mdiss_'+str_version

;Load HFC structures
if (~SILENT) then print,'Loading HFC structures...'
mdi_ss_hfc_struct, oby_str, frc_str, obs_str, pp_info_str, pp_out_str, feat_str
frc_str.version = version
pp_info_str.version = version
feat_str.run_date = run_date
pp_out_str.run_date = run_date
if (UNPROCESSED) then begin
    pp_out_str.background=[1,0]
    pp_out_str.standard=[1,0]
    pp_out_str.limbdark=[1,0]
endif
if (~SILENT) then print,'Loading HFC structures:OK'

; *** Write frc output file for the current session ****
if (~SILENT) then print,'Writing FRC_INFO output file for the current session...'		
frc_file=fname+'_frc_info.csv'
frc_path=output_dir + path_sep() + frc_file 
hfc_write_csv,frc_str,frc_path,error=error
if (~SILENT) then print,'Writing FRC_INFO output file for the current session:OK'

; *** Write observatory output file for the current session ****	
if (~SILENT) then print,'Writing OBSERVATORY output file for the current session...'	
oby_file=fname+'_observatory.csv'
oby_path=output_dir + path_sep() + oby_file 
hfc_write_csv,oby_str,oby_path,error=error
if (~SILENT) then print,'Writing OBSERVATORY output file for the current session:OK'

; *** Write pp info output file for the current session ****	
if (~SILENT) then print,'Writing PP_INFO output file for the current session...'	
pp_info_file=fname+'_pp_info.csv'
pp_info_path=output_dir + path_sep() + pp_info_file 
hfc_write_csv,pp_info_str,pp_info_path,error=error
if (~SILENT) then print,'Writing PP_INFO output file for the current session:OK'

fnex=fname+'_exceptions.txt'
openw, lun_ex, output_dir + path_sep() + fnex, /get_lun

;*** now run the detection and extraction
;for i=0, nc-1 do begin

id_spot=0l

for i=0l, nfnc-1 do begin

  iter = strtrim(nfnc - i,2)
  
  if not arg_present(inc) then begin
  	;Load MDI Ic fits file header
  	mreadfits, fnc[i], inc_i, /noda
  endif else begin
  	inc_i = inc[i]
  endelse	
  
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
        printf, lun_ex, fnc(i), ';           no magnetogram'
        continue        
  end

; *** write observations output to file
    print,'Writing observations output file...'
    obs_str_i = obs_str
    ;MDI Ic entries
    obs_str_i(0).filename = file_basename(fnc(i))
    obs_str_i(0).loc_filename = fnc(i)
    obs_str_i(0) = mdi_ss_observations_entry(inc_i, obs_str_i(0),1)
    ;MDI M entries
    obs_str_i(1).filename = file_basename(fnm(ind))  
    obs_str_i(1).loc_filename = fnm(ind)
    obs_str_i(1) = mdi_ss_observations_entry(inm(ind), obs_str_i(1),2)
  
    obs_file=fname+'_'+date_obs_i+'_init.csv'
    obs_path = output_dir + path_sep() + obs_file
	hfc_write_csv,obs_str_i,obs_path,error=error
    print,'Writing observations output file: OK'

 ;*** read the intensity image into object
 wl=obj_new('wlfitsfdobs', filename=fnc(i), header=hd, unprocessed=unprocessed)
    
 ;*** check the number of missing value pixels in the image, reject if large   
  if fxpar(hd, 'missvals') gt MISSVAL_THRESHOLD then begin
	print, '**** MISSING VALUES overload...'
        printf, lun_ex, fnc(i), ';           too many missing values pixels'
	continue
  endif  
  
  qs=wl->getQuietSunInt()
  if (qs lt 0.0d) then begin
	print, '**** MISSING VALUES overload...'
        printf, lun_ex, fnc(i), ';           too many missing values pixels'
	continue
  endif

; *** read-in the magnetogram    
    mg=obj_new('mgfitsfdobs', loc=fnm(ind))

; *** run sunspot detection and generated sunspot object
    sp=obj_new('sunspotmgobs', wl, mg, /one, no_show=no_show, /setmg, missvalscheck=missvalscheck)
	
; *** write observations output to file
    print,'Writing pp output file...'
    pp_out_str_i = pp_out_str

    ;Here, except intensity corrections, the prep image has the same charateristics than the original one
    ;Just copy meta-data from observations to pp_out structures
    pp_out_str_i.pr_locfname = obs_str_i.loc_filename ;Original file since prep file is not processed  
    pp_out_str_i.org_fname = obs_str_i.filename
    pp_out_str_i.loc_file = obs_str_i.filename 
    pp_out_str_i.naxis1 = obs_str_i.naxis1
    pp_out_str_i.naxis2 = obs_str_i.naxis2
    pp_out_str_i.cdelt1 = obs_str_i.cdelt1
    pp_out_str_i.cdelt2 = obs_str_i.cdelt2
    pp_out_str_i.center_x = obs_str_i.center_x
    pp_out_str_i.center_y = obs_str_i.center_y
    pp_out_str_i.r_sun = obs_str_i.r_sun
    pp_out_str_i.bitpix = obs_str_i.bitpix
    pp_out_str_i.run_date=run_date
    nss=sp->n_spots()
    if (nss ne 0) then begin
      data=sp->dataarray()   
      pp_out_str_i.qsun_int = data(0, 13) ;get quiet sun intensity
    endif

    pp_out_file=fname+'_'+date_obs_i+'_norm.csv'
    pp_out_path = output_dir + path_sep() + pp_out_file
	hfc_write_csv,pp_out_str_i,pp_out_path,error=error
    print,'Writing pp output file: OK'


; *** write feature output    
    if nss ne 0 then begin
      print,'Writing feature output file...'
      feat_str_i = replicate(feat_str,nss)
      feat_file=fname+'_'+date_obs_i+'_feat.csv'
      feat_path=output_dir + path_sep() + feat_file
      feat_str_i=mdi_ss_sunspot_entry(sp, feat_str_i)
      feat_str_i.run_date = run_date
      feat_str_i.feat_filename = feat_path  
      hfc_write_csv,feat_str_i,feat_path,error=error
      print,'Writing feature output file:OK'
    endif else print,'No sunspot detected!'
    if keyword_set(check) then stop
    
 ; *** cleanup    
  obj_destroy, sp
  obj_destroy, wl
  obj_destroy, mg
  heap_gc;, /verb
endfor

print,'Program has ended correctly'
print,'Elapsed time: '+strtrim((systime(/SEC) - launch_time)/60.,2)+' min.'
end


