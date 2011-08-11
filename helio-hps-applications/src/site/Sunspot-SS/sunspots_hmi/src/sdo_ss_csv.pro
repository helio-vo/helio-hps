;+
; NAME:
;		sdo_ss_csv
;
; PURPOSE:
; 		This routine writes the SDO SunSpot detection code results
;		into a csv format file.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		SDOSS
;
; CALLING SEQUENCE:
;		sdo_ss_csv, header_Ic, header_M, header_Ic_corr, header_M_corr,$
;				    data, rscan, ccode, cc_pix, cc_arc
;
; INPUTS:
;		header_Ic      - Structure containing the fits header of original continuum observation file.
;		header_M  	   - Structure containing the fits header of original magentogram observation file.
;		header_Ic_corr - Structure containing the fits header of corrected continuum observation file.
;		header_M_corr  - Structure containing the fits header of corrected magnetogram observation file.
;		process_info   - Structure containing relevant informations about current process. 
;		data           - Array of float type containing [n,19] extracted parameters 
;				    	 of the n sunspots detected by the algorithm on the current image.
;		rscan     	   - Vector of string type containing the n corresponding raster scans.
;		ccode          - Vector of string type containig the n corresponding chain codes.
;		cc_pix         - [2,n] array of long integer type containing the starting positions
;				         of the chain code for the n sunspots detected (in pixels).
;		cc_arc         - [2,n] array of long integer type containing the starting positions
;				         of the chain code for the n sunspots detected (in arcsec).	
;	
; OPTIONAL INPUTS:
;		outroot - Scalar of string type containing the full path name of 
;				  the output directory.
;
; KEYWORD PARAMETERS:
;		None. 	
;
; OUTPUTS:
;		None.	
;
; OPTIONAL OUTPUTS:
;		fn - Name of the output file(s).
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
;		Written by:		X.Bonnin, 18-JUL-2011.
;
;-

PRO sdo_ss_csv, header_Ic, header_M, header_Ic_corr, header_M_corr,$
				process_info, data, rscan, ccode, cc_pix, cc_arc, $
				fn=fn, outroot=outroot


if (n_params() lt 10) then begin
	message,/INFO,'Call is:'
	print,'sdo_ss_csv, header_Ic, header_M, header_Ic_corr, header_M_corr, $'
	print,'            process_info, data, rscan, ccode, cc_pix, cc_arc, $'
	print,'            fn=fn, outrout=outroot'
	return
endif

n = n_elements(ccode)
if (n eq 0) then return

fnc = process_info.fnc & fnc_corr = process_info.fnc_corr
fnm = process_info.fnm & fnm_corr = process_info.fnm_corr
frc_info = process_info.frc_info
obs_info = process_info.obs_info
pp_info = process_info.pp_info
status_ic = process_info.status_ic
status_m = process_info.status_m

str_version = string(strjoin(strsplit(frc_info.version,'.',/EXTRACT)),format='(i4.4)')

pref = 'sdoss_'+str_version+'_'
run_date = anytim(!stime, /ccsds)

;YYYY-MM-DDTHH:NN:SS
str_date = (strsplit(header_Ic.date_obs,'.',/EXTRACT))[0]
;YYYYMMDDTHHNNSS
str_date = strjoin(strsplit(str_date,'-:',/EXTRACT))

;Julian days
jd_Ic = cds2jd(header_Ic.date_obs)
jd_M = cds2jd(header_M.date_obs)

;Write Observatory file
fn_obs = pref + 'observatory.csv'
fn = fn_obs

openw,lun,outroot + path_sep() + fn_obs,/GET_LUN

;Fields: 
printf,lun,'ID_OBSERVATORY;OBSERVAT;INSTRUMENT;TELESCOPE;UNITS;WAVEMIN;WAVEMAX;WAVENAME;WAVEUNIT;SPECTRAL_NAME;OBS_TYPE;COMMENT;RUN_DATE'
;Continuum values
printf,lun,strjoin(['1',obs_info.Observatory,obs_info.Instrument,obs_info.Telescope[0],obs_info.Units[0],$
				   obs_info.MeanWavel,obs_info.MeanWavel,obs_info.wavename,obs_info.WavelUnit,obs_info.spectral_name[0],$
				   obs_info.obs_type,obs_info.comment[0],run_date],';')
;Magnetogram values
printf,lun,strjoin(['2',obs_info.Observatory,obs_info.Instrument,obs_info.Telescope[1],obs_info.Units[1],$
				   obs_info.MeanWavel,obs_info.MeanWavel,obs_info.wavename,obs_info.WavelUnit,obs_info.spectral_name[1],$
				   obs_info.obs_type,obs_info.comment[1],run_date],';')

close,lun
free_lun,lun


;Write FRC file
fn_frc = pref + 'frc_info.csv'
fn = [fn,fn_frc]

openw,lun,outroot + path_sep() + fn_frc,/GET_LUN
;Fields
printf,lun,'ID_FRC_INFO;INSTITUT;NAME_CODE;VERSION_CODE;ENC_MET;FEATURE;PERSON;CONTACT;REFERENCE;RUN_DATE'
;Values
printf,lun,strjoin(['1',frc_info.institute,frc_info.name,frc_info.version,frc_info.enc_met,frc_info.feature,frc_info.person,frc_info.contact,$
				   frc_info.references.links,run_date],';')
close,lun
free_lun,lun

;Write pp_info file
fn_pp = pref + 'pp_info.csv'
fn = [fn,fn_pp]

openw,lun,outroot + path_sep() + fn_pp,/GET_LUN
;Fields
printf,lun,'ID_PP_INFO;INSTITUT;NAME_CODE;VERSION_CODE;PERSON;CONTACT;REFERENCE;RUN_DATE'
;Values
printf,lun,strjoin(['1',pp_info.institute,pp_info.name,pp_info.version,pp_info.person,pp_info.contact,$
				   frc_info.references.links,run_date],';')
close,lun
free_lun,lun



;Write Initial Observations fits info
fn_init = pref+str_date+'_init.csv'
fn = [fn,fn_init]

openw,lun,outroot + path_sep() + fn_init,/GET_LUN
;Fields:
printf,lun,'ID_OBSERVATIONS;OBSERVATORY_ID;DATE_OBS;DATE_END;JDINT;JDFRAC;EXP_TIME;C_ROTATION;BSCALE;BZERO;BITPIX;NAXIS1;NAXIS2;R_SUN;CENTER_X;CENTER_Y;CDELT1;CDELT2;QUALITY;FILENAME;COMMENT;LOC_FILENAME;URL;RUN_DATE'
;Continuum values
printf,lun,strjoin(['1','1',header_Ic.date_obs,header_Ic.date_obs,strtrim(jd_Ic.int,2),strtrim(jd_Ic.frac,2),$
					strtrim(header_Ic.trecstep,2),strtrim(header_Ic.car_rot,2),$
					strtrim(header_Ic.bscale,2),strtrim(header_Ic.bzero,2),$
					strtrim(header_Ic.bitpix,2),strtrim(header_Ic.naxis1,2),$
					strtrim(header_Ic.naxis2,2),strtrim(header_Ic.rsun_obs,2),$
					strtrim(header_Ic.crpix1,2),strtrim(header_Ic.crpix2,2),$
					strtrim(header_Ic.cdelt1,2),strtrim(header_Ic.cdelt2,2),$
					strtrim(header_Ic.quality,2),file_basename(fnc),$
					obs_info.comment[0],fnc,status_ic.url,run_date],';')

;Magnetogram values
printf,lun,strjoin(['2','2',header_m.date_obs,header_m.date_obs,strtrim(jd_m.int,2),strtrim(jd_m.frac,2),$
					strtrim(header_m.trecstep,2),strtrim(header_m.car_rot,2),$
					strtrim(header_m.bscale,2),strtrim(header_m.bzero,2),$
					strtrim(header_m.bitpix,2),strtrim(header_m.naxis1,2),$
					strtrim(header_m.naxis2,2),strtrim(header_m.rsun_obs,2),$
					strtrim(header_m.crpix1,2),strtrim(header_m.crpix2,2),$
					strtrim(header_m.cdelt1,2),strtrim(header_m.cdelt2,2),$
					strtrim(header_m.quality,2),file_basename(fnm),$
					obs_info.comment[1],fnm,status_m.url,run_date],';')


close,lun
free_lun,lun

;Write Normalized Observations fits info
fn_norm = pref+str_date+'_norm.csv'
fn = [fn,fn_norm]

openw,lun,outroot + path_sep() + fn_norm,/GET_LUN
;Fields:
printf,lun,'ID_PP_OUTPUT;OBSERVATORY_ID;DATE_OBS;DATE_END;JDINT;JDFRAC;EXP_TIME;C_ROTATION;BSCALE;BZERO;BITPIX;NAXIS1;NAXIS2;R_SUN;CENTER_X;CENTER_Y;CDELT1;CDELT2;QUALITY;EFIT;BACKGROUND;STANDARD;LIMBDARK;QSUN_INT;FILENAME;COMMENT;LOC_FILENAME;URL;RUN_DATE'
;Continuum values
printf,lun,strjoin(['1','1',header_Ic_corr.date_obs,header_Ic_corr.date_obs,strtrim(jd_Ic.int,2),strtrim(jd_Ic.frac,2),$
					strtrim(header_Ic_corr.trecstep,2),strtrim(header_Ic_corr.car_rot,2),$
					strtrim(header_Ic_corr.bscale,2),strtrim(header_Ic_corr.bzero,2),$
					strtrim(header_Ic_corr.bitpix,2),strtrim(header_Ic_corr.naxis1,2),$
					strtrim(header_Ic_corr.naxis2,2),strtrim(header_Ic_corr.rsun_obs,2),$
					strtrim(header_Ic_corr.crpix1,2),strtrim(header_Ic_corr.crpix2,2),$
					strtrim(header_Ic_corr.cdelt1,2),strtrim(header_Ic_corr.cdelt2,2),$
					strtrim(header_Ic_corr.quality,2),strtrim(pp_info.efit,2),$
					strtrim(pp_info.background,2),strtrim(pp_info.standard,2),$
					strtrim(pp_info.limbdark,2),strtrim(pp_info.qs,2),file_basename(fnc_corr),$
					obs_info.comment[0],fnc_corr,pp_info.url,run_date],';')

;Magnetogram values
printf,lun,strjoin(['2','2',header_m_corr.date_obs,header_m_corr.date_obs,strtrim(jd_m.int,2),strtrim(jd_m.frac,2),$
					strtrim(header_m_corr.trecstep,2),strtrim(header_m_corr.car_rot,2),$
					strtrim(header_m_corr.bscale,2),strtrim(header_m_corr.bzero,2),$
					strtrim(header_m_corr.bitpix,2),strtrim(header_m_corr.naxis1,2),$
					strtrim(header_m_corr.naxis2,2),strtrim(header_m_corr.rsun_obs,2),$
					strtrim(header_m_corr.crpix1,2),strtrim(header_m_corr.crpix2,2),$
					strtrim(header_m_corr.cdelt1,2),strtrim(header_m_corr.cdelt2,2),$
					strtrim(header_m_corr.quality,2),strtrim(pp_info.efit,2),$
					strtrim(pp_info.background,2),strtrim(pp_info.standard,2),$
					strtrim(pp_info.limbdark,2),strtrim(pp_info.qs,2),file_basename(fnm_corr),$
					obs_info.comment[1],fnm_corr,pp_info.url,run_date],';')

close,lun
free_lun,lun
;Write SS parameters file
fn_ss = pref+str_date+'_feat.csv'
fn = [fn,fn_ss]

openw,lun,outroot + path_sep() + fn_ss,/GET_LUN

;Fields:
printf,lun,'ID_SS;IC_FILE;M_FILE;DATE_OBS;SS_BR_X0_PIX;SS_BR_Y0_PIX;SS_BR_X1_PIX;SS_BR_Y1_PIX;SS_BR_X2_PIX;SS_BR_Y2_PIX;SS_BR_X3_PIX;SS_BR_Y3_PIX;SS_BR_X0_ARCSEC;SS_BR_Y0_ARCSEC;SS_BR_X1_ARCSEC;SS_BR_Y1_ARCSEC;SS_BR_X2_ARCSEC;SS_BR_Y2_ARCSEC;SS_BR_X3_ARCSEC;SS_BR_Y3_ARCSEC;SS_BR_HG_LONG0_DEG;SS_BR_HG_LAT0_DEG;SS_BR_HG_LONG1_DEG;SS_BR_HG_LAT1_DEG;SS_BR_HG_LONG2_DEG;SS_BR_HG_LAT2_DEG;SS_BR_HG_LONG3_DEG;SS_BR_HG_LAT3_DEG;SS_BR_CARR_LONG0_DEG;SS_BR_CARR_LAT0_DEG;SS_BR_CARR_LONG1_DEG;SS_BR_CARR_LAT1_DEG;SS_BR_CARR_LONG2_DEG;SS_BR_CARR_LAT2_DEG;SS_BR_CARR_LONG3_DEG;SS_BR_CARR_LAT3_DEG;SS_X_PIX;SS_Y_PIX;SS_X_ARCSEC;SS_Y_ARCSEC;SS_HG_LONG_DEG;SS_HG_LAT_DEG;SS_CARR_LONG_DEG;SS_CARR_LAT_DEG;UMBRA_NUMBER;SS_AREA_PIX;SS_AREA_DEG2;SS_AREA_MM2;SS_DIAM_DEG;SS_DIAM_MM;UMBRA_AREA_PIX;UMBRA_AREA_DEG2;UMBRA_AREA_MM2;UMBRA_DIAM_DEG;UMBRA_DIAM_MM;SS_MIN_INT;SS_MAX_INT;SS_MEAN_INT;SS_MEAN2QSUN;SS_MIN_BZ;SS_MAX_BZ;SS_MEAN_BZ;SS_TOT_BZ;SS_TOT_BZ;UMBRA_MIN_BZ;UMBRA_MAX_BZ;UMBRA_MEAN_BZ;UMBRA_TOT_BZ;UMBRA_ABS_BZ;CC_X_PIX;CC_Y_PIX;CC_X_ARCSEC;CC_Y_ARCSEC;CC;CC_LENGTH;RS;RS_LENGTH;SNAPSHOT_FILENAME;SNAPSHOT_PATH;FEAT_FILENAME;RUN_DATE'

for i=0L,n-1L do begin
	data_i = reform(strtrim(data(i,*),2))
	printf,lun,strjoin([strtrim(i+1L,2),file_basename(fnc),file_basename(fnm),header_Ic.date_obs,data_i(19:43),$
						data_i(0:13),data_i(14:18),data_i(53:56),data_i(43:52),$
						reform(strtrim(cc_pix(*,i),2)),reform(strtrim(cc_arc(*,i),2)),ccode(i),strtrim(strlen(ccode(i)),2),$
						rscan(i),strtrim(strlen(rscan(i)),2),process_info.snapshot_fn,pp_info.snapshot_path,fn_ss,run_date],';')

endfor

END