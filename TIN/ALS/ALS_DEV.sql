SELECT DISTINCT 
HA.PRIM_ENC_CSN_ID AS ENCOUNTER_ID
, I.IDENTITY_ID AS MRN
,i.identity_type_ID
, HA.DISCH_DATE_TIME AS DX_DATE
, EDG.CURRENT_ICD10_LIST AS DX_CODE
, EDG.DX_NAME AS DX_DESCRIPTION

 , zpr.Name as patientRace
 , zps.name as patientSex
 , zeg.name as patientEthnicity
-- ,(Sysdate - pat.Birth_Date) / 365.25

FROM 
CLARITY.HSP_ACCOUNT HA

INNER JOIN CLARITY.PAT_ENC PE ON HA.PRIM_ENC_CSN_ID=PE.PAT_ENC_CSN_ID
INNER JOIN CLARITY.PATIENT PAT ON HA.PAT_ID=PAT.PAT_ID
INNER JOIN CLARITY.IDENTITY_ID I ON pat.PAT_ID= i.PAT_ID

		INNER JOIN patient_race pr on pr.Pat_ID = pat.Pat_ID
		inner join zc_patient_race zpr on zpr.patient_race_c = pr.patient_race_c 
		inner join zc_patient_sex zps on zps.patient_sex_c = pat.sex_c
		inner join zc_ethnic_group zeg on zeg.ethnic_group_c = pat.ethnic_group_c
	
LEFT JOIN CLARITY.CLARITY_DEP DEP ON PE.EFFECTIVE_DEPT_ID = DEP.DEPARTMENT_ID
LEFT JOIN CLARITY_LOC LOC ON DEP.REV_LOC_ID = LOC.LOC_ID
LEFT JOIN ZC_DISP_ENC_TYPE DISP ON PE.ENC_TYPE_C = DISP.DISP_ENC_TYPE_C
INNER JOIN CLARITY.HSP_ACCT_DX_LIST HA_DX ON HA.HSP_ACCOUNT_ID = HA_DX.HSP_ACCOUNT_ID
INNER JOIN CLARITY.CLARITY_EDG EDG ON HA_DX.DX_ID = EDG.DX_ID

WHERE 
HA.DISCH_DATE_TIME BETWEEN TO_DATE('01/01/2015', 'MM/DD/YYYY') AND TO_DATE('12/31/2018', 'MM/DD/YYYY')
AND I.IDENTITY_TYPE_ID = '154'
AND HA.ACCT_BILLSTS_HA_C <> 99
AND LOC.HOSP_PARENT_LOC_ID = 1010
AND EDG.CURRENT_ICD10_LIST =  'G12.21'
AND Not ((PAT.PAT_STATUS_C =2) OR (PAT.PAT_STATUS_C IS Null))
and  (Sysdate - pat.Birth_Date) / 365.25 >= 18.00
--Order by MRN, encounter_ID

-----------------------------------------

UNION 
SELECT DISTINCT 



 ARPB.PAT_ENC_CSN_ID AS ENCOUNTER_ID
, I.IDENTITY_ID AS MRN
, i.identity_type_ID
, ARPB.SERVICE_DATE AS DX_DATE
, EDG.CURRENT_ICD10_LIST AS DX_CODE
, EDG.DX_NAME AS DX_DESCRIPTION

 , zpr.Name as patientRace
 , zps.name as patientSex
 , zeg.name as patientEthnicity



FROM CLARITY.ARPB_TRANSACTIONS ARPB

INNER JOIN CLARITY.PATIENT PAT ON ARPB.PATIENT_ID = PAT.PAT_ID
INNER JOIN CLARITY.IDENTITY_ID I ON pat.PAT_ID = I.PAT_ID


		INNER JOIN patient_race pr on pr.Pat_ID = pat.Pat_ID
		inner join zc_patient_race zpr on zpr.patient_race_c = pr.patient_race_c 
		inner join zc_patient_sex zps on zps.patient_sex_c = pat.sex_c
		inner join zc_ethnic_group zeg on zeg.ethnic_group_c = pat.ethnic_group_c
	
INNER JOIN CLARITY.CLARITY_SER SER ON ARPB.BILLING_PROV_ID = SER.PROV_ID
LEFT JOIN CLARITY.PAT_ENC PE ON ARPB.PAT_ENC_CSN_ID = PE.PAT_ENC_CSN_ID
LEFT JOIN CLARITY.CLARITY_DEP DEP ON PE.EFFECTIVE_DEPT_ID = DEP.DEPARTMENT_ID
left JOIN CLARITY.CLARITY_LOC LOC ON DEP.REV_LOC_ID = LOC.LOC_ID
LEFT JOIN ZC_DISP_ENC_TYPE DISP ON PE.ENC_TYPE_C = DISP.DISP_ENC_TYPE_C
INNER JOIN V_ARPB_CODING_DX ARPB_DX ON ARPB.TX_ID = ARPB_DX.TX_ID
INNER JOIN CLARITY_EDG EDG ON ARPB_DX.DX_ID = EDG.DX_ID

WHERE ARPB.SERVICE_DATE  BETWEEN TO_DATE('01/01/2015', 'MM/DD/YYYY') AND TO_DATE('12/31/2018', 'MM/DD/YYYY') 
AND  ARPB.TX_TYPE_C=1
AND I.IDENTITY_TYPE_ID = '154'
AND LOC.HOSP_PARENT_LOC_ID = 1010
AND EDG.CURRENT_ICD10_LIST =  'G12.21'
AND Not ((PAT.PAT_STATUS_C =2) OR (PAT.PAT_STATUS_C IS Null))
and  (Sysdate - pat.Birth_Date) / 365.25 >= 18.00
--Order by MRN, encounter_ID

---------------------------------------------------------------------------


UNION 

SELECT DISTINCT

 pe.PAT_ENC_CSN_ID AS ENCOUNTER_ID
, I.IDENTITY_ID AS MRN
, i.identity_type_ID
, pe.Contact_date AS DX_DATE
, EDG.CURRENT_ICD10_LIST AS DX_CODE
, EDG.DX_NAME AS DX_DESCRIPTION

 , zpr.Name as patientRace
 , zps.name as patientSex
 , zeg.name as patientEthnicity


FROM PAT_ENC PE
INNER JOIN PAT_ENC_DX PE_DX ON PE.PAT_ENC_CSN_ID = PE_DX.PAT_ENC_CSN_ID


	
INNER JOIN CLARITY_EDG EDG ON PE_DX.DX_ID = EDG.DX_ID
INNER JOIN IDENTITY_ID I ON PE.PAT_ID = I.PAT_ID
INNER JOIN CLARITY.CLARITY_DEP DEP ON PE.EFFECTIVE_DEPT_ID = DEP.DEPARTMENT_ID
INNER JOIN CLARITY.CLARITY_LOC LOC ON DEP.REV_LOC_ID = LOC.LOC_ID
INNER JOIN PATIENT PAT ON PE.PAT_ID = PAT.PAT_ID
		INNER JOIN patient_race pr on pr.Pat_ID = pat.Pat_ID
		inner join zc_patient_race zpr on zpr.patient_race_c = pr.patient_race_c 
		inner join zc_patient_sex zps on zps.patient_sex_c = pat.sex_c
		inner join zc_ethnic_group zeg on zeg.ethnic_group_c = pat.ethnic_group_c

WHERE I.IDENTITY_TYPE_ID ='154'
AND ((EDG.CURRENT_ICD10_LIST= 'G12.21') OR (EDG.CURRENT_ICD9_LIST = '335.20'))
AND PE.CONTACT_DATE BETWEEN to_date('01/01/2015', 'MM/DD/YYYY') AND to_date('12/31/2018', 'MM/DD/YYYY')
AND LOC.HOSP_PARENT_LOC_ID = 1010
AND Not ((PAT.PAT_STATUS_C =2) OR (PAT.PAT_STATUS_C IS Null))
and  (Sysdate - pat.Birth_Date) / 365.25 >= 18.00
Order by MRN, encounter_ID
