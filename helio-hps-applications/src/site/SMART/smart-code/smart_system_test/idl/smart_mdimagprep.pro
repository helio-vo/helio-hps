;LOS correct, noise threshold, non-finite correct...
;INDATA = Data to be calibrated
;LOSMAP = Correction map to be multiplied by DATA 
;NSMOOTH = Pixel radius to smooth by.
;THRESHNOISE = Noise threshold
;
;NOSMOOTH = Switch to not do smoothing
;NONOISE = Switch to not do noise thresholding
;NOLOS = Switch to not do LOS correction
;NOFINITE = Switch to not remove non-finite values

function smart_mdimagprep, indata, threshnoise=threshnoise, nsmooth=nsmooth, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite, nolimb=nolimb

data=indata

wnotfinite=where(finite(data) ne 1)
wfinite=where(finite(data) eq 1)

;REPLACE NON-FINITE DATA WITH 0.
if not keyword_set(nofinite) then begin

	if wnotfinite[0] ne -1 then data[wnotfinite]=0

endif

;GAUSSIAN SMOOTH DATA. (USE CIRCULAR CONVOLUTION KERNAL)
if not keyword_set(nosmooth) then begin

	if not keyword_set(nsmooth) then nsmth=5 else nsmth=nsmooth
	data=smart_grow(data, /gaus, rad=nsmth)

endif

;REPLACE VALUES BELOW NOISE THRESHOLD WITH 0.
if not keyword_set(nonoise) then begin

	if keyword_set(threshnoise) then nthresh=threshnoise else nthresh=50.
	data[where(data gt (-1.*nthresh) and data lt nthresh)]=0.

endif

;DO LINE OF SIGHT CORRECTION.
if not keyword_set(nolos) then begin
	
;	if n_elements(losmap) eq 0 then begin
;		;Generate coordinate maps.
;		imgsz=size(data)
;		xcoord=rot(congrid(transpose(findgen(imgsz[1])),imgsz[1],imgsz[2]),90)
;		ycoord=rot(xcoord,-90)
;		rcoord=sqrt((xcoord-imgsz[1]/2.)^2.+(ycoord-imgsz[2]/2.)^2)
;
;		;Create 1st order LOS correction, using McAteer et al. 2005, (eqn. 1)
;		;Used to correct field strengths
;		limbmask=fltarr(imgsz[1], imgsz[2])
;		limbmask[wfinite]=1
;		loscor=(rcoord+1.)*limbmask
;		loscor=sin(acos(loscor/float(max(loscor))))
;		loscor=(1./loscor)*limbmask
;		if (where(finite(loscor) ne 1))[0] ne -1 then loscor[where(finite(loscor) ne 1)]=0

		;Use my cosine correction map since its the same correction! stupid!
		restore, smart_paths(/resmapp)+'mdi_px_area_map.sav'

;	endif else loscor=cosmap;loscor=losmap
	loscor=cosmap < 1./cos(89.8321*!dtor)
	
	data=data*loscor
	
endif

if not keyword_set(nolimb) then begin
	restore,smart_paths(/resmapp)+'mdi_limbmask_map.sav'
	data=data*limbmask
endif

return, data

end