;INPUTS:
;INMAP1	=
;INMAP2	=
;IMGSZ	=
;OFFLIMB	=

;RETURNS:
;MASKSTRUC	=	{mask:maskstack, mapcos:areacor, maplos:loscor, mapdiff:mapdiff, mapcal:map2cor, xcoord:xcoord, ycoord:ycoord, rcoord:rcoord}

;OUTPUTS:
;MAPDIFF	=
;ERR		=

;-------------------------------------------------------------------------->

function smart_region_extract, inmap1, inmap2, imgsz, offlimb, mapdiff, err, map1=outmap1cor

err=''

map1=inmap1
map2=inmap2

blank=fltarr(imgsz[1],imgsz[2])
blankstruc={mask:blank, mapcos:blank, maplos:blank, mapdiff:blank, mapcal:blank, xcoord:blank, ycoord:blank, rcoord:blank}
maskstruc=blankstruc

;-------------------------------------------------->
;PATHS AND THRESHOLDS

restore,smart_paths(/calibp)

;Algorithm Tresholds
;limbthresh=.9
nthresh=smart_thresh(/tnoise) ;70.
;smthresh=smart_thresh(/tsmthnoise)
growmask=smart_thresh(/tgrowmsk) ;10.
;growar=smart_thresh(/tgrowar)
rsmooth=smart_thresh(/trsmooth) ;5.

;AR Candidate Thresholds
;kurtthresh=smart_thresh(/tkurt)
fluxthresh=smart_thresh(/tflux) ;1d5
tpnfract=smart_thresh(/tpnfract) ;.9
;tplage=smart_thresh(/tplage)

;-------------------------------------------------->



;Extract map times.
anytim1=anytim(map1.time)
anytim2=anytim(map2.time)

time=map2.time
map1d=map1.data
map2d=map2.data

;CORRECTION MAPS
;------------------------------------------------>
;Create limb mask
restore,smart_paths(/resmapp)+'mdi_limbmask_map.sav'

;Generate coordinate maps.
xyrcoord, imgsz, xcoord, ycoord, rcoord

maskstruc.xcoord=xcoord & maskstruc.ycoord=ycoord & maskstruc.rcoord=rcoord

;Create 1st order COS area correction map
;Used to correct pixel areas.
;Multiply the AR masks by this when summing to get area.

restore,smart_paths(/resmap)+'mdi_px_area_map.sav'
areacor=cosmap ;smart_px_area_map(/cos,/res)
;limit the mask to 89 degree correction
areacor=areacor < 1./cos(86.32*!dtor)

;Create 1st order LOS correction, using McAteer et al. 2005, (eqn. 1)
;Used to correct field strengths
;loscor=(rcoord+1.)*limbmask
;loscor=sin(acos(loscor/float(max(loscor))))
;loscor=(1./loscor)*limbmask
;if (where(finite(loscor) ne 1))[0] ne -1 then loscor[where(finite(loscor) ne 1)]=0
loscor=areacor

maskstruc.maplos=loscor & maskstruc.mapcos=areacor

;FOR CALIBRATED MAG AND DIFFERENCE MAP (No smoothing)
;------------------------------------------------>
;Get rid of the non-finite data.
map1d=smart_mdimagprep( map1d,  /nosmooth,/nonoise,/nolos,/nolimb)
map2d=smart_mdimagprep( map2d,  /nosmooth,/nonoise,/nolos,/nolimb)

;Clip Limb
map1d=map1d*limbmask
map2d=map2d*limbmask

;Get rid of low level noise.
map1d[where(map1d gt (-1.*nthresh) and map1d lt nthresh)]=0.
map2d[where(map2d gt (-1.*nthresh) and map2d lt nthresh)]=0.

;LOS Correct the thresholded images
map1cor=map1d*loscor
map2cor=map2d*loscor

;Differentially rotate the first map into the second.
map1_d=map1
map1_d.data=map1cor
map1_d=drot_map(map1_d,anytim2-anytim1,/seconds,/keep_center)
map1cor=map1_d.data

;Create difference map - shows flux emergence
mapdiff=(map2cor-map1cor)/float(anytim(map2.time)-anytim(map1.time)) ;Gauss / second

maskstruc.mapdiff=mapdiff & maskstruc.mapcal=map2cor
outmap1cor=map1cor

;FOR BINARY MASK MAKING (Smoothing, Thresh, Los)
;------------------------------------------------>
;Generate Smoothed -Thresh -LOS Data for binary maps
map1smth=smart_mdimagprep(map1.data, threshnoise=nthresh, nsmooth=rsmooth);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite
map2smth=smart_mdimagprep(map2.data, threshnoise=nthresh, nsmooth=rsmooth);, nosmooth=nosmooth, nonoise=nonoise, nolos=nolos, nofinite=nofinite

;Differentially rotate the first map into the second.
map1smthrot=map1
map1smthrot.data=map1smth
map1smthrot=drot_map(map1smthrot,anytim2-anytim1,/seconds,/keep_center)
map1smth=map1smthrot.data

;Create binary region masks
mask1=blank
mask2=blank
if (where(map1smth ne 0))[0] ne -1 then mask1[where(map1smth ne 0)]=1
if (where(map2smth ne 0))[0] ne -1 then mask2[where(map2smth ne 0)]=1
mask1=smart_cont_sep(mask1, contlevel=.5, areathresh=50.)
mask2=smart_cont_sep(mask2, contlevel=.5, areathresh=50.)
if (where(mask1 gt 0))[0] ne -1 then mask1[where(mask1 gt 0)]=1 
if (where(mask2 gt 0))[0] ne -1 then mask2[where(mask2 gt 0)]=1   

;Grow masks
mask1gr=smart_grow(mask1, radius=growmask)
mask2gr=smart_grow(mask2, radius=growmask)

;Difference masks and find constant pixels
diffmask=abs(mask2gr-mask1gr)

;Clear transient pixels from final mask
maskar=mask2
wnotar=where(diffmask ne 0)
if wnotar[0] ne -1 then maskar[wnotar]=0

;Grow final mask
maskar=smart_grow(maskar, radius=growmask)

;Limb clip the final mask.
maskar=maskar*limbmask

;Contour to separate out the separate detections
maskstack=smart_cont_sep(maskar, contlevel=.5, vthresh=2., areathresh=2.)

if total(maskstack) eq 0 then begin & err=-1 & return,maskstruc & endif

;maskstruc={mask:maskstack, mapcos:areacor, maplos:loscor, mapdiff:mapdiff, mapcal:map2cor, xcoord:xcoord, ycoord:ycoord, rcoord:rcoord}
maskstruc.mask=maskstack

return,maskstruc

end