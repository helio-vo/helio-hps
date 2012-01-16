;+
; NAME:
;		sdo_ss_processing
;
; PURPOSE:
; 		Running sunspot detection algorithm 
;		on SDO HMI Ic and M data.
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		SDOSS
;
; CALLING SEQUENCE:
;		sdo_ss_processing,fnc,fnm
;
; INPUTS:
;       fnc	- list of Ic files
;       fnm - list of corresponding M files
;             (the corresponding fnc & fnm should be pixel by
;              pixel identital in terms of position/time 	
;	
; OPTIONAL INPUTS:
;     	scf 	  - Scaling factor (either 1 or 4):
;             			1 -> normal resolution is used.
;               		4 -> the images are rescaled 4 times down (SOHO resolution).                     
;      write_fits - Write auxillary fits files:
;                       1 -> Intensity with limb darkening removed
;                       2 -> as 1 plus corresponding magnetogram
;                       3 -> as 2 plus detection results
;	   write_png  - Write auxillary png files:
;                       1 -> Intensity with limb darkening removed
;                       2 -> as 1 plus corresponding magnetogram
;                       3 -> as 2 plus detection results on intensity image.	
;	   status_ic  - Structure containing the information about vso query results 
;				    for intensity continuum fits file.
;	   status_m	  - Structure containing the information about vso query results 
;					for magnetogram fits file.
;
;      outroot    - folder for writing output (fits and xml/csv) files.
;	   checkwait  - Debug mode.
;
; KEYWORD PARAMETERS:
;       /WRITE_XML  - Write detection results into csv format files.
;		/WRITE_CSV	- Write detection results into csv format files.  	
;
; OUTPUTS:
;		None.	
;
; OPTIONAL OUTPUTS:
;	    frc_struct     - Structure containing feature recognition code information.
;       pp_info_struct - Structure containing prep-processing code information.
;       oby_struct     - Structure containing observatory information.
;       obs_struct     - Structure containing observations information.
;       pp_out_struct  - Structure containing pre-processing information.
;       feat_struct    - Structure containing feature parameters extracted.
;
; COMMON BLOCKS:		
;		None.
;	
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS/COMMENTS:
;		The SolarSoft Ware (SSW) must be installed.
;		SDO SS auxiliary IDL routines must be compiled.
;		
; CALL:
;		read_sdo
;		float_qsmedian
;		wl_detspgs_sdo
;		sdo_labelcountregion
;		tim2carr
;       anytim2jd
;       anytim
;		arcmin2hel
;		sdo_pix2hel
;		sdo_getbndrct
;		sdo_getrasterscan
;		sdo_ss_getchaincode_temp
;		tvframe
;		sdo_ss_xml
;		sdo_ss_hfc_struct
;		mwritefits
;       hfc_write_csv
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;	Version 1.00
;		Written by S.Zharkov (MSSL).
;
;	Version 1.01
;		22-JUL-2011, X.Bonnin:	Added sdo_ss_init.pro routine,
;								added sdo_ss_csv.pro routine,
;						        added status_ic and status_m optional inputs, 
;								added /WRITE_CSV keyword, and
;								updated the header.
;										
;		28-JUL-2011, X.Bonnin:	Added PNG keyword.
;
;   Version 1.02
;       27-DEC-2011, X.Bonnin:  Introduced hfc table parameters using structures
;                               loaded by the new routine sdo_ss_hfc_struct.
;                               The structures returned are now used
;                               to produce the output csv format files.
;                               Added oby_struct, frc_struct, obs_struct, 
;                               pp_info_struct, pp_out_struct, feat_struct
;                               optional outputs.
;                               They permit to pass code results as output idl arguments 
;                               without having to produce output files.
;
;	Version 1.03
;		10-JAN-2012, X.Bonnin:	Correction of minor bugs.
;								Updated write_png optional input.
;  
;-


pro sdo_ss_processing, fnc, fnm, $ ;inc=inc, inm=inm, dac=dac, dam=dam,$
                       scf=scf, checkwait=checkwait, $
                       status_ic=status_ic, status_m=status_m,$
                       outroot=outroot, write_fits=write_fits, $
                       oby_struct=oby_struct, frc_struct=frc_struct, $
                       obs_struct=obs_struct, pp_info_struct=pp_info_struct, $
                       pp_out_struct=pp_out_struct, feat_struct=feat_struct, $
                       write_png=write_png,WRITE_CSV=WRITE_CSV,WRITE_XML=WRITE_XML


;[1];Initializing program
;[1]:====================
if (n_params() lt 2) then begin
	message,/INFO,'Call is:'
	print,'sdo_ss_processing, fnc, fnm, $'
	print,'                   scf=scf, $'
	print,'                   checkwait=checkwait, $'
	print,'                   status_ic=status_ic,status_m=status_m,$'
	print,'                   outrout=outroot, write_fits=write_fits,$'
    print,'                   oby_struct=oby_struct, frc_struct=frc_struct, $'
    print,'                   obs_struct=obs_struct, pp_info_struct=pp_info_struct, $'
	print,'                   write_png=write_png,/WRITE_CSV,/WRITE_XML'
	return
endif
syst0 = systime(/SEC)
!QUIET = 1

CSV = keyword_set(WRITE_CSV)
XML = keyword_set(XML)
if (not keyword_set(write_png)) then wpng = 0 else begin
	wpng = fix(write_png[0])
	loadct,0,/SILENT
	tvlct,r,g,b,/GET
endelse

nfnc = n_elements(fnc)
nfnm = n_elements(fnm)
if (nfnc ne nfnm) then begin
    message,/CONT,'Numbers of HMI Ic and M files are incompatible!'
    return
endif

if not keyword_set(status_ic) then begin    
    status_ic = {url:"NULL"}
    status_ic = replicate(status_ic,nfnc)
endif
if not keyword_set(status_m) then begin
    status_m = {url:"NULL"}
    status_m = replicate(status_m,nfnm)
endif

;Code Version
;!!!! Warning: the version must be updated if modifications are done
;in the code, and must be consistent with the modification history in the
;header !!!!
version = '1.03'

outfnroot = 'sdoss_'+strjoin(strsplit(version,'.',/EXTRACT))

;Run date
run_date = (strsplit(anytim(!stime, /ccsds),'.',/EXTRACT))[0]

if not keyword_set(scf) then scf=4

if not keyword_set(outroot) then begin
	outroot='ss_output'
	if not (file_test(outroot,/DIR)) then spawn,'mkdir '+outroot 
endif
outroot = outroot + path_sep()

deg2mm = 6.96e8/!radeg

;open exceptions output file (if no exception has been encountered during the code, then this file will be deleted).
flag_ex = 0
excep_file = outfnroot+'_'+strjoin(strsplit(run_date,'-T:',/EXTRACT))+'.log'
excep_path = outroot + excep_file
openw,lun_ex,excep_path, /GET_LUN
;[1]:====================


;[2]:Load input structures
;[2]:=====================
;Load Observatory, FRC, Observations, Pre-Process, feature code parameters 
;for current running using dedicated HFC structures
sdo_ss_hfc_struct, oby_str, frc_str, obs_str, pp_info_str, pp_out_str, feat_str
frc_str.version = version
pp_info_str.version = version
feat_str.run_date = run_date
pp_out_str.run_date = run_date

if (CSV) then begin
    frc_file = outfnroot+'_frc_info.csv'
    frc_path = outroot + frc_file
    hfc_write_csv,frc_str,frc_path
    pp_info_file = outfnroot+'_pp_info.csv'
    pp_info_path = outroot + pp_info_file
    hfc_write_csv,pp_info_str,pp_info_path
    oby_file = outfnroot+'_observatory.csv'
    oby_path = outroot + oby_file
    hfc_write_csv,oby_str,oby_path    
endif
frc_struct = frc_str
pp_info_struct = pp_info_str
oby_struct = oby_str
;[2]:=====================


;[3]:Loops on each fits files
;[3]:========================
obs_struct = obs_str & pp_out_struct = pp_out_str & feat_struct = feat_str
for ind=0, n_elements(fnc)-1 do begin
      obs_str_i = obs_str
      pp_out_str_i = pp_out_str
      feat_str_i = feat_str	

	  if (strlen(strtrim(fnc(ind),2)) eq 0) or (strlen(strtrim(fnm(ind),2)) eq 0) then continue
	
	  ;Reading SDO data files
      tt=systime(/sec)
   ;   if not (keyword_set(inc) and keyword_set(dac)) then $
      read_sdo, fnc(ind), inc, dac, /uncomp_del, header=hd
   ;   if not (keyword_set(inm) and keyword_set(dam)) then $
      read_sdo, fnm(ind), inm, dam, /uncomp_del, header=hd

      ;Load corresponding fields in the observations structure
      obs_str_i.date_obs = [inc.date_obs,inm.date_obs]
      obs_str_i.date_end = [inc.date_obs,inm.date_obs]
      jdc = anytim2jd(inc.date_obs) & jdm = anytim2jd(inm.date_obs) 
      obs_str_i.jdint = [jdc.int,jdm.int]
      obs_str_i.jdfrac = [jdc.frac,jdm.frac]
      obs_str_i.exp_time = [inc.cadence,inm.cadence]
      obs_str_i.c_rotation = fix(tim2carr(obs_str.date_obs,/DC))
      obs_str_i.bscale = [inc.bscale,inm.bscale]  
      obs_str_i.bzero = [inc.bzero,inm.bzero] 
      obs_str_i.bitpix = [inc.bitpix,inm.bitpix]
      obs_str_i.naxis1 = [inc.naxis1,inm.naxis1]
      obs_str_i.naxis2 = [inc.naxis2,inm.naxis2]
      obs_str_i.r_sun = [inc.rsun_obs,inm.rsun_obs]
      obs_str_i.center_x = [inc.crpix1,inm.crpix1]
      obs_str_i.center_y = [inc.crpix2,inm.crpix2]
      obs_str_i.cdelt1 = [inc.cdelt1,inm.cdelt1]
      obs_str_i.cdelt2 = [inc.cdelt2,inm.cdelt2]
      obs_str_i.quality = [inc.quality,inm.quality]
      obs_str_i.filename = [file_basename(fnc(ind)),file_basename(fnm(ind))]
      obs_str_i.comment = [strjoin(inc.comment),strjoin(inm.comment)]
      ;replace the possible semi-commas encountered in the comment field
      ;by commas.
      obs_str_i(0).comment = strjoin(strsplit(obs_str(0).comment,';',/EXTRACT),',')
      obs_str_i(1).comment = strjoin(strsplit(obs_str(1).comment,';',/EXTRACT),',')
      obs_str_i.loc_filename = [fnc(ind),fnm(ind)] 
      obs_str_i.url = [status_ic(ind).url,status_m(ind).url]

      ;'YYYY-MM-DDTHH:NN:SS.SSSZ' --> ;'YYYYMMDDTHHNNSS.SSSZ'
      cdate = strjoin(strsplit(obs_str_i(0).date_obs,'-:',/EXTRACT))
      cdate = (strsplit(cdate,'.',/EXTRACT))[0] ;Remove fractional seconds '.SSSZ'        
      if (CSV) then begin
        obs_file = outfnroot + '_'+cdate+'_init.csv'
        obs_path = outroot + obs_file
        hfc_write_csv,obs_str_i,obs_path
      endif

      ; ***** do the rotation correction
      dac=rot(dac, -inc.crota2, 1.d/scf, inc.crpix1-1, inc.crpix2-1, cubic=-.5)
      inc.crota2=0
      dam=rot(dam, -inm.crota2, 1.d/scf, inm.crpix1-1, inm.crpix2-1, cubic=-.5)
      inm.crota2=0
      
      print, 'data read ', systime(/sec)-tt
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
        err_msg = file_basename(fnc(ind))+'/'+file_basename(fnm(ind))+' ***** problem computing flat continuum image!'
		print, err_msg
		printf,lun_ex,err_msg
        flag_ex = 1
        continue
	endif  
	flatimage(llocs)=dac(llocs)/qsim(llocs)    

	if (wpng gt 0) then begin
		png_file = file_basename(obs_str_i(0).filename,'.fits')+'.png'
		png_path = outroot + png_file
		imc = bytscl(flatimage,top=255,/NAN)
		write_png,png_path,imc,r,g,b		
	endif
	if (wpng gt 1) then begin
		png_file = file_basename(obs_str_i(1).filename,'.fits')+'.png'
		png_path = outroot + png_file
		imm = bytscl(dam,top=255,/NAN)
		write_png,png_path,imm,r,g,b		
	endif	

      print, 'limb darkening removed ', systime(/sec)-tt
	
            ; **** determin quiet Sun value
      ;stop
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
        err_msg = file_basename(fnc(ind))+'/'+file_basename(fnm(ind))+' ***** problem computing detection!'
		print, err_msg
		printf,lun_ex,err_msg
        flag_ex = 1
        continue
	  endif  
        
      print, 'sunspot detection run ', systime(/sec)-tt
      
      
 ; **** now - verification
      
      sp2=ss ge 1
      spot_image=ss & spot_image(*)=0


      sdo_ss_labelcountregion, sp2, n, ploc
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
      
      
      for i=0, n-1 do begin
      		minfluxvalue=abs(min(mgim[*ploc[i]]))
	  		maxfluxvalue=abs(max(mgim[*ploc[i]])) > minfluxvalue
            locs=*ploc[i]
            irrad=total(image[locs])/(qsval*n_elements(locs))
              
            minir=min(image[locs])
            maxir=max(image[locs])
            meanir=mean(image[locs])
            
            if keyword_set(checkmg) then begin
                 print, mgim[locs]
                 im2=image
                 im2[locs]=2*im2[locs]
                 mg2=mgim
                 mg2[locs]=1000
                 print, irrad
                 print, maxfluxvalue
                 window, 1, xs=800, ys=600 ;xs=1024, ys=1024
                     tvframe, bytscl(mg2, max=1000, min=-1000), /asp
                 stop
            endif


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
        
              spot_image[*ploc[i]]=1
              umbra=where(ss(*ploc[i]) eq 2)
              umbraploc=ptr_new(umbra)
              if umbra[0] eq -1 then nu=0 else begin
                pl=*ploc[i]
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

                sdo_ss_labelcountregion, temp, nu, umbraploc
                
              ; print, nu
              endelse
              mean0=mean(image[*ploc[i]])
              
              ;Gravity center
              gcx=total(image(locs)*(locs mod nx))/total(image(locs))
              gcy=total(image(locs)*(locs / nx))/total(image(locs))
              
              feat_str_i(count).id_sunspot = count + 1l          
    
              feat_str_i(count).feat_x_pix = gcx ;gc_pixx
              feat_str_i(count).feat_y_pix = gcy ;gc_pixy
              
              feat_str_i(count).feat_x_arcsec=(gcx-xc)*inc.cdelt1*scf ;gc_arcx
              feat_str_i(count).feat_y_arcsec=(gcy-yc)*inc.cdelt2*scf ;gc_arcy
              
              ll=arcmin2hel(feat_str_i(count).feat_x_arcsec/60, $
							feat_str_i(count).feat_y_arcsec/60, $
                            date=inc.date_obs, /soho)
              
              feat_str_i(count).feat_hg_long_deg = ll(1) ;gc_helon
              feat_str_i(count).feat_hg_lat_deg = ll(0) ;gc_helat
              
              ;TEMPORARY: REMOVE DETECTIONS NEAR THE LIMBS
              ;(i.e., helio long > 70 deg).
              if (abs(feat_str_i(count).feat_hg_long_deg) gt 70.) then begin
              	ptr_free, umbraploc
              	continue
              endif 
              
              feat_str_i(count).feat_carr_long_deg=ll(1)+l0 ;gc_carrlonn
              feat_str_i(count).feat_carr_lat_deg=ll(0) ;gc_carrlat
              feat_str_i(count).umbra_number=nu ;Number of umbras
              feat_str_i(count).feat_area_pix=n_elements(locs) ;ss_area_pix
              
              ; heliographic ss area and diameter
              yy=sdo_pix2hel(inc.date_obs, locs, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, nx, ny, res=.01, area=area, diam=diam)
              feat_str_i(count).feat_area_deg2=area ;ss_area_deg2
              feat_str_i(count).feat_area_mm2=area*(deg2mm)^2 ;ss_area_mm2
              feat_str_i(count).feat_diam_deg=diam ;ss_diam_deg
              feat_str_i(count).feat_diam_mm=diam*(deg2mm) ;ss_diam_mm
                       
              ; heliographic umbra area and diameter
              if (nu ne 0) then begin
              	feat_str_i(count).umbra_area_pix=n_elements(umbra) ;umbra_area_pix
              	yy=sdo_pix2hel(inc.date_obs, umbra, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, $
                               nx, ny, res=.01, area=uarea, diam=udiam)
              	feat_str_i(count).umbra_area_deg2=uarea ;umbra_area_deg2
              	feat_str_i(count).umbra_area_mm2=uarea*(deg2mm)^2 ;umbra_area_mm2
                feat_str_i(count).umbra_diam_deg=udiam  ;umbra_diam_deg
                feat_str_i(count).umbra_diam_mm=udiam*(deg2mm) ;umbra_diam_mm
              endif                                     
              
              ;Bounding rectangle in pixel and arcsec
              sdo_ss_getbndrct, locs, nx, ny, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, arc=arc, xx=zz
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

              ;Bounding rectangle in heliographic and carrington
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
              feat_str_i(count).feat_mean_bz=mean(mgim[*ploc[i]]) 
              feat_str_i(count).feat_tot_bz=total(mgim[*ploc[i]])
              feat_str_i(count).feat_abs_bz=total(abs(mgim[*ploc[i]]))
                           
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
              feat_str_i(count).feat_min_int=minir  ;min intensity on pre-processed image
              feat_str_i(count).feat_max_int=maxir  ;max intensity on pre-processed image              
              feat_str_i(count).feat_mean_int=meanir ;mean intensity on pre-processed image 
              feat_str_i(count).feat_mean2qsun=irrad  ;mean intensity on Quiet Sun ratio 
              pp_out_str_i(0).qsun_int=pp_out_str_i(0).qsun_int+mean(qsval) ;Quiet Sun mean intensity               
              ;Raster scan
              feat_str_i(count).rs=sdo_ss_getrasterscan(zz, nx, ny, locs, umbra)
              feat_str_i(count).rs_length = strlen(feat_str_i(count).rs)                

              ;Chain code
              cc_arc_i=sdo_ss_getchaincode_temp(locs, zz, nx, ny, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, code=code,ad=ad)
              
              feat_str_i(count).cc = strjoin(strtrim(ad,2))
              feat_str_i(count).cc_length = strlen(feat_str_i(count).cc)
              feat_str_i(count).cc_x_pix = code(0,0) ;cc_x_pix
              feat_str_i(count).cc_y_pix = code(1,0) ;cc_y_pix              
              feat_str_i(count).cc_x_arcsec = cc_arc_i(0,0) ;cc_x_arcsec
              feat_str_i(count).cc_y_arcsec = cc_arc_i(1,0) ;cc_x_arcsec
              
	     if keyword_set(checkwait) then begin
            tvframe, dam(gcx-50:gcx+50, gcy-50:gcy+50), /bar, /asp
	     	contour, spot_image(gcx-50:gcx+50, gcy-50:gcy+50), lev=[1, 2], c_th=[3, 2], /ov
            print, feat_str_i(count) & wait, checkwait ;& stop
         endif	      
	              
         count=count+1
         ptr_free, umbraploc
    endfor
    if (count eq 0) then begin
    	message,/CONT,'No sunspot detected on these images!'
    	return
    endif
    feat_str_i=feat_str_i(0:count-1, *)
    nfeat = n_elements(feat_str_i)    
    print, strtrim(nfeat,2)+' sunspot(s) detected on theses images.'
    
    print, 'sunspot verification run ', systime(/sec)-tt
       
       
    ; **** now - write output  
    sp2=spot_image ge 1      
    sdo_ss_labelcountregion, sp2, n, ploc


	;Updated header of corrected fits
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
    	fnc_corr = outroot+ strmid(fnc(ind), strpos(fnc(ind), '/', /reverse_se)+1)+'_corrected_flat.fits'
		mwritefits, outfile=fnc_corr, inc1, flatimage
		if (fix(write_fits) ge 2) then begin
			fnm_corr = outroot+ strmid(fnc(ind), strpos(fnc(ind), '/', /reverse_se)+1)+'_magnetogram.fits'
			mwritefits, outfile=fnm_corr, inc1, dam
		endif
		if (fix(write_fits) ge 3) then mwritefits, outfile=outroot+ strmid(fnc(ind), strpos(fnc(ind), '/', /reverse_se)+1) $
			+'_detection_results.fits', inc1, spot_image
	endif
     
    if (wpng gt 2) and (nfeat gt 0) then begin 
    	png_file = file_basename(obs_str_i(0).filename,'.fits') + $
					'_sdoss_results.png'
		png_path = outroot + png_file
		imc_ss = bytscl(spot_image,top=255)
		write_png,png_path,imc_ss,r,g,b
    endif
    
    ;Update corresponding pp_output structure
    pp_out_str_i.pr_locfname = [file_basename(fnc_corr),file_basename(fnm_corr)]
    pp_out_str_i.org_fname = [file_basename(fnc(ind)),file_basename(fnm(ind))]
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
       	pp_out_file = outfnroot+'_'+cdate+'_norm.csv'
       	pp_out_path = outroot + pp_out_file
       	hfc_write_csv,pp_out_str_i,pp_out_path

        if (nfeat gt 0) then begin
            feat_file = outfnroot+'_'+cdate+'_feat.csv'
            feat_path = outroot + feat_file
            feat_str_i.feat_filename  = feat_path
	    hfc_write_csv,feat_str_i,feat_path    
        endif
    endif

    if (XML) then begin
		print, 'writing output to xml files: ', systime(/sec)-tt
        ;sdo_ss_xml, oby_str, frc_str, obs_str, pp_info_str, pp_out_str, feat_str, $
        ;            outroot=outroot
        print,'Not available currently!'
    endif
    
    if (nfeat gt 0) then begin
        obs_struct = [obs_struct,obs_str_i]
        pp_out_struct = [pp_out_struct,pp_out_str_i]
        feat_struct = [feat_struct,feat_str_i]
    endif

	if keyword_set(checkwait) then  stop
endfor
if (n_elements(obs_struct) gt 1) then obs_struct = obs_struct(1:*)
if (n_elements(pp_out_struct) gt 1) then pp_out_struct = pp_out_struct(1:*)
if (n_elements(feat_struct) gt 1) then feat_struct = feat_struct(1:*)

close,lun_ex
free_lun,lun_ex
if (flag_ex eq 0) then spawn,'rm -rf '+excep_path else begin
    print,'!!!!WARNING!!!!'
    print,'Exceptions have been encountered during processing'
    print,'You should check '+excep_path
endelse
;[3]:========================


print,'Elapsed time: '+strtrim((systime(/SEC) - syst0)/60.,2)+' min.'
print,'Program has ended correctly.'
END