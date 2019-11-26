




Select a.* 
,b.Pat_Enc_CSN_ID
,b.HOSP_ADMSN_TIME

--,b.HOSP_ADMSN_TIME - a.HOSP_DISCH_TIME as difff
,trunc((((86400*(sysdate - a.HOSP_DISCH_TIME))/60)/60)/24) as Days
--,trunc(((86400*(b.HOSP_ADMSN_TIME - a.HOSP_DISCH_TIME))/60)/60)-24*(trunc((((86400*(b.HOSP_ADMSN_TIME - a.HOSP_DISCH_TIME))/60)/60)/24)) as hours


from


(
SELECT DISTINCT P.PAT_ID,
		  I.IDENTITY_ID,
      peh.PAT_ENC_CSN_ID,
		  P.SEX_C,
		  P.ETHNIC_GROUP_C,
		  zpr.NAME AS patientRace,
		  zps.NAME AS patientSex,
		  zeg.NAME AS patientEthnicity,
		  TO_char(peh.ADT_ARRIVAL_TIME, 'DD-MON-YYYY HH24:MI:SS') as ADT_Arrival_Time,
      TO_char(peh.HOSP_ADMSN_TIME, 'DD-MON-YYYY HH24:MI:SS') as Hosp_Admission_Time,
      TO_char(peh.HOSP_DISCH_TIME, 'DD-MON-YYYY HH24:MI:SS') as HOSP_DISCH_TIME,

      
      -- ORACLE Date math reference https://www.akadia.com/services/ora_date_time.html
      TO_CHAR(sysdate, 'DD-MON-YYYY HH24:MI:SS') as SS,
      trunc((((86400*(sysdate-peh.ADT_ARRIVAL_TIME))/60)/60)/24) as Days,
      trunc(((86400*(sysdate-peh.HOSP_DISCH_TIME))/60)/60)-24*(trunc((((86400*(sysdate-peh.HOSP_DISCH_TIME))/60)/60)/24)) as hours,
  
		Case  when  (
				  (
				  -- there is no arrival time and ED episode ID
				  (peh.ADT_ARRIVAL_TIME is null)      and (peh.ED_EPISODE_ID is null)
				  )
          
				  and not
				  --there is no HOSP Admission time and tnere is no HOSAP DC time
				  (
				  (peh.HOSP_ADMSN_TIME is null)      and(peh.HOSP_DISCH_TIME is null)
				  )
			  )  then 'IPI_encounter' 
			  else 'ED_encounter' 
		end as encTYPE

		FROM Clarity_EDG cedg
			INNER JOIN hsp_Acct_DX_List hadx	ON hadx.DX_ID = cedg.DX_ID
			INNER JOIN HSP_ACCT_PAT_CSN hapc	ON hapc.HSP_ACCOUNT_ID = hadx.HSP_ACCOUNT_ID
			INNER JOIN pat_Enc_HSP peh	        ON peh.PAT_ENC_CSN_ID = hapc.PAT_ENC_CSN_ID
			INNER JOIN PATIENT P	            ON P.PAT_ID = peh.PAT_ID
			INNER JOIN IDENTITY_ID I	        ON I.PAT_ID = P.PAT_ID
			INNER JOIN patient_race pr	        ON pr.PAT_ID = P.PAT_ID
			INNER JOIN zc_patient_race zpr	    ON zpr.PATIENT_RACE_C = pr.PATIENT_RACE_C
			INNER JOIN zc_patient_sex zps	    ON zps.PATIENT_SEX_C = P.SEX_C
			INNER JOIN zc_ethnic_group zeg	    ON zeg.ETHNIC_GROUP_C  = P.ETHNIC_GROUP_C

		WHERE hadx.LINE								= 1 -- Primary diagnosis is on line 1
			AND P.PAT_STATUS_C                      != 2 -- NOT Deceased
			AND (SysDate - P.BIRTH_DATE) / 365.25 >= 18 -- age 18 or older
			AND ((cedg.CURRENT_ICD10_LIST LIKE 'I21.%') --use like to get any of the trailing dits after the decimal
			OR (cedg.CURRENT_ICD9_LIST LIKE '410.%'))--like again
			AND  (
				  (
				  -- inpatient admission rules
					  (
						  (
						  (peh.ADT_ARRIVAL_TIME is null)      and (peh.ED_EPISODE_ID is null)
						  )
              
						  and not
						  (
						  (peh.HOSP_ADMSN_TIME is null)      and(peh.HOSP_DISCH_TIME is null)
						  )
					  )
          
          
					  or---Emergency department rules
					  (
					  NOT
					  (
					  -- there is an arrival time and ED visit
							(peh.ADT_ARRIVAL_TIME is null)      and (peh.ED_EPISODE_ID is null)
							)
                
							and not
							-- there is also a hospital admission time and hospital DC time present
							(
							(peh.HOSP_ADMSN_TIME is null)      and(peh.HOSP_DISCH_TIME is null)
							)
					  )
					)
				  ) 
			AND peh.CONTACT_DATE BETWEEN 
				TRUNC(to_date('01-jun-2016 00:00:00', 'dd-mon-yyyy hh24:mi:ss')) 
				AND TRUNC(to_date('01-jun-2018 00:00:00', 'dd-mon-yyyy hh24:mi:ss'))
			AND I.IDENTITY_TYPE_ID = '154'
) a

-----------------------------------

Inner join 
(
Select p.Pat_ID
,I.Identity_ID
,peh.Pat_Enc_CSN_ID
,peh.HOSP_ADMSN_TIME

from 
			PATIENT P	    
			INNER JOIN IDENTITY_ID I	        ON I.PAT_ID = P.PAT_ID
            INNER JOIN Pat_ENC_HSP  PEH     on peh.PAt_ID = p.PAt_ID
	  
							Left outer JOIN Pat_OR_Adm_Link POAL ON pe.Pat_Enc_CSN_ID = POAL.OR_Link_CSN
							Left outer JOIN Or_Log L ON POAL.Or_Caselog_Id = L.Log_Id
							Left outer JOIN Or_Log_All_Proc OLAP ON OLAP.Log_Id = L.Log_Id
							Left Outer Join OR_Proc OP on OP.OR_Proc_Id = OLAP.OR_Proc_Id
							Left outer Join OR_Proc_CPT_ID OCPT on OCPT.Or_Proc_Id = OP.OR_Proc_ID
  Where I.identity_type_ID = '154'
  AND P.PAT_STATUS_C                      != 2 -- NOT Deceased
  AND (SysDate - P.BIRTH_DATE) / 365.25 >= 18 -- age 18 or older
  AND (
		(OCPT.Real_CPT_Code = '93454')
		or (OCPT.Real_CPT_Code = '93456')
		or (OCPT.Real_CPT_Code = '93458')
		or (OCPT.Real_CPT_Code = '93460')
		)
		peh.CONTACT_DATE BETWEEN 
				TRUNC(to_date('01-jun-2016 00:00:00', 'dd-mon-yyyy hh24:mi:ss')) 
				AND TRUNC(to_date('01-jun-2018 00:00:00', 'dd-mon-yyyy hh24:mi:ss'))
--- ont in OR LOG.... I may have to search AMARS OP CPT SQL
 and OP.Proc_Name  like'%CORONARY ANGIOGRAPHY%'

)b
on b.pat_id = a.Pat_ID
--where b.HOSP_ADMSN_TIME < a.HOSP_DISCH_TIME