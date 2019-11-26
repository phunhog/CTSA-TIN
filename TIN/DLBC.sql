SELECT       
 p.PatientID
 ,p.RSRMPILong as MPI
 ,SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5',p.RSRMPILong )), 3, 32)as HashPatientID
 , Convert(nvarchar(12),t.TumorID) as tumorID
 ,SUBSTRING(master.dbo.fn_varbintohexstr(HashBytes('MD5',Convert(nvarchar(12),t.TumorID) )), 3, 32)as HashTUmorID

 , t.PrimarySite
 , s.Descript as PrimarySiteDescriprion
 , t.Histology
 , m.Descript as HistologyPrescription
 , t.Grade
 , [dbo].[udfMETRIQ_TR_Date](t.DateDx) as DiagnosisDate
 , t.TxSummFirst as FirstCourseTxSummary
 , t.BestCSTNMStage 
 , t.CS_SSFactor1 as SiteSpecificFactor1
 , [dbo].[udfMETRIQ_TR_Date](p.BirthDate) as BirthDate

  ,Datediff(yyyy,[dbo].[udfMETRIQ_TR_Date](p.BirthDate),[dbo].[udfMETRIQ_TR_Date](t.DateDx)) as AgeAtDX
FROM            tblPatient AS p 
INNER JOIN tblTumor AS t ON p.RSRMPILong = t.RSRMPILong
Inner join [dbo].[tblWHOICDO3Topography]s on s.Code = t.PrimarySite
Inner join [dbo].[tblWHOICDO3Morphology]m on m.Code = t.Histology

WHERE        (t.Histology = N'96803') 
AND (t.DateDx BETWEEN 20050101 AND 20170301) -- include date range
AND (t.BestCSTNMStage LIKE '1%' OR t.BestCSTNMStage LIKE '2%')-- include stages 1 and 2-- not sure if this matches to "Ann Arbor Stage"
and NOT (t.CS_SSFactor1 = '010') --- NOT HIV related lymphoma
and t.TxSummFirst like'%I%' --Evidence of Immunotherapy in first course treastment
and Datediff(yyyy,[dbo].[udfMETRIQ_TR_Date](p.BirthDate),[dbo].[udfMETRIQ_TR_Date](t.DateDx))between 18 and 90 -- include ages