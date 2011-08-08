pro smart_add_properties, infilelist, nl_prop=nl_prop, extent_prop=extent_prop, fractal_prop=fractal_prop, $
	turbulence_prop=turbulence_prop, noaa_prop=noaa_prop, _extra=_extra
	
filelist=infilelist

if keyword_set(extent_prop) then begin
	restore,smart_paths(/resmap,/no_calib)+'mdi_rorsun_map.sav'
	rsundeg=asin(rorsun)/!dtor
endif

nfile=n_elements(filelist)
for i=0l,nfile-1l do begin

	;spawn,'gunzip -f '+filelist[i]
	restore,filelist[i];strjoin((str_sep(filelist[i],'.'))[0l:1l],'.')
	if n_elements(mdimap) lt 1 then begin
		fitsfile=(str_sep(strjoin(reverse((reverse(str_sep(filelist[i],'_')))[0:1]),'_'),'.'))[0]
		fits2map,smart_paths(/fits,/no_cal)+'smart_mask_'+fitsfile+'.fits.gz',mdimap
		mreadfits,smart_paths(/fits,/no_cal)+'smart_mask_'+fitsfile+'.fits.gz',dummy,armask
	endif

	if keyword_set(extent_prop) then begin
	;Do extent stuff for each AR
		extentstr=smart_blanknar(/extentstr)
		extentstr=replicate(extentstr,n_elements(arstruct))
	endif
	
	for j=0l,n_elements(arstruct)-1l do begin
	
		if keyword_set(nl_prop) then begin
		;Do nl stuff for each AR
			thisar=arstruct[j]
		if (thisar.type)[0] ne 'M' then goto,skipar
			data=mdimap.data
			data[where(armask ne j+1)]=0
			nltime=mdimap.time
			nlid=thisar.id
			datacr=smart_crop_ar(mdimap.data, armask, nlid,/zero);, arstruct=arstrflr[i]
			smart_nlmagic, nlstr, data=datacr, $
				id=nlid, time=nltime, _extra=_extra; plot=plot, png=png, ps=ps, plot=plot, pathplot=pathplot,
		
			thisar.nlstr=nlstr
			arstruct[j]=thisar
		skipar:
		endif
		
		if keyword_set(extent_prop) then begin
		;Do extent stuff for each AR
                        thisar=arstruct[j]
			nlid=thisar.id
			data=mdimap.data
			data[where(armask ne j+1)]=0
			thisextstr=smart_arextent(data, rsundeg=rsundeg, dx=mdimap.dx,dy=mdimap.dy,date=mdimap.time)
			extentstr[j]=thisextstr
			arstruct[j].exstr=thisextstr
		endif
		
		if keyword_set(entropy_prop) then begin
		;Do information entropy stuff for each AR
		
			;use entropy_func
			;crop ar
			;divide by 100 and 1000 and round() and fix()
			;call entropy_func
		
		endif
		
		;Do fractal stuff
			
		;Do turbulence stuff
		
		;Do coronal temperature stuff?
		
		;Do sunspot area and number and such stuff?
	
	endfor

	if keyword_set(noaa_prop) then begin
	;DO NOAA Regions
		;noaastr_daily=smart_blanknar()
		noaatime=mdimap.time
		indate=time2file(noaatime,/date)
		noaastr=smart_rdnar(indate)
		noaastr_daily=noaastr
	endif

	save,arstruct, extentstr, noaastr_daily, armask,s_f, file=filelist[i],/compress;, mdimap, mapdiff, armask ;strjoin((str_sep(filelist[i],'.'))[0l:1l],'.') ;filelist[i]
;	spawn,'gzip -f '+strjoin((str_sep(filelist[i],'.'))[0l:1l],'.')

endfor



end
