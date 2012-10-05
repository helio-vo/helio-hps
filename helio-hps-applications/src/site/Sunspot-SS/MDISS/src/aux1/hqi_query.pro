FUNCTION hqi_query,address,from,method=method, $
                   starttime=starttime, $
                   endtime=endtime, $
                   where=where, url=url, $
                   maxrecords=maxrecords, $
                   STRUCTURE=STRUCTURE, $
                   VERBOSE=VERBOSE
                   
;+
; NAME:
;		hqi_query
;
; PURPOSE:
;		Send a PQL query to a distant SQL database server 
;       using the Helio Query Interface (HQI),
;       and return the votable in a string or a structure.
;
; CATEGORY:
;		Web service
;
; GROUP:
;		None.
;
; CALLING SEQUENCE:
;		IDL> response = hqi_query(address,from)
;
; INPUTS:
;       address - URL of the distant HQI.
;       from    - Name of the table to query. 
;
; OPTIONAL INPUTS:
;       method     - Name of the method to invoke.
;                    Default is "HelioQueryService".
;       starttime  - Specify start date and time.
;       endtime    - Specify end date and time.
;       where      - Specify a where clause (in PQL syntax).
;       maxrecords - Specify the max number of records returned.
;
; KEYWORD PARAMETERS: 
;       /STRUCTURE - Return response as a structure instead of a string.
;		/VERBOSE   - Talkative mode.
;		
; OUTPUTS:
;		reponse - Response returned by the hqi (string or structure type). 				
;
; OPTIONAL OUTPUTS:
;       url - the url of the query.		
;		
; COMMON BLOCKS:
;		None.		
;
; SIDE EFFECTS:
;		None.
;
; RESTRICTIONS/COMMENTS:
;       An internet access is required.
;
; CALL:
;		webget
;       decode_votable
;
; EXAMPLE:
;		;To get SoHO/MDI instrument data between 2007-01-02T00:00:00 and 
;       ;2007-01-04T00:00:00 from IAS/MEDOC:
;       content = hqi_query('helio-hqi.ias.u-psud.fr/helio-soho','soho_view' ,$
;                           starttime='2007-01-02T00:00:00', $
;                           endtime='2007-01-04T00:00:00', $
;                           where='instrument,MDI',url=url)
;       print,url
;           'http://helio-hqi.ias.u-psud.fr/helio-soho/HelioQueryService?FROM=soho_view&STARTTIME=2007-01-02T00:00:00&ENDTIME=2007-01-04T00:00:00&WHERE=instrument;MDI'
;		
; MODIFICATION HISTORY:
;		Written by:		X.Bonnin, 10-JAN-2012.
;-                     
qte = string(34b)  
  
if (n_params() lt 2) then begin
    message,/CONT,'Call is:'
    print,'response = hqi_query(address, from, $'
    print,'                     method=method, $'
    print,'                     starttime=starttime, $'
    print,'                     endtime=endtime, $'
    print,'                     where=where, url=url, $'
    print,'                     /STRUCTURE,/VERBOSE'
    return,''
endif                 
STRUCTURE = keyword_set(STRUCTURE)
VERBOSE = keyword_set(VERBOSE)

if not (keyword_set(method)) then mthd = 'HelioQueryService' $
else mthd = strtrim(method[0],2)


; Build url of the query
if (strmatch(address,'http://')) then url = strtrim(address[0],2) $
else url = 'http://'+strtrim(address[0],2)
 
url = url + '/' + mthd + '?FROM=' + strtrim(from[0],2)

if (keyword_set(starttime)) then url = url + '&STARTTIME=' + strtrim(starttime[0],2)
if (keyword_set(endtime)) then url = url + '&ENDTIME=' + strtrim(endtime[0],2)  
if (keyword_set(where)) then url = url + '&WHERE=' + strtrim(where[0],2)
if (keyword_set(maxrecords)) then url = url + '&MAXRECORDS=' + strtrim(maxrecords[0],2)
   
cmd = 'curl -s '+qte+url+qte   
if (VERBOSE) then print,cmd
spawn,cmd,response
   
if (VERBOSE) then print,strtrim(n_elements(response),2) + ' rows returned.'

if (STRUCTURE) then response = decode_votable(response,/QUIET)

return,response
END   