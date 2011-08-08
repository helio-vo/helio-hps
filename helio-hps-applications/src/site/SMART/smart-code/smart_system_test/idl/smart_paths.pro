;---------------------------------------------------------------------->

function smart_paths, mdip=mdip, calmdip=calmdip, logp=logp,savp=savp,fitsp=fitsp, resavetrackp=resavetrackp, $
	resmapp=resmapp, plotp=plotp, voevents=voevents, $ ;htmlp=htmlp, $
	nardb=nardb, calibp=calibp, flarep=flarep, psplotp=psplotp, summaryp=summaryp, $
	pngp=pngp, statplotp=statplotp, date=date, $
	no_calib=no_calib,db=db

gridroot='/opt/exp_soft/helio/processing-codes/smart-code/smart_system_test'
;gridroot='/tmp/smart_storage' ;not grid
localroot='.'

if keyword_set(calibp) then begin 
	retval='docalib.tmp.sav' 
	return,retval
endif

if not keyword_set(no_calib) then restore,smart_paths(/calibp)

if keyword_set(mdip) then retval=gridroot+'/data/mdi/'
if keyword_set(calmdip) then retval=gridroot+'/data/mdi/'
if keyword_set(logp) then retval=localroot+'/data/logs/'
if keyword_set(resavetrackp) then retval=localroot+'/data/sav/'
if keyword_set(resmapp) then retval=gridroot+'/calib/'
if keyword_set(savp) then retval=localroot+'/data/sav/'
if keyword_set(fitsp) then retval=localroot+'/data/fits/'
if keyword_set(plotp) then retval=localroot+'/data/plots/'
if keyword_set(voevents) then retval=localroot+'/data/voevent/'

;if keyword_set(htmlp) then retval='~/Sites/phiggins/smart/html/'
;if keyword_set(nardb) then retval='/Volumes/sswdb/ydb/nar/'
if keyword_set(flarep) then retval='~/Sites/phiggins/smart/flare/'
if keyword_set(psplotp) then retval=localroot+'/data/plots/'
if keyword_set(summaryp) then retval=localroot+'/data/plots/'
if keyword_set(pngp) then retval=localroot+'/data/plots/'
if keyword_set(statplotp) then retval=localroot+'/data/plots/'
if keyword_set(db) then retval=localroot+'/data/database/'

;summaryp=summaryp

if keyword_set(no_calib) then goto,skipgrian
if grianlive eq 1 then begin
;	if keyword_set(mdip) then retval='~/Sites/data/'+strtrim(date,2)+'/fits/smdi/'
;	if keyword_set(logp) then retval='~/Sites/smart/log/'
;	if keyword_set(savp) then retval='~/Sites/smart/sav/'
;	if keyword_set(flarep) then retval='~/Sites/smart/flare/'
;	if keyword_set(summaryp) then retval='~/Sites/data/'+strtrim(date,2)+'/meta/'
endif
skipgrian:

;summaryp=summaryp
;put the INC file in data/date/meta/

return, retval

end

;---------------------------------------------------------------------->
