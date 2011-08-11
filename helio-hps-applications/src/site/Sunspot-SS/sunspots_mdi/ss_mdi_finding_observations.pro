pro ss_mdi_finding_observations, inc, inm, fnc, fnm, no_show=no_show, $
	unprocessed=unprocessed, fname=fname, check=check, missvalscheck=missvalscheck

; ******
;   finds files, runs sunspot detection, writes output
;
;   INPUT
;         fnc           array of MDI continuum filenames
;         fnm           array of MDI magnetogram filenames
;         inc           array of continuum index structures (mreadfits, fnc, inc, /nodata)
;         inm           array of magnetogram index structures (mreadfits, fnc, inc, /nodata)
;
;   KEYWORDS
;         no_show       set it to suppress window output of the results
;         unprocessed   set it to remove limb darkening (for level 1.8 data)
;         fname         provide prefix for ASCII output files ('ss_mdi_' used as default)
;         check         used for debugging, provides graphic output of the results and stops after each files
;         missvalscheck set it do check magnetograms for MISSVALS (just set it)
;
;   EXAMPLE (to use)
;           
;       ss_mdi_finding_observations, fnc, fnm, inc, inm, /unproc, /missvalscheck, /no_show, fname='TEST_'


if n_params() lt 2 then begin
  print, '*****invalid number of parameters, returning'
  return
end

if not arg_present(inc) then mreadfits, fnc, inc, /noda
if not arg_present(inm) then mreadfits, fnm, inm, /noda

MISSVAL_THRESHOLD=300000l
nc=n_elements(inc)

jdc=anytim2jd(inc.date_obs) & jdc=jdc.int+jdc.frac
jdm=anytim2jd(inm.date_obs) & jdm=jdm.int+jdm.frac

if not keyword_set(fname) then fname='ss_mdi_'

; *** set up writing output ****
fnobs=fname+'TEST_observations.txt'
fnex=fname+'TEST_exceptions.txt'
fnss=fname+'TEST_sunspots.txt'
openw, lun_obs, fnobs, /get_lun
openw, lun_ex, fnex, /get_lun
openw, lun_ss, fnss, /get_lun


;*** now run the detection and extraction
;for i=0, nc-1 do begin

id_spot=0l

for i=0l, nc-1 do begin

; **** for given intensity image, find the nearest magnetogram
  jd=abs(jdm-jdc(i))
  mn=min(jd, ind)
  print, mn*24*60
  print, inc(i).date_obs, inm(ind).date_obs
  
  if mn ge 1 then begin
        print, '**** no adjacent magnetogram image found, stopping for time being...'
        printf, lun_ex, fnc(i), ';           no magnetogram'
        continue        
  end
    
 ;*** read the intesity image into objecy
    wl=obj_new('wlfitsfdobs', filename=fnc(i), header=hd, unprocessed=unprocessed)
    
 ;*** check the number of missing value pixels in the image, reject if large   
  if fxpar(hd, 'missvals') gt MISSVAL_THRESHOLD then begin
	print, '**** MISSING VALUES overload...'
        printf, lun_ex, fnc(i), ';           too many missing values pixels'
	continue
	endif 
	
    
; *** write observations output to file
    obs_str=ss_observations_entry(fnc(i), hd, i)    
    printf, lun_obs, obs_str
    
    
; *** read-in the magnetogram    
    mg=obj_new('mgfitsfdobs', loc=fnm(ind))
; *** run sunspot detection and generated sunspot object
    sp=obj_new('sunspotmgobs', wl, mg, /one, no_show=no_show, /setmg, missvalscheck=missvalscheck)

; *** get the number of detected sunspots & write output    
    nss=sp->n_spots()
    if nss ne 0 then begin
      ss_str=ss_sunspot_entry(fnc(i), sp, id_spot)
      printf, lun_ss, ss_str
     endif 
    if keyword_set(check) then stop
    
 ; *** cleanup    
  obj_destroy, sp
  obj_destroy, wl
  obj_destroy, mg
  heap_gc;, /verb
endfor

free_lun, lun_obs,  lun_ex, lun_ss
end


