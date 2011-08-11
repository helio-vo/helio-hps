; *****************************************************************************************************

function ss_observations_entry, fn, header, id_ascii
; FUNCTION
;     to create a string entry for observations ASCII file

        observatory_id=4
        date_obs=fxpar(header, 'DATE_OBS')
        jd=anytim2jd(date_obs)
        CRnum=tim2carr(date_obs, /dc)
        
        nx=fxpar(header, 'NAXIS1')
        ny=fxpar(header, 'NAXIS2')
        cdx=fxpar(header, 'CDELT1')
        cdy=fxpar(header, 'CDELT2')
        xc=fxpar(header, 'X0')
        yc=fxpar(header, 'Y0')
        R=fxpar(header, 'R_SUN')

        bscale=fxpar(header, 'BSCALE')
        bzero=fxpar(header, 'BZERO')
        comment=fxpar(header, 'COMMENT')
        quality=fxpar(header, 'QUALITY')
        bitpix=fxpar(header, 'BITPIX')

        filename=strmid(fn, strpos(fn, '/', /reverse_search)+1)
        nc=n_elements(comment)
        cmnt0=''
        for in=0, nc-1 do cmnt0=cmnt0+comment[in]

        com_len='A'+trim( string(strlen(cmnt0)+3) )
        null=0; '\N'
        date_end=date_obs
        exp_time=0.00
    ; *** order:
    ;       id_observations, observatory_id, date_obs, date_end, jdint, jdfrac, exp_time, c_rotation,
    ;       bscale, bzero, bitpix, naxis1, naxis2, r_sun, center_x, center_y, cdelt1, cdelt2, quality
    ;       filename, date_obs_string, date_end_string, comment, loc_filename, id_ascii

      str_out=string(null, observatory_id, date_obs, date_end, jd.int, jd.frac, exp_time , fix(crnum), bscale, bzero, $
            bitpix, nx, ny, r, xc, yc, cdx, cdy, quality, filename, date_obs, date_obs, cmnt0, fn, id_ascii, $
             format='(2(i5, ";"), 2(A30, ";"), i10, ";", d25.16, ";", d25.16, ";", i8,  ";", 2(d15.10, ";"),' +$
                    'i4,  ";", 2(i6, ";"), 5(d25.16, ";"), A15, ";", 3(A30, ";"), '+ $
                     com_len+', ";", A150, ";", i7)')  
  return, str_out
end