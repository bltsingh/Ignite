SELECT 
claimsInfo.MEMBER_ID,
inpatientAdmitClaims.ADM_DATE HOSP_ADM_DATE,
inpatientAdmitClaims.DC_DATE HOSP_DC_DATE,
inpatientAdmitClaims.FROM_DATE HOSP_FROM_DATE,
inpatientAdmitClaims.TO_DATE HOSP_TO_DATE,

inpatientAdmitClaims.PRPR_ID HOSP_PRPR_ID,
inpatientAdmitClaims.PROC1 HOSP_PROC,

/*
CASE 
	WHEN inpatientAdmitClaims.DX_LEVEL = 'DX1' THEN DX1,
	WHEN inpatientAdmitClaims.DX_LEVEL = 'DX2' THEN DX2,
	WHEN inpatientAdmitClaims.DX_LEVEL = 'DX3' THEN DX3,
	WHEN inpatientAdmitClaims.DX_LEVEL = 'DX4' THEN DX4,
	WHEN inpatientAdmitClaims.DX_LEVEL = 'DX5' THEN DX5,
	WHEN inpatientAdmitClaims.DX_LEVEL = 'DX_AD' THEN DX_AD
END AS HOSP_DX,
*/

inpatientAdmitClaims.ALLOW HOSP_ALLOW,
inpatientAdmitClaims.PAID HOSP_PAID,
inpatientAdmitClaims.IS_ADM_RES_READM,

claimsInfo.CLCL_ID,
claimsInfo.CDML_SEQ_NO,
claimsInfo.CDML_FROM_DATE,
claimsInfo.CDML_TO_DTED,
claimsInfo.CLCL_CL_SUB_TYPE,
claimsInfo.CPTCODE IPCD_ID,
claimsInfo.MODIFIER,
claimsInfo.IDCD_ID1,
claimsInfo.IDCD_ID2,
claimsInfo.IDCD_ID3,
claimsInfo.IDCD_ID4,
claimsInfo.IDCD_ID5,
claimsInfo.IDCD_ID6,
claimsInfo.IDCD_ADMIT,
claimsInfo.IDCD_PRIMARY,
claimsInfo.CDML_UNITS_ALLOW,
claimsInfo.CDML_CHG_AMT,
claimsInfo.CDML_ALLOW,
claimsInfo.CDML_PAID_AMT,
claimsInfo.CDML_COINS_AMT,
claimsInfo.CDML_COPAY_AMT,
claimsInfo.CDML_DED_AMT,

claimsInfo.PRPR_ID,
claimsInfo.GRGR_ID,
claimsInfo.SBSB_ID,

claimsInfo.MEMBER_ID,
memberInfo.MEME_LAST_NAME,
memberInfo.MEME_FIRST_NAME,
claimsInfo.MEME_BIRTH_DT,
claimsInfo.SCCF_NO,

claimsInfo.PDPD_ID,
claimsInfo.LOB,
claimsInfo.SUBPOPULATION,
claimsInfo.LOB_REPORT,
claimsInfo.SESE_ID,
claimsInfo.NWPR_PFX,
claimsInfo.INP_ADMITS,
claimsInfo.INP_DAYS,
claimsInfo.UTILIZATION

FROM NHB02LDV.REF.MEDICAL_CLAIMS claimsInfo

INNER JOIN NHB02LDV.REF.MEME_MEMBER memberInfo ON claimsInfo.MEME_CK = memberInfo.MEME_CK

/* JOINS TO INPATIENT ADMITS TABLE */
INNER JOIN (
	/* GRABS INFO FROM INPATIENT_ADMITS TABLE */
	SELECT 
	inpatientAdmits.MEME_FNAME,
	inpatientAdmits.MEME_LNAME,
	inpatientAdmits.MEME_BIRTH_DT,
	inpatientAdmits.SBSB_ID,
	inpatientAdmits.MEME_SFX,

	CASE
		WHEN inpatientAdmits.MEME_SFX < 10 THEN inpatientAdmits.SBSB_ID || '0' || CAST(inpatientAdmits.MEME_SFX AS VARCHAR(1))
		ELSE inpatientAdmits.SBSB_ID || CAST(inpatientAdmits.MEME_SFX AS VARCHAR(2))
	END AS MEMBER_ID,

	inpatientAdmits.ADM_DATE,
	inpatientAdmits.DC_DATE,
	inpatientAdmits.FROM_DATE,
	inpatientAdmits.TO_DATE,
	inpatientAdmits.PRPR_ID,
	inpatientAdmits.PROC1,

	CASE
		WHEN DX1_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') THEN 'DX1'
		WHEN DX2_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') THEN 'DX2'
		WHEN DX3_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') THEN 'DX3'
		WHEN DX4_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') THEN 'DX4'
		WHEN DX5_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') THEN 'DX5'
		WHEN DX_AD_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') THEN 'DX_AD'
	END AS DX_LEVEL,

	inpatientAdmits.DX1,
	inpatientAdmits.DX2,
	inpatientAdmits.DX3,
	inpatientAdmits.DX4,
	inpatientAdmits.DX5,
	inpatientAdmits.DX_AD,
	inpatientAdmits.CHARGE_AMT,
	inpatientAdmits.ALLOW,
	inpatientAdmits.PAID,
	inpatientAdmits.IS_READMISSION,
	inpatientAdmits.IS_ADM_RES_READM,
	inpatientAdmits.READM_UNQ_KEY

	FROM NHB02LDV.REF.INPATIENT_ADMITS inpatientAdmits

	/* DX CRITERIA */
	WHERE 	(DX1_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') OR
			DX2_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') OR
			DX3_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') OR
			DX4_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') OR
			DX5_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism') OR
			DX_AD_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism')
			)
	LIMIT 10 /* LIMIT NUMBER OF INPATIENT CLAIMS */
	) inpatientAdmitClaims

ON 	(memberInfo.MEME_LAST_NAME = inpatientAdmitClaims.MEME_LNAME AND
	memberInfo.MEME_FIRST_NAME = inpatientAdmitClaims.MEME_FNAME AND
	memberInfo.MEME_BIRTH_DT = inpatientAdmitClaims.MEME_BIRTH_DT
	)


WHERE claimsInfo.PAID_CLM = 'Y' /* only paid claims */
AND months_between(inpatientAdmitClaims.FROM_DATE,claimsInfo.CDML_FROM_DATE)<= 6 /* claims history up to 6 months prior to hospital admit date */
AND claimsInfo.CLCL_CL_SUB_TYPE <> 'D' /* eliminates dental claims */


ORDER BY claimsInfo.MEMBER_ID, claimsInfo.CDML_FROM_DATE, claimsInfo.CLCL_ID, claimsInfo.CDML_SEQ_NO


/*
SELECT DISTINCT
YEAR,
--NYS_DRG_DESC,
DX1,
DX1_DESC,
DX2,
DX2_DESC,
DX3,
DX3_DESC,
DX4,
DX4_DESC,
--APRDRG_32,
--APR_DRG_DESC,
--ALLOW_GRP,
--AGE_GRP,
SUM(CLAIMS) NUM_CLAIMS,
SUM(ALLOW) TOTAL_ALLOWED,
AVG(ALLOW) AVG_ALLOWED

FROM NHB02LDV.REF.INPATIENT_ADMITS

WHERE DX1_DESC IN ('Unspecified septicemia', 'Sepsis, unspecified organism')
AND YEAR IN ('2016', '2017')
--AND DX2_DESC IN ('Pneumonia, organism unspecified', 'Acute respiratory failure')

GROUP BY
YEAR,
--NYS_DRG_DESC,
DX1,
DX1_DESC,
DX2,
DX2_DESC,
DX3,
DX3_DESC,
DX4,
DX4_DESC
--APRDRG_32,
--APR_DRG_DESC
--ALLOW_GRP
--AGE_GRP

ORDER BY SUM(ALLOW) DESC
*/