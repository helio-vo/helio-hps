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
;      scf 	      - Scaling factor (either 1 or 4):
;             			1 -> normal resolution is used.
;               		4 -> the images are rescaled 4 times down (SOHO resolution).                     
;      write_fits - Write auxillary files:
;                       1 -> Intensity with limb darkening removed
;                       2 -> as 1 plus corresponding magnetogram
;                       3 -> as 2 plus detection results
;	   status_ic  - Structure containing the information about vso query results 
;				    for intensity continuum fits file.
;	   status_m	  - Structure containing the information about vso query results 
;					for magnetogram fits file.
;
;      outroot    - folder for writing output (fits and xml/csv) files.
;	   checkwait  - Debug mode.
;
; KEYWORD PARAMETERS:
;		/CSV	- Write detection results into csv format files
;				  instead of xml files.  	
;		/PNG	- Create png image file of the continuum intensity image with sunspots contours.
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
;		The SolarSoft Ware (SSW) must be installed.
;		SDO SS auxiliary IDL routines must be compiled.
;		
; CALL:
;
;		sdo_ss_labelcountregion
;		sdo_ss_xml
;		sdo_ss_csv
;		sdo_ss_init
;		sdo_ss_getbndrct
;		sdo_ss_getrasterscan
;		sdo_ss_getchaincode
;		tim2carr
;		arcmin2hel
;		sdo_pix2hel
;		tvframe
;		read_sdo
;		float_qsmedian
;		wl_detspgs_sdo
;		mwritefits
;		pngscreen
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;	Version 1.0
;		Written by S.Zharkov (MSSL).
;
;	Version 1.1
;		22-JUL-2011, X.Bonnin:	Added sdo_ss_init.pro routine,
;								added sdo_ss_csv.pro routine,
;						        added status_ic and status_m optional inputs, 
;								added /CSV keyword and, 
;								updated the header.
;										
;		28-JUL-2011, X.Bonnin:	Added extra parameters to data variable.
;								Inverted 2 and 3 options of write_fits optional input.		
;								Added PNG keyword.
;-


pro sdo_ss_processing, fnc, fnm, $;inc=inc, inm=inm, dac=dac, dam=dam,$
                       write_fits=write_fits, scf=scf, checkwait=checkwait, $
                       status_ic=status_ic,status_m=status_m,$
                       outroot=outroot,$
                       CSV=CSV,PNG=PNG


;[1];Initializing program
;[1]:====================
if (n_params() lt 2) then begin
	message,/INFO,'Call is:'
	print,'sdo_ss_processing, fnc, fnm, $'
	print,'                   write_fits=write_fits, scf=scf, $'
	print,'                   checkwait=checkwait, $'
	print,'                   status_ic=status_ic,status_m=status_m,$'
	print,'                   outrout=outroot, $'
	print,'                   /CSV,/PNG'
	return
endif

if not keyword_set(status_ic) then status_ic = {url:"NULL"}
if not keyword_set(status_m) then status_m = {url:"NULL"}

;Get Observatory, FRC, and Pre-Process code informations for current running
sdo_ss_init,obs_info,frc_info, pp_info

if not keyword_set(scf) then scf=4

if not keyword_set(outroot) then begin
	outroot='ss_output'
	if not (file_test(outroot,/DIR)) then spawn,'mkdir '+outroot 
	outroot = outroot + path_sep()
endif

CSV = keyword_set(CSV)
PNG = keyword_set(PNG)

deg2mm = 6.96e8/!radeg

;[1]:====================


;[2]:Loops on each fits files
;[2]:========================
for ind=0, n_elements(fnc)-1 do begin
	
	  if (strlen(strtrim(fnc(ind),2)) eq 0) or (strlen(strtrim(fnm(ind),2)) eq 0) then continue
	
	  ;Reading SDO data files
      tt=systime(/sec)
   ;   if not (keyword_set(inc) and keyword_set(dac)) then $
      read_sdo, fnc(ind), inc, dac, /uncomp_del, header=hd
   ;   if not (keyword_set(inm) and keyword_set(dam)) then $
      read_sdo, fnm(ind), inm, dam, /uncomp_del, header=hd
      
      ; ***** do the rotation correction correction
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
		print, '***** problem computing flat continuum image, returning.'
		return
	endif  
	flatimage(llocs)=dac(llocs)/qsim(llocs)    

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
      ss=wl_detspgs_sdo(flatimage, inc.naxis1/scf, inc.naxis2/scf, inc.crpix1/scf-1, inc.crpix2/scf-1, inc.rsun_obs/inc.CDELT1/scf, qsval, /sbl, /one, scale=scale)
      
      print, 'sunspot detection run ', systime(/sec)-tt
      
      
 ; **** now - verification
      
      sp2=ss ge 1
      spot_image=ss & spot_image(*)=0


      sdo_ss_labelcountregion, sp2, n, ploc
      count=0
      
      mgim=dam
      image=flatimage
      
      if n ne 0 then begin
        data=fltarr(n, 58)
        rscan=strarr(n)
        cc = strarr(n)
        cc_pix = lonarr(2,n)
        cc_arc = dblarr(2,n)
        
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
                
                sdo_ss_labelcountregion, temp, nu, umbraploc
                
              ; print, nu
              endelse
              mean0=mean(image[*ploc[i]])
              
              ;Gravity center
              gcx=total(image(locs)*(locs mod nx))/total(image(locs))
              gcy=total(image(locs)*(locs / nx))/total(image(locs))
              
              
              data(count,0) = gcx ;gc_pixx
              data(count,1) = gcy ;gc_pixy
              
              data(count, 2)=(gcx-xc)*inc.cdelt1*scf ;gc_arcx
              data(count, 3)=(gcy-yc)*inc.cdelt2*scf ;gc_arcy
              
              ll=arcmin2hel(data(count, 2)/60, data(count, 3)/60, date=inc.date_obs, /soho)
              
              data(count,4) = ll(1) ;gc_helon
              data(count,5) = ll(0) ;gc_helat
              
              data(count, 6)=ll(1)+l0 ;gc_carrlonn
              data(count, 7)=ll(0) ;gc_carrlat
              data(count, 8)=nu ;Number of umbras
              data(count, 9)=n_elements(locs) ;ss_area_pix
              
              ; heliographic ss area and diameter
              yy=sdo_pix2hel(inc.date_obs, locs, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, nx, ny, res=.01, area=area, diam=diam)
              data(count, 10)=area ;ss_area_deg2
              data(count, 11)=area*(deg2mm)^2 ;ss_area_mm2
              data(count, 12)=diam ;ss_diam_deg
              data(count, 13)=diam*(deg2mm) ;ss_diam_mm
                       
              ; heliographic umbra area and diameter
              if (nu ne 0) then begin
              	data(count, 14)=n_elements(umbra) ;umbra_area_pix
              	yy=sdo_pix2hel(inc.date_obs, umbra, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, nx, ny, res=.01, area=uarea, diam=udiam)
              	data(count, 15)=uarea
              	data(count, 16)=uarea*(deg2mm)^2 ;umbra_area_mm2
                data(count, 17)=udiam  ;umbra_diam_deg
                data(count, 18)=udiam*(deg2mm) ;umbra_diam_mm
              endif else data(count,14:18) = 0                                      
              
              ;Bounding rectangle in pixel and arcsec
              sdo_ss_getbndrct, locs, nx, ny, xc, yc, inc.cdelt1*scf, inc.cdelt2*scf, arc=arc, xx=zz
              data(count, 19:26)=[zz[0:1],zz[0],zz[3],zz[2],zz[1],zz[2:3]] ;BR_PIX (4 points)
              data(count, 27:34)=[arc[0:1],arc[0],arc[3],arc[2],arc[1],arc[2:3]] ;BR_ARC (4 points)
              
              ;Bounding rectangle in heliographic and carrington
              ll=arcmin2hel([arc(0),arc(0),arc(2),arc(2)]/60, [arc(1),arc(3),arc(1),arc(3)]/60, date=inc.date_obs, /soho)
              ll = reverse(ll,1)
              data(count, 35:42)=[reform(ll(*,0)),reform(ll(*,1)),reform(ll(*,2)),reform(ll(*,3))] ;heliographic
              ll(0,*) = ll(0,*) + l0
              data(count, 35:42)=[reform(ll(*,0)),reform(ll(*,1)),reform(ll(*,2)),reform(ll(*,3))] ;carrington
              
              ; Magnetic field Bz values
              
              ; minimum/maximum/mean/tot ss Bz flux
              data(count, 43)=minfluxvalue
              data(count, 44)=maxfluxvalue
              data(count, 45)=mean(mgim[*ploc[i]]) 
              data(count, 46)=total(mgim[*ploc[i]])
              data(count, 47)=total(abs(mgim[*ploc[i]]))
                           
              ; minimum/maximum/mean/tot umbral flux
              if nu ne 0 then begin
              	data(count, 48)=uminfluxvalue 
              	data(count, 49)=umaxfluxvalue
                data(count, 50)=umeanfluxvalue 
                data(count, 51)=utotfluxvalue
                data(count, 52)=uabstotfluxvalue
              endif else data(count,48:52)=0
             
              ; Intensity values
              data(count, 53)=minir  ;min intensity/qsim
              data(count, 54)=maxir  ;max intensity/qsim             
              data(count, 55)=meanir ;mean intensity/qsim
              data(count, 56)=irrad  ;mean intensity/qsim on Quiet Sun qval ratio 
              data(count, 57)=mean(qsim[locs]) ;Quiet Sun mean intensity at the sunspot location 
              
              ;Raster scan
              rscan(count)=sdo_ss_getrasterscan(zz, nx, ny, locs, umbra)
              
              ;Chain code
              cc_arc_i=sdo_ss_getchaincode(locs, zz, nx, ny, xc, yc, $
              							   inc.cdelt1*scf, inc.cdelt2*scf, $
              							   code=code,ad=ad)
              
              cc(count) = strjoin(strtrim(ad,2))
              cc_pix(*,count) = code(*,0) ;cc_pix
              cc_arc(*,count) = cc_arc_i(*,0) ;cc_arc
              
	     if keyword_set(checkwait) then begin
            tvframe, dam(gcx-50:gcx+50, gcy-50:gcy+50), /bar, /asp
	     	contour, spot_image(gcx-50:gcx+50, gcy-50:gcy+50), lev=[1, 2], c_th=[3, 2], /ov
            print, data(count, *) & wait, checkwait ;& stop
         endif	      
	              
         count=count+1
         ptr_free, umbraploc
    endfor
    data=data(0:count-1, *)
    rscan=rscan(0:count-1)
    cc = cc(0:count-1)
    cc_pix = cc_pix(*,0:count-1)
    cc_arc = cc_arc(*,0:count-1)
    
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
     
    if (PNG) then begin 
    	xarc = (indgen(inc1.naxis1)-inc1.crpix1)*inc1.cdelt1
    	yarc = (indgen(inc1.naxis2)-inc1.crpix2)*inc1.cdelt2
    
    	window,xsize=800,ysize=800
    	display2d,flatimage,xarc,yarc,$
    			  xtitle='X (arcsec)',ytitle='Y (arcsec)',$
    			  color_table=0
    	loadct,8,/SILENT
    	contour,spot_image,xarc,yarc,/OVERPLOT,level=[1,2],c_th=[0.8, 0.2],c_col=[255,160]
    	
    	;Extra information
    	xmin = min(xarc)+45 & xmax=max(xarc)-45 
    	ymin = min(yarc,max=ymax)
    	yoff = 50 & dy = 45
    	
    	;Write filename
    	xyouts,xmax,ymin+yoff,file_basename(fnc),/DATA,alignment=1.0
    	
    	;Write image info
    	xyouts,xmin,ymax-yoff,'Heliophysics Feature Catalogue / Paris Observatory',/DATA
    	xyouts,xmin,ymax-yoff-dy,'SDO/HMI Intensity Continuum '+obs_info.MeanWavel+' '+obs_info.WavelUnit,/DATA
    	xyouts,xmin,ymax-yoff-2*dy,inc.date_obs,/DATA
    	xyouts,xmin,ymax-yoff-3*dy,'rotation '+strtrim(inc.car_rot,2),/DATA
    	
    	snapshot_fn = outroot+ strmid(fnc(ind), strpos(fnc(ind), '/', /reverse_se)+1) $
				  +'_detection_results.png'
    	pngscreen,snapshot_fn
    endif else snapshot_fn = 'NULL'
    
    pp_info.qs = mean(qsim)
    run_info = {fnc:fnc(ind),fnm:fnm(ind),$
    			fnc_corr:fnc_corr,fnm_corr:fnm_corr,$
    			obs_info:obs_info,frc_info:frc_info,pp_info:pp_info,$
    			status_ic:status_ic,status_m:status_m,snapshot_fn:snapshot_fn}  
    if (CSV) then begin
	   print, 'writing output to csv files: ', systime(/sec)-tt
	   sdo_ss_csv, inc,inm,inc1,inm1, $
	    		   run_info,data, $
				   rscan, cc, cc_pix, cc_arc,$
				   outroot=outroot
	endif else begin
		print, 'writing output to xml files: ', systime(/sec)-tt
        sdo_ss_xml, data, $
            	    rscan, cc, cc_pix, cc_arc,$
                    inc.date_obs, outroot=outroot
    endelse
  
	if keyword_set(checkwait) then  stop
endfor
;[2]:========================

END