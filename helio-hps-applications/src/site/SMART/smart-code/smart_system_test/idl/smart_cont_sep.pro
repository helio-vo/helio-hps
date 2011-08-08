;DATA = array to be contoured
;CONTLEVEL = value to contour at
;VTHRESH = minimum number of vertices for a given contour
;AREATHRESH = minimum number of pixels contained in a given contour
;
;Returns a mask of the same dimensions as DATA. 

function smart_cont_sep, indata, contlevel=contlevel, vthresh=vthresh, areathresh=areathresh

data=indata
imgsz=size(data)
blank=fltarr(imgsz[1],imgsz[2])
mask=blank

if not keyword_set(contlevel) then contlevel=.5
if not keyword_set(vthresh) then vthresh=2 ;10
if not keyword_set(areathresh) then areathresh=0 ;10

contour,data,findgen(imgsz[1]),findgen(imgsz[2]),level=contlevel,path_info=path_info,/path_data_coords,path_xy=path_xy

if n_elements(path_info) gt 0 then begin 
	
	;Get rid of noise pixels.
	;pixmask=fltarr(imgsz[1],imgsz[2])
	wgoodcont=where(path_info.n gt vthresh)
	if wgoodcont[0] eq -1 then return, blank else infos=path_info[wgoodcont]
	ninfos=n_elements(infos)
	
	;Reverse sort by size...blah
	;infos=[reverse(sort(infos.high_low))]
	;infos=infos[reverse(findgen(n_elements(infos)))]
	
	maskval=0
	for j=0,ninfos-1 do begin
		info1=infos[j]
		xx=path_xy[0,info1.offset:info1.offset+info1.n-1]
		yy=path_xy[1,info1.offset:info1.offset+info1.n-1]
		poly1=polyfillv(xx,yy,imgsz[1],imgsz[2])
		;;if n_elements(poly1) le 1 then pixmask[poly1]=1
		;if n_elements(poly1) le areathresh then datacont[reform(path_xy[0,*]+path_xy[1,*]*imgsz[1])]=3

		if n_elements(poly1) gt areathresh then begin 
			if info1.HIGH_LOW eq 1 then begin
				maskval=maskval+1 & mask[poly1]=mask[poly1]+maskval 
			endif else begin
				holeval=mask[poly1[n_elements(poly1)/2.]]*(-1.)
				mask[poly1]=mask[poly1]+holeval
			endelse
		endif
;	tvscl,rebin(mask,512,512)
;	print,n_elements(poly1),' vs ',areathresh
	endfor

endif else return,fltarr(imgsz[1],imgsz[2])

;Compensate for weird 1px shift down and left
mask=shift(mask,1,1)

return,mask
		
end


	
;	;wnoise=where(pixmask eq 1)
;	;if wnoise[0] ne -1 then datacont[wnoise]=3
;	datacont=datacont*limbmask
;
;	wpen=where(datacont eq 2)
;	wum=where(datacont eq 1)
;	
;	;Count sun spots.
;	thisnsunspots=0.
;	spotinfos=path_info
;	for j=0,n_elements(spotinfos)-1 do begin
;		info1=spotinfos[j]
;		xx=path_xy[0,info1.offset:info1.offset+info1.n-1]
;		yy=path_xy[1,info1.offset:info1.offset+info1.n-1]
;		poly1=polyfillv(xx,yy,imgsz[1],imgsz[2])
;		;if n_elements(poly1) le 1 then pixmask[poly1]=1
;		if n_elements(poly1) ge spotthresh then thisnsunspots=thisnsunspots+1.
;	endfor
;	
;endif else 
;		
;end