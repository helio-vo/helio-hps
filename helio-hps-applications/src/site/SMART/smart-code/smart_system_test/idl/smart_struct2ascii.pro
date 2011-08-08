pro smart_struct2ascii, arstruct, extentstr, file=file, outfile=outfile, append=append, no_nl=no_nl, no_ext=no_ext

if n_elements(file) lt 1 then file=time2file(arstruct[0].time)
	

for j=0,n_elements(file)-1 do begin
	thisfile=file[j]
	if n_elements(arstruct) lt 1 then restore,thisfile
	
	wrpath=smart_paths(/log,/no_calib)
	;wrpath='~/science/data/issi_data/'
	
	if not keyword_set(outfile) then outfile=wrpath+'smart_meta_'+time2file(file2time(thisfile))+'.dat'
	
	if not keyword_set(append) then begin
		fsmid=string('ID',format='(A25)')
		fields=[fsmid, string(['Time','Class','Type','Xcen_px','Ycen_px','Xbarycen','Ybarycen', $
			'Hcx_asec','Hcy_asec','Hglon_deg','Hglat_deg','CarLon','CarLat', $
			'Area_Mmsq','Bflux_Mx','Bfluxp_Mx','Bfluxn_Mx','Bfluximb','DBfluxDt_Mx', $
			'Bmin_G','Bmax_G','Bmean_G'],format='(A13)')]
		if not keyword_set(no_nl) then begin
			nlfields=string(['Lnl_Mm','Lsg_Mm','MxGrad_GpMm','MeanGrad','MednGrad','Rval_Mx','WLsg_GpMm','R_Str','WLsg_Str'],format='(A13)')
			fields=[fields,nlfields]
		endif
		if not keyword_set(no_ext) then begin
			extfields=string(['HGlon_wdth','HGlat_wdth','RdegE','RdegW'],format='(A13)')
			fields=[fields,extfields]
		endif
		spawn,'echo "'+strjoin(fields,'')+'" > '+outfile
	endif
	
	nar=n_elements(arstruct)
	
	for i=0,nar-1 do begin
	
		formdata='(E13.5)'	
	
		thisar=arstruct[i]
		if not keyword_set(no_ext) then thisext=extentstr[i]
	
	;Naming
		;if strlen(thisar.smid) lt 3 then smid=thisar.smid else $ ;thisplotid?
		;	smid=string(strmid(thisar.smid,4,4)+'.'+strmid(thisar.smid,9,4)+'.'+(str_sep(thisar.smid,'.'))[2], form='(A25)')
		smid=string(thisar.smid, form='(A25)')
		class=thisar.class
		type=strjoin(thisar.type,'')
		time=time2file(file2time(thisfile))
	;Position Properties	
		xcen=string(thisar.xpos,form=formdata)
		ycen=string(thisar.ypos,form=formdata)
		xbary=string(thisar.xbary,form=formdata)
		ybary=string(thisar.ybary,form=formdata)
		hcenx=string(thisar.hclon,form=formdata)
		hceny=string(thisar.hclat,form=formdata)
		hglat=string(thisar.hglat,form=formdata)
		hglon=string(thisar.hglon,form=formdata)
		carlon=string(thisar.carlon,form=formdata)
		carlat=string(thisar.carlat,form=formdata)
	;Magnetic Properties
		area=string(thisar.area,form=formdata)
		flux=string(thisar.bflux*1d16,form=formdata)
		fluxp=string(thisar.bfluxpos*1d16,form=formdata)
		fluxn=string(thisar.bfluxneg*1d16,form=formdata)
		fluximb=string(abs(thisar.bfluxpos-thisar.bfluxneg)/thisar.bflux,form=formdata)
		fluxemg=string(thisar.bfluxemrg*1d16,form=formdata)
		bmin=string(thisar.bmin,form=formdata)
		bmax=string(thisar.bmax,form=formdata)
		bmean=string(thisar.meanval,form=formdata)
		
		thismeta=[smid, string([time,class,type,xcen,ycen,xbary,ybary, $
			hcenx,hceny,hglon,hglat,carlon,carlat, $
			area,flux,fluxp,fluxn,fluximb,fluxemg,bmin,bmax,bmean],form='(A13)')]

	;PIL Properties
	if not keyword_set(no_nl) then begin
		lnl=string((thisar.nlstr).lnl,form=formdata)
		lsg=string((thisar.nlstr).lsg,form=formdata)
		maxgrad=string((thisar.nlstr).gradmax,form=formdata)
		meangrad=string((thisar.nlstr).gradmean,form=formdata)
		mediangrad=string((thisar.nlstr).gradmedian,form=formdata)
		rval=string((thisar.nlstr).rval,form=formdata)
		wlsg=string((thisar.nlstr).wlsg,form=formdata)
		r_star=string((thisar.nlstr).r_star,form=formdata)
		wlsg_star=string((thisar.nlstr).wlsg_star,form=formdata)

		thisnlmeta=string([lnl,lsg,maxgrad,meangrad,mediangrad,rval,wlsg,r_star,wlsg_star],form='(A13)')
		thismeta=[thismeta,thisnlmeta]
	endif

	;Extent Properties
	if not keyword_set(no_ext) then begin
		hglonwd=string(thisext.HGLONWIDTH,form=formdata)
		hglatwd=string(thisext.HGLATWIDTH,form=formdata)
		rdeglone=string((thisext.RDEGLON)[0],form=formdata)
		rdeglonw=string((thisext.RDEGLON)[1],form=formdata)

		thisextmeta=string([hglonwd,hglatwd,rdeglone,rdeglonw],form='(A13)')
		thismeta=[thismeta,thisextmeta]
	endif

		spawn,'echo "'+strjoin(thismeta,'')+'" >> '+outfile ;wrpath+'smart_meta_'+time2file(file2time(thisfile))+'.dat'
	
	endfor
endfor

end