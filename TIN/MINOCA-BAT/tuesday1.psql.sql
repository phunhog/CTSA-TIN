Select p.Pat_ID
,I.Identity_ID
,peh.Pat_Enc_CSN_ID
,peh.HOSP_ADMSN_TIME
,OCPT.Real_CPT_Code

from 
			PATIENT P	    
			INNER JOIN IDENTITY_ID I	        ON I.PAT_ID = P.PAT_ID
            INNER JOIN Pat_ENC_HSP  PEH     on peh.PAt_ID = p.PAt_ID
	  
							Left outer JOIN Pat_OR_Adm_Link POAL ON peh.Pat_Enc_CSN_ID = POAL.OR_Link_CSN
							Left outer JOIN Or_Log L ON POAL.Or_Caselog_Id = L.Log_Id
							Left outer JOIN Or_Log_All_Proc OLAP ON OLAP.Log_Id = L.Log_Id
							Left Outer Join OR_Proc OP on OP.OR_Proc_Id = OLAP.OR_Proc_Id
							Left outer Join OR_Proc_CPT_ID OCPT on OCPT.Or_Proc_Id = OP.OR_Proc_ID
  Where I.identity_type_ID = '154'
  AND P.PAT_STATUS_C                      != 2 -- NOT Deceased
  AND (SysDate - P.BIRTH_DATE) / 365.25 >= 18 -- age 18 or older
  AND (
		(OCPT.Real_CPT_Code like '3351%')
		or (OCPT.Real_CPT_Code in ('33521','33522','33523', '33530', '33533', '33534','33535','33536','33543','33545','33548'))
		or (OCPT.Real_CPT_Code in('33140','33141'))
	
		)
		and peh.CONTACT_DATE BETWEEN 
				TRUNC(to_date('01-jun-2016 00:00:00', 'dd-mon-yyyy hh24:mi:ss')) 
				AND TRUNC(to_date('01-jul-2016 00:00:00', 'dd-mon-yyyy hh24:mi:ss'))
