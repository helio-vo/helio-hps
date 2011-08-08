;Find NL parameters for a calibrated MDI image map
;INPUT
;MAP = a calibrated MDI image map (ie. use FITS2MAP)
;DATA (opt)= the data array inside map 
;EXTRACTAR (opt)=[radius of square bounding box (even number), X-center of box, Y-center of box]
;MASKCOS (opt)= a cosine corrected map of the image. 1 near the center, larger values at the limbs.
;MASKAREA (opt)= the above map in units of Mm^2
;PLOT (opt)= set to plot a NL summary image
;PS (opt)= set to write a PS file (requires PLOT be set.)
;PATHPLOT (opt)= set for the PS output path
;
;OUTPUT
;NLVALS = a 1D array of B vals along the NL
;NLGRAD = a 1D array of gradB vals along the NL
;NLMASK = a mask the same dimensions of DATA with 1 along NL and 0 elsewhere.
;NLSTRUCT = a structure containing many NL characteristics
;nlstruct={nlmask:mask of NL, nlthin:thinned mask, nllength:length of NL, nlmaxgrad:Max gradient along NL, $
;	nlmaxb:Max B along NL, r_star:R* modified Schrijver, schrijver_r:Schrijver R Value, wlsg:WLSG - Non potentiality Guage}
;
;------------------------------------------------------------------->

pro smart_nlmagic, nlstruct, starthinned, shj_map, wlsg_nl, map=inmap, data=data, crop_ar=crop_ar, $
	ps=ps, png=png, plot=plot, pathplot=pathplot, id=id, time=time
	
if n_elements(data) lt 1 then img=inmap.data else img=data
if n_elements(inmap) eq 1 then time=inmap.time

;Crop the data.
datasz=size(img)

if keyword_set(crop_ar) then begin

	wn0x=where(total(img,2) ne 0)
	wn0y=where(total(img,1) ne 0)
	wx=[min(wn0x), max(wn0x)]
	wy=[min(wn0y), max(wn0y)]
	img=img[(wx[0]-21.) > 0.:(wx[1]+21.) < (datasz[1]-1.), wy[0]-21. > 0.:wy[1]+21. < (datasz[2]-1.)]
endif

if n_elements(plotpath) lt 1 then plotpath=smart_paths(/plotp,/no_calib)

if n_elements(id) lt 1 then id='00' else id=id[0]
if n_elements(time) lt 1 then time='000000_0000' else time=time2file(time[0])

if keyword_set(plot) then begin
if keyword_set(ps) then setplotenv,file=plotpath+'smart_'+time+'_nl_'+id+'.eps',/ps,xs=12,ys=8 else begin
	setplot,'z' ;window,xs=800,ys=600;
	device, set_resolution = [ 700, 700 ]
endelse
endif

imgsz=size(img)
blank=fltarr(imgsz[1],imgsz[2])

;Unit conversion.
mmppx=smart_mdipxarea(map, /mmppx)
cmppx=smart_mdipxarea(map, /cmppx)
mmsqrppx=smart_mdipxarea(map, /mmsqr)

;Restore Cosine correction
restore,smart_paths(/resmap, /no_calib)+'mdi_px_area_map.sav'
areacor=cosmap ;smart_px_area_map(/cos,/res)
;limit the mask to 86 degree correction
areacor=areacor < 1./cos(86.31*!dtor)

;Put map in Mm instead of arcsec
;map.dx=mmppx
;map.dy=mmppx

;Insert cropped image into map
;map.data=img
;map2index,map,index
;index2map,index,img,map

;For Shrijver-R Value
;---------------------------------------------------------------------->
schrijver_r=0d
;Threshold by 150 Mx/cm^2 = 150 G
shj_thresh=150.
;Dilate by 1.5 pixels
shj_dilate=1.5
;Gaussian dilate by FWHM 15 Mm
shj_fwhm=15./mmppx
;PIL mask
shj_nl=blank
shj_map=blank

;Detect NL
;Check to see if too small to do convol...
shj_img=img
shj_img[where(abs(img) lt shj_thresh)]=0
if imgsz[1] lt 45 or imgsz[2] lt 45 then goto,skipshrijver
shj_pos=blank
if (where(shj_img gt 0))[0] ne -1 then wpos=where(shj_img gt 0) else goto,skipshrijver
shj_pos[wpos]=1.
shj_pos=smart_grow(shj_pos,radius=shj_dilate)
shj_neg=blank
if (where(shj_img lt 0))[0] ne -1 then wneg=where(shj_img lt 0) else goto,skipshrijver
shj_neg[wneg]=1.
shj_neg=smart_grow(shj_neg,radius=shj_dilate)
if (where((shj_neg+shj_pos) gt 1))[0] ne -1 then wnl=where((shj_neg+shj_pos) gt 1) else goto,skipshrijver
shj_nl[wnl]=1.

;Gaussian Dilate
shj_map=smart_grow(shj_nl,/gaus,fwhm=shj_fwhm)

;Calculate R-Value (cos correction, units)
schrijver_r=total(shj_map*abs(shj_img)*areacor*cmppx)*1d ;in Mx

skipshrijver:

;Stil NEED TO READ FALCONER 1997 and the so and so 1977 paper to see fi this is right....
;For WLSG Value
;---------------------------------------------------------------------->
wlsg=0d
;Threshold transverse potential field!! by 150 Mx/cm^2 = 150 G
wlsg_thresh=150.
;Gradient Threshold 50 G/Mm
wlsg_grad=50

;The DERIV function performs numerical differentiation using 3-point, Lagrangian interpolation. 
wlsggrad=abs(deriv(shj_img))/mmppx ;in G/Mm
wlsg_nl=float(m_thin(shj_nl))
wlsg_nl[where(wlsg_nl*wlsggrad lt 50)]=0
wlsg=total(wlsg_nl*wlsggrad)*1d ;in G/Mm
lsg=total(wlsg_nl)*mmppx*1d ;in Mm
;get thinned NL mask
;where greater than 50 G/Mm
;need transverse potential field

;WLsg= sum of gradient over high gradient NL

;For NL mask (used for wlsg*, R* and Lnl*)
;---------------------------------------------------------------------->
;PIL length 
lnl=0d
;R*
r_star=0d
;WLSG*
wlsg_star=0d
;gradient values
gradmax=0d
gradmean=0d
gradmedian=0d
;PIL mask
starnl=blank
rstarmask=blank
stargrad=blank
starthinned=blank

starthresh=70.
stardilate=1.5

starimg=img
starimg[where(abs(img) lt starthresh)]=0
starpos=blank
if (where(starimg gt 0))[0] ne -1 then wpos=where(starimg gt 0) else goto,skipstar
starpos[wpos]=1.
starpos=smart_grow(starpos,radius=stardilate)
starneg=blank
if (where(starimg lt 0))[0] ne -1 then wneg=where(starimg lt 0) else goto,skipstar
starneg[wneg]=1.
starneg=smart_grow(starneg,radius=stardilate)
if (where((starneg+starpos) gt 1))[0] ne -1 then wnl=where((starneg+starpos) gt 1) else goto,skipstar
starnl[wnl]=1.

;R*
;Do same steps as above but for lower threshold.
rstarmask=smart_grow(starnl,/gaus,fwhm=shj_fwhm)
r_star=total(rstarmask*abs(starimg)*areacor*cmppx)*1d ;in Mx

;Lnl
;total the thinned NL mask
starthinned=float(m_thin(starnl))
;Limit the PIL to segments 
lnl=total(starthinned)*mmppx*1d

;WLsg*
;total the WLSG thinned NL mask
stargrad=abs(deriv(starimg))/mmppx
wlsg_star=total(stargrad*starthinned)*1d

gradvals=(stargrad*starthinned)[where(starthinned gt 0)]
gradmax=max(gradvals)*1d
gradmedian=median(gradvals)*1d
gradmean=mean(gradvals)*1d

skipstar:

nlstr={lnl:lnl, lsg:lsg, gradmax:gradmax, gradmean:gradmean, gradmedian:gradmedian, $
	rval:schrijver_r, wlsg:wlsg, r_star:r_star, wlsg_star:wlsg_star}
nlstruct=nlstr

if keyword_set(plot) then begin
	if keyword_set(png) and not keyword_set(ps) then begin 
		!p.background=255
		!p.color=0
		!x.thick=3
		!y.thick=3
		!p.thick=3
		c_thick=3
		!p.charsize=1.8
		charsize=1.8
		!p.charthick=3
	endif
	
	loadct,0,/silent
	
	;Image scaling.
	imgmin=-1000.
	imgmax=1000.
	plotimg=img > imgmin < imgmax
	
	;Fudge colorbar so min max values don't appear wierd colors.
	plotimg[0]=max(plotimg)+(abs(imgmax)+abs(imgmin))*14./256.
	plotimg[1]=plotimg[0]*(-1.)
	
	;Plot the image.
	plot_image,plotimg,origin=[-imgsz[1]/2.*mmppx,-imgsz[2]/2.*mmppx],scale=[mmppx,mmppx],title=id+'_'+time,xtit='[Mm]',ytit='[Mm]'
	setcolors,/sys,/silent
	;setplot,'ps'
	;setcolors,/sys,/silent
	;setplot,'z'
	cx=(findgen(imgsz[1])-imgsz[1]/2.)*mmppx
	cy=(findgen(imgsz[2])-imgsz[2]/2.)*mmppx
	contour,shj_map,cx,cy,level=[.01,.04,.05,.06],/over,color=!magenta
	contour,starthinned,cx,cy,level=.5,color=!red,/over,/fill
	contour,wlsg_nl,cx,cy,level=.5,color=!green,/over,/fill
	
	err=''
	if keyword_set(png) and not keyword_set(ps) then begin 
		;window_capture,file=plotpath+'smart_'+time+'_nl_'+id+'.png',/png
		nlimg=tvrd()
		wr_png, plotpath+'smart_'+time+'_nl_'+id+'.png', nlimg
	endif
	if keyword_set(ps) then closeplotenv
	if keyword_set(ps) and keyword_set(png) then eps2png, plotpath+'smart_'+time+'_nl_'+id+'.eps', plotpath+'smart_'+time+'_nl_'+id+'.png', resolution=100, err=err
endif

;if err[0] ne '' then spawn,'echo "'+err[0]+'" >> ~/Sites/phiggins/smart_logs/smart_nl_png_crash.txt'

return



;OLD STUFF!!!!!!!
;---------------------------------------------------------------------------------->

;Create Masks
posmask=fltarr(imgsz[1],imgsz[2])
wpos=where(img gt 0)
if wpos[0] ne -1 then posmask[wpos]=1
wneg=where(img lt 0)
negmask=fltarr(imgsz[1],imgsz[2])
if wneg[0] ne -1 then negmask[wneg]=1

;Grow Masks
posmask=smart_grow(posmask, radius=growmask)
negmask=smart_grow(negmask, radius=growmask)

;Find Overlap
wnl=where(abs(posmask+negmask) eq 2)
nlmask=fltarr(imgsz[1],imgsz[2])
if wnl[0] ne -1 then nlmask[wnl]=1

;Find NL values
gradb=abs(deriv(img))/mmppx ;in Gauss/Mm
;wltgrad=where(gradb lt mingrad)
;gradb[wltgrad]=0d
;nlmask[wltgrad]=0d
wnlmask=where(nlmask ne 0)
if wnlmask[0] ne -1 then nlgradb=gradb[wnlmask]*1d else nlgradb=0d ;in Gauss/Mm
if wnlmask[0] ne -1 then nlbval=img[wnlmask]*1d else nlbval=0d ;in Gauss

;Thin NL to single pixel width
nlthin=float(m_thin(nlmask))

;Approximate length
lengthnl=total(nlthin)*mmppx*1d ;in Mm

;B Values along NL
if wnl[0] ne -1 then nlvals=img[wnl]*1d else nlvals=0d ;in Gauss

;Max, mean Gradient
nlmaxgrad=max(nlgradb) ;in Gauss/Mm
nlmeangrad=mean(nlgradb) ;in Gauss/Mm

;Max, mean B Value
nlmaxb=max(nlbval) ;in Gauss
nlmeanb=mean(nlbval) ;in Gauss

;Calculate Schrijver R-Value
nlrmask=smart_grow(nlmask, /gaus, fwhm=blurrad)
schrijver_map=abs(img)*maskarea*nlrmask ;in Gauss
schrijver_r=total(schrijver_map)*1d ;in Gauss*Mm^2

;Calculate R*-Value
rstarplus=total(abs(img > 0.)*maskarea*nlrmask)*1d ;in Gauss*Mm^2
rstarneg=total(abs(img < 0.)*maskarea*nlrmask)*1d ;in Gauss*Mm^2
rstar=(rstarplus < rstarneg)*2.

;Calculate WLSG
;wlsg=total(nlgradb*maskarea)*1d ;in Gauss/Mm*Mm^2 = Gauss*Mm
wlsg=total(gradb*nlthin*mmppx) ;in Gauss

nlstruct={nlmask:fix(round(nlmask)), nlthin:fix(round(nlthin)), nllength:lengthnl, nlmaxgrad:nlmaxgrad, $
	nlmaxb:nlmaxb, nlmeangrad:nlmeangrad, nlmeanb:nlmeanb, schrijver_r:schrijver_r, wlsg:wlsg, rstar:rstar}

;Find bounds of mask
wx=where(total(nlmask,2) ne 0)
wy=where(total(nlmask,1) ne 0)
if wx[0] ne -1 and wy[0] ne -1 then begin
	xbound=minmax(wx)
	ybound=minmax(wy)
	xbound[0]=xbound[0]-20 > 0 & xbound[1]=xbound[1]+20 <  imgsz[1]-1
	ybound[0]=ybound[0]-20 > 0 & ybound[1]=ybound[1]+20 <  imgsz[2]-1
endif else begin & xbound=[0,imgsz[1]-1] & ybound=[0,imgsz[2]-1] & endelse

;window,1,xs=1000, ys=1000
;!p.multi=[0,2,2]
;plot_image,img[xbound[0]:xbound[1],ybound[0]:ybound[1]] > (-1) < 1, charsize=2, title='Tri-nary Region Map'
;plot_image,nlmask[xbound[0]:xbound[1],ybound[0]:ybound[1]], charsize=2, title='Neutral Line Mask'
;plot_image,nlthin[xbound[0]:xbound[1],ybound[0]:ybound[1]], charsize=2, title='Thinned Neutral Line Mask'
;plot_image,nlrmask[xbound[0]:xbound[1],ybound[0]:ybound[1]], charsize=2, title='Schrijver R-Map'
;window_capture,file='~/science/plots/neutral_lines_20090618/'+strtrim(long(wlsg),2), /png

;DO PLOTTING ----------->

if keyword_set(plot) then begin

;Put everything in a map.
mapmask=map
mapmask.data=nlmask

mapgrad=map
gdata=nlgradb ;Gauss per Mm
gdata[where(gdata eq 0)]=max(gdata)
mapgrad.data=gdata

mapschrijver=map
schrijverdata=schrijver_map
schrijverdata[where(schrijverdata eq 0)]=max(schrijverdata)
mapschrijver.data=schrijverdata

!p.multi=[0,3,1]
!p.background=254
!p.color=0
!p.thick=2
!p.charsize=2
cbsz=1.4
if keyword_set(ps) then begin
	!p.thick=10
	!p.charsize=4
	cbsz=3
endif
loadct,0

plot_map,map,title=(str_sep(map.time,' '))[0]+' MDI LOS Mag [G]', xtitle='Mm', ytitle='Mm', dmax=300, dmin=-300
if keyword_set(ps) then COLOR_BAR, map.data, .34, .35, .1, .95,/norm,chars=cbsz else COLOR_BAR, map.data, 10, 240, 315, 40,chars=cbsz
setcolors,/sys
if (where(mapmask.data))[0] ne -1 then plot_map,mapmask,level=.5,/over,color=!red

loadct,5

if (where(mapmask.data))[0] eq -1 then begin
	gdata=(mapgrad.data)
	gdata[0,0]=1
	mapgrad.data=gdata
endif
plot_map,mapgrad, title='LOS B Field Gradient [G/Mm]', xtitle='Mm', ytitle='   '
if keyword_set(ps) then COLOR_BAR, mapgrad.data, .67, .68, .1, .95,/norm,chars=cbsz else COLOR_BAR, mapgrad.data, 10, 240, 615, 40,chars=cbsz
setcolors,/sys
if (where(mapmask.data))[0] ne -1 then plot_map,mapmask,level=.5,/over,color=!black

loadct,0
wn0=where(nlmask*gradb*mmppx ne 0)
if wn0[0] eq -1 then wn0=[0,1]
plot_hist, (nlmask*gradb*mmppx)[wn0], xtit='Neutral Line Gradient Values [G/Mm]', ytit='# of Pixels',tit='Neutral Line Values Distribution',chars=4

if keyword_set(ps) then closeplotenv

;plot_image,data <100 >(-100)
;setcolors,/sys
;contour,nlmask,levels=.5,/over,color=!red,thick=3

endif

return

end