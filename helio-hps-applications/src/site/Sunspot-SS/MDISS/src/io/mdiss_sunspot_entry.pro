;+
; NAME:
;		mdiss_sunspot_entry
;
; PURPOSE:
;   	Returns sunspot structure entry for feature ASCII file
;
; CATEGORY:
;		I/O
;
; GROUP:
;		MDISS
;
; CALLING SEQUENCE:
;		IDL>struct_out = mdiss_sunspot_entry(sp, struct_in)
;
; INPUTS:
;       sp         - Sunpot IDL object containing detection results.
;       struct_in  - Structure containing feature structure to update for the output file.       
;
; OPTIONAL INPUTS:
;       None.
;	    
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;		struct_out - Return the struct_in structure updated with parameters found in sp.				
;
; OPTIONAL OUTPUTS:
;		error - Equal to 1 if an error occurs, 0 otherwise.		
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
;		arcmin2hel
;       get_chaincode
;
; EXAMPLE:
;		None.
;		
; MODIFICATION HISTORY:
;		Written by:		S.Zharkov (MSSL).
;
;       20-NOV-2011, X.Bonnin:  Modify inputs/outputs arguments.
;-

function mdiss_sunspot_entry, sp, struct_in, $
                               error=error

error = 1
if (n_params() lt 2) then begin
    message,/INFO,'Call is:'
    print,'struct_out = mdiss_sunspot_entry(sp, struct_in, error=error)'
    return,struct_in
endif

ss_str = struct_in

  deg2mm = 6.96e8/!radeg

 
 ; run_date=systime(/utc)
  date_obs=sp->getdate()
  
  
  n=sp->n_spots()
  if n eq 0 then stop
  if (n ne n_elements(ss_str)) then ss_str = replicate(ss_str(0),n)

  data=sp->dataarray()
  
  imcont=float(sp->getimage())
  sz = size(imcont)
  nx = sz[1] & ny = sz[2]
  immg=sp->getmgdata()
  st=sp->GetStructure()
  l0=tim2carr(date_obs) & l0=l0[0]
  
  id_spot = 0l
  qsint=data(0, 13)
  for i=0, n-1 do begin
    s1=sp->getspot(i)
    s1->getbndrct, brx0, bry0, brx1, bry1, arc_arr=ab
    if (brx0 eq brx1) or (bry0 eq bry1) then continue
    
    ;Bounding rectangle in heliographic and carrington
    ll=arcmin2hel([ab(0),ab(0),ab(2),ab(2)]/60, [ab(1),ab(3),ab(1),ab(3)]/60, date=date_obs, /soho)
    ll = reverse(ll,1)
	hb =[reform(ll(*,0)),reform(ll(*,1)),reform(ll(*,2)),reform(ll(*,3))] ;heliographic
    ll(0,*) = ll(0,*) + l0
    cb=[reform(ll(*,0)),reform(ll(*,1)),reform(ll(*,2)),reform(ll(*,3))] ;carrington    
  
    ;Compute raster scan
    rscan=s1->getrasterscan(/CODE)
    
    ;Compute chain code
    locs=s1->getlocs()
    mask = intarr(nx,ny)
    mask[locs] = 1
	
    get_chaincode,mask,ccode=ccode,ad=ad

    ad = strjoin(strtrim(ad,2))
    if (ad eq '') then continue ;error with chain code computing
    cc = ad
    cc_x_pix = ccode(0,0)
    cc_y_pix = ccode(1,0)
    cc_x_arcsec = st.cdx*(cc_x_pix - st.cdx)
    cc_y_arcsec = st.cdy*(cc_y_pix - st.cdy)
   
    feat_mean_int=s1->getphysparams(sp, max_value=feat_max_int, $
            min_value=feat_min_int, m2QS=mean_int_ratio )
   
    feat_x_arcsec=data(i, 0) & feat_y_arcsec=data(i, 1)
    feat_x_pix=st.xc+feat_x_arcsec/st.cdx
    feat_y_pix=st.yc+feat_y_arcsec/st.cdy
    feat_carr_long_deg=data(i, 2) & feat_carr_lat_deg=data(i, 3)
    
    feat_hg_long_deg=feat_carr_long_deg-l0 
    feat_hg_lat_deg=feat_carr_lat_deg
   
    ; Don't save ss on the limbs (in order to avoid false detections)
    if (abs(feat_hg_long_deg) gt 80.) then continue
   
    nu=s1->numbra()
    
    feat_area_pix=n_elements(locs)
    feat_area_deg2=data(i, 7)
    feat_area_mm2 = feat_area_deg2*(deg2mm)^2
    s1->getdata, heldiam=feat_diam_deg
    feat_diam_mm = feat_diam_deg*deg2mm
   
    feat_mean2qsun=mean_int_ratio
    feat_min_int=min(imcont(locs),/NAN)/qsint
    feat_max_int=max(imcont(locs),/NAN)/qsint
    feat_mean_int=mean(imcont(locs),/NAN)/qsint
   
    flux_total=data(i, 8)
    flux_umbra_total=data(i, 9)
    flux_max=data(i, 10)
    flux_umbra_max=data(i, 11)
    
    flux_min=min(immg(locs),/NAN)
    flux_mean=mean(immg(locs),/NAN)
    flux_abs_total=total(abs(immg(locs)),/NAN)
    
    umbra_number=nu
    if nu ne 0 then begin
        umbralocs=s1->getumbra()
        ulocs=locs(umbralocs)
        
        umbra_area_pix=n_elements(ulocs)
        umbra_area_deg2 = 0. ;To be done
        umbra_area_mm2 = 0. ;To be done
        umbra_diam_deg = 0. ;To be done
        umbra_diam_mm = 0. ;To be done
        
        umbra_tot_flux=total(immg(ulocs),/NAN)
        umbra_tot_absflux=total(abs(immg(ulocs)),/NAN)
        umbra_min_flux=min(immg(ulocs),/NAN)
        umbra_max_flux=max(immg(ulocs),/NAN)
        umbra_mean_flux=mean(immg(ulocs),/NAN)
        
        umbra_mean2qsun_int=total(imcont(ulocs))/n_elements(ulocs)/qsint
        umbra_min_int=min(imcont(ulocs),/NAN)/qsint
        umbra_max_int=max(imcont(ulocs),/NAN)/qsint
        umbra_mean_int=mean(imcont(ulocs),/NAN)/qsint
        ;stop
     endif else begin
    	umbra_area_pix= 0
        umbra_area_deg2 = 0. 
        umbra_area_mm2 = 0. 
        umbra_diam_deg = 0. 
        umbra_diam_mm = 0. 
        umbra_tot_flux=0
        umbra_tot_absflux=0
        umbra_min_flux=0
        umbra_max_flux=0
        umbra_mean_flux=0
        
        umbra_mean2qsun_int=0
        umbra_min_int=0
        umbra_max_int=0
        umbra_mean_int=0
     endelse
     
     cc_length = strlen(cc)
     rs_length=strlen(rscan)
     
     
     ;Fill ss structure
     ss_str(id_spot).id_sunspot = id_spot + 1
     ss_str(id_spot).br_x0_pix = brx0
     ss_str(id_spot).br_y0_pix = bry0
     ss_str(id_spot).br_x1_pix = brx0
     ss_str(id_spot).br_y1_pix = bry1
     ss_str(id_spot).br_x2_pix = brx1
     ss_str(id_spot).br_y2_pix = bry0
     ss_str(id_spot).br_x3_pix = brx1
     ss_str(id_spot).br_y3_pix = bry1
     ss_str(id_spot).br_x0_arcsec = ab(0)
     ss_str(id_spot).br_y0_arcsec = ab(1)
     ss_str(id_spot).br_x1_arcsec = ab(0)
     ss_str(id_spot).br_y1_arcsec = ab(3)
     ss_str(id_spot).br_x2_arcsec = ab(2)
     ss_str(id_spot).br_y2_arcsec = ab(1)
     ss_str(id_spot).br_x3_arcsec = ab(2)
     ss_str(id_spot).br_y3_arcsec = ab(3)
     ss_str(id_spot).br_hg_long0_deg = hb(0)
     ss_str(id_spot).br_hg_lat0_deg = hb(1)
     ss_str(id_spot).br_hg_long1_deg = hb(0)
     ss_str(id_spot).br_hg_lat1_deg = hb(3)
     ss_str(id_spot).br_hg_long2_deg = hb(2)
     ss_str(id_spot).br_hg_lat2_deg = hb(1)
     ss_str(id_spot).br_hg_long3_deg = hb(2)
     ss_str(id_spot).br_hg_lat3_deg = hb(3)
     ss_str(id_spot).br_carr_long0_deg = cb(0)
     ss_str(id_spot).br_carr_lat0_deg = cb(1)
     ss_str(id_spot).br_carr_long1_deg = cb(0)
     ss_str(id_spot).br_carr_lat1_deg = cb(3)
     ss_str(id_spot).br_carr_long2_deg = cb(2)
     ss_str(id_spot).br_carr_lat2_deg = cb(1)
     ss_str(id_spot).br_carr_long3_deg = cb(2)
     ss_str(id_spot).br_carr_lat3_deg = cb(3)
     ss_str(id_spot).feat_x_pix = feat_x_pix
     ss_str(id_spot).feat_y_pix = feat_y_pix
     ss_str(id_spot).feat_x_arcsec = feat_x_arcsec
     ss_str(id_spot).feat_y_arcsec = feat_y_arcsec
     ss_str(id_spot).feat_hg_long_deg = feat_hg_long_deg
     ss_str(id_spot).feat_hg_lat_deg = feat_hg_lat_deg
     ss_str(id_spot).feat_carr_long_deg = feat_carr_long_deg
     ss_str(id_spot).feat_carr_lat_deg = feat_carr_lat_deg
     ss_str(id_spot).umbra_number = umbra_number
     ss_str(id_spot).feat_area_pix = feat_area_pix
     ss_str(id_spot).feat_area_deg2 = feat_area_deg2
     ss_str(id_spot).feat_area_mm2 = feat_area_mm2
     ss_str(id_spot).feat_diam_deg = feat_diam_deg
     ss_str(id_spot).feat_diam_mm = feat_diam_mm
     ss_str(id_spot).umbra_area_pix = umbra_area_pix
     ss_str(id_spot).umbra_area_deg2 = umbra_area_deg2
     ss_str(id_spot).umbra_area_mm2 = umbra_area_mm2
     ss_str(id_spot).umbra_diam_deg = umbra_diam_deg
     ss_str(id_spot).umbra_diam_mm = umbra_diam_mm
     ss_str(id_spot).feat_min_int = feat_min_int
     ss_str(id_spot).feat_max_int = feat_max_int
     ss_str(id_spot).feat_mean_int = feat_mean_int
     ss_str(id_spot).feat_mean2qsun = feat_mean2qsun
     ss_str(id_spot).feat_min_bz = flux_min
     ss_str(id_spot).feat_max_bz = flux_max
     ss_str(id_spot).feat_mean_bz = flux_mean
     ss_str(id_spot).feat_tot_bz = flux_total
     ss_str(id_spot).feat_abs_bz = flux_abs_total
     ss_str(id_spot).umbra_min_bz = umbra_min_flux
     ss_str(id_spot).umbra_max_bz = umbra_max_flux
     ss_str(id_spot).umbra_mean_bz = umbra_mean_flux
     ss_str(id_spot).umbra_tot_bz = umbra_tot_flux
     ss_str(id_spot).umbra_abs_bz = umbra_tot_absflux
     ss_str(id_spot).cc_x_pix = cc_x_pix
     ss_str(id_spot).cc_y_pix = cc_y_pix
     ss_str(id_spot).cc_x_arcsec = cc_x_arcsec
     ss_str(id_spot).cc_y_arcsec = cc_y_arcsec
     ss_str(id_spot).cc = cc
     ss_str(id_spot).cc_length = cc_length 
     ss_str(id_spot).rs = rscan
     ss_str(id_spot).rs_length = rs_length
     id_spot++ 
  endfor
  if (id_spot eq 0) then return,0 
    
  struct_out = ss_str(0:id_spot-1)
  error = 0
  return, struct_out

end


