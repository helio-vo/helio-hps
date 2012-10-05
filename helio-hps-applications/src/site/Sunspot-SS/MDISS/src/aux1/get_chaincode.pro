pro get_chaincode, image, ccode=ccode, $
	code_locations=code_locations, imc=imc, $
	ad=ad

locs=where(image ne 0)

in=size(image)
nx=in(1) & ny=in(2)

if n_elements(locs) eq 1 then begin
	ccode=lonarr(2,1)
	ccode(0, *)=locs(0) mod nx
	ccode(1, *)=locs(0) / nx
	return
end

xp=locs mod nx
yp=locs / nx

; ****  find seed
ind=where(yp eq min(yp))

ind2=where(xp(ind) eq min(xp(ind)))

xs=xp(ind(max(ind2)))
ys=yp(ind(max(ind2)))

ccx=xs
ccy=ys

nmax=n_elements(locs)

count=0
flag=0

dir=3

; *** directions array

connect=8
ardir=intarr(8, 2)

ardir(0, *)=[1, 0]
ardir(1, *)=[1, 1]
ardir(2, *)=[0, 1]
ardir(3, *)=[-1, 1]
ardir(4, *)=[-1, 0]
ardir(5, *)=[-1, -1]
ardir(6, *)=[0, -1]
ardir(7, *)=[1, -1]

;HFC chain code convention
ardir=-ardir

ad=dir
while count lt 3*nmax and flag eq 0 do begin
		;ii=0

		if ((dir mod 2) eq 0) then $
			sstart=(dir+6) mod connect else $
			sstart=(dir+7) mod connect
		for ii=0, connect-1 do begin
		;	print, sstart, image(xs+ardir(sstart, 0), $
		;		ys+ardir(sstart, 1))
			ixs = xs+ardir(sstart, 0) & iys = ys+ardir(sstart, 1)
			if (ixs lt 0) or (ixs gt nx-1) $
				or (iys lt 0) or (iys gt ny-1) then begin
					ad = ''
					return
			endif
			if image(ixs,iys) ne 0 then break $
			  else sstart=(sstart+1) mod connect
		end
		if ii eq connect then stop

		ad=[ad, sstart]
		dir=sstart
		xs=xs+ardir(sstart, 0)
		ys=ys+ardir(sstart, 1)
		count++

		ccx=[ccx, xs]
		ccy=[ccy, ys]

		if count  gt 1 then $
			if (ccx[count] eq ccx[1]) and (ccy[count] eq ccy[1]) $
			  and (ccx[count-1] eq ccx[0]) and (ccy[count-1] eq ccy[0]) $
			  then flag = 1

endwhile

ccode=lonarr(2, count-1)
ccode(0, *)=ccx(0:count-2)
ccode(1, *)=ccy(0:count-2)


ad = ad[1:count-1]
;	help, ccx, ccy,flag
;	tvframe, image, /bar
;	oplot, ccode(0, *), ccode(1, *), col=100, th=2

;stop

end