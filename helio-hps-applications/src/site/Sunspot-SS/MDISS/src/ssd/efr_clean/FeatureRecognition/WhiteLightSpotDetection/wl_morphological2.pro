;========================================================================================

function WL_Morphological2, CleanedImage, xc, yc, R, $
				threshold=threshold, cent=cent, sbl=sbl, edges=edges, show=show

;	**********************************
;		 MORPHOLOGICAL METHOD
;	**********************************


; FUNCTION
;		from CleanedImage the regions with sunspots are found
;
;	INPUT
;			CleanedImage		white light 'flat' image
;			xc, yc, R			disk centre coordinates and radius
;
;	OUTPUT
;			binary2				binary image with ROI marked

info=size(CleanedImage)
nx=info[1]

	;	produce binary image
if not arg_present(cent) then $
	imeq= hist_equal(CleanedImage, percent=.1) $
		else imeq= hist_equal(CleanedImage, percent=cent)

;stop


if not keyword_set(sbl) then $
	edgemap=morph_gradient(imeq, replicate(1, 5, 5)) $

		else begin


			edgemap=bytscl(sobel(imeq))
	;		edgemap=bytscl(sobel(CleanedImage))

			if not keyword_set(threshold) then threshold=10
			binxxx=edgemap gt threshold

			count=0
			thrx=threshold

			tmp=label_region(median(edgemap gt thrx, 5))
			ncand=max(tmp)
			while ncand gt 100 and count lt 100 do begin
				thrx=thrx+1
				tmp=label_region(median(edgemap gt thrx, 5))
				ncand=max(tmp)
				count=count+1
			end

			print, 'Determined Threshold:', thrx
			binary=median(edgemap gt thrx, 5)

	;		binary=median(edgemap gt threshold, 5)

	;		stop
			if keyword_set(show) and keyword_set(sbl) then begin
				window, 15, xs=1024, ys=1024
				tvscl, binary
			end

			binary=RemLimbBinary(binary, xc, yc, R-1, nx)

		endelse

if not keyword_set(sbl) then begin
		if not keyword_set(threshold) then $
			binary= edgemap gt 100 $
				else binary= edgemap gt threshold
		binxxx=binary
		binary=RemLimbBinary(binary, xc, yc, R-1, nx)

		;	window, 13, xs=nx, ys=ny, title='Histogram Equalised and Morph Gradient'
		;	tvscl, binary


				re=5
				circe=shift(dist(2*re+1), re, re) le re
		;		binary=erode(binary, circe)

		; use watershed operator to fill the space within the edges

				wshbin=watershed(morph_close(binary, replicate(1, 4, 4)))
				wshbin2=watershed(morph_close(binary, replicate(1, 7, 7)))
				wshbin3=watershed(morph_close(binary, circe))
				l6=where(wshbin gt 1)
				l7=where(wshbin2 gt 1)
				l8=where(wshbin3 gt 1)
				binary2=binary
				if n_elements(l6) gt 1 then binary2[l6]=1b
				if n_elements(l7) gt 1 then binary2[l7]=1b
				if n_elements(l8) gt 1 then binary2[l8]=1b

				; filter out the smaller structures and fill the smaller holes in the image
				binary2=morph_close( median(binary2, 8), replicate(1, 3, 3))
				binary2=dilate(binary2, replicate(1, 2, 2))
		endif ;else binary2=dilate(morph_close(binary, replicate(1, 5, 5)), replicate(1, 2, 2))

;binx=binary2

if keyword_set(sbl) then begin
	temp= ((watershed(binary) gt 1) + binary) ge 1
	edges=sobel(temp)
end


;temporary stuff

im=cleanedimage
im2=cleanedimage
locs2=where(temp ne 0)
locs=where(edges ne 0)
im[locs]=max(im)
im2[locs2]=im2[locs2]/2


ex1=edges
N=5000
;for i0=0, N-1 do $
;	ex1[fix(xc+R*sin(i0*2*!pi/N)+.5), $
;		fix(yc+R*cos(i0*2*!pi/N)+.5)]=max(edges)
if keyword_set(show) and keyword_set(sbl) then begin


		window, 10, xs=1024, ys=1024
		tvscl, binxxx

		window, 11, xs=1024, ys=1024
		tvscl, im2

		window, 12, xs=1024, ys=1024
		tvscl, temp

		window, 13, xs=1024, ys=1024
		tvscl, ex1

stop
end

binary2=temp
return, binary2


end