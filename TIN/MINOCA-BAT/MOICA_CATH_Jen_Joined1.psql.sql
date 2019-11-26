SELECT DISTINCT P.PAT_ID,
  I.IDENTITY_ID,
  I.IDENTITY_TYPE_ID,
  PEH.PAT_ENC_CSN_ID,
  PEH.HOSP_ADMSN_TIME,
  TO_CHAR(HT.SERVICE_DATE, 'MM/DD/YYYY') AS PROC_DATE,
  HT.CPT_CODE                            AS CPT,
  SER.PROV_NAME                          AS prov_name,
  HT.PAT_ENC_CSN_ID,
  P.PAT_STATUS,
  P.BIRTH_DATE,
  P.ETHNIC_GROUP_C,
  
  P.SEX_C,
  P.ETHNIC_GROUP_C,
  zpr.NAME AS patientRace,
  zps.NAME AS patientSex,
  zeg.NAME AS patientEthnicity,
  TO_char(peh.ADT_ARRIVAL_TIME, 'DD-MON-YYYY HH24:MI:SS') as ADT_Arrival_Time,
  TO_char(peh.HOSP_ADMSN_TIME, 'DD-MON-YYYY HH24:MI:SS') as Hosp_Admission_Time,
  TO_char(peh.HOSP_DISCH_TIME, 'DD-MON-YYYY HH24:MI:SS') as HOSP_DISCH_TIME
  
  
  
  
  
  
  
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
ON DEP.REV_LOC_ID                      = LOC.LOC_ID


INNER JOIN patient_race pr	        ON pr.PAT_ID = P.PAT_ID
			INNER JOIN zc_patient_race zpr	    ON zpr.PATIENT_RACE_C = pr.PATIENT_RACE_C
			INNER JOIN zc_patient_sex zps	    ON zps.PATIENT_SEX_C = P.SEX_C
			INNER JOIN zc_ethnic_group zeg	    ON zeg.ETHNIC_GROUP_C  = P.ETHNIC_GROUP_C




WHERE I.IDENTITY_TYPE_ID               = '154'
AND HT.CPT_CODE                       IN ('93454', '93456', '93458', '93460')
AND HT.SERVICE_DATE                   >= TO_DATE('01/04/2019', 'MM/DD/YYYY')
AND HT.SERVICE_DATE                   <= TO_DATE('01/04/2019', 'MM/DD/YYYY')
AND HT.TX_TYPE_HA_C                    = 1
AND HA.ACCT_BILLSTS_HA_C              <> 99
AND LOC.HOSP_PARENT_LOC_ID             = 1010
AND P.PAT_STATUS_C                    != 2
AND (SysDate - P.BIRTH_DATE) / 365.25 >= 18