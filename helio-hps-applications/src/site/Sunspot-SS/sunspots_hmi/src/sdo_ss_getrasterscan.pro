;+
; NAME:
;		sdo_ss_getrasterscan
;
; PURPOSE:
; 		This routine generates the raster scan of the current detected sunspot.
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		SDOSS
;
; CALLING SEQUENCE:
;		sdo_ss_getrasterscan, xx, nx, ny, locs, umbra
;
; INPUTS:
;		xx     - Bounding rectangle of the current sunspot
;			     [xmin,ymin,xmax,ymax].
;		nx     - Number of pixels along X axis in image.
;		ny     - Number of pixels along Y axis in image.
;		locs   - Pixels of the current sunspot.
;		umbra  - Pixels of the umbra of the current sunspot.
;	
; OPTIONAL INPUTS:
;		None.
;
; KEYWORD PARAMETERS:
;		None.
;
; OUTPUTS:
;		x - Raster scan of the current sunspot.	
;
; OPTIONAL OUTPUTS:
;		None.
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
;		image2raster
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by S.Zharkov (MSSL).
;
;		18-JUL-2011, X.Bonnin:	Added header.
;
;-

function sdo_ss_getrasterscan, xx, nx, ny, locs, umbra

 
x0=xx(0) & y0=xx(1) & x1=xx(2) & y1=xx(3)

dlt=5
nx0=x1-x0+1
ny0=y1-y0+1

nx1=nx0+2*dlt
ny1=ny0+2*dlt

imb=bytarr(nx, ny)
imb[locs]=1
if (umbra)[0] ne -1 then imb[locs[umbra]]=2

;stop
imc=imb[x0:x1, y0:y1]
imc1=imb[x0-dlt : x1+dlt, y0-dlt : y1+dlt]

x=image2raster(imc, code=code)

return, x

end