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


++++++++++++++++++++++++++++++++++++++++++++++++++++++

Select p.Pat_ID
,I.Identity_ID
,peh.Pat_Enc_CSN_ID
,peh.HOSP_ADMSN_TIME
,PEH.HOSP_DISCH_TIME

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


--------------------Below Case3 Cath
UNION SELECT DISTINCT P.PAT_ID as yy,
  
    I.IDENTITY_ID,

    PEH.PAT_ENC_CSN_ID,
    PEH.HOSP_ADMSN_TIME,
	PEH.HOSP_DISCH_TIME
    /*
    TO_CHAR(HT.SERVICE_DATE, 'MM/DD/YYYY') AS PROC_DATE,
    HT.CPT_CODE                            AS CPT,
    SER.PROV_NAME                          AS prov_name,
    HT.PAT_ENC_CSN_ID,
    P.PAT_STATUS,
    P.BIRTH_DATE,
    P.ETHNIC_GROUP_C,
    P.SEX_C,
    P.ETHNIC_GROUP_C,
    TO_CHAR(PEH.ADT_ARRIVAL_TIME, 'DD-MON-YYYY HH24:MI:SS') AS ADT_Arrival_Time,
    TO_CHAR(PEH.HOSP_ADMSN_TIME, 'DD-MON-YYYY HH24:MI:SS')  AS Hosp_Admission_Time,
    TO_CHAR(PEH.HOSP_DISCH_TIME, 'DD-MON-YYYY HH24:MI:SS')  AS HOSP_DISCH_TIME
    */
  FROM PATIENT P
  INNER JOIN IDENTITY_ID I
  ON I.PAT_ID = P.PAT_ID
  INNER JOIN Pat_ENC_HSP PEH
  ON PEH.PAT_ID = P.PAT_ID
  INNER JOIN CLARITY.HSP_TRANSACTIONS HT
  ON HT.PAT_ENC_CSN_ID = PEH.PAT_ENC_CSN_ID
  INNER JOIN CLARITY.HSP_ACCOUNT HA
  ON HA.HSP_ACCOUNT_ID = HT.HSP_ACCOUNT_ID
  INNER JOIN CLARITY.CLARITY_SER SER
  ON HT.BILLING_PROV_ID = SER.PROV_ID
  INNER JOIN CLARITY.IDENTITY_ID IDEN
  ON HA.PAT_ID = IDEN.PAT_ID
  INNER JOIN CLARITY.PATIENT PAT
  ON HA.PAT_ID = PAT.PAT_ID
  LEFT JOIN CLARITY.CLARITY_DEP DEP
  ON HA.DISCH_DEPT_ID = DEP.DEPARTMENT_ID
  LEFT JOIN CLARITY_LOC LOC
  ON DEP.REV_LOC_ID = LOC.LOC_ID
  INNER JOIN patient_race pr
  ON pr.PAT_ID = P.PAT_ID
  INNER JOIN zc_patient_race zpr
  ON zpr.PATIENT_RACE_C = pr.PATIENT_RACE_C
  INNER JOIN zc_patient_sex zps
  ON zps.PATIENT_SEX_C = P.SEX_C
  INNER JOIN zc_ethnic_group zeg
  ON zeg.ETHNIC_GROUP_C                  = P.ETHNIC_GROUP_C
  
  WHERE I.IDENTITY_TYPE_ID               = '154'
  AND HT.CPT_CODE                       IN ('92921', '92924','92925','92928','92929','92933','92934','92937','92938','92941','92943','92944','92973')

  AND HT.TX_TYPE_HA_C                    = 1
  AND HA.ACCT_BILLSTS_HA_C              <> 99
  AND LOC.HOSP_PARENT_LOC_ID             = 1010
  AND P.PAT_STATUS_C                    != 2
  AND (SysDate - P.BIRTH_DATE) / 365.25 >= 18
  and peh.CONTACT_DATE BETWEEN 
				TRUNC(to_date('01-jun-2016 00:00:00', 'dd-mon-yyyy hh24:mi:ss')) 
				AND TRUNC(to_date('01-jul-2016 00:00:00', 'dd-mon-yyyy hh24:mi:ss'))

