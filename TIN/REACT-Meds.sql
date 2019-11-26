SELECT DISTINCT
P.PAt_ID



FROM CLARITY.PATIENT p
INNER JOIN CLARITY.MEDS_REV_LAST_LIST lr  p.PAT_ID = lr.Pat_ID
INNER JOIN CLARITY.ORDER_MED om ON lr.MEDICATION_ORDER_ID = om.ORDER_MED_ID
INNER JOIN CLARITY.CLARITY_MEDICATION cm ON om.MEDICATION_ID = cm.MEDICATION_ID

WHERE lr.TAKING_YN = 'Y' 
AND OM.MEDICATION_ID IN (101149, 108719, 109157, 11664, 118319, 118320, 118321, 118322, 118323, 118324, 118325, 118326, 118327, 11983, 146124, 146125, 14959, 152122, 164556, 164557, 164558, 19433, 19434, 1966, 21372, 250729, 250734, 251108, 251110, 253471, 258457, 258459, 258737, 258795, 260682, 260683, 260685, 260686, 265732, 265733, 267951, 267953, 268839, 268919, 276725, 276732, 285118, 285119, 285120, 285133, 285134, 285205, 285242, 291206, 291207, 300944, 409416, 410506, 411213, 411320, 411514, 411515, 8748, 8749, 8750, 8751, 8752, 97052, 97172, 97372, 99903)
GROUP BY AL1.PAT_ID