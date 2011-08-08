;---------------------------------------------------------------------->
;+
; PROJECT:  	SolarMonitor Active Region Tracking (SMART) System
;
; PROCEDURE:    SMART_ARG
;
; PURPOSE:    	Read in MDI full disc map and return SMART Active Region Logs.
;
; USEAGE:     	smart_arg, time='20090101'
;
; INPUT:        NONE
;
; KEYWORDS:   	
;				TIME		- Desired seed time for algorithm.
;
;				NMONTHS 	- Number of months of data to run algorithm for if using  
;							a seed time more than a month earlier than "today".
;
;				CALIB		- Set if using calibrated MDI data rather than planning 
;							data. 
;
;				LOCALMDI	- Set if using a local data directory.
;
;				GRIANLIVE	- Set if running on GRIAN. (Plot to Z buffer and change 
;							directory structure.)
;
; OUTPUT:    
;   	    	Daily Log files listing active regions and their physical parameters.
;   	    	
; EXAMPLE:    	;Run code from start date to present date using planning data stored 
;				;on SolarMonitor.org:
;				smart_arg, time='20090101'
;
;				;Create a PS plot for one day of calibrated data stored locally:
;				smart_arg,time='19990613',/calib,/local,nday=1,/ps
;
;				;Run a year of calibrated data downloaded from Stanford:
;				smart_arg, time='20080101',nmonth=12,/calib
;
;				;Running code on GRIAN for planning data downloaded from SOHO FTP:
;				smart_arg, time=time2file(systim(/utc),/date), /grian
;             
; AUTHOR:     	26-Feb-2009 P.A.Higgins - Written
;				18-Apr-2009 P.A.Higgins - Code runs locally and on Grian using both
;											calibrated and uncalibrated data.
;				17-Jun-2009 P.A.Higgins - Modularized AR extraction algorithm.
;										    included NL extraction, Schrijver R, and 
;										    Falconer WLSG calculation. Also replaced 
;										    cylindrical projection with 1st order cosine
;                                           pixel area correction.
; CONTACT:		pohuigin@gmail.com or peter.gallagher@tcd.ie
; VERSION   	0.1
;-
;---------------------------------------------------------------------->

function smart_thresh, tnoise=tnoise, tgrowmsk=tgrowmsk, $
	tflux=tflux, tpnfract=tpnfract, trsmooth=trsmooth, FRM_PARAMSET=FRM_PARAMSET ;$
;	tarmatch=tarmatch, tnoaamatch=tnoaamatch, 
  if running_gdl() then restore_command='cmrestore' else restore_command='restore'

restore_ex=execute(restore_command+',smart_paths(/calibp)')

retval=''

growmask=10.

;Thresholds for running the algorithm.
if keyword_set(tgrowmsk) then retval=growmask ;pixels to grow by
if keyword_set(trsmooth) then retval=5.;10 ;px radius to gaussian smooth image by

;Threshold for considering a candidate as noise.
if keyword_set(tflux) then retval=1d5 ;minimum Bflux (Gauss Mm^2) for AR candidate
if keyword_set(tpnfract) then retval=.9
												
;Thresholds for matching ARs in the history algorithm.
;if keyword_set(tarmatch) then retval=5 ;pixels away
;if keyword_set(tnoaamatch) then retval=5 ;pixels away

if keyword_set(tnoise) then retval=70. ;in gauss

;FOR HEK:
FRM_PARAMSET='tgrowmsk=10., trsmooth=5., tflux=1d5, tpnfract=.9, tnoise=70.'

return, retval

end

;---------------------------------------------------------------------->

pro smart_readmdi, map, carmap, file=file
print,'SMART_READMDI'
if running_gdl() then restore_command='cmrestore' else restore_command='restore'
restore_ex=execute(restore_command+',smart_paths(/calibp)')

;if calib eq 0 then mreadfits, file, index
;fits2map, file, map

mreadfits,file,index,data
smart_index2map,index,data,map

;Shift image to center.
map.data=shift(map.data,((-1.)*map.yc/map.dy),((-1.)*map.xc/map.dx))
map.xc=0
map.yc=0

;Rotate image.
roll=map.roll_angle
;if calib eq 0 then roll=(-1.)*index.crot else roll=map.roll_angle
map.data=rot(map.data,(-1.)*roll)
map.roll_angle=0.

add_prop,map,data=float(map.data),/replace

;Do a fudge calibration if using planning data.
if calib eq 0 then begin
	inplan=map.data
	smart_mdiplan2cal,inplan,outcal
	map.data=outcal
endif

end

;---------------------------------------------------------------------->

pro smart_findar, map1=inmap1, map2=inmap2
print,'SMART_FINDAR'

noregions=''
map1=inmap1
map2=inmap2
imgsz=size(map2.data)
blank=fltarr(imgsz[1],imgsz[2])
time=map2.time

;; filling file structure
s_f=smart_blanknar(/strfile)
s_f.run_date=anytim(systim(/utc),/ccsd)
s_f.mdi_filename=map2.datafile
s_f.mdi_solarm='smdi_fd_'+time2file(map2.date_obs)+'.fits.gz'
s_f.date_obs=map2.date_obs
s_f.mdi_filename_t=map1.datafile
s_f.mdi_solarm_t='smdi_fd_'+time2file(map1.date_obs)+'.fits.gz'
s_f.date_obs_t=map1.date_obs


;-------------------------------------------------->
;PATHS AND THRESHOLDS
if running_gdl() then restore_command='cmrestore' else restore_command='restore'
restore_ex=execute(restore_command+',smart_paths(/calibp)')

;Algorithm Tresholds
nthresh=smart_thresh(/tnoise)
;smthresh=smart_thresh(/tsmthnoise)
growmask=smart_thresh(/tgrowmsk)
;growar=smart_thresh(/tgrowar)
rsmooth=smart_thresh(/trsmooth)

;AR Candidate Thresholds
fluxthresh=smart_thresh(/tflux)
tpnfract=smart_thresh(/tpnfract)

logpath=smart_paths(/logp)
savpath=smart_paths(/savp)
plotpath=smart_paths(/plotp)

;-------------------------------------------------->

;Create NOAA structure for the day.
noaastr=smart_blanknar()
indate=time2file(time,/date)
;noaastr_daily=smart_rdnar(indate)
noaastr_daily=noaastr

;Generate coordinate maps.
dxdy=[map2.dx,map2.dy]

;Calculate the area of a pixel in Mm^2
pixarea=smart_mdipxarea(map2, /mmsqr) ;Mm^2

;-------------------------------------------------->
;Detect and measure the ARs
maskstruc=smart_region_extract(map1, map2, imgsz, offlimb, mapdiff, err, map1=map1cor)

;Zero the NANs in the maps.
outdata1=smart_mdimagprep(map1.data, /nosmooth,/nonoise,/nolos)
map1.data=outdata1
outdata2=smart_mdimagprep(map2.data, /nosmooth,/nonoise,/nolos)
map2.data=outdata2

;Extract Maps
xcoord=maskstruc.xcoord ;0 -> Nx pixels horizontally
ycoord=maskstruc.ycoord ;0 -> Ny pixels vertically
rcoord=maskstruc.rcoord ;0 in center, Npx from center every where else
cosmap=maskstruc.mapcos ;Area correction
losmap=maskstruc.maplos ;LOS correction
mapdiff=maskstruc.mapdiff ;Noise, LOS, non-finite corrected
mapcal=maskstruc.mapcal ;Noise, LOS, non-finite corrected
arstack=maskstruc.mask ;Mask with different detections having intg values

nar=max(arstack) ;number of detections
if nar eq 0 then nar=1

;Initialize structure array.
blankar=smart_blanknar(/arstr)
arstruct=REPLICATE(blankar, nar) 

;Initialize NL structure array.
blanknl=smart_blanknar(/nlstr, blank=blank)
nlstruct=blanknl;REPLICATE(blanknl, nar) 

if err eq -1 then begin & noregions=1 & goto,no_regions_visible & endif

nids=1
for k=0,nar-1 do begin
	thismask=arstack
	wnotstack=where(arstack ne k+1.)
	warstack=where(arstack eq k+1.)
	if wnotstack[0] ne -1 then thismask[wnotstack]=0.
	if warstack[0] ne -1 then thismask[warstack]=1.
	
; Create chain_code	
	chaincode=chaincode_creation(thismask,cc_px=cc_px,cc_arc=cc_arc,cc_len=cc_len)
	
;Use LOS corrected B values; COS() correct mask
	thisar=thismask*mapcal*1d ;in Gauss
	thismaskcos=thismask*cosmap*pixarea ;in Mm^2
	thisdiffar=thismask*mapdiff
	
;Uncalibrated AR values
	warc=where(thismask ne 0)
	if warc[0] ne -1 then arvals=(thismask*map2.data*1d)[warc] else arvals=[0.d,0.d] ;in Gauss

;Area of AR
	thisarea=total(thismaskcos) ;in Mm^2

;B Flux
	thisbfluxpos=total(abs(thisar > 0)*thismaskcos) ;in Gauss Mm^2
	thisbfluxneg=total(abs(thisar < 0)*thismaskcos) ;in Gauss Mm^2
	thisbflux=thisbfluxpos+thisbfluxneg ;in Gauss Mm^2
	;thisbfluxfrac=(thisbfluxpos < abs(thisbfluxneg))/(thisbfluxpos > abs(thisbfluxneg)) ;fraction
	if thisbflux eq 0 then thisbfluxfrac=0. else thisbfluxfrac=abs(thisbfluxpos-thisbfluxneg)/thisbflux
	
;B min, max
	thisbminval=min(thisar)
	thisbmaxval=max(thisar)

;Flux emergence
	;thisflxemrg=total(thisdiffar*thismaskcos) ;in Gauss Mm^2 / second
	thisar1=thismask*map1cor*1d
	thisflxemrg=(thisbflux-total(abs(thisar1)*thismaskcos))/float(anytim(map2.time)-anytim(map1.time))

;Find statistical moments of each AR candidate.
	thismean=mean(arvals)
	thisstd=stddev(arvals)
	thisabsmean=mean(abs(arvals))
	thisabsstd=stddev(abs(arvals))
	thiskurt=kurtosis(arvals)
	thisabskurt=kurtosis(abs(arvals))
	thisnarval=n_elements(arvals)*1d

;AR XY position in px
	;thisxpos=total(thismaskcos*xcoord)/total(thismaskcos)
	;thisypos=total(thismaskcos*ycoord)/total(thismaskcos)
	if total(thisar) ne 0 then thisxpos=total(abs(thisar)*thismaskcos*xcoord)/total(abs(thisar)*thismaskcos) else thisxpos=0
	if total(thisar) ne 0 then thisypos=total(abs(thisar)*thismaskcos*ycoord)/total(abs(thisar)*thismaskcos) else thisypos=0

;AR XY barycenter in px
	if total(thisar) ne 0 then thisxbary=total(thismaskcos*xcoord)/total(thismaskcos) else thisxbary=0
	if total(thisar) ne 0 then thisybary=total(thismaskcos*ycoord)/total(thismaskcos) else thisybary=0

;AR Solar X,Y position (Heliocentric) in asec
	if total(thisar) ne 0 then thishclon=(thisxpos-imgsz[1]/2.)*dxdy[0] else thishclon=0
	if total(thisar) ne 0 then thishclat=(thisypos-imgsz[2]/2.)*dxdy[1] else thishclat=0

;AR Carrington position in deg
	if total(thisar) ne 0 then begin
		thiscar=conv_a2c([thishclon,thishclat],map2.time)
		thiscarlon=thiscar[0]
		thiscarlat=thiscar[1]
	endif
	
;AR HG position in deg
	if total(thisar) ne 0 then begin
		thishg=conv_a2h([thishclon,thishclat],map2.time)
		thishglon=thishg[0]
		thishglat=thishg[1]
	endif else begin & thishglon=0 & thishglat=0 & endelse
	
	;thislat=hglat[thisxpos,thisypos]*1d else thislat=0
	;if total(thisar) ne 0 then thislon=hglon[thisxpos,thisypos]*1d else thislon=0

;Create an ID for each candidate that is expected to be an AR.
	thisid=string(k+1., format='(I02)')

;Perform classification algorithm.
;type -> [U/M,B/S,E/D] ;uni/multipolar, big/small, emerging/decaying
	thistype=['','','']

;Differentiate UNIPOLAR and MULTIPOLAR
	if thisbfluxfrac lt tpnfract[0] then thistype[0]='M' else thistype[0]='U'
;Differentiate BIG and SMALL
	if thisbflux ge fluxthresh then thistype[1]='B' else thistype[1]='S'
;Differentiate EMERGING and DECAYING
	if thisflxemrg gt 0 then thistype[2]='E' else thistype[2]='D'

case strjoin(thistype) of
	'MBE' : thisclass='AR'
	'MBD' : thisclass='AR'
	'UBE' : thisclass='PL'
	'UBD' : thisclass='PL'
	'MSE' : thisclass='BE'
	'MSD' : thisclass='BD'
	'USE' : thisclass='UE'
	'USD' : thisclass='UD'
endcase

;NL Characteristics, shrijver-R calculation, WLSG falconer value etc.
	if thistype[0] ne 'M' then thisnlstruct=blanknl else $
		thisnlstruct=blanknl;smart_nlmagic, map2, nlvals, nlmask, thisnlstruct, data=thisar, maskcos=cosmap, maskarea=cosmap*pixarea;, ps=ps, plot=plot
;!!!TEMP comment out nl finder.

;Fill AR property structure
;Naming
	arstruct[k].smid=thisid & arstruct[k].id=thisid & arstruct[k].class=thisclass
	arstruct[k].type=thistype
;Position
	arstruct[k].hglon=thishglon & arstruct[k].hglat=thishglat & arstruct[k].xpos=thisxpos 
	arstruct[k].ypos=thisypos & arstruct[k].xbary=thisxbary & arstruct[k].ybary=thisybary
	arstruct[k].hclon=thishclon & arstruct[k].hclat=thishclat & arstruct[k].carlon=thiscarlon
	arstruct[k].carlat=thiscarlat
;Statistical
	arstruct[k].meanval=thismean & arstruct[k].stddv=thisstd
	arstruct[k].kurt=thiskurt & arstruct[k].narpx=thisnarval
;Magnetic Properties
	arstruct[k].bflux=thisbflux & arstruct[k].bfluxpos=thisbfluxpos
	arstruct[k].bfluxneg=thisbfluxneg & arstruct[k].bfluxemrg=thisflxemrg
	arstruct[k].time=time & arstruct[k].area=thisarea & arstruct[k].bmin=thisbminval
	arstruct[k].bmax=thisbmaxval
;NOAA Structure
	arstruct[k].noaa=noaastr

;Polarity Separation Line	
	arstruct[k].nlstr=thisnlstruct
	
;Input chaincode properties
  arstruct[k].chaincode=chaincode
  arstruct[k].cc_len=cc_len
  arstruct[k].cc_px=cc_px
  arstruct[k].cc_arc=cc_arc

endfor

;Check for NO REGIONS
if (where(arstruct.id ne ''))[0] eq -1 then noregions=1 

;Deal with case of no regions on disk.
no_regions_visible:
if noregions eq 1 then begin
	arstruct=blankar
endif

mdimap=map2
mdimap.data=mapcal

;Try to decrease file size.
armask=fix(round(arstack))
mdimap.data=float(mdimap.data)
mapdiff=float(mapdiff)

spawn,'rm -f '+savpath+'smart_'+time2file(time)+'.sav*'
if running_gdl() then save_command='cmsave' else save_command='save'
save_ex=execute(save_command+', mdimap, mapdiff, armask, arstruct, noaastr_daily, s_f, file=savpath+"smart_"+time2file(time)+".sav"')

spawn,'echo "'+savpath+'smart_'+time2file(time)+'.sav" >> '+smart_paths(/logp,/no_calib)+logfile
if psplot eq 1 then begin
	setplot,'z'
	device, set_resolution = [1500,1500]
	!p.background=255
	!p.color=0
	!p.charsize=1.8
	!p.thick=3
	!x.thick=3
	!y.thick=3
	
	smart_plot_detections,savpath+'smart_'+time2file(time)+'.sav',/catalog,position=[ 0.07, 0.05, 0.99, 0.97 ]

	zb_plot = tvrd()
	wr_png, plotpath+'smart_'+time2file(time)+'.png', zb_plot
	setplot,'x'

;	smart_plot_detections,savpath+'smart_'+time2file(time)+'.sav',/catalog,/ps, $
;		outfile=plotpath+'smart_'+time2file(time)+'.eps'
;	eps2png,plotpath+'smart_'+time2file(time)+'.eps',plotpath+'smart_'+time2file(time)+'.png',resolution=100
endif; else smart_plot_detections,savpath+'smart_'+time2file(time)+'.sav',/catalog




return

end

;---------------------------------------------------------------------->

pro smart_extract_ar, filelist
print,'SMART_EXTRACT_AR'
if running_gdl() then restore_command='cmrestore' else restore_command='restore'
restore_ex=execute(restore_command+',smart_paths(/calibp)')

wgood=where(filelist ne '')
if wgood[0] eq -1 then return else filelist=filelist[wgood]
filelist=filelist[uniq(filelist)]
tlist=anytim(filelist)
slist=sort(tlist)
filelist=filelist[slist]
tlist=tlist[slist]
if n_elements(filelist) lt 2 then begin & filelist='' & return & endif

nfiles=n_elements(filelist)

print,'NUMBER OF FILES = '+strtrim(nfiles,2)

;Run through all MDI files and extract the AR positions and info.

localfile0=filelist[0l]

for i=1l,nfiles-1l do begin
	localfile1=filelist[i]

;Read in the images and perform some image manipulation.
	smart_readmdi, map1, file=localfile0
	smart_readmdi, map2, file=localfile1

;Do differencing and detect the first ARs
	smart_findar, map1=map1, map2=map2;, car1=car1, car2=car2

	localfile0=localfile1

endfor

return

end

;---------------------------------------------------------------------->

pro smart_server, filelist=filelist, logfile=logfile, debug=debug, winnum=winnum, $
	calib=calib, grianlive=grianlive, localmdi=localmdi, psplot=psplot, append=append, $
	FRM_PARAMSET=FRM_PARAMSET

runbegin=anytim(systim(/utc))
if keyword_set(debug) then print, 'starting time of the run: '+runbegin

if keyword_set(calib) then calib=1 else calib=0
if keyword_set(debug) then print, 'CALIB = '+ string(calib)
if keyword_set(grianlive) then grianlive=1 else grianlive=0
if keyword_set(debug) then print, 'Grian live = '+ string(grianlive)
if keyword_set(localmdi) then localmdi=1 else localmdi=0
if keyword_set(debug) then print, 'LocalMDI = '+string(localmdi)
if keyword_set(psplot) then psplot=1 else psplot=0
if keyword_set(debug) then print, 'PSPLOT = '+string(psplot)
if ~keyword_set(winnum) then winnum=0
if keyword_set(debug) then print, 'WinNUM = '+string(winnum)
;if keyword_set(logfile) then logfile=logfile else logfile='smart_log_'+time2file(systim(/utc))+'.dat'
if ~keyword_set(logfile) then logfile='smart_log_'+time2file(systim(/utc))+'.dat'
if keyword_set(debug) then print, 'logfile = '+logfile

if keyword_set(debug) then print, 'trying to read file using cmsave/save!'
if running_gdl() then save_command='cmsave' else save_command='save'
save_ex=execute(save_command+',calib,grianlive,localmdi,psplot,winnum,logfile,file=smart_paths(/calibp)')

if keyword_set(debug) then print,'save log file in: '+smart_paths(/calibp)

;stop 

;Initialize logfile if not already exist.
;if (file_search(smart_paths(/logp,/no_calib)+logfile))[0] eq '' 
if not keyword_set(append) then spawn,'echo "" > '+smart_paths(/logp,/no_calib)+logfile

	smart_extract_ar, filelist;, img, timend, time=time

if filelist[0] eq '' then print,'NO FILES FOUND'

dummy=smart_thresh(FRM_PARAMSET=FRM_PARAMSET)
FRM_PARAMSET='calib='+strtrim(calib,2)+', psplot='+strtrim(psplot,2)+', '+FRM_PARAMSET

; TODO: this rm is giving errors
spawn,'rm -f '+smart_paths(/calibp)

runtotal=(anytim(systim(/utc))-runbegin)/60.
print,'SMART RUN TIME: '+strtrim(runtotal,2)+' MINUTES.'

;spawn,'echo "SMART_ARG Code has completed'+strtrim(time,2)+' -> '+strtrim(timend,2)+'. Run time: '+strtrim(runtotal,2)+' MINUTES." | mail pohuigin@gmail.com'

end
