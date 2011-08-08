pro smart_sav2fits, filelist, wrpath,gzip=gzip

;write the smart_sav files to and fits files

for j=0,n_elements(filelist)-1 do begin
	
	thisfile=filelist[j]
	restore,thisfile
	
	;mdimap
	map2index,mdimap,index
	mdidata=mdimap.data

	mwritefits, index, mdidata, $
	outfile=wrpath+'smart_mdimag_'+time2file(file2time(thisfile))+'.fits', $
	/flat_fits
	
	mwritefits, index, armask, $
	outfile=wrpath+'smart_mask_'+time2file(file2time(thisfile))+'.fits', $
	/flat_fits

	mwritefits, index, mapdiff, $
	outfile=wrpath+'smart_diff_'+time2file(file2time(thisfile))+'.fits', $
	/flat_fits

	if keyword_set(gzip) then begin
		spawn,'gzip -f '+wrpath+'smart_mdimag_'+time2file(file2time(thisfile))+'.fits'
		spawn,'gzip -f '+wrpath+'smart_mask_'+time2file(file2time(thisfile))+'.fits'
		spawn,'gzip -f '+wrpath+'smart_diff_'+time2file(file2time(thisfile))+'.fits'
	endif

endfor

end