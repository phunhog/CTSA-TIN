SELECT pe.PAT_ID,
  pe.PAT_ENC_CSN_ID,
  POAL.PAT_ENC_CSN_ID,
  pe.CONTACT_DATE,
  POAL.PAT_ID,
  POAL.PAT_ENC_CSN_ID,
  L.LOG_ID,
  L.LOG_NAME,
  L.SURGERY_DATE,
  L.CASE_TYPE_C,
  L.PAT_ID    AS PAT_ID1,
  OLAP.LOG_ID AS LOG_ID1,
  OLAP.LINE,
  OLAP.OR_PROC_ID,
  OP.OR_PROC_ID AS OR_PROC_ID1,
  OCPT.REAL_CPT_CODE,
  OP.PROC_NAME,
  OCPT.CPT_ID,
  OCPT.LINE AS LINE1,
  OP.INACTIVE_YN,
  OCPT.OR_PROC_ID AS OR_PROC_ID2
  
FROM CLARITY.PAT_ENC pe


INNER JOIN Pat_OR_Adm_Link POAL

--Which is the correct join here
--ON pe.PAT_ENC_CSN_ID = POAL.PAT_ENC_CSN_ID and pe.PAt_ID = POAL.PAT_ID
--ON pe.PAT_ENC_CSN_ID = POAL.OR_LINK_CSN
ON pe.PAT_ENC_CSN_ID = POAL.PAT_ENC_CSN_ID




LEFT OUTER JOIN Or_Log L ON POAL.OR_CASELOG_ID = L.LOG_ID
LEFT OUTER JOIN Or_Log_All_Proc OLAP ON OLAP.LOG_ID = L.LOG_ID
LEFT OUTER JOIN OR_Proc OP ON OP.OR_PROC_ID = OLAP.OR_PROC_ID
LEFT OUTER JOIN OR_Proc_CPT_ID OCPT ON OCPT.OR_PROC_ID    = OP.OR_PROC_ID


WHERE pe.CONTACT_DATE =  '04-JAN-19'
--AND OP.PROC_NAME      = 'CARDIAC CATHETERIZATION'
--and INACTIVE_YN= 'N'
--and pe.PAT_ENC_CSN_ID = '53101453'
--and  OCPT.REAL_CPT_CODE like '93%'