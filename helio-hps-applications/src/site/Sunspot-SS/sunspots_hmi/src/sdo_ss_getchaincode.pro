;+
; NAME:
;		sdo_ss_getchaincode
;
; PURPOSE:
; 		This routine generates the chain code of the current detected sunspot.
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		SDOSS
;
; CALLING SEQUENCE:
;		sdo_ss_getchaincode, locs, xx, nx, ny, xc, yc, cdx, cdy
;
; INPUTS:
;		locs - Pixels of the current sunspot.
;		xx   - Bounding rectangle of the current sunspot
;			   [xmin,ymin,xmax,ymax].
;		nx   - Number of pixels along X axis in image.
;		ny   - Number of pixels along Y axis in image.
;		xc	 - X coordinate of the Sun center in pixel.
;		yc   - Y coordinate of the Sun center in pixel.
;		cdx  - Spatial scale along X axis (in arcsec/pix).
;		cdy  - Spatial scale along Y axis (in arcsec/pix).
;	
; OPTIONAL INPUTS:
;		None.
;
; KEYWORD PARAMETERS:
;		/CHECK	- Debug mode. 	
;
; OUTPUTS:
;		None.	
;
; OPTIONAL OUTPUTS:
;		code	- Coordinates of the sunspot contour in pixels
;		ad		- Scalar of string type containing the chain code.
;
; COMMON BLOCKS:		
;		None.
;	
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS/COMMENTS:
;		The SolarSoft Ware (SSW) with sdo, vso, and ontology packages must be installed.
;		SDOSS auxiliary IDL routines must be compiled.
;		An internet access is required to donwload SDO/HMI data.
;		
; CALL:
;		None.
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by S.Zharkov (MSSL).
;
;		18-JUL-2011, X.Bonnin:	Added ad optional output parameter.
;
;-

function sdo_ss_getchaincode, locs, xx, nx, ny, xc, yc, cdx, cdy, $
							  code=code, ad=ad, check=check


;self->getbndrct, x0, y0, x1, y1, arc=arc

x0=xx(0) & y0=xx(1) & x1=xx(2) & y1=xx(3)

dlt=5
nx0=x1-x0+1
ny0=y1-y0+1

nx1=nx0+2*dlt
ny1=ny0+2*dlt

imb=bytarr(nx, ny)
imb[locs]=1

imc=imb[x0:x1, y0:y1]
imc1=imb[x0-dlt : x1+dlt, y0-dlt : y1+dlt]

in=size(imc1)
nx0=in(1) & ny0=in(2)

imc=imc1 & imc(*)=0

imc2=congrid(imc1, nx0*2, ny0*2)

get_chaincode_temp, imc2, ccode=ccode, ad=ad

code = ccode

xp=ccode(0, *)/2.-dlt+x0
yp=ccode(1, *)/2.-dlt+y0


nl=n_elements(xp)
xy1=dblarr(2, nl)

xy1(0, *)=(xp-xc)*cdx;/2
xy1(1, *)=(yp-yc)*cdy;/2


if keyword_set(check) then begin
  tvframe, imc1, /bar, xr=[arc(0)-(dlt)*cdx, arc(2)+(dlt+1/2.)*cdx], $
    yr=[arc(1)-(dlt)*cdy, arc(3)+(dlt+1/2.)*cdy]
  oplot, xy1(0, *), xy1(1, *), col=100, th=2
  stop
endif
return, xy1

end