
SELECT       
 MRN
 , CSN
 , Last
 , First
 , MI
 , DOB
 , enc_type_c
 , patientsex
 , patientrace
 ,  patientethnicity
  , ssn
  , currentAge
  , ageAtMI
  , HOSP_ADMSN_TIME
  , HOSP_DISCHRG_TIME
  , AgeGroup
  , LastZip
  ,e.NOTE_ID
   ,e.NOTE_CSN_ID
    ,e.IP_NOTE_TYPE_C

	Into NewNetaTable

FROM   [DH5772\RSR].BrownNLP.[dbo].[qryAMIRO1MetaData]  AS a


Inner join 
  OPENQUERY(CLARITY, 
            '
			--fast PLSQL here-- join to NT commented out
			SELECT DISTINCT PE.PAT_ENC_CSN_ID,
			  PE.CONTACT_DATE,
			  P.PAT_NAME,
			  P.SEX_C,
			  i.Identity_ID,
			  ni.NOTE_ID,
			  ni.IP_NOTE_TYPE_C,
        	  znt.Name as InptNoteType,
			  ni.NOTE_FORMAT_NOADD_C,
			  ni.CREATE_INSTANT_DTTM,
			  nei.NOTE_CSN_ID,
			  nei.CONTACT_DATE AS NoteDate,
			  nei.SPECIFIED_DATETIME,
			  nei.CONTACT_DATE_REAL,
			  nei.AUTHOR_USER_ID,
			  
			  nei.NOTE_USER_ID,
			  nei.NOTE_STATUS_C,
			  --nt.Line,
			  --nt.NOTE_TEXT,
			  ni.CURRENT_AUTHOR_ID
			  
			FROM PAT_ENC PE
			INNER JOIN PATIENT P ON P.PAT_ID = PE.PAT_ID
				INNER join identity_ID i on i.pat_ID = p.Pat_ID
			INNER JOIN HNO_Info ni ON ni.PAT_ENC_CSN_ID = PE.PAT_ENC_CSN_ID
			INNER JOIN HNO_Enc_Info nei ON nei.NOTE_ID = ni.NOTE_ID
      			Inner join ZC_NOTE_TYPE_IP znt on znt.TYPE_IP_C = ni.IP_NOTE_TYPE_C
			--INNER JOIN HNO_Note_Text nt ON nt.NOTE_CSN_ID        = nei.NOTE_CSN_ID
			

			Where i.Identity_Type_ID = ''154''
			and ((nei.NOTE_STATUS_C = 2)or(nei.NOTE_STATUS_C = 3))
		
			'
			) e

on a.CSN = e.Pat_enc_CSN_ID
and e.Identity_ID = a.MRN
Order by note_ID,Note_CSN_ID,Contact_Date_Real