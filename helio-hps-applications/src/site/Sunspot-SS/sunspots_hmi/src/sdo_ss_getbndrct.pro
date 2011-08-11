;+
; NAME:
;		sdo_ss_getbndrct
;
; PURPOSE:
; 		Get coordinates of lower left and upper right corners 
;		of the feature bounding rectangle.
;
; CATEGORY:
;		Image processing
;
; GROUP:
;		SDOSS
;
; CALLING SEQUENCE:
;		sdo_ss_getbndrct,binary, locs, nx, ny, xc, yc, cdx, cdy, arc_arr=arc_arr, xx=xx
;
; INPUTS:
;       locs - Vector containing the pixels location of 
;			   the feature in the 2D image.
;		nx	  - Number of pixels along X axis (i.e. NAXSI1).
;		ny	  - Numner of pixels along Y axis (i.e. NAXIS2).
;		xc	  - X coordinate of image center in pixels (i.e. CENTER_X).
;		yc	  - Y coordinate of image center in pixels (i.e. CENTER_Y).
;		cdx   - X axis spatial scale in arcsec/pix (i.e. CDELT1).
;		cdy	  - Y axis spatial scale in arcsec/pix (i.e. CDELT2).
;	
; OPTIONAL INPUTS:
;     	None. 
;
; KEYWORD PARAMETERS:
;		None.
;
; OUTPUTS:
;		None.
;
; OPTIONAL OUTPUTS:
;		arc_arr - 4 elements vector containing the coordinates in arcsec of the 
;				  lower left corner [X0,Y0] and upper right corner [X1,Y1] of
;				  the bounding rectangle.
;		xx		- 4 elements vector containing the coordinates in pixels of the 
;				  lower left corner [X0,Y0] and upper right corner [X1,Y1] of
;				  the bounding rectangle. 
;
; COMMON BLOCKS:		
;		None.
;	
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS/COMMENTS:
;		None.
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
;		18-JUL-2011, X.Bonnin:	Updated header.
;-

pro sdo_ss_getbndrct, locs, nx, ny, xc, yc, cdx, cdy,  arc_arr=arc_arr, xx=xx


xp=locs mod nx
yp=locs / nx

x0=min(xp)
y0=min(yp)

x1=max(xp)
y1=max(yp)

xx=[x0, y0, x1, y1]
arc_arr=dblarr(4)
    
br_arcx0=(x0-xc)*cdx
br_arcx1=(x1-xc)*cdx
br_arcy0=(y0-yc)*cdy
br_arcy1=(y1-yc)*cdy

arc_arr[0]=br_arcx0
arc_arr[1]=br_arcy0
arc_arr[2]=br_arcx1
arc_arr[3]=br_arcy1

end