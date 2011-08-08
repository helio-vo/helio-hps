pro smart_disk_display, filelist=filelist, xwin=xwin

pathfits=smart_paths(/fits,/no_cal)
plotpath=smart_paths(/plot,/no_cal)

nfile=n_elements(filelist)

for i=0,nfile-1 do begin
	thisfile=filelist[i]
	thisfdate=time2file(file2time(thisfile))
	
	mreadfits,pathfits+'smart_mask_'+thisfdate+'.fits.gz',ind,mask
	fits2map,pathfits+'smart_mdimag_'+thisfdate+'.fits.gz',datamap
	restore,thisfile

	if not keyword_set(xwin) then setplot,'z'
	if not keyword_set(xwin) then device, set_resolution = [1500,1500]
	!p.background=255
	!p.color=0
	!p.charsize=1.8
	!p.thick=3
	!x.thick=3
	!y.thick=3

	smart_plot_detections, /catalog,position=[ 0.07, 0.05, 0.99, 0.97 ], grid=10, $
		arstruct=arstruct, datamap=datamap, mask=mask

	if not keyword_set(xwin) then zb_plot = tvrd()
	if not keyword_set(xwin) then wr_png, plotpath+'smart_'+time2file(file2time(thisfile))+'.png', zb_plot
	if not keyword_set(xwin) then setplot,'x'

endfor










end