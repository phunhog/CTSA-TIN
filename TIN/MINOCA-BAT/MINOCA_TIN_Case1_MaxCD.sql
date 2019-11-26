SELECT DISTINCT P.PAT_ID,
  I.IDENTITY_ID,
  P.SEX_C,
  P.ETHNIC_GROUP_C,
  zpr.NAME AS patientRace,
  zps.NAME AS patientSex,
  zeg.NAME AS patientEthnicity,
  Max(peh.Hosp_Disch_time)as MI_DISCH_Time
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
AND ((cedg.CURRENT_ICD10_LIST LIKE 'I21.%')
OR (cedg.CURRENT_ICD9_LIST LIKE '410.%'))
AND ((((peh.ADT_ARRIVAL_TIME   IS NULL)
AND (peh.ED_EPISODE_ID         IS NULL))
AND NOT ((peh.HOSP_ADMSN_TIME  IS NULL)
AND (peh.HOSP_DISCH_TIME       IS NULL)))
OR (NOT ((peh.ADT_ARRIVAL_TIME IS NULL)
AND (peh.ED_EPISODE_ID         IS NULL))
AND NOT ((peh.HOSP_ADMSN_TIME  IS NULL)
AND (peh.HOSP_DISCH_TIME       IS NULL))))
AND peh.CONTACT_DATE BETWEEN TRUNC(to_date('01-jun-2016 00:00:00', 'dd-mon-yyyy hh24:mi:ss')) AND TRUNC(to_date('01-jun-2018 00:00:00', 'dd-mon-yyyy hh24:mi:ss'))
AND I.IDENTITY_TYPE_ID = '154'
GROUP BY P.PAT_ID,
  I.IDENTITY_ID,
  P.SEX_C,
  P.ETHNIC_GROUP_C,
  zpr.NAME,
  zps.NAME,
  zeg.NAME
ORDER BY I.IDENTITY_ID