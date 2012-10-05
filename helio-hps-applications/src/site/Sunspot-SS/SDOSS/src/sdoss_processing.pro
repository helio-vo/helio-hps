pro sdoss_processing, fnc, fnm, $ 
                      scf=scf, feat_min_pix=feat_min_pix, $
                      fnc_url=fnc_url, fnm_url=fnm_url, $
                      unprocessed_files=unprocessed_files, $
                      output_dir=output_dir, $
                      write_fits=write_fits, $
                      QUICKLOOK=QUICKLOOK,$
                      SNAPSHOT=SNAPSHOT, $
                      CSV=CSV,$
                      XML=XML, $
                      LOG=LOG, $
                      VERBOSE=VERBOSE,DEBUG=DEBUG

;+
; NAME:
;	sdoss_processing
;
; PURPOSE:
; 	Running sunspot detection algorithm 
;	on SDO HMI Ic and M data.
;
; CATEGORY:
;	Image processing
;
; GROUP:
;	SDOSS
;
; CALLING SEQUENCE:
;	sdoss_processing, fnc, fnm
;
; INPUTS:
;       fnc	- list of HMI/Ic file(s).
;       fnm     - list of near close HMI/M file(s). 	
;	
; OPTIONAL INPUTS:
;      scf 	     - Scaling factor (either 1 or 4):
;             	                1 -> normal resolution is used (default)
;               	        4 -> the images are rescaled 4 times down
;                    	             (SOHO/MDI resolution).
;      fnc_url       - List of urls of fnc fits files (to be written
;                      in the output observations file(s)).
;      fnm_url       - List of urls of fnm fits files (to be written
;                      in the output observations file(s)).
;      write_fits    - Write auxillary fits files:
;                       	1 -> Intensity with limb darkening removed
;                       	2 -> as 1 plus corresponding magnetogram
;                       	3 -> as 2 plus detection results	
;      feat_min_pix  - Specify the minimal area of features to save in number of pixels.
;                      Default is 1.
;      output_dir    - Folder for writing output (fits and xml/csv) files.
;
; KEYWORD PARAMETERS:
;       /DEBUG         - Debug mode.
;	/VERBOSE       - Talkative mode.
;       /QUICKLOOK     - Write quicklook images in png format.
;       /SNAPSHOT      - Write snapshot images in png format. OBSOLETE
;       /XML           - Write detection results into csv format files.
;	/CSV           - Write detection results into csv format files.  	
;       /LOG           - Write log file containing history of the
;                        processing.
;
; OUTPUTS:
;	None.	
;
; OPTIONAL OUTPUTS:
;       unprocessed_files - List of unprocessed files.
;
; COMMON BLOCKS:		
;	None.
;	
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS/COMMENTS:
;	The gen, sdo, ontology, and vso SolarSoftWare (SSW) packages must be loaded.
;	SDOSS auxiliary routines must be compiled.
;		
; CALL:
;	read_sdo
;	float_qsmedian
;	wl_detspgs_sdo
;	sdo_labelcountregion
;	tim2carr
;       jd2str
;       anytim2jd
;       anytim
;	arcmin2hel
;	sdo_pix2hel
;	sdoss_getbndrct
;	sdoss_getrasterscan
;	sdoss_getchaincode
;	tvframe
;	sdoss_xml
;	sdoss_hfc_setup
;	mwritefits
;       hfc_write_csv
;	feat_cc_extract
;	ssw_jsoc_time2data
;
; EXAMPLE:
;	None.		
;
; MODIFICATION HISTORY:
;	Version 1.00
;		Written by S.Zharkov (MSSL).
;
;	Version 1.01
;		22-JUL-2011, X.Bonnin:	Added /WRITE_CSV keyword, and
;								updated the header.
;										
;		28-JUL-2011, X.Bonnin:	Added write_png optional input.
;
;       Version 1.02
;               27-DEC-2011, X.Bonnin:  Introduced hfc table parameters using structures
;                                       loaded by the new routine sdoss_hfc_setup.
;                                       They permit to pass code results as output idl arguments 
;                                       without having to produce output files.
;	Version 1.03
;		10-JAN-2012, X.Bonnin:	Correction of minor bugs.
;					Updated write_png optional input.
;       Version 1.04
;               30-JAN-2012, X.Bonnin:  Added feat_min_pix optional keyword. 
;	Version 1.05
;		12-APR-2012, X.Bonnin:	Added unprocessed_files optional outputs.
;					Renamed /CHECKWAIT to /DEBUG.
;					Added /VERBOSE keyword.
;					Added _sdo_ substring to the csv output file names.
;					Fixed a bug that provides wrong chain codes.
;                                       Added command line call
;                                       functionality.
;
;-
version = '1.05'

quote = string(39b)
deg2mm = 6.96e8/!radeg

;[1];Initializing program
;[1]:====================

args = strlowcase(strtrim(command_line_args(),2))
nargs = n_elements(args)
if (nargs gt 1) then begin
   fnc = file_search(args[0],/FOLD_CASE)
   fnm = file_search(args[1],/FOLD_CASE)
   inputpar = ['scf','write_fits', $
               'fnc_url','fnm_url', $
               'data_dir','output_dir', $
               'feat_min_pix']
   inputkey = ['/csv','/log','/quicklook', $
               '/debug','/verbose']
   for i=0l,n_elements(args)-1 do begin
      where_key = (where(args[i] eq inputkey))[0]
      if (where_key ne -1) then begin
         flag = execute(strmid(inputkey[where_key],1)+'=1')
         continue
      endif
      value = strsplit(args[i],'=',/EXTRACT)
      if (n_elements(value) eq 2) then begin
         where_par = (where(value[0] eq inputpar))[0]
         if (where_par ne -1) then begin
            flag = execute(value[0]+'='+quote+value[1]+quote)
         endif
      endif
   endfor
   set_plot,'NULL'
endif else begin
   if (n_params() lt 2) then begin
      message,/INFO,'Call is:'
      print,'sdoss_processing, fnc, fnm, $'
      print,'                  scf=scf, $'
      print,'                  fnc_url=fnc_url, fnm_url=fnm_url, $'
      print,'                  feat_min_pix=feat_min_pix, $'
      print,'                  output_dir=output_dir, write_fits=write_fits,$'
      print,'                  unprocessed_files=unprocessed_files, $'
      print,'                  /QUICKLOOK,/CSV,/XML,/SNAPSHOT, $'
      print,'                  /LOG, /DEBUG, /VERBOSE'
      return
   endif
endelse
history=''

;Run date
syst0 = systime(/SEC)
run_date = (strsplit(anytim(!stime, /ccsds),'.',/EXTRACT))[0]
compact_date = strjoin(strsplit(run_date,'-T:'))

sec2day = 1.0d/(3600.0d*24.0d)
!QUIET = 1

DEBUG = keyword_set(DEBUG)
VERBOSE = keyword_set(VERBOSE)
if (DEBUG) then begin
   !QUIET = 0
   VERBOSE = 1
endif
QLK = keyword_set(QUICKLOOK)
SNP = keyword_set(SNAPSHOT)
LOG = keyword_set(LOG)
CSV = keyword_set(CSV)
XML = keyword_set(XML)

outfnroot = 'sdoss_'+strjoin(strsplit(version,'.',/EXTRACT))

if (not keyword_set(output_dir)) then cd,current=outroot else outroot = strtrim(output_dir[0],2) 
outroot = outroot + path_sep()

;Initialize history, processed, and unprocessed outputs 
if (VERBOSE) then print,'sdoss has started on '+run_date
unprocessed = fnc

;Check that $SSW_ONTOLOGY env. variable is set
ssw_ont = getenv('SSW_ONTOLOGY')
if (ssw_ont eq '') then begin
   message,/CONT,'$SSW_ONTOLOGY environment variable must be defined!'
   return
endif

; rgb vectors to write png files
r = bindgen(256)
g = bindgen(256)
b = bindgen(256)

if (not keyword_set(feat_min_pix)) then feat_min_pix = 1

nfnc = n_elements(fnc)
nfnm = n_elements(fnm)
if (nfnc ne nfnm) then begin
    message,/CONT,'Numbers of input HMI Ic and M files must be the same!'
    return
endif

if (not keyword_set(scf)) then scf=1
;[1]:====================


;[2]:Load input structures
;[2]:=====================
;Load Observatory, FRC, Observations, Pre-Process, feature code parameters 
;for current running using dedicated HFC structures
if (VERBOSE) then print,'Initializing outputs...'
sdoss_hfc_setup, oby_str, frc_str, obs_str, pp_info_str, pp_out_str, feat_str
frc_str.version = version
pp_info_str.version = version
feat_str.run_date = run_date
pp_out_str.run_date = run_date
if (VERBOSE) then print,'Initializing outputs...done'

if (CSV) then begin
    frc_file = outfnroot+'_sdo_frc_info.csv'
    frc_path = outroot + frc_file
    if (VERBOSE) then print,'Writing '+frc_path
    hfc_write_csv,frc_str,frc_path
    pp_info_file = outfnroot+'_sdo_pp_info.csv'
    pp_info_path = outroot + pp_info_file
    if (VERBOSE) then print,'Writing '+pp_info_path
    hfc_write_csv,pp_info_str,pp_info_path
    oby_file = outfnroot+'_sdo_observatory.csv'
    oby_path = outroot + oby_file
    if (VERBOSE) then print,'Writing '+oby_path
    hfc_write_csv,oby_str,oby_path    
endif
;[2]:=====================


;[3]:Loops on each fits files
;[3]:========================
for i=0l, nfnc-1l do begin
   iter = strtrim(nfnc - i,2)
   obs_str_i = obs_str
   pp_out_str_i = pp_out_str
   feat_str_i = feat_str	
	
   fnc_i = fnc[i] & fnm_i = fnm[i]
   fnc_url_i = 'NULL' & fnm_url_i = 'NULL'
   if (keyword_set(fnc_url)) then fnc_url_i = fnc_url[i] 
   if (keyword_set(fnm_url)) then fnm_url_i = fnm_url[i] 
	
   ;Reading SDO data files
   tt=systime(/sec)
 
   msg = 'Reading '+fnc_i+'...'
   if (VERBOSE) then print,msg
   history = [history,msg]
   if (not file_test(fnc_i,/REG)) then begin
      msg = fnc_i+' fits file does not exist!'
      message,/CONT,msg
      history=[history,msg]
      continue
   endif
   read_sdo, fnc_i, inc, dac, /UNCOMP_DEL, header=hd
   if (size(inc,/TNAME) ne 'STRUCT') then begin
      msg = 'Can not read '+fnc_i
      message,/CONT,msg
      history =[history,msg]
      continue
   endif
   if (VERBOSE) then print,'Reading '+fnc_i+'...done'

   msg = 'Reading '+fnm_i+'...'
   if (VERBOSE) then print,msg
   history=[history,msg]
   if (not file_test(fnm_i,/REG)) then begin
      msg = fnm_i+' fits file does not exist!'
      message,/CONT,msg
      history=[history,msg]
      continue
   endif
   read_sdo, fnm_i, inm, dam, /UNCOMP_DEL, header=hd
   if (size(inm,/TNAME) ne 'STRUCT') then begin
      msg = 'Can not read '+fnm_i
      message,/CONT,msg
      history=[history,msg]
      continue
   endif
   if (VERBOSE) then print,'Reading '+fnc_i+'...done'
        
   ; Checking dates and times of loaded files
   jdc = anytim2jd(inc.date_obs) & jdm = anytim2jd(inm.date_obs)
   if (abs(jdc.int+jdc.frac - (jdm.int+jdm.frac)) gt 6.0d/24.0d) then begin
      msg = 'WARNING: dates and times of '+fnc_i+' and '+fnm_i+' files are too different!'
      message,/CONT,msg
      history=[history,msg]
      continue
   endif
        
   ; Load corresponding fields in the observations structure
   inc_date_obs = (strsplit(inc.date_obs,'.',/EXTRACT))[0]
   inc_date_end = jd2str(jdc.int+jdc.frac+inc.cadence*sec2day,format=1)
   inm_date_obs = (strsplit(inm.date_obs,'.',/EXTRACT))[0]
   inm_date_end = jd2str(jdm.int+jdm.frac+inm.cadence*sec2day,format=1)
   obs_str_i.date_obs = [inc_date_obs,inm_date_obs]
   obs_str_i.date_end = [inc_date_end,inm_date_end]
   obs_str_i.jdint = [jdc.int,jdm.int]
   obs_str_i.jdfrac = [jdc.frac,jdm.frac]
   obs_str_i.exp_time = [inc.cadence,inm.cadence]
   obs_str_i.c_rotation = [inc.car_rot,inm.car_rot]
   obs_str_i.bscale = [inc.bscale,inm.bscale]  
   obs_str_i.bzero = [inc.bzero,inm.bzero] 
   obs_str_i.bitpix = [inc.bitpix,inm.bitpix]
   obs_str_i.naxis1 = [inc.naxis1,inm.naxis1]
   obs_str_i.naxis2 = [inc.naxis2,inm.naxis2]
   obs_str_i.center_x = [inc.crpix1,inm.crpix1]
   obs_str_i.center_y = [inc.crpix2,inm.crpix2]
   obs_str_i.cdelt1 = [inc.cdelt1,inm.cdelt1]
   obs_str_i.cdelt2 = [inc.cdelt2,inm.cdelt2]
   obs_str_i.r_sun = [inc.rsun_obs/inc.cdelt1,inm.rsun_obs/inm.cdelt1]
   
   obs_str_i.quality = [inc.quality,inm.quality]
   obs_str_i.filename = [file_basename(fnc_i),file_basename(fnm_i)]
   obs_str_i.comment = [strjoin(inc.comment),strjoin(inm.comment)]
   ; replace the possible semi-commas encountered in the comment field
   ; by commas.
   obs_str_i(0).comment = strjoin(strsplit(obs_str(0).comment,';',/EXTRACT),',')
   obs_str_i(1).comment = strjoin(strsplit(obs_str(1).comment,';',/EXTRACT),',')
   obs_str_i.loc_filename = [fnc_i,fnm_i] 
   obs_str_i.url = [fnc_url_i,fnm_url_i]
	
   ;'YYYY-MM-DDTHH:NN:SS.SSSZ' --> ;'YYYYMMDDTHHNNSS.SSSZ'
   t_rec = strjoin((strsplit(inc.t_rec,'_',/EXTRACT))[0:1],'T') ;use t_rec for output filename
   cdate = strjoin(strsplit(t_rec,'-:.',/EXTRACT))
 
   ; ***** do the rotation correction
   dac=rot(dac, -inc.crota2, 1.d/scf, inc.crpix1-1, inc.crpix2-1, cubic=-.5)
   inc.crota2=0
   dam=rot(dam, -inm.crota2, 1.d/scf, inm.crpix1-1, inm.crpix2-1, cubic=-.5)
   inm.crota2=0
	
   if (VERBOSE) then print, 'Reading data took '+ strtrim(systime(/sec)-tt,2) + ' sec.'	

   if (QLK) then begin
      png_file = file_basename(obs_str_i(0).filename,'.fits')+'.png'
      png_path = outroot + png_file
      if (VERBOSE) then print,'Writing '+png_path
      imc = bytscl(dac,top=255,/NAN)
      write_png,png_path,imc,r,g,b	
      obs_str_i(0).qclk_fname = png_file
   
      png_file = file_basename(obs_str_i(1).filename,'.fits')+'.png'
      png_path = outroot + png_file
      if (VERBOSE) then print,'Writing '+png_path
      imm = bytscl(dam,top=255,min=-1.e2,max=1.e2,/NAN)
      write_png,png_path,imm,r,g,b	
      obs_str_i(1).qclk_fname = png_file	
   endif
	
   if (CSV) then begin
      obs_file = outfnroot + '_'+cdate+'_sdo_init.csv'
      obs_path = outroot + obs_file
      if (VERBOSE) then print,'Writing '+obs_path
      hfc_write_csv,obs_str_i,obs_path
   endif

   if (VERBOSE) then print,'Pre-processing images...'
   if scf eq 4 then begin
      xc=fix(inc.crpix1-.5) &  yc=fix(inc.crpix2-.5)
      dac=dac((xc-512):(xc+511), (yc-512):(yc+511))
      dam=dam((xc-512):(xc+511), (yc-512):(yc+511))
      xc=512. & yc=512.
      nx=1024 & ny=1024
   endif else begin
      xc=inc.crpix1/scf-1
      yc=inc.crpix2/scf-1
      nx=inc.naxis1 & ny=inc.naxis2
   endelse
   qsim=float_qsmedian(dac, inc.rsun_obs/inc.CDELT1/scf, xc ,yc) ;Quiet Sun image (QS) + limb darkening
   flatimage = qsim 
   llocs=where(qsim ne 0) 
   if llocs(0) eq -1 then begin
      err_msg = iter+': WARNING '+file_basename(fnc_i)+' ***** problem computing flat continuum image!'
      message,/CONT, err_msg
      history = [history,err_msg]
      continue
   endif  
   flatimage(llocs)=dac(llocs)/qsim(llocs)    	
   
   if (VERBOSE) then begin
      print,'Pre-processing images...done'
      print,'Substracting limb darkening took '+strtrim(systime(/sec)-tt,2) + ' sec.'
      print,'Run the detection...'
   endif
  ; **** determin quiet Sun value
                                
   hh=histogram(flatimage, loc=xx, nbin=10000/scf)
   mm=max(hh(1:*), ii) & qsval=xx(ii(0)+1)
	 
   ; ***** run the detection
   if scf eq 1 then scale=4 
   if scf eq 4 then scale=1
	 
   MAXIMUM_FEATURE_LENGTH_X=300*scale
   MAXIMUM_FEATURE_LENGTH_Y=300*scale
   ss=wl_detspgs_sdo(flatimage, inc.naxis1/scf, inc.naxis2/scf, inc.crpix1/scf-1, inc.crpix2/scf-1, $
                     inc.rsun_obs/inc.CDELT1/scf, qsval, /sbl, /one, scale=scale, error=error)
   if (error) then begin
      err_msg = iter+': '+file_basename(fnc_i)+'/'+file_basename(fnm_i)+' ***** problem computing detection!'
      message,/CONT, err_msg
      history = [history,err_msg]
      continue
   endif  
   
   if (VERBOSE) then begin
      print,'Run the detection...'
      print,'Running sunspot detection took '+strtrim(systime(/sec)-tt,2)+' sec.'
      print,'Computing output parameters...'
   endif
	 
   ; **** now - verification
	 
   sp2=ss ge 1
   spot_image=ss & spot_image(*)=0
   
   
   sdoss_labelcountregion, sp2, n, ploc
   count=0
   
   mgim=dam
   image=flatimage
   
   if n ne 0 then begin
      feat_str_i = replicate(feat_str,n)
                
           ; data array for sunspots
	   ; data: gc_pixx, gc_pixy, gc_arcx, gc_arcy, gc_helon, gc_helat, c_carrlonn, gc_carrlat
	   ;       #umbras, #pixel , #umbrapixels, heliographArea (deg2), heliographArea (Mm2)
	   ;		heliographUmbra_Area (deg2), heliographUmbra_Area (Mm2),
	   ;       totalFlux, umbralFlux, meanIntensity (on QSint), minIntensity, maxIntensity, 
	   ;	    quietSunIntensity
	   ;       maximumFlux, maximumUbralFlux, heliographic diameter
	   ;       4 bounding rectangle parameters
      l0=(tim2carr(inc.date_obs))(0)
   endif
	 
	 
   for j=0, n-1 do begin
      minfluxvalue=abs(min(mgim[*ploc[j]]))
      maxfluxvalue=abs(max(mgim[*ploc[j]])) > minfluxvalue
      locs=*ploc[j]
      irrad=total(image[locs])/(qsval*n_elements(locs))
      
      minir=min(image[locs])
      maxir=max(image[locs])
      meanir=mean(image[locs])
      
           ;if (DEBUG) then begin
	    	;print, mgim[locs]
	        ;im2=image
	        ;im2[locs]=2*im2[locs]
	        ;mg2=mgim
	        ;mg2[locs]=1000
	        ;print, irrad
	        ;print, maxfluxvalue
	        ;loadct,0,/SILENT
	        ;window, /FREE ;xs=1024, ys=1024
	        ;		tvframe, bytscl(mg2, max=1000, min=-1000), /asp
	        ;stop
	    ;endif
	
      xp=locs mod nx
      yp=locs / nx
      
      if (max(xp) - min(xp)) ge MAXIMUM_FEATURE_LENGTH_X then continue
      if (max(yp) - min(yp)) ge MAXIMUM_FEATURE_LENGTH_Y then continue
      
      if ((n_elements(locs) le 2) and irrad gt .98) then continue
      if (irrad lt .85)  then begin
        	if (n_elements(locs) lt 10 and $
                    (maxfluxvalue lt 75)) then continue $
                else if (maxfluxvalue lt 40) then continue
             endif $
             else if (maxfluxvalue lt 100) then continue   
      
      spot_image[*ploc[j]]=1
      umbra=where(ss(*ploc[j]) eq 2)
      umbraploc=ptr_new(umbra)
      if umbra[0] eq -1 then nu=0 else begin
         pl=*ploc[j]
         temp=bytarr(nx, ny)
         temp[pl[umbra]]=1
         spot_image[pl[umbra]]=2
         uminfluxvalue=abs(min(mgim[pl[umbra]]))
         umaxfluxvalue=abs(max(mgim[pl[umbra]])) > uminfluxvalue
         umeanfluxvalue=mean(mgim[pl[umbra]])
         utotfluxvalue=total(mgim[pl[umbra]])
         uabstotfluxvalue=total(abs(mgim[pl[umbra]]))
         umin_int = min(image[pl[umbra]],max=umax_int)        
         umean_int = mean(image[pl[umbra]])
         
         sdoss_labelcountregion, temp, nu, umbraploc
	           
        ; print, nu
      endelse
      mean0=mean(image[*ploc[j]])
      
        ;Gravity center
      gcx=total(image(locs)*(locs mod nx))/total(image(locs))
      gcy=total(image(locs)*(locs / nx))/total(image(locs))
      
      feat_str_i(count).id_sunspot = count + 1l          
      
      feat_str_i(count).feat_x_pix = gcx       ;gc_pixx
      feat_str_i(count).feat_y_pix = gcy       ;gc_pixy
			         
      feat_str_i(count).feat_x_arcsec=(gcx-xc)*inc.cdelt1*scf       ;gc_arcx
      feat_str_i(count).feat_y_arcsec=(gcy-yc)*inc.cdelt2*scf       ;gc_arcy
      
      ll=arcmin2hel(feat_str_i(count).feat_x_arcsec/60, $
                    feat_str_i(count).feat_y_arcsec/60, $
                    date=inc.date_obs, /soho)
			         
      feat_str_i(count).feat_hg_long_deg = ll(1)  ;gc_helon
      feat_str_i(count).feat_hg_lat_deg = ll(0)   ;gc_helat
	         
      ; TEMPORARY: REMOVE DETECTIONS NEAR THE LIMBS
      ; (i.e., helio long > 70 deg).
      if (abs(feat_str_i(count).feat_hg_long_deg) gt 70.) then begin
         ptr_free, umbraploc
         continue
      endif 
	         
      feat_str_i(count).feat_carr_long_deg=ll(1)+l0      ;gc_carrlonn
      feat_str_i(count).feat_carr_lat_deg=ll(0)          ;gc_carrlat
      feat_str_i(count).umbra_number=nu                  ;Number of umbras
      feat_str_i(count).feat_area_pix=n_elements(locs)   ;ss_area_pix
	         
      ; heliographic ss area and diameter
      yy=sdo_pix2hel(inc.date_obs, locs, xc, yc, $
                     inc.cdelt1*scf, inc.cdelt2*scf, nx, ny, res=.01, area=area, diam=diam)
      feat_str_i(count).feat_area_deg2=area             ;ss_area_deg2
      feat_str_i(count).feat_area_mm2=area*(deg2mm)^2   ;ss_area_mm2
      feat_str_i(count).feat_diam_deg=diam              ;ss_diam_deg
      feat_str_i(count).feat_diam_mm=diam*(deg2mm)      ;ss_diam_mm
	
      if (feat_str_i(count).feat_area_pix lt feat_min_pix) then begin
         if (DEBUG) then print, strtrim(count,2)+' --> feature area is too small: '+$
                                strtrim(feat_str_i(count).feat_area_pix,2)+' pixels'
         continue  
      endif    
	                
      ; heliographic umbra area and diameter
      if (nu ne 0) then begin
         feat_str_i(count).umbra_area_pix=n_elements(umbra) ;umbra_area_pix
         yy=sdo_pix2hel(inc.date_obs, umbra, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, $
                        nx, ny, res=.01, area=uarea, diam=udiam)
         feat_str_i(count).umbra_area_deg2=uarea                  ;umbra_area_deg2
         feat_str_i(count).umbra_area_mm2=uarea*(deg2mm)^2        ;umbra_area_mm2
         feat_str_i(count).umbra_diam_deg=udiam                   ;umbra_diam_deg
         feat_str_i(count).umbra_diam_mm=udiam*(deg2mm)           ;umbra_diam_mm
      endif                                     
	   
      ; Bounding rectangle in pixel and arcsec
      sdoss_getbndrct, locs, nx, ny, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, arc=arc, xx=zz
      feat_str_i(count).br_x0_pix=zz[0]
      feat_str_i(count).br_y0_pix=zz[1]
      feat_str_i(count).br_x1_pix=zz[0]
      feat_str_i(count).br_y1_pix=zz[3]     
      feat_str_i(count).br_x2_pix=zz[2] 
      feat_str_i(count).br_y2_pix=zz[1] 
      feat_str_i(count).br_x3_pix=zz[2]   
      feat_str_i(count).br_y3_pix=zz[3]
      
      feat_str_i(count).br_x0_arcsec=arc[0]
      feat_str_i(count).br_y0_arcsec=arc[1]
      feat_str_i(count).br_x1_arcsec=arc[0]
      feat_str_i(count).br_y1_arcsec=arc[3]     
      feat_str_i(count).br_x2_arcsec=arc[2] 
      feat_str_i(count).br_y2_arcsec=arc[1] 
      feat_str_i(count).br_x3_arcsec=arc[2]   
      feat_str_i(count).br_y3_arcsec=arc[3]
	
      ; Bounding rectangle in heliographic and carrington
      ll=arcmin2hel([arc(0),arc(0),arc(2),arc(2)]/60, [arc(1),arc(3),arc(1),arc(3)]/60, date=inc.date_obs, /soho)
      ll = reverse(ll,1)
      feat_str_i(count).br_hg_long0_deg = ll(0,0)
      feat_str_i(count).br_hg_lat0_deg = ll(1,0)
      feat_str_i(count).br_hg_long1_deg = ll(0,1)
      feat_str_i(count).br_hg_lat1_deg = ll(1,1)
      feat_str_i(count).br_hg_long2_deg = ll(0,2)
      feat_str_i(count).br_hg_lat2_deg = ll(1,2)
      feat_str_i(count).br_hg_long3_deg = ll(0,3)
      feat_str_i(count).br_hg_lat3_deg = ll(1,3)
      ll(0,*) = ll(0,*) + l0
      feat_str_i(count).br_carr_long0_deg = ll(0,0)
      feat_str_i(count).br_carr_lat0_deg = ll(1,0)
      feat_str_i(count).br_carr_long1_deg = ll(0,1)
      feat_str_i(count).br_carr_lat1_deg = ll(1,1)
      feat_str_i(count).br_carr_long2_deg = ll(0,2)
      feat_str_i(count).br_carr_lat2_deg = ll(1,2)
      feat_str_i(count).br_carr_long3_deg = ll(0,3)
      feat_str_i(count).br_carr_lat3_deg = ll(1,3) 
	         
      ; Magnetic field Bz values
	         
      ; minimum/maximum/mean/tot ss Bz flux
      feat_str_i(count).feat_min_bz=minfluxvalue
      feat_str_i(count).feat_max_bz=maxfluxvalue
      feat_str_i(count).feat_mean_bz=mean(mgim[*ploc[j]]) 
      feat_str_i(count).feat_tot_bz=total(mgim[*ploc[j]])
      feat_str_i(count).feat_abs_bz=total(abs(mgim[*ploc[j]]))
	                      
      ; minimum/maximum/mean/tot umbral flux
      if nu ne 0 then begin
         feat_str_i(count).umbra_min_bz=uminfluxvalue 
         feat_str_i(count).umbra_max_bz=umaxfluxvalue
         feat_str_i(count).umbra_mean_bz=umeanfluxvalue 
         feat_str_i(count).umbra_tot_bz=utotfluxvalue
         feat_str_i(count).umbra_abs_bz=uabstotfluxvalue
         feat_str_i(count).umbra_min_int=umin_int
         feat_str_i(count).umbra_max_int=umax_int  
         feat_str_i(count).umbra_mean_int=umean_int
      endif 
	        
      ; Intensity values
      feat_str_i(count).feat_min_int=minir                                ;min intensity on pre-processed image
      feat_str_i(count).feat_max_int=maxir                                ;max intensity on pre-processed image              
      feat_str_i(count).feat_mean_int=meanir                              ;mean intensity on pre-processed image 
      feat_str_i(count).feat_mean2qsun=irrad                              ;mean intensity on Quiet Sun ratio 
      pp_out_str_i(0).qsun_int=pp_out_str_i(0).qsun_int+mean(qsval)       ;Quiet Sun mean intensity               
      ; Raster scan
      feat_str_i(count).rs=sdoss_getrasterscan(zz, nx, ny, locs, umbra, DEBUG=0)
      if (feat_str_i(count).rs eq '') then begin
         msg='Warning: Empty raster scan! ('+fnc_i+':'+strtrim(j,2)+')'
         print,msg
         history = [history,msg]
         continue
      endif
      feat_str_i(count).rs_length = strlen(feat_str_i(count).rs)                

      ; Chain code
      ad=''
      cc_arc_i=sdoss_getchaincode(locs, zz, nx, ny, xc, yc, $
                                  inc.cdelt1*scf, inc.cdelt2*scf, cc_pix=cc_pix_i,$
                                  ad=ad,DEBUG=0)
      ad = strtrim(ad,2)
      if (ad[0] eq '') then begin
         msg = 'Warning: Empty chain code! ('+fnc_i+':'+strtrim(j,2)+')'
         print, msg
         history = [history,msg]
         continue
      endif
      feat_str_i(count).cc = strjoin(strtrim(ad,2))
      feat_str_i(count).cc_length = strlen(feat_str_i(count).cc)
      feat_str_i(count).cc_x_pix = cc_pix_i(0,0)          ;cc_x_pix
      feat_str_i(count).cc_y_pix = cc_pix_i(1,0)          ;cc_y_pix              
      feat_str_i(count).cc_x_arcsec = cc_arc_i(0,0)       ;cc_x_arcsec
      feat_str_i(count).cc_y_arcsec = cc_arc_i(1,0)       ;cc_x_arcsec

      if (DEBUG) then begin
         print,'Feature number: '+strtrim(count,2) 
         window,2
         loadct,0,/SILENT
         xr=[gcx-50,gcx+50]
         yr=[gcy-50,gcy+50]
         tvframe, dam[xr[0]:xr[1],yr[0]:yr[1]], /bar, /asp
         contour, spot_image(xr[0]:xr[1],yr[0]:yr[1]), lev=[1, 2], c_th=[3, 2], /ov
         cc = feat_cc_extract(feat_str_i(count).cc,[feat_str_i(count).cc_x_pix,feat_str_i(count).cc_y_pix])
         loadct,39,/SILENT
         oplot,cc[0,*] - (gcx - 50),cc[1,*] - (gcy - 50),color=200,thick=2,line=2
         
         print,feat_str_i(count).feat_x_pix,feat_str_i(count).feat_y_pix
			
                   ;print, feat_str_i(count) 
         stop
      endif	      
	          
      count=count+1
      ptr_free, umbraploc
   endfor
   unprocessed[i] = ''
   if (count eq 0) then begin
      msg = 'No sunspot detected on these images!'
      history = [history,msg]
      if (VERBOSE) then print,msg
      continue
   endif else begin
      feat_str_i=feat_str_i(0:count-1, *)
      nfeat = n_elements(feat_str_i)    
      msg = strtrim(nfeat,2)+' sunspot(s) detected on theses images.'
      if (VERBOSE) then print,msg
   endelse
   if (VERBOSE) then begin
      print,'Computing output parameters...done'
      msg = 'running sunspot verification took '+strtrim(systime(/sec)-tt,2)+' sec.'
      print,msg
      print,'Writing output files...'
   endif
   
   ; **** now - write output  
   sp2=spot_image ge 1      
   sdoss_labelcountregion, sp2, n, ploc
   
	
   ; Updated header of corrected fits
   inc1=inc
   inc1.cdelt1=inc.cdelt1*scf & inc1.cdelt2=inc.cdelt2*scf
   inc1.naxis1=inc.naxis1/scf & inc1.naxis2=inc.naxis2/scf
   inc1.crpix1=xc & inc1.crpix2=yc
	
   inm1=inm
   inm1.cdelt1=inm.cdelt1*scf & inm1.cdelt2=inm.cdelt2*scf
   inm1.naxis1=inm.naxis1/scf & inm1.naxis2=inm.naxis2/scf
   inm1.crpix1=xc & inm1.crpix2=yc
   
   fnc_corr = "NULL"
   fnm_corr = "NULL"
   snapshot_fn = "NULL"
   if keyword_set(write_fits) then begin	
      if (VERBOSE) then print,'Writing fits files...'
      fnc_corr = outroot+ strmid(fnc_i, strpos(fnc_i, '/', /reverse_se)+1)+'_corrected_flat.fits'
      mwritefits, outfile=fnc_corr, inc1, flatimage
      if (fix(write_fits) ge 2) then begin
         fnm_corr = outroot+ strmid(fnc_i, strpos(fnc_i, '/', /reverse_se)+1)+'_magnetogram.fits'
         mwritefits, outfile=fnm_corr, inc1, dam
      endif
      if (fix(write_fits) ge 3) then mwritefits, outfile=outroot+ $
         strmid(fnc_i, strpos(fnc_i, '/', /reverse_se)+1) $
         +'_detection_results.fits', inc1, spot_image
      if (VERBOSE) then print,'Writing fits files...done'
   endif
	
   if (SNP) and (nfeat gt 0) then begin 
      png_file = file_basename(obs_str_i(0).filename,'.fits') + $
                 '_sdoss_results.png'
      png_path = outroot + png_file
      if (VERBOSE) then print,'Writing '+png_path
      imc_ss = bytscl(spot_image,top=255)
      write_png,png_path,imc_ss,r,g,b
   endif
	
   ; Update corresponding pp_output structure
   pp_out_str_i.pr_locfname = [file_basename(fnc_corr),file_basename(fnm_corr)]
   pp_out_str_i.org_fname = [file_basename(fnc_i),file_basename(fnm_i)]
   pp_out_str_i.loc_file = [fnc_corr,fnm_corr]
   pp_out_str_i.cdelt1 = [inc1.cdelt1,inm1.cdelt1]
   pp_out_str_i.cdelt2 = [inc1.cdelt2,inm1.cdelt2]
   pp_out_str_i.naxis1 = [inc1.naxis1,inm1.naxis1]
   pp_out_str_i.naxis2 = [inc1.naxis2,inm1.naxis2]
   pp_out_str_i.center_x = [inc1.crpix1,inm1.crpix1]
   pp_out_str_i.center_y = [inc1.crpix2,inm1.crpix2]
   pp_out_str_i.bitpix = [inc1.bitpix, inm1.bitpix]
   pp_out_str_i.qsun_int = [pp_out_str_i(0).qsun_int/float(nfeat),0]
   
   if (CSV) then begin
      pp_out_file = outfnroot+'_'+cdate+'_sdo_norm.csv'
      pp_out_path = outroot + pp_out_file
      if (VERBOSE) then print,'Writing '+pp_out_path
      hfc_write_csv,pp_out_str_i,pp_out_path
      
      if (nfeat gt 0) then begin
         feat_file = outfnroot+'_'+cdate+'_sdo_feat.csv'
         feat_path = outroot + feat_file
         feat_str_i.feat_filename  = feat_path
         if (VERBOSE) then print,'Writing '+feat_path
         hfc_write_csv,feat_str_i,feat_path    
      endif
      if (VERBOSE) then print, 'Writing output to csv files took '+strtrim(systime(/SEC)-tt,2)+' sec.'
   endif
	
   if (XML) then begin
      if (VERBOSE) then print, 'Writing output to xml files took '+strtrim(systime(/sec)-tt,2)+' sec.'
      ;sdoss_xml, oby_str, frc_str, obs_str, pp_info_str, pp_out_str, feat_str, $
	   ;            outroot=outroot
      if (VERBOSE) then print,'Not available currently!'
   endif
	
   if (VERBOSE) then print,'Writing output files...done'
   if (DEBUG) then stop
endfor
where_unpro = where(unprocessed ne '',nunpro)
nproc = nfnc - nunpro

if (nproc gt 1) then begin
   if (VERBOSE) then print,'There is/are '+strtrim(nproc,2)+' processed file(s).'
endif
if (where_unpro[0] ne -1) then begin
   unprocessed = unprocessed[where_unpro]
   if (VERBOSE) then print,'WARNING: There is/are '+strtrim(nunpro,2)+' unprocessed file(s).'
endif

msg = 'Total processing took '+strtrim((systime(/SEC) - syst0)/60.,2)+' min.'
if (VERBOSE) then print,msg
history=[history,msg]

if (LOG) then begin
   history=history[1:*]
   openw,lun,'sdoss_processing.log',/GET_LUN,/APPEND
   for i=0,n_elements(history)-1 do printf,lun,history[i]
   close,lun
   free_lun,lun
endif

;[3]:========================

END
