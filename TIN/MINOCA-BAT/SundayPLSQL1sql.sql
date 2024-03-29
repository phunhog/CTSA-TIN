SELECT p.PAT_ID,
  pe.PAT_ENC_CSN_ID,
  p.PAT_LAST_NAME,
  I.IDENTITY_ID AS MRN,
  pe.CONTACT_DATE,
  pe.ENC_TYPE_C,
  pe.DEPARTMENT_ID,
  pe.VISIT_PROV_ID,
  pe.ENC_CLOSED_YN,
  POAL.PAT_ID,
  L.LOG_ID,
  POAL.CASE_ID,
  POAL.LOG_ID AS LOG_ID1
FROM Pat_Enc pe
INNER JOIN patient p
ON p.PAT_ID = pe.PAT_ID
INNER JOIN Identity_ID I
ON I.PAT_ID = p.PAT_ID
LEFT JOIN Pat_OR_Adm_Link POAL
ON pe.PAT_ENC_CSN_ID = POAL.PAT_ENC_CSN_ID
LEFT OUTER JOIN Or_Log L
ON POAL.OR_CASELOG_ID  = L.LOG_ID
WHERE p.PAT_ID         = 'Z3157169'
--AND pe.PAT_ENC_CSN_ID  = 67161023
AND I.IDENTITY_TYPE_ID = '154'