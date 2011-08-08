;Extract the AR structures from a load of archived savs that match the IDTRACK you supply.
;For instance,
;IDL> strarr=smart_track_id('20031026_1247.ar.13',path='~/',time=['26-oct-2003','28-oct-2003'])
;will output an array of structures for the active region with catalog id, '20031026_1247.ar.13' 
;between the specified dates for files in the home directory.

;arstr=smart_track_id('20091026_1423.mg.11', path='~/science/data/smart2/sav_track/', timerange=['26-oct-2003','4-nov-2003'])

pro run_track_id, file=file
print,'RUN_TRACK_ID'

savpath='~/Sites/phiggins/smart/sav/'
trackpath='~/Sites/phiggins/smart/tracked_sav/'
plotpath='~/Sites/phiggins/smart_plots_tracked/'

thistim=anytim(file2time(file),/vms)
restore,file

smidar=arstruct.smid
wgood=where(strlen(smidar) gt 2)
if wgood[0] eq -1 then begin
	print,'NOTHING TO TRACK!!'
	return
endif
smidar=smidar[wgood]

smidtim=anytim(file2time(strmid(smidar,0,13)),/vms) 

for i=0,n_elements(smidar)-1 do begin
if smidtim[i] eq thistim then goto,gotoskiptrack
	timerange=[smidtim[i],thistim]
	idtrack=strmid(smidar[i],0,19)

	arstr_arr=smart_track_id(idtrack, path=savpath, timerange=timerange, extstr=extstr_arr)
	
	smart_plot_track_id, arstr_arr, extstr_arr, path=plotpath

	save,arstr_arr,extstr_arr,file=trackpath+idtrack+'.sav'
	
gotoskiptrack:

endfor

end