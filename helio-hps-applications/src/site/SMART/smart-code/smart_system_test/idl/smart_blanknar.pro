function smart_blanknar, flare=flare, arstr=arstr, sfflare=sfflare, nlstr=nlstr, extentstr=extentstr, strfile=strfile,blank=blank

;NOAA
noaastr={time:0L,day:0,noaa:0,location:intarr(2),longitude:0,area:0,st$macintosh:byte(intarr(3)),long_ext:intarr(2),num_spots:intarr(2),st$mag_type:byte(intarr(16)),spare:byte(intarr(9))}
str=noaastr
;srs_str={name:'', loc:'', mtwil:'', mcint:'', area:0, lonlen:0, nspots:0, mu:0D, cor_area:0D}

;Polarity separation line
strnl={lnl:0d, lsg:0d, gradmax:0d, gradmean:0d, gradmedian:0d, $
	rval:0d, wlsg:0d, r_star:0d, wlsg_star:0d}
if keyword_set(nlstr) then str=strnl

;Defines Feature's Extent (NSEW & ~Sun center to edge)
exstr={xylon:[0D,0D],xylat:[0D,0D],rdeglon:[0D,0D],rdeglat:[0D,0D],hglon:[0D,0D],hglat:[0D,0D],xymean10lon:[0D,0D],xymean10lat:[0D,0D],hglonwidth:0D,hglatwidth:0D}
if keyword_set(extentstr) then str=exstr

;SEC Event Listing
if keyword_Set(flare) then str={eventnum:0L, start_time:'', max_time:'', end_time:'', satellite:'', q:'', type:'', freq:'', fclass:'', fbase:0., flux:0., p1:0., region:'', hglat:1000, hglon:1000}

;SMART AR Structure
if keyword_Set(arstr) then str={smid:'', id:'', class:'', type:['','',''], time:'', $
	hglon:10000D, hglat:10000D, hclon:10000D, hclat:10000D, carlon:10000D, carlat:10000D, $
	xpos:0D, ypos:0D, xbary:0D, ybary:0D, meanval:0D, stddv:0D, kurt:0D, narpx:0D, $
	bflux:0D, bfluxpos:0D, bfluxneg:0D, bfluxemrg:0D, area:0D, bmin:0D, bmax:0D, $
	chaincode:'',cc_len:0D,cc_px:[-9999,-9999],cc_arc:[-9999.,-9999.],$
	exstr:exstr,nlstr:strnl, noaa:noaastr} ;r_star:0D, wlsg_star:0D, schrijver_r:0D, wlsg:0D, nl_sg:0D, nl_length:0D, 

;Sam Freeland Flares
if keyword_set(sfflare) then str={date_obs:'',ename:'',class:'',fstart:'',fstop:'',fpeak:'',xcen:0,ycen:0,helio:'',lfiles:'',recok:0,url_index:'',url_movie:''}

;SMART MDI files used info
if keyword_set(strfile) then str={run_date:'',mdi_filename:'',mdi_solarm:'',date_obs:'',mdi_filename_t:'',mdi_solarm_t:'',date_obs_t:''}

return, str

end