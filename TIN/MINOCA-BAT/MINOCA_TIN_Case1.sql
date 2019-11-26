Select 'MINOCA TIN Case 1'

select --IDENTITY_ID
patientRace,
--patientSex,
--patientEthnicity, 
sum(kounter) as CaseCount

from

(

		Select Distinct

		  IDENTITY_ID,
		  SEX_C,
  
		  ETHNIC_GROUP_C,
		  patientRace,
		  patientSex,
		  patientEthnicity, 
		  1 as kounter
		 from
		openquery
		(CLARITY,




		'SELECT DISTINCT P.PAT_ID,
		  I.IDENTITY_ID,
		  P.SEX_C,
		  P.ETHNIC_GROUP_C,
		  zpr.NAME AS patientRace,
		  zps.NAME AS patientSex,
		  zeg.NAME AS patientEthnicity,
		--peh.ADT_ARRIVAL_TIME,
		--peh.HOSP_ADMSN_TIME,
		--peh.HOSP_DISCH_TIME,
		--peh.ED_EPISODE_ID,
  
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
			  )  then ''IPI_encounter'' 
			  else ''ED_encounter'' 
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
			AND ((cedg.CURRENT_ICD10_LIST LIKE ''I21.%'') --use like to get any of the trailing dits after the decimal
			OR (cedg.CURRENT_ICD9_LIST LIKE ''410.%''))--like again
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
				TRUNC(to_date(''01-jun-2016 00:00:00'', ''dd-mon-yyyy hh24:mi:ss'')) 
				AND TRUNC(to_date(''01-jun-2018 00:00:00'', ''dd-mon-yyyy hh24:mi:ss''))
			AND I.IDENTITY_TYPE_ID = ''154''
		order by I.IDENTITY_ID
		'


		)c


) x
group by  patientRace
		  --patientSex,
		  --patientEthnicity
		
		


