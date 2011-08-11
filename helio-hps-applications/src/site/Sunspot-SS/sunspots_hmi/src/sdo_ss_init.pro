;+
; NAME:
;		sdo_ss_init
;
; PURPOSE:
; 		This routine initializes the SDO SunSpot detection code.
;
; CATEGORY:
;		I/O
;
; GROUP:
;		SDOSS
;
; CALLING SEQUENCE:
;		sdo_ss_init,obs_info,frc_info, pp_info
;
; INPUTS:
;		None.
;	
; OPTIONAL INPUTS:
;		None.
;
; KEYWORD PARAMETERS:
;		None. 	
;
; OUTPUTS:
;		obs_info - Structure containing information about observations.
;		frc_info - Structure containing information about SDO SS code.	
;		pp_info	 - Structure containing information about Pre-Process code.
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
;		anytim
;
; EXAMPLE:
;		None.		
;
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 18-JUL-2011.
;
;-

PRO sdo_ss_init,obs_info,frc_info, pp_info

;Observations information
obs_info = {Observatory:'SDO',Instrument:'HMI',Telescope:['continuum','magnetogram'],$
			Units:['Counts','Gauss'],ChannelID:'SDO/HMI',MeanWavel:'617.133',$
			WavelUnit:'nm',wavename:'Fe I',spectral_name:['visible','line_of_sight magnetic field'],$
			obs_type:['Remote-sensing'],comment:['Ic_45s','M_45s']}

;Feature Recognition Code information
references = {names:'Publication',$
			  links:'http://adsabs.harvard.edu/abs/2005SoPh..228..361Z/',$
			  types:'html'} 

frc_info = {feature:'Sunspots',$
			name:'SDOSS',version:'1.10',$
			institute:'MSSL',$
			person:'Sergei Zharkov',$
			contact:'sz2 at mssl dot ucl dot ac dot uk',$
			identifier:'HELIO_HFC',$
			enc_met:'CHAIN CODE/RASTER SCAN',$
			references:references}
			
;Pre-Processed observations information
pp_info = {institute:'Observatoire de Paris Meudon',name:'SDOSS',version:'1.10',person:'Xavier Bonnin',$	
		   contact:'xavier dot bonnin at obspm dot fr',references:"",url:'NULL',snapshot_path:'NULL',$
		   efit:0,background:1,standard:1,limbdark:1,$
		   qs:0,lineclean:0}


END