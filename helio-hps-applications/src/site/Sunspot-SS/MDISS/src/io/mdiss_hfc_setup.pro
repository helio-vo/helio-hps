PRO mdiss_hfc_setup,oby_str, frc_stc, obs_stc, pp_info_stc, pp_out_stc, feat_stc

;+
; NAME:
;		mdiss_hfc_setup
;
; PURPOSE:
; 		Load some meta-data information concerning
;       frc, observatory, observations, pp_output, pp_info, feature
;       into structres using HFC table definitions.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		SSMDI
;
; CALLING SEQUENCE:
;		mdiss_hfc_setup, oby_str, frc_stc, obs_stc, pp_info_stc, pp_out_stc, feat_stc
;
; INPUTS:
;       None.	
;	
; OPTIONAL INPUTS:
;		None.
;
; KEYWORD PARAMETERS:
;		None.	
;
; OUTPUTS:
;		oby_str       - Structure containing information about observatory.
;		frc_stc       - Structure containing information about SDO SS code.	
;		obs_stc       - Structure containing information about observations.
;		pp_info_stc	  - Structure containing information about Pre-Process code.
;       pp_out_stc    - Structure containing information about Pre-Process obsevations.
;       feat_stc      - Empty structure containing output feature parameters.	
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
;		None
;		
; CALL:
;		hfc_observations__define
;       hfc_observatory__define
;       hfc_frc_info__define
;       hfc_pp_output__define
;       hfc_pp_info__define.pro
;       hfc_sunspots__define
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 18-OCT-2011.
;
;-

;Observatory information
oby_str = {hfc_observatory}
oby_str = replicate(oby_str,2)
oby_str.id_observatory = [1,2]
oby_str.observat=['SOHO','SOHO']
oby_str.instrume=['MDI','MDI']
oby_str.telescop=['continuum','magnetogram']
oby_str.units=['Counts','Gauss']
oby_str.wavemin=['676.780','676.780']
oby_str.wavemax=['676.780','676.780']
oby_str.waveunit=['nm','nm']
oby_str.wavename=['Ni I','Ni I']
oby_str.spectral_name=['visible','line_of_sight magnetic field']
oby_str.obs_type=['Remote-sensing','Remote-sensing']
oby_str.comment=['','']

;Observations information
obs_stc = {hfc_observations}
obs_stc = replicate(obs_stc,2)
obs_stc.id_observations = [1,2]
obs_stc.observatory_id = [1,2]

;Feature Recognition Code information
references = {names:'Publication',$
			  links:'http://adsabs.harvard.edu/abs/2005SoPh..228..361Z/',$
			  types:'html'} 

frc_stc = {hfc_frc_info}
frc_stc.id_frc_info = 1
frc_stc.feature_name='SUNSPOTS'
frc_stc.code='MDISS'
frc_stc.version=''
frc_stc.institut='MSSL'
frc_stc.person = 'Sergei Zharkov'
frc_stc.contact='sz2@mssl.ucl.ac.uk'
frc_stc.enc_met='RASTERSCAN/CHAINCODE'
frc_stc.reference=references.links
			
;Pre-Processed code information
pp_info_stc = {hfc_pp_info}
pp_info_stc.id_pp_info = 1
pp_info_stc.institut='OBSPM'
pp_info_stc.code='MDISS'
pp_info_stc.version=''
pp_info_stc.person='Xavier Bonnin'
pp_info_stc.contact='xavier.bonnin@obspm.fr'
pp_info_stc.reference=references.links

;Pre-Processed observations information
pp_out_stc = {hfc_pp_output}
pp_out_stc = replicate(pp_out_stc,2)
pp_out_stc.id_pp_output = [1,2]
pp_out_stc.pp_info_id = [1,1]
pp_out_stc.observations_id = [1,2]
pp_out_stc.url=['NULL','NULL']
pp_out_stc.efit=[0,0]
pp_out_stc.lineclean=[0,0]

;Load feature structure
feat_stc = {hfc_sunspots}
feat_stc.frc_info_id = 1
feat_stc.observations_id_ic = 1
feat_stc.observations_id_m = 2


error = 0
END
