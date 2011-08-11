pro ss_mdi_finding_observations, inc, inm, fnc, fnm, no_show=no_show, $
	unprocessed=unprocessed, fname=fname, check=check, missvalscheck=missvalscheck

MISSVAL_THRESHOLD=300000l
nc=n_elements(inc)

jdc=anytim2jd(inc.date_obs) & jdc=jdc.int+jdc.frac
jdm=anytim2jd(inm.date_obs) & jdm=jdm.int+jdm.frac

if not keyword_set(fname) then fname='ss_mdi_up'

; *** set up writing output ****
fnobs=fname+'TEST_observations.txt'
;fnex=fname+'_ppoutput.txt'
fnex=fname+'TEST_exceptions.txt'
fnss=fname+'TEST_sunspots.txt'
openw, lun_obs, fnobs, /get_lun
openw, lun_ex, fnex, /get_lun
openw, lun_ss, fnss, /get_lun


;*** now run the detection and extraction
;for i=0, nc-1 do begin

id_spot=0l

for i=0l, nc-1 do begin
;for i=0, 6 do begin
  jd=abs(jdm-jdc(i))
  mn=min(jd, ind)
  print, mn*24*60
  print, inc(i).date_obs, inm(ind).date_obs
  
  if mn ge 1 then begin
        print, '**** no adjacent magnetogram image found, stopping for time being...'
        printf, lun_ex, fnc(i), ';           no magnetogram'
	continue
;        
    end
    wl=obj_new('wlfitsfdobs', filename=fnc(i), header=hd, unprocessed=unprocessed)
  if fxpar(hd, 'missvals') gt MISSVAL_THRESHOLD then begin
	print, '**** MISSING VALUES overload...'
        printf, lun_ex, fnc(i), ';           too many missing values pixels'
	continue
	endif 
	
    
    ; *** write observations output to file
    obs_str=ss_observations_entry(fnc(i), hd, i)
    
    printf, lun_obs, obs_str
    mg=obj_new('mgfitsfdobs', loc=fnm(ind))
    sp=obj_new('sunspotmgobs', wl, mg, /one, no_show=no_show, /setmg, missvalscheck=missvalscheck)
    
    nss=sp->n_spots()
    if nss ne 0 then begin
      ss_str=ss_sunspot_entry(fnc(i), sp, id_spot)
      printf, lun_ss, ss_str
     endif 
    if keyword_set(check) then stop
  obj_destroy, sp
  obj_destroy, wl
  obj_destroy, mg
  heap_gc;, /verb
endfor

free_lun, lun_obs,  lun_ex, lun_ss
end


