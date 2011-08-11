; *****************************************************************************************************

function ss_sunspot_entry, fn, sp, id_spot
; FUNCTION
;     to create a string entry for detected sunspot ASCII file

  strout=''
  frc_info_id=101
  procd_obs_id=0
  run_date=systime(/utc)
  date_obs=sp->getdate()
  
  
  n=sp->n_spots()
  if n eq 0 then stop

  data=sp->dataarray()
  
  imcont=float(sp->getimage())
  immg=sp->getmgdata()
  st=sp->GetStructure()
  l0=tim2carr(date_obs) & l0=l0[0]
  
  qsint=data(0, 13)
  for i=0, n-1 do begin
    id_spot++
    s1=sp->getspot(i)
    s1->getbndrct, brx0, bry0, brx1, bry1, arc_arr=ab
    rscan=s1->getrasterscan()
    feat_mean_int=s1->getphysparams(sp, max_value=feat_max_int, $
            min_value=feat_min_int, m2QS=mean_int_ratio )
    
    feat_x_arcsec=data(i, 0) & feat_y_arcsec=data(i, 1)
    feat_x_pix=st.xc+feat_x_arcsec/st.cdx
    feat_y_pix=st.yc+feat_y_arcsec/st.cdy
    feat_carr_long_deg=data(i, 2) & feat_carr_lat_deg=data(i, 3)
    
    feat_hg_long_deg=feat_carr_long_deg-l0 ;?????????
    feat_hg_lat_deg=feat_carr_lat_deg
    
    locs=s1->getlocs()
    nu=s1->numbra()
    
    feat_area_pix=n_elements(locs)
    feat_area_deg2=data(i, 7)
    s1->getdata, heldiam=feat_diameter
   
   feat_mean2qsun=mean_int_ratio
    feat_min_int=min(imcont(locs))/qsint
    feat_max_int=max(imcont(locs))/qsint
   
    flux_total=data(i, 8)
    flux_umbra_total=data(i, 9)
    flux_max=data(i, 10)
    flux_umbra_max=data(i, 11)
    
    flux_min=min(immg(locs))
    flux_abs_total=total(abs(immg(locs)))
    
    umbra_number=nu
    if nu ne 0 then begin
        umbralocs=s1->getumbra()
        ulocs=locs(umbralocs)
        
        umbra_area_pix=n_elements(ulocs)
        umbra_tot_flux=total(immg(ulocs))
        umbra_tot_absflux=total(abs(immg(ulocs)))
        umbra_min_flux=min(immg(ulocs))
        umbra_max_flux=max(immg(ulocs))
        
        umbra_mean2qsun_int=total(imcont(ulocs))/n_elements(ulocs)/qsint
        umbra_min_int=min(imcont(ulocs))/qsint
        umbra_max_int=max(imcont(ulocs))/qsint
        ;stop
     endif else begin
        umbra_area_pix=0
        umbra_tot_flux=0
        umbra_tot_absflux=0
        umbra_min_flux=0
        umbra_max_flux=0
        
        umbra_mean2qsun_int=0
        umbra_min_int=0
        umbra_max_int=0
     endelse
     
     rs_length=strlen(rscan);+2
     rs_form='A'+strtrim(string(rs_length))+', ";"'
     strout=[strout, string(id_spot, frc_info_id, procd_obs_id, run_date, date_obs, $
              feat_x_arcsec, feat_y_arcsec, feat_x_pix, feat_y_pix, feat_hg_long_deg, $
              feat_hg_lat_deg, feat_carr_long_deg, feat_carr_lat_deg, feat_area_pix,$
              feat_area_deg2, feat_diameter, feat_mean2qsun, feat_min_int, feat_max_int, $
              flux_total, flux_abs_total, flux_min, flux_max, umbra_number, umbra_area_pix, $
              umbra_mean2qsun_int, umbra_min_int, umbra_max_int, umbra_tot_flux, $
              umbra_tot_absflux, umbra_min_flux, umbra_max_flux, $
              brx0, bry0, brx1, bry1, ab(0), ab(1), ab(2), ab(3), fn, rs_length, rscan, $
              format='(3(I5, ";"), 2(A30, ";"), 8(D25.8, ";"), I7, ";", 9(D25.8, ";")'+$
                '2(I6, ";"), 7(D25.8, ";"), 4(I5, ";"), 4(D25.8, ";"), A150, ";", I7, ";",' $
                + rs_form+')' $
              )]
     
   ;  strout=strout+'\n'
   ; stop
  endfor
  strout=strout(1:*)
  return, strout
end


