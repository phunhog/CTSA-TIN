Select 'MINOCA TIN Case 2'

select 
--IDENTITY_ID
--patientRace,
--patientSex,
patientEthnicity, 
sum(kounter) as CaseCount

from

(

Select 
Cx.PAT_ID,
    Cx.IDENTITY_ID,
    Cx.patientSex,
    Cx.patientRace,
	CX.patientEthnicity,

    Cx.MI_DISCH_Time,
    Cx.CathAdmitTime,
	CX.CATH_CSN,
	cx.CathDCTime,


	Datediff(hh,Cx.CathAdmitTime,Cx.MI_DISCH_Time ) as tt,
	1 as Kounter
	
	from 
openquery
(CLARITY,
'SELECT a.PAT_ID,
    a.IDENTITY_ID,
    a.SEX_C,
    a.ETHNIC_GROUP_C,
	a.patientRace,
	a.patientSex,
	a.patientEthnicity,


    a.MI_DISCH_Time,
	b.Pat_Enc_CSN_ID as CATH_CSN,
    b.HOSP_ADMSN_TIME as CathAdmitTime,
	b.HOSP_Disch_TIME as CathDCTime
	FROM
  
	(
	SELECT DISTINCT P.PAT_ID,
    I.IDENTITY_ID,
    P.SEX_C,
    P.ETHNIC_GROUP_C,
	zpr.NAME AS patientRace,
	zps.NAME AS patientSex,
	zeg.NAME AS patientEthnicity,

    MAX(peh.HOSP_DISCH_TIME) AS MI_DISCH_Time
  FROM Clarity_EDG cedg
  INNER JOIN hsp_Acct_DX_List hadx
  ON hadx.DX_ID = cedg.DX_ID
  INNER JOIN HSP_ACCT_PAT_CSN hapc
  ON hapc.HSP_ACCOUNT_ID = hadx.HSP_ACCOUNT_ID
  INNER JOIN pat_Enc_HSP peh
  ON peh.PAT_ENC_CSN_ID = hapc.PAT_ENC_CSN_ID
  INNER JOIN PATIENT P
  ON P.PAT_ID = peh.PAT_ID
  INNER JOIN IDENTITY_ID I
  ON I.PAT_ID = P.PAT_ID
  INNER JOIN patient_race pr
  ON pr.PAT_ID = P.PAT_ID
  INNER JOIN zc_patient_race zpr
  ON zpr.PATIENT_RACE_C = pr.PATIENT_RACE_C
  INNER JOIN zc_patient_sex zps
  ON zps.PATIENT_SEX_C = P.SEX_C
  INNER JOIN zc_ethnic_group zeg
  ON zeg.ETHNIC_GROUP_C                  = P.ETHNIC_GROUP_C
  WHERE hadx.LINE                        = 1
  AND P.PAT_STATUS_C                    != 2
  AND (SysDate - P.BIRTH_DATE) / 365.25 >= 18
  AND ((cedg.CURRENT_ICD10_LIST LIKE ''I21.%'')
  OR (cedg.CURRENT_ICD9_LIST LIKE ''410.%''))
  AND ((((peh.ADT_ARRIVAL_TIME   IS NULL)
  AND (peh.ED_EPISODE_ID         IS NULL))
  AND NOT ((peh.HOSP_ADMSN_TIME  IS NULL)
  AND (peh.HOSP_DISCH_TIME       IS NULL)))
  OR (NOT ((peh.ADT_ARRIVAL_TIME IS NULL)
  AND (peh.ED_EPISODE_ID         IS NULL))
  AND NOT ((peh.HOSP_ADMSN_TIME  IS NULL)
  AND (peh.HOSP_DISCH_TIME       IS NULL))))
  AND peh.CONTACT_DATE BETWEEN TRUNC(to_date(''01-jun-2016 00:00:00'', ''dd-mon-yyyy hh24:mi:ss'')) AND TRUNC(to_date(''01-jun-2018 00:00:00'', ''dd-mon-yyyy hh24:mi:ss''))
  AND I.IDENTITY_TYPE_ID = ''154''
  GROUP BY P.PAT_ID,
    I.IDENTITY_ID,
    P.SEX_C,
    P.ETHNIC_GROUP_C,
    zpr.NAME,
    zps.NAME,
    zeg.NAME
  ORDER BY I.IDENTITY_ID
  ) a


INNER JOIN
  (SELECT DISTINCT P.PAT_ID as XX,
  
    I.IDENTITY_ID,
    I.IDENTITY_TYPE_ID,
    PEH.PAT_ENC_CSN_ID,
    PEH.HOSP_ADMSN_TIME,
	PEH.HOSP_DISCH_TIME
    /*
    TO_CHAR(HT.SERVICE_DATE, ''MM/DD/YYYY'') AS PROC_DATE,
    HT.CPT_CODE                            AS CPT,
    SER.PROV_NAME                          AS prov_name,
    HT.PAT_ENC_CSN_ID,
    P.PAT_STATUS,
    P.BIRTH_DATE,
    P.ETHNIC_GROUP_C,
    P.SEX_C,
    P.ETHNIC_GROUP_C,
    TO_CHAR(PEH.ADT_ARRIVAL_TIME, ''DD-MON-YYYY HH24:MI:SS'') AS ADT_Arrival_Time,
    TO_CHAR(PEH.HOSP_ADMSN_TIME, ''DD-MON-YYYY HH24:MI:SS'')  AS Hosp_Admission_Time,
    TO_CHAR(PEH.HOSP_DISCH_TIME, ''DD-MON-YYYY HH24:MI:SS'')  AS HOSP_DISCH_TIME
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
  WHERE I.IDENTITY_TYPE_ID               = ''154''
  AND HT.CPT_CODE                       IN (''93454'', ''93456'', ''93458'', ''93460'')

  AND HT.TX_TYPE_HA_C                    = 1
  AND HA.ACCT_BILLSTS_HA_C              <> 99
  AND LOC.HOSP_PARENT_LOC_ID             = 1010
  AND P.PAT_STATUS_C                    != 2
  AND (SysDate - P.BIRTH_DATE) / 365.25 >= 18
  ) b 
  
  ON a.PAT_ID                        = b.XX

  ') CX
  where Datediff(hh,Cx.CathAdmitTime,Cx.MI_DISCH_Time ) Between 0 and  168

  ) x

  group by  
  --patientRace
--patientSex
patientEthnicity
		
		

