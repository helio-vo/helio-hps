;filename, FRM_PARAMSET=FRM_PARAMSET, no_sav=no_sav, no_xml=no_xml, votable=votable, outvotable=outvotable

;------------------------------------------------>

function smart_voevent_fill, inarstruct, inevstruct,extentstr=inextentstr, FRM_PARAMSET=FRM_PARAMSET;, jsoc=jsoc

arstruct=inarstruct
evstruct=inevstruct
extentstr=inextentstr

evstructreq=evstruct.required

evstructreq.EVENT_COORDUNIT='arcsec, arcsec' ;solar-x, solar-y units
evstructreq.EVENT_ENDTIME=strjoin(str_sep(arstruct.time,' '),'T')
evstructreq.EVENT_STARTTIME=strjoin(str_sep(arstruct.time,' '),'T')
evstructreq.EVENT_COORD1=arstruct.hclon ;flux weighted mean solar-x position
evstructreq.EVENT_COORD2=arstruct.hclat ;flux weighted mean solar-y position
evstructreq.EVENT_C1ERROR=1.9780144 ;MDI pixel size
evstructreq.EVENT_C2ERROR=1.9780144 ;MDI pixel size

evstructreq.FRM_CONTACT='pohuigin@gmail.com'
evstructreq.FRM_DATERUN=strjoin(str_sep(systim(/utc),' '),'T')
evstructreq.FRM_HUMANFLAG='F'
evstructreq.FRM_IDENTIFIER='phiggins'
evstructreq.FRM_INSTITUTE='Trinity College Dublin'
evstructreq.FRM_NAME='SMART Solar Monitor Active Region Tracker'
evstructreq.FRM_PARAMSET=FRM_PARAMSET
evstructreq.FRM_URL='http://solarmonitor.org/smart_documentation.php'

evstructreq.OBS_OBSERVATORY='SOHO'
evstructreq.OBS_CHANNELID='V band'
evstructreq.OBS_INSTRUMENT='MDI'
evstructreq.OBS_MEANWAVEL='6768'
evstructreq.OBS_WAVELUNIT='Angstroms'

x1x2=(extentstr.xylon-512.)*1.9780144
y1y2=(extentstr.xylat-512.)*1.9780144

evstructreq.BOUNDBOX_C1LL=x1x2[0]
evstructreq.BOUNDBOX_C2LL=y1y2[0]
evstructreq.BOUNDBOX_C1UR=x1x2[1]
evstructreq.BOUNDBOX_C2UR=y1y2[1]


evstruct.required=evstructreq

;** Structure <2143404>, 8 tags, length=2108, data length=2108, refs=1:
;   REQUIRED        STRUCT    -> <Anonymous> Array[1]
;   OPTIONAL        STRUCT    -> <Anonymous> Array[1]
;   SPECFILE        STRING    '/Users/phiggins/science/procedures/hek_ont'...
;   REFERENCE_NAMES STRING    Array[20]
;   REFERENCE_LINKS STRING    Array[20]
;   REFERENCE_TYPES STRING    Array[20]
;   DESCRIPTION     STRING    ''
;   CITATIONS       STRUCT    -> <Anonymous> Array[20]

;** Structure <2143004>, 30 tags, length=288, data length=288, refs=2:
;   EVENT_TYPE      STRING    'AR: ActiveRegion'
;   KB_ARCHIVDATE   STRING    'Reserved for KB archivist: KB entry date'
;   KB_ARCHIVID     STRING    'Reserved for KB archivist: KB entry identi'...
;   KB_ARCHIVIST    STRING    'Reserved for KB archivist: KB entry made b'...
;   KB_ARCHIVURL    STRING    'Reserved for KB archivist: URL to suppl. i'...
;   EVENT_COORDSYS  STRING    'UTC-HPC-TOPO'
;   EVENT_COORDUNIT STRING    'blank'
;   EVENT_ENDTIME   STRING    '1492-10-12 00:00:00'
;   EVENT_STARTTIME STRING    '1492-10-12 00:00:00'
;   EVENT_COORD1    FLOAT               Inf
;   EVENT_COORD2    FLOAT               Inf
;   EVENT_C1ERROR   FLOAT               Inf
;   EVENT_C2ERROR   FLOAT               Inf
;   FRM_CONTACT     STRING    'blank'
;   FRM_DATERUN     STRING    'blank'
;   FRM_HUMANFLAG   STRING    'blank'
;   FRM_IDENTIFIER  STRING    'blank'
;   FRM_INSTITUTE   STRING    'blank'
;   FRM_NAME        STRING    'blank'
;   FRM_PARAMSET    STRING    'blank'
;   FRM_URL         STRING    'blank'                         
;   OBS_OBSERVATORY STRING    'blank'
;   OBS_CHANNELID   STRING    'blank'
;   OBS_INSTRUMENT  STRING    'blank'
;   OBS_MEANWAVEL   FLOAT               Inf
;   OBS_WAVELUNIT   STRING    'blank'
;   BOUNDBOX_C1LL   FLOAT               Inf
;   BOUNDBOX_C2LL   FLOAT               Inf
;   BOUNDBOX_C1UR   FLOAT               Inf
;   BOUNDBOX_C2UR   FLOAT               Inf


return, evstruct

end

;------------------------------------------------>

pro smart_voevent, filename, FRM_PARAMSET=FRM_PARAMSET, no_sav=no_sav, no_xml=no_xml, votable=votable, outvotable=outvotable

if n_elements(FRM_PARAMSET) ne 1 then FRM_PARAMSET=''

savp=smart_paths(/no_cal, /sav)
voeventp=smart_paths(/voevents,/no_cal)

blankstruct = struct4event('AR')

if keyword_set(votable) then evstructarr=blankstruct
if n_elements(outvotable) lt 1 then outvotable=voeventp+'votable_'+file2time(filename[0])+'_'+file2time(filename[n_elements(filename)-1])+'.sav'

nfile=n_elements(filename)
for j=0,nfile-1 do begin

	if (reverse(str_sep(filename[j],'.')))[0] eq 'gz' then begin
		spawn,'gunzip -f '+filename[j]
		restore,strjoin((str_sep(filename[j],'.'))[0:n_elements(str_sep(filename[j],'.'))-2],'.')
		spawn,'gzip -f '+strjoin((str_sep(filename[j],'.'))[0:n_elements(str_sep(filename[j],'.'))-2],'.')
	endif else restore,filename[j]
	
	nar=n_elements(arstruct)
	
	evstruct = blankstruct
	evstruct = replicate(evstruct,nar)
	
	for i=0,nar-1 do begin
		;Create VO Event IDL structure
		evstruct[i]=smart_voevent_fill(arstruct[i], evstruct[i],extentstr=extentstr[i],FRM_PARAMSET=FRM_PARAMSET)

		;Write XML VO Event
		if not keyword_set(no_xml) then export_event, evstruct[i], /write_file, $
			outdir=voeventp, $
			suff=time2file(arstruct[i].time)+'_'+string(arstruct[i].id, format='(I03)'), $
			outfil='smart_voevent_'+time2file(arstruct[i].time)+'_id'+strtrim(arstruct[i].id,2)+'.xml'

	endfor
	
	;Write IDL SAV file
	if not keyword_set(no_sav) then save, evstruct, file=voeventp+'smart_voevent_'+time2file(arstruct[0].time)+'.sav'
	
	if keyword_set(votable) then evstructarr=[evstructarr, evstruct]
	
endfor

if keyword_set(votable) then begin 
	evstructarr=evstructarr[1:*]
	save,evstructarr,file=outvotable
endif

end