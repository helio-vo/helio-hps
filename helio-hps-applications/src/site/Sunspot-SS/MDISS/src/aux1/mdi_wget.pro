PRO mdi_wget,filename=filename, $
             ds=ds,date_obs=date_obs,index=index, $
             output_dir=output_dir,locfname=locfname, $
             tries=tries,provider=provider,urls=urls, $
             VERBOSE=VERBOSE

;+
; NAME:
;		mdi_wget
;
; PURPOSE:
;		Download SOHO/MDI fits file from distant server using wget command.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		IDL> mdi_wget,filename=filename
;   or
;       IDL> mdi_wget,date_obs=date_obs,ds=ds
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS:
;       filename   - Name of the mdi file to download.
;		ds         - Data series to download.
;                    It can be 'fd_Ic_6h_01d' or 'fd_M_96m_01d'.
;       date_obs   - Scalar or Vector containing the date(s) of observation for which fits file(s) must
;                    be downloaded.
;       index      - Scalar or Vector containing the date index(es) of fits file(s) to download.
;                    (Ignored if date_obs is set.)
;       output_dir - Full path name to the directory where file(s) will be saved.
;       provider   - Name of the data provider. Only sdac and medoc is available.
;       tries      - Number of server connection try.
;                    Default is 1.
;
; KEYWORD PARAMETERS: 
;		/VERBOSE - Talkative mode.
;		
; OUTPUTS:
;		None.				
;
; OPTIONAL OUTPUTS:
;		locfname - Full path name of the downloaded file(s).
;       urls     - urls of download file(s).		
;		
; COMMON BLOCKS:
;		None.		
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS/COMMENTS:
;		- An internet access is required to download SOHO/MDI data.
;       - wget software must be installed.
;
; CALL:
;		mdi_date2id
;       mdi_id2date
;
; EXAMPLE:
;		None.
;		
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 10-JAN-2012.
;
;       10-MAY-2012, X.Bonnin:  Added filename optional input.
;                               Added urls option output. 
;
;-
locfname = "" & urls = ""
if (n_params() eq 0) then begin
    message,/INFO,'Call is:'
    print,'mdi_wget,filename=filename, $'
    print,'         ds=ds,date_obs=date_obs, $'
    print,'         index=index, locfname=locfname, $'
    print,'         output_dir=output_dir,tries=tries, $'
    print,'         provider=provider,urls=urls,/VERBOSE'
    return
endif

VERBOSE = keyword_set(VERBOSE)

if not (keyword_set(tries)) then try = '1' else try = strtrim(tries[0],2)
if not (keyword_set(provider)) then provider = 'sdac'
pvdr = strlowcase(strtrim(provider[0],2))

if (keyword_set(filename)) then file = strtrim(file_basename(filename[0]),2)
if (keyword_set(ds)) then series = strtrim(ds[0],2) else ds='fd_Ic_6h_01d'

fflag = keyword_set(filename)
dflag = keyword_set(date_obs)
iflag = keyword_set(index)

if not (keyword_set(output_dir)) then cd,current=output_dir

if not (dflag) and not (iflag) and not (fflag) then begin
    message,/CONT,'You must provide at least the filename or the date(s) of observation or the index(es) of file(s)!'
    return
endif

if (dflag) then nobs = n_elements(date_obs) 
if (iflag) then nobs = n_elements(index)
if (fflag) then nobs = n_elements(filename)

case pvdr of
    'medoc':url = 'www.medoc-ias.u-psud.fr/archive/5/private/data/processed/mdi/'
    'sdac':url = 'http://sohodata.nascom.nasa.gov/archive/soho/private/data/processed/mdi'
    else:begin
        message,/CONT,'Unknown provider!'
        return
    end
endcase

if (VERBOSE) then vb = '-v' else vb = '-q'

for i=0l,nobs-1l do begin
   
    if (dflag) then begin
        date_obs_i = date_obs[i]
        index_i = mdi_date2id(date_obs_i)  
    endif
    if (iflag) then begin
        index_i = index[i]
        date_obs_i = mdi_id2date(index_i)
    endif
    if (fflag) then begin
        pobs = strsplit(file[i],'_.',/EXTRACT)
        index_i = pobs[4]
        if (pobs[1] eq 'Ic') then pobs = 'intensity' $
        else pobs = 'magnetogram'
        date_obs_i = mdi_id2date(index_i)
    endif

    if (series eq 'fd_Ic_6h_01d') then begin
        if (index_i lt 3346) then format = '(i6.6)' else format = '(i4.4)'
        dirname = 'fd_Ic_6h_01d/fd_Ic_6h_01d.'+string(index_i,format=format)+'/'
    endif
    
    if (series eq 'fd_M_96m_01d') then begin
        if (index_i lt 5844) then format = '(i6.6)' else format = '(i4.4)'
        dirname = 'fd_M_6h_01d/fd_M_96m_01d.'+string(index_i,format=format)+'/'
    endif
    
    basename_i = series+string(index_i,format='(i4.4)')+'.????.fits' 
    if (fflag) then basename_i = file[i]

    url = url + dirname
    if (fflag) then url = url + '/' + file[i]
    cmd = 'wget '+vb+' -r -nc -nd -t '+try+' --no-parent -A.fits '+url+' -P '+output_dir
    
    if (VERBOSE) then print,cmd
    spawn,cmd
    
    locfname_i = file_search(output_dir + path_sep() + basename_i)
    if (locfname_i[0] ne '') then begin
        locfname = [locfname,locfname_i] 
        if (fflag) then urls = [urls,url] $
        else urls = [urls,url+'/'+file_basename(locfname_i)]
        continue
    endif
endfor
nloc = n_elements(locfname)
if (nloc gt 1) then begin
    locfname = locfname[1:*]
    urls = urls[1:*]
endif
if (VERBOSE) then print,strtrim(nloc-1l,2)+ ' file(s) downloaded.'

END