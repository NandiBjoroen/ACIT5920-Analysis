global out "<<Replace with file directory>>"
global in "<<Replace with file directory>>"


// Set up Stata
version
clear all
set more off



/*****************************************************************************

NOTE: SURVEY ITEMS RELEVANT TO SOME NPMs & NOMs *HAVE CHANGED* ACROSS YEARS. 
COMMENTS HAVE BEEN INCLUDED IN THE DO FILE WHERE CHANGES NEED TO BE MADE TO
ACCOMMODATE VARIABLE DIFFERENCES. PLEASE REVIEW COMMENTS TO ENSURE VARIABLES
ARE DEFINED APPROPRIATELY FOR YOUR ANALYSIS.

QUICK REFERENCE GUIDE FOR WHERE MEASURES SHOULD BE SET TO MISSING BY 2-YEAR 
DATASET (Only 1 of 2 years available)
2017-2018:
	wellvisit_12to17, referral, referral_1, bullyothers, bullyothers_1,
	arebullied, arebullied_1 flrshyoung, flrshchild, flrshchild_1
	
2018-2019
	wellvisit_12to17
	
2021-2022
	housing_0to11 hrtl_3to5 hrtl_index

*****************************************************************************/


********************************************************************
/* ADAPT BELOW CODE AS APPROPRIATE FOR SELECTED YEAR(S) OF ANALYSIS
// Using data 2024-2025
use "$in/topical_2024e.dta"
append using "$in/topical_2025.dta"
	replace stratum = "2" if stratum == "2A"
	destring stratum, replace
*/

// Using data 2016-2025
use "$in\nsch_2016e_topical.dta"
tostring stratum, replace
append using "$in\nsch_2017e_topical.dta"
append using "$in\nsch_2018e_topical.dta"
append using "$in\nsch_2019e_topical.dta"
append using "$in\nsch_2020e_topical.dta"
append using "$in\nsch_2021e_topical.dta"
append using "$in\nsch_2022e_topical.dta"
append using "$in\nsch_2023e_topical.dta"
append using "$in\nsch_2024e_topical.dta"
append using "$in\nsch_2025e_topical.dta"
	replace stratum = "2" if stratum == "2A"
	destring stratum, replace

********************************************************************

	
	
****************************************
// SET UP SURVEY VARIABLES FOR ANALYSIS
****************************************
** Set up survey data
egen stratacross = group(fipsst stratum)
gen fwc2yr = fwc/2

/*NOTE: WILL NEED TO SET UP SVYSET FOR ANY SURVEY ANALYSES - COMMENTED  OUT SO THAT APPROPRIATE FWC IS CHOSEN
svyset[pweight=fwc], strat(stratacross) psu(hhid) singleunit(certainty) vce(linearized)
*/
**global labels
label define yesno 1 "1.Yes" 2 "2.No"


gen state = fipsst
label define state 1 "AL" 2 "AK" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" 15 "HI" 16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" 25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" 35 "NM" 36 "NY" 37 "NC" 38 "ND" 39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" 46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"
label values state state

gen region = .m
replace region = 1 if inlist(state,9,23,25,33,44,50)
replace region = 2 if inlist(state,34,36)
replace region = 3 if inlist(state,10,11,24,42,51,54)
replace region = 4 if inlist(state,1,12,13,21,28,37,45,47)
replace region = 5 if inlist(state,17,18,26,27,39,55)
replace region = 6 if inlist(state,5,22,35,40,48)
replace region = 7 if inlist(state,19,20,29,31)
replace region = 8 if inlist(state,8,30,38,46,49,56)
replace region = 9 if inlist(state,4,6,15,32)
replace region = 10 if inlist(state,2,16,41,53)


****************************************
// STRATIFIERS
****************************************
*Education
label define educ 1 "<High School" 2 "High School" 3 "Some College" 4 "College+"
label var higrade_tvis educ

*MSA - suppressed in certain states
gen msa = .m
replace msa = 1 if mpc_yn == 1 //metro principal city
replace msa = 2 if metro_yn == 1 & mpc_yn == 2 //MSA, not principal city
replace msa = 3 if metro_yn == 2 //not in a MSA
label define msa 1 "MSA, Principal City" 2 "MSA, Not Principal City" 3 "Non-MSA"
label var msa msa


/***CYSHCN***/
***Functional Difficulties
*Same variables 2016-2025
gen diffcnt = 0
foreach var of varlist breathing swallowing stomach physicalpain hands coordination memorycond walkstairs dressing errandalone k2q43b blindness {
	replace diffcnt = diffcnt + 1 if `var' == 1
}
label var diffcnt "Number of functional difficulties"


***Current or Lifelong Health Conditions
/*Notes: 
 *SELECT APPROPRIATE CONDITION CODE BASED ON WHICH YEAR(S) OF DATA USED
 * 22 conditions 2016-2021
 *FASD, autoimmune, diabetes_curr added in 2022 - includes Type 1 diabete, celiac, juvenile idiopathic arthritis 
 *Arthritis_curr and k2q41b dropped in 2022
 * 23 conditions in 2022
 *Genetic dropped in 2023 
 * 22 conditions in 2023-2025
*/

***MULTIPLE YEARS ANALYSES
*2016-2025: at least 1 year from 2016-2021 and 1 year from 2022-2025
gen condcnt = 0
foreach var of varlist allergies_curr arthritis_curr autoimmune blood cystfib k2q41b diabetes_curr downsyn fasd genetic headache_curr heart_curr k2q30b k2q31b k2q32b k2q33b k2q34b k2q35b k2q36b k2q37b k2q38b k2q40b k2q42b k2q60b k2q61a {
	replace condcnt = condcnt + 1 if `var' == 1
} 
label var condcnt "Number of current & lifelong conditions"
/*
*2022-2025 ONLY: use single-year code for 2022 below

***SINGLE YEAR ANALYSES
*2023, 2023/2024, or 2024/2025 - drops genetic
gen condcnt = 0
foreach var of varlist allergies_curr autoimmune blood cystfib diabetes_curr downsyn fasd headache_curr heart_curr k2q30b k2q31b k2q32b k2q33b k2q34b k2q35b k2q36b k2q37b k2q38b k2q40b k2q42b k2q60b k2q61a {
	replace condcnt = condcnt + 1 if `var' == 1 & inrange(year,2024,2025)
} 
label var condcnt "Number of current & lifelong conditions"

*2022 OR 2022/2023 - includes autoimmune, diabetes_curr, fasd
gen condcnt = 0
foreach var of varlist allergies_curr autoimmune blood cystfib diabetes_curr downsyn fasd genetic headache_curr heart_curr k2q30b k2q31b k2q32b k2q33b k2q34b k2q35b k2q36b k2q37b k2q38b k2q40b k2q42b k2q60b k2q61a {
	replace condcnt = condcnt + 1 if `var' == 1 & year == 2022
} 
label var condcnt "Number of current & lifelong conditions"

*2016 - 2021
gen condcnt = 0
foreach var of varlist allergies_curr arthritis_curr blood cystfib k2q41b downsyn genetic headache_curr heart_curr k2q30b k2q31b k2q32b k2q33b k2q34b k2q35b k2q36b k2q37b k2q38b k2q40b k2q42b k2q60b k2q61a {
	replace condcnt = condcnt + 1 if `var' == 1 & inrange(year,2016,2021)
} 
label var condcnt "Number of current & lifelong conditions"
*/
	*ALL/ANY NSCH YEARS
	/***Expanded CSHCN - combining screener & 1+ difficulty & 1+ condition***/
	gen cshcn_exp = 2
	replace cshcn_exp = 1 if sc_cshcn == 1 | (diffcnt>=1 & condcnt>=1)
	label var cshcn_exp "Expanded CSHCN: Screener or Had 1+ Difficulty & 1+ Condition"
	label values cshcn_exp yesno

	
***CSHCN Type
gen rxmeds = 2 
replace rxmeds = 1 if sc_k2q10 == 1 & sc_k2q11 == 1 & sc_k2q12 == 1
label var rxmeds "Children qualifying on the CSHCN screener prescription medication criteria"
label values rxmeds yesno

gen serve = 2 
replace serve = 1 if sc_k2q13 == 1 & sc_k2q14 == 1 & sc_k2q15 == 1
label var serve "Children qualifying on the CSHCN screener cor elevated services use criteria"
label values serve yesno

gen func = 2 
replace func = 1 if sc_k2q16 == 1 & sc_k2q17 == 1 & sc_k2q18 == 1
label var func "Children qualifying on the CSHCN screener funtional limitations criteria"
label values func yesno

gen therapy = 2 
replace therapy = 1 if sc_k2q19 == 1 & sc_k2q20 == 1 & sc_k2q21 == 1
label var therapy "Children qualifying on the CSHCN screener specialized therapy criteria"
label values therapy yesno

gen mhealth = 2 
replace mhealth = 1 if sc_k2q22 == 1 & sc_k2q23 == 1
label var mhealth "Children qualifying on the CSHCN screener ongoing emotional, developmental, or behavioral conditions that need ongoing treatment"
label values mhealth yesno

	gen cshcntype = 5 //no SHCN
	replace cshcntype = 1 if func == 1
	replace cshcntype = 2 if cshcntype != 1 & (serve == 1 | therapy == 1 | mhealth == 1)
	replace cshcntype = 4 if !inlist(cshcntype,1,2) & rxmeds == 1
	replace cshcntype = 3 if !inlist(cshcntype,1,2,4) & cshcn_exp == 1
	label var cshcntype "CSHCN Type"
	label define cshcntype 1 "1.Any Functional Limitation" 2 "2.Elevated Services Need/Use w or w/o Rx" 3 "3.No Screener Criteria but 1+ Condition & 1+ Difficulty" 4 "4. Rx Meds only" 5 "5. No SHCN"
	label values cshcntype cshcntype
	

*Age Groups
gen age = 1 if sc_age_years <= 5
replace age = 2 if 6 <= sc_age_years & sc_age_years <= 11
replace age = 3 if 12 <= sc_age_years & sc_age_years <= 17 
label define age 1 "0-5yr" 2 "6-11yr" 3 "12-17yr"
label values age age

label define sex 1 "Male" 2 "Female"	
label values sc_sex sex 

*Race/Ethnicity
gen race_eth = .m 
replace race_eth = 1 if sc_hispanic_r == 1 //Hispanic
replace race_eth = 2 if sc_hispanic_r == 2 & sc_race_r == 3 //AIAN
replace race_eth = 3 if sc_hispanic_r == 2 & sc_race_r == 4 //Asian
replace race_eth = 4 if sc_hispanic_r == 2 & sc_race_r == 2 //NHB
replace race_eth = 5 if sc_hispanic_r == 2 & sc_race_r == 5 //NHPI
replace race_eth = 6 if sc_hispanic_r == 2 & sc_race_r == 1 //NHW
replace race_eth = 7 if sc_hispanic_r == 2 & sc_race_r == 7 //Multiple
label define race_eth  1 "1.Hispanic, NH" 2 "2.AIAN, NH" 3 "3.Asian, NH" 4 "4.Black, NH" 5 "5.NHPI, NH" 6 "6.White, NH" 7 "7.Multiple, NH"
label values race_eth race_eth

label var sc_aian "AI/AN alone or in combination"
label values sc_aian yesno

gen nh_nhpi_any = 1 if sc_hispanic_r == 2 & sc_nhpi == 1
	replace nh_nhpi_any = 2 if nh_nhpi_any != 1
	label var nh_nhpi_any "NH NH/PI alone or in combination"
	label values nh_nhpi_any yesno
	

*NOTE: POVERTY & FAMILY INCOME NOT INCLUDED HERE BECAUSE HAVE TO RESHAPE STATA FILE TO ACCOMODATE MULTIPLE IMPLICATES
*SEE BOTTOM OF DO FILE FOR CODE IF BETTER TO RESHAPE THEN CREATE VARIABLES


*Household structure - 2017 and later, note: SAS code created hhstructure twice & this code overwrote 1st hhstructure
*NOTE: if using data from 2017 or later, then delete or comment out code including "family"
gen hhstructure = .m 
replace hhstructure = 1 if inlist(family_r,1,3)
replace hhstructure = 2 if inlist(family_r,2,4)
replace hhstructure = 3 if inlist(family_r,5,6)
replace hhstructure = 4 if inlist(family_r,7,8)
	*2016 NSCH only
	replace hhstructure = 1 if inlist(family,1,3) & year == 2016
	replace hhstructure = 2 if inlist(family,2,4) & year == 2016
	replace hhstructure = 3 if inlist(family,5,6,7,8) & year == 2016
	replace hhstructure = 4 if inlist(family,9) & year == 2016
label define hhstructure 1 "1.2 parent, married" 2 "2.2 parent, unmarried" 3 "3.single parent" 4 "4.other"
label values hhstructure hhstructure


*Health insurance type
gen insurance = .m
replace insurance = 1 if inlist(instype,1,3) //Any public
replace insurance = 2 if instype == 2 //Private
replace insurance = 3 if instype == 5 //Uninsured
label define insurance 1 "1.Any Public" 2 "2.Private" 3 "3.No Insurance"
label values insurance insurance


*Primary language in household
gen language = .m
replace language = 1 if hhlanguage == 1
replace language = 2 if inlist(hhlanguage,2,3)
label define language 1 "English" 2 "Not English"
label var language language

*Parental nativity
gen nativity = .m 
replace nativity = 1 if house_gen == 3 //US born
replace nativity = 2 if inlist(house_gen,1,2) //foreign born
label define nativity 1 "Parent(s) born in US" 2 "1+ Parent born outside US"
label var nativity nativity

***********************************
// National Performance Measures
***********************************
/***NPM Breastfeeding: breastfeeding exlusivity at 6mo, children 6mo-2yr***/
*stopped BF
gen brststop = .m
replace brststop = 1 if breastfedend_mo_s < 6
replace brststop = 2 if 6 <= breastfedend_mo_s | k6q41r_still == 1
replace brststop = 1 if k6q41r_still == .l
replace brststop = .m if breastfedend_mo_s == .m 
replace brststop = .n if 2 < sc_age_years
label var brststop "age in months when stopped breastfeeding"
label define brststop 1 "1. <6mo excBF" 2 "2. 6+mo excBF"
label values brststop brststop

*1st fed formula
gen fedform = .m
replace fedform = 1 if frstformula_mo_s < 6
replace fedform = 2 if 6<= frstformula_mo_s | k6q42r_never == 1
replace fedform = .m if frstformula_mo_s == .m
replace fedform = .n if 2 < sc_age_years
label var fedform "age in months when first fed formula"
label define fedform 1 "1. <6mo formula" 2 "2. 6+mo formula"
label values fedform fedform

*1st fed food
gen fedother = .m
replace fedother = 1 if frstsolids_mo_s < 6
replace fedother = 2 if 6<= frstsolids_mo_s | k6q43r_never == 1
replace fedother = .m if frstsolids_mo_s == .m
replace fedother = .n if 2 < sc_age_years
label var fedother "age in months when first fed other food"
label define fedother 1 "1. <6mo food" 2 "2. 6+mo food"
label values fedother fedother

*exclusive BF
gen exbrstfd = .m
replace exbrstfd = 1 if k6q40 == 2
replace exbrstfd = 2 if exbrstfd != 1 & brststop == 1
replace exbrstfd = 3 if exbrstfd != 1 & exbrstfd != 2 & brststop == 2 & (fedform == 1 | fedother == 1)
replace exbrstfd = 4 if !inrange(exbrstfd,1,3) & brststop == 2 & (fedform == 2 | fedother == 2)
replace exbrstfd = .m if !inrange(exbrstfd,1,4) & (k6q40 == 1 | k6q40 ==.m) //BF exclusivity and duration unknown
replace exbrstfd = .l if sc_age_lt6 == 1
replace exbrstfd = .n if 2 < sc_age_years
label var exbrstfd "exclusively BF or given breast milk for 1st 6mo, 6mo-2yr"
label define exbrstfd 1 "1.Never BF" 2 "2.BF <6mo" 3 "3.BF 6mo, not excl" 4 "4.Excl BF 6mo"
label values exbrstfd exbrstfd

*exclusive BF - dichotomous
gen ex6brstfd = .m
replace ex6brstfd = 1 if exbrstfd == 4
replace ex6brstfd = 2 if inlist(exbrstfd,1,2,3)
replace ex6brstfd = .l if sc_age_lt6 == 1
replace ex6brstfd = .n if 2 < sc_age_years
label var ex6brstfd "NPM Breastfeeding, 6mo-2yr"
label define ex6brstfd 1 "1.Yes, excl BF" 2 "2.No, not excl BF"
label values ex6brstfd ex6brstfd


/***NPM Housing Instability, children 0-11 years***/
*2016-2023
gen housing_0to11 = .m
replace housing_0to11 = 1 if year <= 2023 & (everhomeless == 1 | missmortgage == 1 | placeslived == 2)
replace housing_0to11 = 2 if year <= 2023 & inlist(everhomeless,2,3,.m) & inlist(missmortgage,2,3,.m) & inlist(placeslived,1,.m)
replace housing_0to11 = .m if year <= 2023 & inlist(everhomeless,3,.m) & inlist(missmortgage,3,.m) & placeslived == .m

*2024 and later - placeslived replaced with moves
replace housing_0to11 = 1 if 2025 <= year & (everhomeless == 1 | missmortgage == 1 | moves == 3)
replace housing_0to11 = 2 if 2025 <= year & inlist(everhomeless,2,3,.m) & inlist(missmortgage,2,3,.m) & inlist(moves,1,2,.m)
replace housing_0to11 = .m if 2025 <= year & inlist(everhomeless,3,.m) & inlist(missmortgage,3,.m) & moves == .m
replace housing_0to11 = .n if 11 < sc_age_years
label var housing_0to11 "NPM Housing Instability, 0-11yrs"


/***NPM Developmental Screening, children 9-35mo***/
gen both_9to23 = .m
replace both_9to23 = 2 if k6q12 == 2 & sc_age_years < 2 | (k6q13a == 2 | k6q13b == 2)
replace both_9to23 = 1 if inlist(k6q13a,1,.m) & inlist(k6q13b,1,.m)
replace both_9to23 = .m if k6q13a == .m & k6q13b == .m
replace both_9to23 = .l if sc_age_years == 2 | sc_age_lt9 == 1
replace both_9to23 = .n if 3 <= sc_age_years
label var both_9to23 "Yes, screening occurred, 9-23mo"

gen both_24to35 = .m
replace both_24to35 = 2 if k6q12 == 2 & sc_age_years == 2 | (k6q14a == 2 | k6q14b == 2)
replace both_24to35 = 1 if inlist(k6q14a,1,.m) & inlist(k6q14b,1,.m)
replace both_24to35 = .m if k6q14a == .m & k6q14b == .m
replace both_24to35 = .l if sc_age_years < 2
replace both_24to35 = .n if 3 <= sc_age_years
label var both_24to35 "Yes, screening occurred, 24-35mo"

gen devscreen_9to35 = .m
replace devscreen_9to35 = 1 if both_9to23 == 1 | both_24to35 == 1
replace devscreen_9to35 = 2 if both_9to23 == 2 | both_24to35 == 2 //"or" does not matter b/c age-specific
replace devscreen_9to35 = .m if both_9to23 == .m | both_24to35 == .m
replace devscreen_9to35 = .l if sc_age_lt9 == 1
replace devscreen_9to35 = .n if 3 <= sc_age_years
label var devscreen_9to35 "NPM Developmental Screening, 9-35mo"


/***NPM Preventive Visit, 1-17yr***/
*NOTE: code only works for multi-year dataset that includes 1+ year 2016-2021 & 1+ year from 2022 or later
*If using 2016-2021, DROP " | k4q30_r_3 == 1"
*If using 2022 or later, DROP " | k4q30_r == 3"
gen prevdent_1to17 = .m
replace prevdent_1to17 = 1 if inlist(dentistvisit,2,3)
replace prevdent_1to17 = 2 if dentistvisit == 1 | k4q30_r == 3 | k4q30_r_3 == 1
replace prevdent_1to17 = .m if dentistvisit == .m
replace prevdent_1to17 = .l if sc_age_years < 1
label var prevdent_1to17 "NPM Preventive Dental Visit, 1-17yr"


/***NPM Physical Activity, children 6-11 years***/
gen physactiv_6to11 = .m
replace physactiv_6to11 = 1 if physactiv == 4
replace physactiv_6to11 = 2 if inlist(physactiv,1,2,3)
replace physactiv_6to11 = .l if sc_age_years < 6 | 11 < sc_age_years
label var physactiv_6to11 "NPM Physical Activity, 6-11yr"


/***NPM Food Sufficiency, children 0-11 years***/
*2018 question changed from 'you' to 'household' ability to afford, did not impact measure
gen food_0to11 = .m
replace food_0to11 = 1 if foodsit == 1
replace food_0to11 = 2 if inlist(foodsit,2,3,4)
replace food_0to11 = .l if 11 < sc_age_years
label var food_0to11 "NPM Food Sufficiency, 0-11yrs"


/***NPM Adolescent Well-Visit, adolescents 12-17 years***/
*S4Q01 is not comparable in 2018 but is okay to include as part of systems of care NOM; 2021 starts the inclusion of telehealth visits
*all kids
gen prevmed = .m
replace prevmed = 1 if inlist(k4q20r,2,3)
replace prevmed = 2 if k4q20r == 1 | s4q01 == 2
label var prevmed "Preventive visit, past 12mo"

*adolescents 12-17yrs
gen wellvisit_12to17 = prevmed
replace wellvisit_12to17 = .l if sc_age_years < 12
	*NOTE: if not using 2018 data, delete or comment out next line of code
	replace wellvisit_12to17 = .m if year == 2018
label var wellvisit_12to17 "NPM Adolescent Well-Visit, 12-17yrs"
label values wellvisit_12to17 yesno


/***NPM_Mental Health Tx: Mental health treatment, age 12-17 Years***//**NOTE: Previously NOM18**/
gen mhtx_12to17 = .m
replace mhtx_12to17 = k4q22_r if inlist(k4q22_r,1,2) /**Yes/No, but needed; *Note: follows the NPM denominator*/
replace mhtx_12to17 = .l if k4q22_r==3 /*skip No, do not need*/
replace mhtx_12to17 = .m if k4q22_r==.m
replace mhtx_12to17 = .n if sc_age_years < 12
label var mhtx_12to17 "NPM Mental Health Treatment, 12-17yrs"


/***NPM Adult Mentor, adolescents 12-17 years***/
gen mentor_12to17 = k9q96
replace mentor_12to17 = .n if sc_age_years < 12
label var mentor_12to17 "NPM Adult Mentor, 12-17yrs"


/***NPM Personal Doctor/Nurse - CSHCN & All Kids***/
**all kids
gen perdrns = .m
replace perdrns = 1 if inlist(k4q04_r,1,2)
replace perdrns = 2 if k4q04_r == 3
label var perdrns "NPM Personal Doctor/Nurse, all kids"

	*CSHCN
	gen perdrns_1 = perdrns if cshcn_exp == 1
	replace perdrns_1 = .l if cshcn_exp == 2
	label var perdrns_1 "NPM Personal Doctor/Nurse, CSHCN"

	
/***NPM Usual Source of Sick Care - CSHCN & All Kids***/
gen usualsck = .m 
/***
	NEED TO DOUBLE CHECK THIS CODE WHEN YEARS FROM 2022 AND BEFORE ARE STACKED WITH 2023
***/
replace usualsck = 1 if year < 2023 & k4q01 == 1 & inlist(k4q02_r,1,3,4,5,6,7,8)
replace usualsck = 1 if 2023 <= year & k4q01 == 1 & (gowhensick == 1 | inrange(gowhensick,3,8))
replace usualsck = 2 if usualsck != 1 & year < 2023 & (k4q01 == 2 | k4q02_r == 2)
replace usualsck = 2 if usualsck != 1 & 2023 <= year & (k4q01 == 2 | gowhensick == 2)
replace usualsck = .m if !inlist(usualsck,1,2) & year < 2023 & (k4q01 == .m | k4q02_r == .m )
replace usualsck = .m if !inlist(usualsck,1,2) & 2023 <= year & (k4q01 == .m | gowhensick == .m)
label var usualsck "NPM Usual Source of Sick Care, all kids"

	*CSHCN
	gen usualsck_1 = usualsck if cshcn_exp == 1
	replace usualsck_1 = .l if cshcn_exp == 2
	label var usualsck_1 "NPM Usual Source of Sick Care, CSHCN"


/***NPM Family Centered Care - CSHCN & All Kids***/
gen time = k5q40
replace time = 0 if k5q40 == .l
replace time = 3 if k5q40 == 4
label var time "Doctors spent enough time with children"

gen listen = k5q41
replace listen = 0 if k5q41 == .l
replace listen = 3 if k5q41 == 4
label var listen "Doctors listened carefully to children's parents"

gen sensitiv = k5q42
replace sensitiv = 0 if k5q42 == .l
replace sensitiv = 3 if k5q42 == 4
label var sensitiv "Doctors showed sensitivity to children's family's values & customs"

gen info = k5q43
replace info = 0 if k5q43 == .l
replace info = 3 if k5q43 == 4
label var info "Doctors provided info specific to parents' concerns"

gen partner = k5q44
replace partner = 0 if k5q44 == .l
replace partner = 3 if k5q44 == 4
label var partner "Doctors helped parents to feel like partners in child's care"

gen famcentcare = .m
replace famcentcare = .l if time == 0
replace famcentcare = 1 if famcentcare != .l & inlist(time,1,2,.m) & inlist(listen,1,2,.m) & inlist(sensitiv,1,2,.m) & inlist(info,1,2,.m) & inlist(partner,1,2,.m)
replace famcentcare = 2 if famcentcare != .l & famcentcare != 1 & (inlist(time,3,.m) | inlist(listen,3,.m) | inlist(sensitiv,3,.m) | inlist(info,3,.m) | inlist(partner,3,.m))
replace famcentcare = .m if time == .m & listen == .m & sensitiv == .m & info == .m & partner == .m
label var famcentcare "NPM Family Centered Care, all kids"

gen famcentcare_1=famcentcare if cshcn_exp == 1
replace famcentcare_1 = .l if cshcn_exp == 2
label var famcentcare_1 "NPM Family Centered Care, CSHCN"


/***NPM Referrals - CSHCN & All Kids***/
*NOTE: Referral problem is not comparable for 2016/2017 to others years
gen norefprb = .m
replace norefprb = .l if k5q10 == 2
replace norefprb = 2 if inlist(k5q11,2,3,4)
replace norefprb = 1 if k5q11 == 1
replace norefprb = .m if k5q10 == .m | k5q11 == .m 
label var norefprb "Referrals, all kids all years"

	*Excluding 2016/2017 because data aren't comparable to later years
	gen referral = .m
	replace referral = norefprb if !inlist(year,2016,2017)
	label var norefprb "NPM Referrals, all kids 2018+"

	*CSHCN referrals
	gen referral_1 = referral if cshcn_exp == 1
	replace referral_1 = .l if cshcn_exp == 2
	label var referral_1 "NPM Referrals, CSHCN 2018+"


/***NPM Care Coordination - CSHCN & All Kids***/
gen drcomm = k5q30 
replace drcomm = 0 if k5q20_r == 3 | s4q01 == 2
replace drcomm = 3 if drcomm != 0 & k5q30 == 4
label var drcomm "Satisfaction with communication among child's providers"


gen carehelp = 0 if (k5q20_r  == 3 | s4q01 == 2) | (k5q20_r == 2 & k5q21 == 2)
replace carehelp = .m if carehelp != 0 & (k5q20_r == .m  | k5q21 == .m | k5q22 == .m)
replace carehelp = 1 if carehelp != 0 & ((k5q20_r == 1 & k5q21 == 2) | (inlist(k5q20_r,1,2) & inlist(k5q22,1,.l)))
replace carehelp = 2 if !inlist(carehelp,0,1,.m) & inlist(k5q22,2,3)
replace carehelp = .m if s4q01 == .m
label var carehelp "Got all needed extra help with care coordination"

gen othcomm = .m 
replace othcomm = 0 if inlist(k5q31_r,2,3) | s4q01 == 2
replace othcomm = 1 if k5q32 == 1
replace othcomm = 2 if inrange(k5q32,2,4)
label var othcomm "Satisfaction with communication among child's providers, school, child care, & special educ program"

gen carecoor = .l if inlist(carehelp,0,.m) & inlist(drcomm,0,.m) & inlist(othcomm,0,.m)
replace carecoor = 1 if carecoor != .l & inlist(carehelp,0,1,.m) & inlist(drcomm,0,1,.m) & inlist(othcomm,0,1,.m)
replace carecoor = 2 if !inlist(carecoor,1,.l) & (inlist(carehelp,2,.m) | inlist(drcomm,2,3,.m) | inlist(othcomm,2,.m))
replace carecoor = .m if carehelp == .m & drcomm == .m & othcomm == .m
label var carecoor "NPM Care Coordination, all kids"

	gen carecoor_1 = carecoor if cshcn_exp == 1
	replace carecoor_1 = .l if cshcn_exp == 2
	label var carecoor_1 "NPM Care Coordination, CSHCN"


/***NPM Medical Home - CSHCN & All Kids***/
*NOTE: Referral problem component is not comparable for 2016/2017 to others years but overall Medical Home is not affected
gen medicalhome = .m
replace medicalhome = 1 if inlist(perdrns,1,.m) & inlist(usualsck,1,.m) & inlist(famcentcare,1,.l,.m) & inlist(norefprb,1,.l,.m) & inlist(carecoor,1,.l,.m)
replace medicalhome = 2 if perdrns == 2 | usualsck == 2 | famcentcare == 2 | norefprb == 2 | carecoor == 2
replace medicalhome = .m if perdrns == .m & usualsck == .m & inlist(famcentcare,.l,.m) & inlist(norefprb,.l,.m) & inlist(carecoor,.l,.m)
label var medicalhome "NPM Medical Home, all kids"

	gen medicalhome_1 = medicalhome if cshcn_exp == 1
	replace medicalhome_1 = .l if cshcn_exp == 2
	label var medicalhome_1 "NPM Medical Home, CSHCN"

/***NPM Transition, 12-17yrs - CSHCN & All Kids***/
*Transition Part A: time alone with health care provider
gen timealone = docprivate
replace timealone = 2 if 2018 <= year & s4q01 == 2 //NSCH 2018 - current
replace timealone = .m if 2018 <= year & s4q01 == .m  //NSCH 2018 - current
replace timealone = 2 if inlist(year,2016,2017) & (s4q01 == 2 | k4q20r == 1) //NSCH 2016 & 2017
replace timealone = .m if inlist(year,2016,2017) & (s4q01 == .m | k4q20r == .m) //NSCH 2016 & 2017
replace timealone = .n if sc_age_years < 12
label var timealone "Children had time alone with provider at last visit, 12-17yrs"

*Transition Part B: active work with child 
gen activework = .m
replace activework = 1 if changeage == 1 | gainskills == 1
replace activework = 2 if activework != 1 & (changeage == 2 | gainskills == 2)
replace activework = .m if !inlist(activework,1,2) & inlist(changeage,3,.m) & inlist(gainskills,3,.m)
replace activework = .n if sc_age_years < 12
label var activework "Provider worked with child to gain skills or manage health/health care, 12-17yrs"

*Transition Part C: anticipatory guidance
gen trtadult = .m 
replace trtadult = 1 if treatchild == 1 & treatadult == 1
replace trtadult = 2 if treatchild == 1 & treatadult == 2
replace trtadult = .l if treatchild == 2
replace trtadult = .m if treatchild == .m | treatadult == .m 
replace trtadult = .n if sc_age_years < 12
label var trtadult "Provider discussed shift to adult health care provider 'if needed', 12-17yrs"

*Transition
gen transition = .m 
replace transition = 1 if inlist(timealone,1,.m) & inlist(activework,1,.m) & inlist(trtadult,1,.m,.l)
replace transition = 2 if timealone == 2 | activework == 2 | trtadult == 2
replace transition = .m if timealone == .m & activework == .m & trtadult == .m
replace transition = .n if sc_age_years < 12
label var transition "NPM Transition, all kids"

gen transition_1 = transition if cshcn_exp == 1
replace transition_1 = .l if cshcn_exp == 2
label var transition_1 "NPM Transition, CSHCN"


/***NPM Bullying - CSHCN & All Kids***/
*Bully Others
gen bullyothers = .m
replace bullyothers = 1 if inrange(bully,2,5)
replace bullyothers = 2 if bully == 1
replace bullyothers = .l if sc_age_years < 12
label var bullyothers "NPM Bully who bullies others, 12-17yrs"

	gen bullyothers_1 = bullyothers if cshcn_exp == 1
	replace bullyothers_1 = .l if cshcn_exp == 2
	label var bullyothers_1 "NPM Bully who bullies others, CSHCN"
	
gen arebullied = .m
replace arebullied = 1 if inrange(bullied_r,2,5)
replace arebullied = 2 if bullied_r == 1
replace arebullied = .l if sc_age_years < 12
label var arebullied "NPM Bully victim, 12-17yrs"

	gen arebullied_1 = arebullied if cshcn_exp == 1
	replace arebullied_1 = .l if cshcn_exp == 2
	label var arebullied_1 "NPM Bully victim, CSHCN"


**Labeling NPM values
foreach var of varlist housing_0to11 both_9to23 both_24to35 devscreen_9to35 prevdent_1to17 physactiv_6to11 food_0to11 prevmed mhtx_12to17 mentor_12to17 perdrns perdrns_1 usualsck famcentcare famcentcare_1 referral referral_1 carecoor carecoor_1 medicalhome medicalhome_1 timealone activework trtadult transition transition_1 bullyothers bullyothers_1 arebullied arebullied_1 {
	label values `var' yesno
	}


***********************************
// National Outcome Measures
***********************************
/***NOM: School Readiness 'HRTL', children 3-5 years***/
gen el_beginsound = recogbegin
gen el_samesound = samesound
gen el_onedigit = readonedigit
gen el_simpleadd = simpleaddition
gen el_groupmore = groupofobjects
gen el_letters = recogabc
gen el_writename = writename
gen se_recogemotions = nameemotions
gen se_sharetoys = sharetoys
gen se_playwell = playwell
gen se_showconcern = hurtsad
gen se_explainthings = clearexp
gen se_focustask = focuson
gen h_generalhealth = k2q01
gen h_conditionteeth = k2q01_d
gen h_howoften = hcability

foreach var of varlist el_beginsound el_samesound el_onedigit el_simpleadd el_groupmore el_letters el_writename se_recogemotions se_sharetoys se_playwell se_showconcern se_explainthings se_focustask h_generalhealth h_conditionteeth h_howoften {
	recode `var' 1=5 2=4 4=2 5=1
}

gen h_extent = hcextent
recode h_extent 1=3 3=1

gen el_wordsrhyme=rhymeword_r 
gen el_count=countto_r
gen sr_endstartactivity=startnewact
gen sr_calmdown=calmdown_r
gen sr_waitturn=waitforturn
gen sr_distracted=distracted
gen sr_temper=temper_r
gen m_circle=drawacircle
gen m_face=drawaface
gen m_person=drawaperson
gen m_bounceball=bounceaball

gen h_healthconds = .m 
replace h_healthconds = 4 if h_howoften == 5
replace h_healthconds = 3 if h_howoften == 4
replace h_healthconds = 2 if h_howoften == 3 | inlist(h_extent,2,3)
replace h_healthconds = 1 if inlist(h_howoften,1,2) | h_extent == 1


	*********************************
	*****HRTL Individual Domains*****
	
	***Early Learning Skills
	*1. how often can this child recognize the beginning sound of a word
	*3yrs
	gen el_beginsound_index = .m
	replace el_beginsound_index = 2 if el_beginsound == 1 & sc_age_years == 3
	replace el_beginsound_index = 3 if inrange(el_beginsound,2,5) & sc_age_years == 3
	*4yrs
	replace el_beginsound_index = 1 if el_beginsound == 1 & sc_age_years == 4
	replace el_beginsound_index = 2 if el_beginsound == 2 & sc_age_years == 4
	replace el_beginsound_index = 3 if inrange(el_beginsound,3,5) & sc_age_years == 4
	*5yrs
	replace el_beginsound_index = 1 if inrange(el_beginsound,1,2) & sc_age_years == 5
	replace el_beginsound_index = 2 if el_beginsound == 3 & sc_age_years == 5
	replace el_beginsound_index = 3 if inrange(el_beginsound,4,5) & sc_age_years == 5

	*2. how often can this child come up with words that start with the same sound
	*3yrs
	gen el_samesound_index = .m
	replace el_samesound_index = 2 if el_samesound == 1 & sc_age_years == 3
	replace el_samesound_index = 3 if inrange(el_samesound,2,5) & sc_age_years == 3
	*4yrs
	replace el_samesound_index = 1 if el_samesound == 1 & sc_age_years == 4
	replace el_samesound_index = 2 if el_samesound == 2 & sc_age_years == 4
	replace el_samesound_index = 3 if inrange(el_samesound,3,5) & sc_age_years == 4
	*5yrs
	replace el_samesound_index = 1 if inrange(el_samesound,1,2) & sc_age_years == 5
	replace el_samesound_index = 2 if el_samesound == 3 & sc_age_years == 5
	replace el_samesound_index = 3 if inrange(el_samesound,4,5) & sc_age_years == 5

	*3. how often can this child come up with words that rhyme 
	*3 & 4 yrs
	gen el_wordsrhyme_index = .m
	replace el_wordsrhyme_index = 2 if el_wordsrhyme == 1 & (sc_age_years == 3 | sc_age_years == 4)
	replace el_wordsrhyme_index = 3 if inrange(el_wordsrhyme,2,4) & (sc_age_years == 3 | sc_age_years == 4)
	*5yrs
	replace el_wordsrhyme_index = 1 if el_wordsrhyme == 1 & sc_age_years == 5
	replace el_wordsrhyme_index = 2 if el_wordsrhyme == 2 & sc_age_years == 5
	replace el_wordsrhyme_index = 3 if inrange(el_wordsrhyme,3,4) & sc_age_years == 5

	*4. how many letters of the alphabet can this child recognize
	*3yrs
	gen el_letters_index = .m
	replace el_letters_index = 1 if el_letters == 1 & sc_age_years == 3
	replace el_letters_index = 2 if el_letters == 2 & sc_age_years == 3
	replace el_letters_index = 3 if inrange(el_letters,3,5) & sc_age_years == 3
	*4yrs
	replace el_letters_index = 1 if el_letters == 1 & sc_age_years == 4
	replace el_letters_index = 2 if inrange(el_letters,2,3) & sc_age_years == 4
	replace el_letters_index = 3 if inrange(el_letters,4,5) & sc_age_years == 4
	*5yrs
	replace el_letters_index = 1 if inrange(el_letters,1,2) & sc_age_years == 5
	replace el_letters_index = 2 if inrange(el_letters,3,4) & sc_age_years == 5
	replace el_letters_index = 3 if el_letters == 5 & sc_age_years == 5

	*5. how often can this child write their first name
	*3yrs
	gen el_writename_index = .m
	replace el_writename_index = 2 if el_writename == 1 & sc_age_years == 3
	replace el_writename_index = 3 if inrange(el_writename,2,5) & sc_age_years == 3
	*4yrs
	replace el_writename_index = 1 if el_writename == 1 & sc_age_years == 4
	replace el_writename_index = 2 if el_writename == 2 & sc_age_years == 4
	replace el_writename_index = 3 if inrange(el_writename,3,5) & sc_age_years == 4
	*5yrs
	replace el_writename_index = 1 if inrange(el_writename,1,2) & sc_age_years == 5
	replace el_writename_index = 2 if inrange(el_writename,3,4) & sc_age_years == 5
	replace el_writename_index = 3 if el_writename == 5 & sc_age_years == 5

	*6. how often can this child read one-digit numbers
	*3yrs
	gen el_onedigit_index = .m
	replace el_onedigit_index = 2 if el_onedigit == 1 & sc_age_years == 3
	replace el_onedigit_index = 3 if inrange(el_onedigit,2,5) & sc_age_years == 3
	*4yrs
	replace el_onedigit_index = 1 if el_onedigit == 1 & sc_age_years == 4
	replace el_onedigit_index = 2 if inrange(el_onedigit,2,3) & sc_age_years == 4
	replace el_onedigit_index = 3 if inrange(el_onedigit,4,5) & sc_age_years == 4
	*5yrs
	replace el_onedigit_index = 1 if inrange(el_onedigit,1,3) & sc_age_years == 5
	replace el_onedigit_index = 2 if el_onedigit == 4 & sc_age_years == 5
	replace el_onedigit_index = 3 if el_onedigit == 5 & sc_age_years == 5

	*7. how high could this child count correctly if counting objects
	*3yrs
	gen el_count_index = .m
	replace el_count_index = 1 if el_count == 1 & sc_age_years == 3
	replace el_count_index = 2 if el_count == 2 & sc_age_years == 3
	replace el_count_index = 3 if inrange(el_count,3,5) & sc_age_years == 3
	*4yrs
	replace el_count_index = 1 if inrange(el_count,1,2) & sc_age_years == 4
	replace el_count_index = 2 if el_count == 3 & sc_age_years == 4
	replace el_count_index = 3 if inrange(el_count,4,5) & sc_age_years == 4
	*5yrs
	replace el_count_index = 1 if inrange(el_count,1,3) & sc_age_years == 5
	replace el_count_index = 2 if el_count == 4 & sc_age_years == 5
	replace el_count_index = 3 if el_count == 5 & sc_age_years == 5

	*8. how often can this child tell which group of objects has more
	*3yrs
	gen el_groupmore_index = .m
	replace el_groupmore_index = 1 if el_groupmore == 1 & sc_age_years == 3
	replace el_groupmore_index = 2 if el_groupmore == 2 & sc_age_years == 3
	replace el_groupmore_index = 3 if inrange(el_groupmore,3,5) & sc_age_years == 3
	*4yrs
	replace el_groupmore_index = 1 if inrange(el_groupmore,1,2) & sc_age_years == 4
	replace el_groupmore_index = 2 if el_groupmore == 3 & sc_age_years == 4
	replace el_groupmore_index = 3 if inrange(el_groupmore,4,5) & sc_age_years == 4
	*5yrs
	replace el_groupmore_index = 1 if inrange(el_groupmore,1,3) & sc_age_years == 5
	replace el_groupmore_index = 2 if el_groupmore == 4 & sc_age_years == 5
	replace el_groupmore_index = 3 if el_groupmore == 5 & sc_age_years == 5

	*9. how often can this child correctly do simple addition
	*3yrs
	gen el_simpleadd_index = .m
	replace el_simpleadd_index = 2 if el_simpleadd == 1 & sc_age_years == 3
	replace el_simpleadd_index = 3 if inrange(el_simpleadd,2,5) & sc_age_years == 3
	*4yrs
	replace el_simpleadd_index = 1 if el_simpleadd == 1 & sc_age_years == 4
	replace el_simpleadd_index = 2 if el_simpleadd == 2 & sc_age_years == 4
	replace el_simpleadd_index = 3 if inrange(el_simpleadd,3,5) & sc_age_years == 4
	*5yrs
	replace el_simpleadd_index = 1 if inrange(el_simpleadd,1,2) & sc_age_years == 5
	replace el_simpleadd_index = 2 if el_simpleadd == 3 & sc_age_years == 5
	replace el_simpleadd_index = 3 if inrange(el_simpleadd,4,5) & sc_age_years == 5



	***Social Emotional
	*10. how often does this child explain things they have sen or done so that you know what happened
	*3yrs
	gen se_explainthings_index = .m
	replace se_explainthings_index = 1 if se_explainthings == 1 & sc_age_years == 3
	replace se_explainthings_index = 2 if inrange(se_explainthings,2,3) & sc_age_years == 3
	replace se_explainthings_index = 3 if inrange(se_explainthings,4,5) & sc_age_years == 3
	*4yrs
	replace se_explainthings_index = 1 if inrange(se_explainthings,1,2) & sc_age_years == 4
	replace se_explainthings_index = 2 if se_explainthings == 3 & sc_age_years == 4
	replace se_explainthings_index = 3 if inrange(se_explainthings,4,5) & sc_age_years == 4
	*5yrs
	replace se_explainthings_index = 1 if inrange(se_explainthings,1,3) & sc_age_years == 5
	replace se_explainthings_index = 2 if se_explainthings == 4 & sc_age_years == 5
	replace se_explainthings_index = 3 if se_explainthings == 5 & sc_age_years == 5

	*11. how often can this child recognize and name their own emotions 
	*3yrs
	gen se_recogemotions_index = .m
	replace se_recogemotions_index = 1 if se_recogemotions == 1 & sc_age_years == 3
	replace se_recogemotions_index = 2 if se_recogemotions == 2 & sc_age_years == 3
	replace se_recogemotions_index = 3 if inrange(se_recogemotions,3,5) & sc_age_years == 3
	*4 & 5yrs
	replace se_recogemotions_index = 1 if inrange(se_recogemotions,1,2) & (sc_age_years == 4 | sc_age_years == 5)
	replace se_recogemotions_index = 2 if se_recogemotions == 3 & (sc_age_years == 4 | sc_age_years == 5)
	replace se_recogemotions_index = 3 if inrange(se_recogemotions,4,5) & (sc_age_years == 4 | sc_age_years == 5)

	*12. how often does this child share toys or games
	*3 & 4yrs
	gen se_sharetoys_index = .m
	replace se_sharetoys_index = 1 if se_sharetoys == 1 & (sc_age_years == 3 | sc_age_years == 4)
	replace se_sharetoys_index = 2 if inrange(se_sharetoys,2,3) & (sc_age_years == 3 | sc_age_years == 4)
	replace se_sharetoys_index = 3 if inrange(se_sharetoys,4,5) & (sc_age_years == 3 | sc_age_years == 4)
	*5yrs
	replace se_sharetoys_index = 1 if inrange(se_sharetoys,1,2) & sc_age_years == 5
	replace se_sharetoys_index = 2 if se_sharetoys == 3 & sc_age_years == 5
	replace se_sharetoys_index = 3 if inrange(se_sharetoys,4,5) & sc_age_years == 5

	*13. how often does this child play well with others
	*3-5yrs
	gen se_playwell_index = .m
	replace se_playwell_index = 1 if inrange(se_playwell,1,2) & inrange(sc_age_years,3,5)
	replace se_playwell_index = 2 if se_playwell == 3 & inrange(sc_age_years,3,5)
	replace se_playwell_index = 3 if inrange(se_playwell,4,5) & inrange(sc_age_years,3,5)

	*14. how often does this child show concern when others seem hurt or unhappy
	*3-5yrs
	gen se_showconcern_index = .m
	replace se_showconcern_index = 1 if inrange(se_showconcern,1,2) & inrange(sc_age_years,3,5)
	replace se_showconcern_index = 2 if se_showconcern == 3 & inrange(sc_age_years,3,5)
	replace se_showconcern_index = 3 if inrange(se_showconcern,4,5) & inrange(sc_age_years,3,5)

	*15. how often can this child recognize and name their own emotions 
	*3yrs
	gen se_focustask_index = .m
	replace se_focustask_index = 1 if se_focustask == 1 & sc_age_years == 3
	replace se_focustask_index = 2 if se_focustask == 2 & sc_age_years == 3
	replace se_focustask_index = 3 if inrange(se_focustask,3,5) & sc_age_years == 3
	*4yrs
	replace se_focustask_index = 1 if se_focustask == 1 & sc_age_years == 4
	replace se_focustask_index = 2 if inrange(se_focustask,2,3) & sc_age_years == 4
	replace se_focustask_index = 3 if inrange(se_focustask,4,5) & sc_age_years == 4
	*5yrs
	replace se_focustask_index = 1 if inrange(se_focustask,1,2) & sc_age_years == 5
	replace se_focustask_index = 2 if se_focustask == 3 & sc_age_years == 5
	replace se_focustask_index = 3 if inrange(se_focustask,4,5) & sc_age_years == 5



	***Self-Regulation
	*16. how often does this child have difficulty when asked to end one activity and start another
	*3-5yrs
	gen sr_endstartactivity_index = .m
	replace sr_endstartactivity_index = 1 if inrange(sr_endstartactivity,1,2) & inrange(sc_age_years,3,5)
	replace sr_endstartactivity_index = 2 if sr_endstartactivity == 3 & inrange(sc_age_years,3,5)
	replace sr_endstartactivity_index = 3 if inrange(sr_endstartactivity,4,5) & inrange(sc_age_years,3,5)

	*17. how often does this child have trouble calming down
	*3-5yrs
	gen sr_calmdown_index = .m
	replace sr_calmdown_index = 1 if inrange(sr_calmdown,1,2) & inrange(sc_age_years,3,5)
	replace sr_calmdown_index = 2 if sr_calmdown == 3 & inrange(sc_age_years,3,5)
	replace sr_calmdown_index = 3 if inrange(sr_calmdown,4,5) & inrange(sc_age_years,3,5)

	*18. how often does this child have difficulty waiting for their turn
	*3-5yrs
	gen sr_waitturn_index = .m
	replace sr_waitturn_index = 1 if inrange(sr_waitturn,1,2) & inrange(sc_age_years,3,5)
	replace sr_waitturn_index = 2 if sr_waitturn == 3 & inrange(sc_age_years,3,5)
	replace sr_waitturn_index = 3 if inrange(sr_waitturn,4,5) & inrange(sc_age_years,3,5)

	*19. how often does this child get easily distracted
	*3-5yrs
	gen sr_distracted_index = .m
	replace sr_distracted_index = 1 if inrange(sr_distracted,1,2) & inrange(sc_age_years,3,5)
	replace sr_distracted_index = 2 if sr_distracted == 3 & inrange(sc_age_years,3,5)
	replace sr_distracted_index = 3 if inrange(sr_distracted,4,5) & inrange(sc_age_years,3,5)

	*20. how often does this child lose their temper
	*3-5yrs
	gen sr_temper_index = .m
	replace sr_temper_index = 1 if inrange(sr_temper,1,2) & inrange(sc_age_years,3,5)
	replace sr_temper_index = 2 if sr_temper == 3 & inrange(sc_age_years,3,5)
	replace sr_temper_index = 3 if inrange(sr_temper,4,5) & inrange(sc_age_years,3,5)



	***Motor
	*21. how well can this child draw a circle
	*3yrs
	gen m_circle_index = .m
	replace m_circle_index = 1 if m_circle == 1 & sc_age_years == 3
	replace m_circle_index = 2 if m_circle == 2 & sc_age_years == 3
	replace m_circle_index = 3 if inrange(m_circle,3,4) & sc_age_years == 3
	*4 & 5yrs
	replace m_circle_index = 1 if inrange(m_circle,1,2) & (sc_age_years == 4 | sc_age_years == 5)
	replace m_circle_index = 2 if m_circle == 3 & (sc_age_years == 4 | sc_age_years == 5)
	replace m_circle_index = 3 if m_circle == 4 & (sc_age_years == 4 | sc_age_years == 5)

	*22. how well can this child draw a face with eyes and mouth
	*3yrs
	gen m_face_index = .m
	replace m_face_index = 1 if m_face == 1 & sc_age_years == 3
	replace m_face_index = 2 if m_face == 2 & sc_age_years == 3
	replace m_face_index = 3 if inrange(m_face,3,4) & sc_age_years == 3
	*4yrs
	replace m_face_index = 1 if m_face == 1 & sc_age_years == 4
	replace m_face_index = 2 if inrange(m_face,2,3) & sc_age_years == 4
	replace m_face_index = 3 if m_face == 4 & sc_age_years == 4
	*4yrs
	replace m_face_index = 1 if inrange(m_face,1,2) & sc_age_years == 5
	replace m_face_index = 2 if m_face == 3 & sc_age_years == 5
	replace m_face_index = 3 if m_face == 4 & sc_age_years == 5

	*23. how well can this child draw a person with head, body, arms, and legs
	*3yrs
	gen m_person_index = .m
	replace m_person_index = 2 if m_person == 1 & sc_age_years == 3
	replace m_person_index = 3 if inrange(m_person,2,5) & sc_age_years == 3
	*4yrs
	replace m_person_index = 1 if m_person == 1 & sc_age_years == 4
	replace m_person_index = 2 if m_person == 2 & sc_age_years == 4
	replace m_person_index = 3 if inrange(m_person,3,4) & sc_age_years == 4
	*4yrs
	replace m_person_index = 1 if inrange(m_person,1,2) & sc_age_years == 5
	replace m_person_index = 2 if m_person == 3 & sc_age_years == 5
	replace m_person_index = 3 if m_person == 4 & sc_age_years == 5

	*24. how well can this child bounce a ball
	*3yrs
	gen m_bounceball_index = .m
	replace m_bounceball_index = 2 if m_bounceball == 1 & sc_age_years == 3
	replace m_bounceball_index = 3 if inrange(m_bounceball,2,4) & sc_age_years == 3
	*4 & 5yrs
	replace m_bounceball_index = 1 if m_bounceball == 1 & (sc_age_years == 4 | sc_age_years == 5)
	replace m_bounceball_index = 2 if m_bounceball == 2 & (sc_age_years == 4 | sc_age_years == 5)
	replace m_bounceball_index = 3 if inrange(m_bounceball,3,4) & (sc_age_years == 4 | sc_age_years == 5)



	***Health
	*25. how would you describe this child's health in general
	*3-5yrs
	gen h_generalhealth_index = .m
	replace h_generalhealth_index = 1 if inrange(h_generalhealth,1,2) & inrange(sc_age_years,3,5)
	replace h_generalhealth_index = 2 if h_generalhealth == 3 & inrange(sc_age_years,3,5)
	replace h_generalhealth_index = 3 if inrange(h_generalhealth,4,5) & inrange(sc_age_years,3,5)
	
	*25. how would you describe the condition of this child's health
	*3-5yrs
	gen h_conditionteeth_index = .m
	replace h_conditionteeth_index = 1 if inrange(h_conditionteeth,1,2) & inrange(sc_age_years,3,5)
	replace h_conditionteeth_index = 2 if h_conditionteeth == 3 & inrange(sc_age_years,3,5)
	replace h_conditionteeth_index = 3 if inrange(h_conditionteeth,4,5) & inrange(sc_age_years,3,5)
	
	*25. health conditions and impacts
	*3-5yrs
	gen h_healthconds_index = .m
	replace h_healthconds_index = 1 if h_healthconds == 1 & inrange(sc_age_years,3,5)
	replace h_healthconds_index = 2 if h_healthconds == 2 & inrange(sc_age_years,3,5)
	replace h_healthconds_index = 3 if inrange(h_healthconds,3,4) & inrange(sc_age_years,3,5)
	
	
	**************************************
	*****HRTL Domain & Overall Scores*****
	egen el_mean = rmean(el_beginsound_index el_samesound_index el_wordsrhyme_index el_letters_index /// 
		el_writename_index el_onedigit_index el_count_index el_groupmore_index el_simpleadd_index)
	egen se_mean = rmean(se_explainthings_index se_recogemotions_index se_sharetoys_index se_playwell_index /// 
		se_showconcern_index se_focustask_index)
	egen sr_mean = rmean(sr_temper_index sr_distracted_index sr_waitturn_index sr_calmdown_index /// 
		sr_endstartactivity_index)
	egen m_mean = rmean(m_circle_index m_face_index m_person_index m_bounceball_index)
	egen h_mean = rmean(h_generalhealth_index h_conditionteeth_index h_healthconds_index)

		*generate domain scores
		*NOTE: NEED TO RUN LOCAL THROUGH } OR WILL GET ERROR MESSAGE
		local newvars el_domain se_domain sr_domain m_domain h_domain

		foreach x of varlist el_mean se_mean sr_mean m_mean h_mean {
			gettoken new newvars : newvars 
			gen `new' = `x' if `x' == .m 
			replace `new' = 1 if `x' < 2
			replace `new' = 2 if 2 <= `x' & `x' < 2.5
			replace `new' = 3 if 2.5 <= `x' & `x' != .
		}
		
		*count number of missing across domains
		egen domain_n = rmiss(el_domain se_domain sr_domain m_domain h_domain)

			*recode number of missing to correspond to number of nonmissing
			recode domain_n 0=5 1=4 2=3 3=2 4=1 5=0
			
			label var el_domain "Early Learning Skills Index"
			label var se_domain "Social Emotional Development Index"
			label var sr_domain "Self-Regulation Index"
			label var m_domain  "Motor Development Index"
			label var h_domain  "Health Index"
			label var domain_n  "Number of nonmissing domains"

			*number on track
			gen domain_ns = 0
			gen domain_e  = 0
			gen domain_ot = 0

			*NOTE: NEED TO RUN LOCAL THROUGH } OR WILL GET ERROR MESSAGE
			local otvars el_ot se_ot sr_ot m_ot h_ot 

			foreach i of varlist el_domain se_domain sr_domain m_domain h_domain {
				gettoken ontr otvars : otvars 
				replace domain_ns = domain_ns + 1 if `i' == 1
				replace domain_e  = domain_e  + 1 if `i' == 2
				replace domain_ot = domain_ot + 1 if `i' == 3

				gen `ontr' = 1 		if `i' == 3
				replace `ontr' = 2  if `i' == 1 | `i' == 2
			}
				label var domain_ns "Number of Needs Support Domains"
				label var domain_e  "Number of Emerging Domains"
				label var domain_ot "Number of On Track Domains"
				label var el_ot "Early Learning Skills - On Track"
				label var se_ot "Social Emotional - On Track"
				label var sr_ot "Self-Regulation - On Track"
				label var m_ot  "Motor Development - On Track"
				label var h_ot  "Health - On Track"
			
			***HRTL Overall Measure
			*Children with no missing domain values
			gen hrtl_index = 1     if domain_n == 5 & 2 <= domain_ns //Needs Support in multiple domains
			replace hrtl_index = 2 if domain_n == 5 & domain_ot <= 4 & domain_ns <= 1 //Emerging - LT 5 OT & <=1 NS
			replace hrtl_index = 3 if domain_n == 5 & inlist(domain_ot,4,5) & domain_ns == 0 //On Track - 4 or 5 OT
			
			*Children with at least 1 missing domain value - use all available data
			replace hrtl_index = 3 if inrange(domain_n,1,4) & domain_n == domain_ot 
			replace hrtl_index = 1 if inrange(domain_n,1,4) & 1 <= domain_ns 
			replace hrtl_index = 2 if inrange(domain_n,1,4) & !inlist(hrtl_index,1,3)
			
			/***NOM HRTL - dichotomous measure***/
			gen hrtl_3to5 = 1 if hrtl_index == 3
			replace hrtl_3to5 = 2 if inlist(hrtl_index,1,2)			
			
			label var hrtl_index "Healthy & Ready to Learn Index"
			label define hrtl_index 1 "1.Needs Support" 2 "2.Emerging" 3 "3.On Track"
			label values hrtl_index el_domain se_domain sr_domain m_domain h_domain hrtl_index
			
			label var hrtl_3to5 "NOM School Readiness - HRTL"
			label define hrtl_3to5 1 "1.Yes, needs no supports" 2 "2.No, needs supports"
			label values hrtl_3to5 hrtl_3to5
			

			*recode values to .l and .m for missing values, minimum age, and 2016-2021 when data weren't collected/aren't comparable
			foreach var of varlist el_domain el_mean el_ot el_beginsound_index el_wordsrhyme_index el_samesound_index el_letters_index el_writename_index el_onedigit_index el_count_index el_groupmore_index el_simpleadd_index se_domain se_mean se_ot se_showconcern_index se_recogemotions_index se_playwell_index se_sharetoys_index se_explainthings_index se_focustask_index sr_domain sr_mean sr_ot sr_calmdown_index sr_waitturn_index sr_distracted_index sr_endstartactivity_index sr_temper_index m_domain m_mean m_ot m_circle_index m_face_index m_person_index m_bounceball_index h_domain h_mean h_ot h_generalhealth_index h_conditionteeth_index h_healthconds_index hrtl_index hrtl_3to5 domain_n domain_ns domain_e domain_ot {				
				replace `var' = .m	if `var' == . & inrange(sc_age_years,3,5)
				replace `var' = .l  if sc_age_years < 3 | inrange(sc_age_years,6,17)
				replace `var' = .n if year < 2022
				}

				
/***NOM: Tooth Decay/Cavities, children 1-17 years***/
gen toothdecay = cavities
replace toothdecay = .l if sc_age_years < 1
label var toothdecay "NOM Tooth Decay/Cavities, 1-17yrs"


/***NOM: Children's Health Status - excellent/very good***/
gen healthstatus = .m 
replace healthstatus = 1 if inrange(k2q01,1,2)
replace healthstatus = 2 if inrange(k2q01,3,5)
label var healthstatus "NOM Children's Health Status, all kids"
label define healthstatus 1 "1.Excellent/Very Good" 2 "2.Good/Fair/Poor"


/***NOM: Child/Adolescent Obesity, children 6-17 years***/
gen chadolbmi = .m 
replace chadolbmi = 1 if bmiclass == 4 // 95th percentile <= BMI
replace chadolbmi = 2 if inrange(bmiclass,1,3)
replace chadolbmi = .l if sc_age_years < 6
label var chadolbmi "NOM Child/Adolescent Obesity, 6-17yrs"


/***NOM: Behavioral/Conduct Disorder, children 6-11 years***/
gen behconduct_6to11 = k2q34b if inlist(k2q34b,.m,1) //Yes, current
replace behconduct_6to11 = 2  if inlist(k2q34b,.l,2) //Not current
replace behconduct_6to11 = .l if sc_age_years < 6 | 11 < sc_age_years
label var behconduct_6to11 "NOM Children who have a behavioral/conduct disorder, 6-11yrs"


/***NOM: Adolescent Depression/Anxiety, 12-17 years***/
gen anxiety = k2q33b if inlist(k2q33b,1,.m)
replace anxiety = 2  if inlist(k2q33b,2,.l)
replace anxiety = .l if sc_age_years < 12
label var anxiety "Adolescents who currently have anxiety probs, 12-17yrs"

gen depress = k2q32b if inlist(k2q32b,1,.m)
replace depress = 2  if inlist(k2q32b,2,.l)
replace depress = .l if sc_age_years < 12
label var depress "Adolescents who currently have depression, 12-17yrs"

gen depanx_12to17 = 1 if anxiety == 1 | depress == 1
replace depanx_12to17 = 2 if inlist(anxiety,2,.m) & inlist(depress,2,.m)
replace depanx_12to17 = .m if anxiety == .m & depress == .m
replace depanx_12to17 = .l if sc_age_years < 12
label var depanx_12to17 "NOM Adolescent Depression/Anxiety, 12-17yrs"


/***NOM: CSHCN Systems of Care***/
	*6 Subcomponents
	
***Subcomponent 1. Children whose families are partners in shared decision-making
gen sharedec = .l if inlist(decisions_r,.l,2) & 2023 <= year //decisions question changed in 2023 to ask if caregiver or HCP...
/*
NOTE: NEED TO ADD THE NEXT LINE OF CODE INTO VARIABLE GENERATION IF USING YEARS PRIOR TO 2023
*/
replace sharedec = .l if inlist(decisions,.l,2) & year < 2023
replace sharedec = 1 if inlist(discussopt,1,2,.m) & inlist(raiseconc,1,2,.m) & inlist(bestforchild,1,2,.m) 
replace sharedec = 2 if sharedec != 1 & (inlist(discussopt,3,4,.m) | inlist(raiseconc,3,4,.m) | inlist(bestforchild,3,4,.m))
replace sharedec = .m if discussopt == .m & raiseconc == .m & bestforchild == .m
label var sharedec "Children whose families involved in shared decision-making"


***Subcomponent 2. Medical Home - See NPM Medical Home 


***Subcomponent 3. Adequate Insurance, insured without gaps - SM Adequate Insurance
local insvars benefits allows expense 

	foreach i of varlist k3q20 k3q22 k3q21b {
		gettoken ins insvars : insvars 
		gen `ins' = `i' 
		replace `ins' = 3  if `i' == 4
		replace `ins' = .m if currins == .m
		replace `ins' = .l if currins == 2
	}
		*account for OOP costs in expense 
		replace expense = 4 if howmuch == 1 & !inlist(currins,.m,2)
		
		label var benefits "Current insurance benefits meet child's needs"
		label var allows   "Current insurance coverage allows to see needed providers"
		label var expense  "Current insurance out-of-pocket expenses are reasonable"
		
	gen insadeq = .m
	replace insadeq = 1 if inlist(benefits,1,2,.m) & inlist(allows,1,2,.m) & inlist(expense,1,2,4,.m)
	replace insadeq = 2 if benefits == 3 | allows == 3 | expense == 3
	replace insadeq = .m if benefits == .m & allows == .m & expense == .m 
	replace insadeq = .l if currins == 2
	label var insadeq "Adequate Insurance"
	
	gen inscurr=currins
	label var inscurr "Currently Has Health Insurance"
	
	gen gapins = 1 if insgap == 1
	replace gapins = 2 if inlist(insgap,2,3) | inscurr == 2
	replace gapins = .m if insgap == .m 
	label var gapins "Children without insurance at some point during past year"
	
	gen syscare3 = .m 
	replace syscare3 = 1 if inlist(gapins,1,.m) & inlist(insadeq,1,.m)
	replace syscare3 = 2 if inscurr == 2 | gapins == 2 | insadeq == 2
	replace syscare3 = .m if gapins == .m & insadeq == .m 
	label var syscare3 "Children who are continuously & adequately insured"


***Subcomponent 4. Received both preventive medical and dental care 
gen meddentcare = .m 
replace meddentcare = 1 if inlist(prevmed,1,.m) & inlist(prevdent_1to17,1,.l,.m)
replace meddentcare = 2 if meddentcare !=1 & prevmed == 2 | prevdent_1to17 == 2
replace meddentcare = .m if prevmed == .m & inlist(prevdent_1to17,.l,.m)
label var meddentcare "Children who received preventive medical & dental care"


***Subcomponent 5. Had difficulties in accessing care & always/usually frustrated in getting care 
gen frustrated = .m 
replace frustrated = 0 if c4q04 == 1
replace frustrated = 1 if c4q04 == 2
replace frustrated = 2 if c4q04 == 3 | c4q04 == 4
label var frustrated "Family frustrated in efforts to get health care"

gen unmetfrust = .m 
replace unmetfrust = 1 if inlist(k4q27,2,.m) & inlist(frustrated,0,1,.m)
replace unmetfrust = 2 if unmetfrust != 1 & (k4q27 == 1 | frustrated == 2)
replace unmetfrust = .m if k4q27 == .m & frustrated == .m 
label var unmetfrust "Children whose parents had difficulties in accessing care"


***Subcomponent 6. NPM Transition, all kids


***NOM CSHCN Systems of Care composite
*NOTE: S4Q01 preventive visit not comparable in 2018 to others years but overall Systems of Care is not affected
gen systcare = .m
*11 years and younger
replace systcare = 1 if sc_age_years <= 11 & inlist(sharedec,1,.l,.m) & inlist(medicalhome,1,.m) & inlist(syscare3,1,.m) & inlist(meddentcare,1,.m) & inlist(unmetfrust,1,.m)
replace systcare = 2 if sc_age_years <= 11 & (sharedec == 2 | medicalhome == 2 | syscare3 == 2 | meddentcare == 2 | unmetfrust == 2)
replace systcare = .m if sc_age_years <= 11 & inlist(sharedec,.l,.m) & medicalhome == .m & syscare3 == .m & meddentcare == .m & unmetfrust == .m

*12 years and older
replace systcare = 1 if 12 <= sc_age_years & inlist(sharedec,1,.l,.m) & inlist(medicalhome,1,.m) & inlist(syscare3,1,.m) & inlist(meddentcare,1,.m) & inlist(unmetfrust,1,.m) & inlist(transition,1,.m)
replace systcare = 2 if 12 <= sc_age_years & (sharedec == 2 | medicalhome == 2 | syscare3 == 2 | meddentcare == 2 | unmetfrust == 2 | transition == 2)
replace systcare = .m if 12 <= sc_age_years & inlist(sharedec,.l,.m) & medicalhome == .m & syscare3 == .m & meddentcare == .m & unmetfrust == .m & transition == .m
label var systcare "Systems of Care, all kids"

	gen systcare_1 = systcare if cshcn_exp == 1
	replace systcare_1 = .l  if cshcn_exp == 2
	label var systcare_1 "NOM CSHCN Systems of Care"


/***NOM: Flourishing, children 6 months to 5 years***/
local flvars tender resil0to5 curious0to5 smile 

	foreach i of varlist k6q70_r k6q73_r k6q71_r k6q72_r {
		gettoken flour flvars : flvars 
		gen `flour' = `i' 
		replace `flour' = .l  if sc_age_lt6 == 1
		replace `flour' = .n  if 5 < sc_age_years
	}	
		label var tender "Children who are affectionate and tender with parent, 6mo-5yr"
		label var resil0to5 "Children who bounce back quickly when things don't go their way, 6mo-5yr"
		label var curious0to5 "Children who show interest and curiosity in new things, 6mo-5yr"
		label var smile "Children who smile and laugh, 6mo-5yr"
		
	gen flrsh0to5ct = 0
	replace flrsh0to5ct = flrsh0to5ct + 1 if tender == 1 | tender == 2
	replace flrsh0to5ct = flrsh0to5ct + 1 if resil0to5 == 1 | resil0to5 == 2
	replace flrsh0to5ct = flrsh0to5ct + 1 if curious0to5 == 1 | curious0to5 == 2
	replace flrsh0to5ct = flrsh0to5ct + 1 if smile == 1 | smile == 2
	replace flrsh0to5ct = .m if tender == .m & resil0to5 == .m & curious0to5 == .m & smile == .m 
	replace flrsh0to5ct = .l if sc_age_lt6 == 1 
	replace flrsh0to5ct = .n if 5 < sc_age_years
	label var flrsh0to5ct "Count of always/usually responses to flourishing, 6mo-5yr"

	gen flrish0to5 = 1 if inrange(flrsh0to5ct,0,2)
	replace flrish0to5 = 2 if flrsh0to5ct == 3
	replace flrish0to5 = 3 if flrsh0to5ct == 4
	replace flrish0to5 = .m if tender == .m & resil0to5 == .m & curious0to5 == .m & smile == .m
	replace flrish0to5 = .l if sc_age_lt6 == 1 
	replace flrish0to5 = .n if 5 < sc_age_years
	label var flrish0to5 "Flourishing for young children, 6mo-5yr"
			
	*count number of missing across flourishing items
	egen flrsh0to5_n = rmiss(tender resil0to5 curious0to5 smile)
		
		*recode number of missing to correspond to number of nonmissing
		recode flrsh0to5_n 0=4 1=3 2=2 3=1 4=0
		
		gen flrshyoung = .m
		replace flrshyoung = 1 if 0 < flrsh0to5_n & (flrsh0to5_n == flrsh0to5ct)
		replace flrshyoung = 2 if 0 < flrsh0to5_n & flrshyoung != 1
		replace flrshyoung = .m if flrish0to5 == .m 
		replace flrshyoung = .l if sc_age_lt6 == 1
		replace flrshyoung = .n if 5 < sc_age_years
		label var flrshyoung "NOM Flourishing, 6mo-5yr"


/***NOM: Flourishing, child-adolescent 6 to 17 years***/
local flcavars curious6to17 finishes resil6to17 

	foreach i of varlist k6q71_r k7q84_r k7q85_r {
		gettoken flour flcavars : flcavars 
		gen `flour' = `i' 
		replace `flour' = .n  if sc_age_years < 6
	}	
		label var curious6to17 "Children who show interest and curiosity in new things, 6-17yr"
		label var finishes "Children who work to finish tasks they start, 6-17yr"
		label var resil6to17 "Children who stay calm and in control when faced with a challenge, 6-17yr"
		
	gen flrsh6to17ct = 0
	replace flrsh6to17ct = flrsh6to17ct + 1 if curious6to17 == 1 | curious6to17 == 2
	replace flrsh6to17ct = flrsh6to17ct + 1 if finishes == 1 | finishes == 2
	replace flrsh6to17ct = flrsh6to17ct + 1 if resil6to17 == 1 | resil6to17 == 2
	replace flrsh6to17ct = .m if curious6to17 == .m & finishes == .m & resil6to17 == .m
	replace flrsh6to17ct = .n if sc_age_years < 6
	label var flrsh6to17ct "Count of always/usually responses to flourishing, 6-17yr"

	gen flrish6to17 = 1 if inrange(flrsh6to17ct,0,1)
	replace flrish6to17 = 2 if flrsh6to17ct == 2
	replace flrish6to17 = 3 if flrsh6to17ct == 3
	replace flrish6to17 = .m if curious6to17 == .m & finishes == .m & resil6to17 == .m
	replace flrish6to17 = .n if sc_age_years < 6
	label var flrish6to17 "Flourishing for children and adolescents, 6mo-5yr"
			
	*count number of missing across flourishing items
	egen flrsh6to17_n = rmiss(curious6to17 finishes resil6to17)
		
		*recode number of missing to correspond to number of nonmissing
		recode flrsh6to17_n 0=3 1=2 2=1 3=0
		
		gen flrshchild = .m
		replace flrshchild = 1 if 0 < flrsh6to17_n & (flrsh6to17_n == flrsh6to17ct)
		replace flrshchild = 2 if 0 < flrsh6to17_n & flrshchild != 1
		replace flrshchild = .m if flrish6to17 == .m 
		replace flrshchild = .n if sc_age_years < 6
		label var flrshchild "NOM Flourishing, 6-17yr"
		
		gen flrshchild_1 = flrshchild if cshcn_exp == 1
		replace flrshchild_1 = .l if cshcn_exp == 2
		label var flrshchild_1 "NOM Flourishing, CSHCN 6-17yr"
		
		*recode flourishing to missing for 2016/2017 because data are not comparable
		foreach var of varlist flrsh0to5ct flrshyoung flrsh6to17ct flrshchild flrshchild_1 {
			replace `var' = .n if year < 2018
		}


/***NOM: ACEs***/
gen acect = 0
replace acect = acect + 1 if inlist(ace1,3,4) //cover basics
replace acect = acect + 1 if ace3 == 1 //divorce
replace acect = acect + 1 if ace4 == 1 //parent/guardian death
replace acect = acect + 1 if ace5 == 1 //parent/guardian jail or prison
replace acect = acect + 1 if ace6 == 1 //adults abuse others
replace acect = acect + 1 if ace7 == 1 //victim of violence
replace acect = acect + 1 if ace8 == 1 //lived with someone mentally ill
replace acect = acect + 1 if ace9 == 1 //lived with drug/alcohol abuse
replace acect = acect + 1 if ace10 == 1 //treated unfairly bc of race
replace acect = acect + 1 if ace11 == 1 //treated unfairly bc of health condition
replace acect = .m if ace1 == .m & ace3 == .m & ace4 == .m & ace5 == .m & ace6 == .m & ace7 == .m & ace8 == .m & ace9 == .m & ace10 == .m & inlist(ace11,.,.m)
label var acect "Number of ACEs of 10 asked about"

gen ace = .m
replace ace = 1 if acect == 0
replace ace = 2 if acect == 1
replace ace = 3 if 1 < acect
replace ace = .m if acect == .m
label var ace "Number of ACEs, 0 1 2+"
label define ace 1 "0 ACEs" 2 "1 ACE" 3 "2+ ACEs"
label values ace ace

gen ace2 = 1 if ace == 3
replace ace2 = 2 if inlist(ace,1,2)
replace ace2 = .m if ace == .m 
label var ace2 "NOM 2+ ACEs, all kids"


**Labeling NOM values - yes/no
foreach var of varlist toothdecay chadolbmi behconduct_6to11 anxiety depress depanx_12to17 systcare systcare_1 flrshyoung flrshchild flrshchild_1 ace2 {
	label values `var' yesno
	}


***********************************
// Standardized Measures
***********************************

/***SM: Smoking, household***/
gen hhsmoking=k9q40
label var hhsmoking "SM Smoking in household, all kids"


/***SM: Adequate Insurance***/
gen adqins = 1 if inlist(gapins,1,.m) & inlist(insadeq,1,.m)
replace adqins = 2 if currins == 2 | gapins == 2 | insadeq == 2
replace adqins = .m if gapins == .m & insadeq == .m 
label var adqins "SM Adequate Insurance, all kids"


/***SM: Foregone Health Care***/
gen forgonehlth = k4q27 
label var forgonehlth "SM Forgone Health Care, all kids"


/***SM: Adolescent Physical Activity***/
gen physactiv_12to17 = .m
replace physactiv_12to17 = 1 if physactiv == 4
replace physactiv_12to17 = 2 if inrange(physactiv,1,3)
replace physactiv_12to17 = .l if sc_age_years < 12
label var physactiv_12to17 "SM Adolescent Physical Activity, 12-17yr"


**Labeling SM values - yes/no
foreach var of varlist hhsmoking adqins forgonehlth physactiv_12to17 {
	label values `var' yesno
	}

***********************************
// Form 11
***********************************

/***FORM 11: Children with special health care needs***/
gen f11cshcn = cshcn_exp
label var f11cshcn "Title V FORM 11: CSHCN"

/***FORM 11: Current autism, age 3-17 Years***/
gen f11autism = .m
replace f11autism = 1 if k2q35b == 1 
replace f11autism = 2 if inlist(k2q35b,.l,2) 
replace f11autism = .l if sc_age_years < 3
label var f11autism "Title V FORM 11: Autism"

/***FORM 11: Current ADD/ADHD, age 3-17 Years***/
gen f11add = .m
replace f11add = 1 if k2q31b == 1 
replace f11add = 2 if inlist(k2q31b,.l,2) 
replace f11add = .l if sc_age_years < 3
label var f11add "Title V FORM 11: ADD/ADHD"

**Labeling form 11 values - yes/no
foreach var of varlist f11cshcn f11autism f11add {
	label values `var' yesno
	}
	
***Save stacked files for future use
save "$out\tvis16-25.dta", replace  


/*******************************************
  BIVARIATE ESTIMATES - NPMs & NOMs
CAUTION: Need to use subpop option for 
correct SEs when running individual measures
*******************************************/
/*NOTE: INCLUDE APPROPRIATE WEIGHT VAR - fwc2yr etc IF NOT ALREADY SET
*all years with single year estimates*/
svyset[pweight=fwc], strat(stratacross) psu(hhid) singleunit(certainty) vce(linearized)
/*two years, e.g., 2022/2023
svyset[pweight=fwc2yr], strat(stratacross) psu(hhid) singleunit(certainty) vce(linearized)
*/

***SINGLE YEAR ESTIMATES FOR NPMS NOMS & SMS
*NPMs & NOMs by year
foreach var in /*NPMs*/ ex6brstfd housing_0to11 devscreen_9to35 prevdent_1to17 physactiv_6to11 food_0to11 wellvisit_12to17 mhtx_12to17 mentor_12to17 medicalhome_1 medicalhome perdrns_1 perdrns usualsck_1 usualsck famcentcare_1 famcentcare referral_1 referral carecoor_1 carecoor transition_1 transition bullyothers_1 bullyothers arebullied_1  arebullied /*NOM*/hrtl_3to5 toothdecay healthstatus chadolbmi behconduct_6to11 depanx_12to17 systcare_1 flrshyoung flrshchild_1 flrshchild ace2 /*SM*/hhsmoking adqins forgonehlth physactiv_12to17 /*Form 11*/ f11cshcn f11autism f11add {
	svy: tab year `var', row percent se ci format(%4.2f)
	svy: tab year `var', obs count format(%11.5gc)
}
* example with subpop option for correct SEs if running a single variable that does not include all children/design information
svy,subpop(if sc_age_lt6==2 & sc_age_years<=2): tab year ex6brstfd, row percent se ci format(%4.2f)

*Stratifiers by year
foreach var in age cshcn_exp cshcntype higrade_tvis hhstructure insurance language nativity race_eth sc_aian nh_nhpi_any sc_sex ace msa {
	svy: tab year `var', row percent se ci format(%4.2f)
	svy: tab year `var', obs count format(%11.5gc)
}

***RUN IF NOT ALREADY RESTRICTED TO A TWO-YEAR DATA FILE 
use "$in\tvis16-25.dta" if inlist(year,2024,2025)
save "$in\tvis24-25", replace  

svyset[pweight=fwc2yr], strat(stratacross) psu(hhid) singleunit(certainty) vce(linearized) // set weights


*NPMs & NOMs by state
foreach var in /*NPMs*/ ex6brstfd housing_0to11 devscreen_9to35 prevdent_1to17 physactiv_6to11 food_0to11 wellvisit_12to17 mhtx_12to17 mentor_12to17 medicalhome_1 medicalhome perdrns_1 perdrns usualsck_1 usualsck famcentcare_1 famcentcare referral_1 referral carecoor_1 carecoor transition_1 transition bullyothers_1 bullyothers arebullied_1  arebullied /*NOM*/hrtl_3to5 toothdecay healthstatus chadolbmi behconduct_6to11 depanx_12to17 systcare_1 flrshyoung flrshchild_1 flrshchild ace2 /*SM*/hhsmoking adqins forgonehlth physactiv_12to17 /*Form 11*/ f11cshcn f11autism f11add  {
	svy: tab state `var', row percent se ci format(%4.2f)
	svy: tab state `var', obs count format(%11.5gc)
}
* example with subpop option for correct SEs if running a single variable that does not include all children/design information
svy,subpop(if sc_age_lt6==2 & sc_age_years<=2): tab state ex6brstfd, row percent se ci format(%4.2f)

*NPMs & NOMs by all stratifiers
foreach var in /*NPMs*/ ex6brstfd housing_0to11 devscreen_9to35 prevdent_1to17 physactiv_6to11 food_0to11 wellvisit_12to17 mhtx_12to17 mentor_12to17 medicalhome_1 medicalhome perdrns_1 perdrns usualsck_1 usualsck famcentcare_1 famcentcare referral_1 referral carecoor_1 carecoor transition_1 transition bullyothers_1 bullyothers arebullied_1  arebullied /*NOM*/hrtl_3to5 toothdecay healthstatus chadolbmi behconduct_6to11 depanx_12to17 systcare_1 flrshyoung flrshchild_1 flrshchild ace2 /*SM*/hhsmoking adqins forgonehlth physactiv_12to17 /*Form 11*/ f11cshcn f11autism f11add{
	foreach x in region state cshcn_exp cshcntype higrade_tvis hhstructure insurance language nativity race_eth sc_aian nh_nhpi_any sc_sex ace msa {
		svy: tab `x' `var', row percent se ci format(%4.2f)
		svy: tab `x' `var', obs count format(%11.5gc)
	}
}


*****************************************************************************
// RESHAPE FILE TO USE MULTIPLE IMPLICATES FOR FAMILY INCOME TO POVERTY RATIO 
*****************************************************************************
** Create variable to indicate implicate
*fpl_i0 may already be generated, check your codebook
gen fpl_i0=.
	
*Save before reshaping
save "$in/tvis24-25", replace /* must be saved prior to declaring imputation */ 

mi import wide, imputed(fpl_i0=fpl_i1-fpl_i6) drop 
	
mi passive: generate povcat_i=1 if fpl_i0<100 /* generate new variable based on imputed fpl */
mi passive: replace povcat_i=2 if fpl_i0>=100&fpl_i0<200
mi passive: replace povcat_i=3 if fpl_i0>=200&fpl_i0<400
mi passive: replace povcat_i=4 if fpl_i0>=400&fpl_i0~=.

*INCLUDE APPROPRIATE WEIGHT VAR - fwc2yr etc.
mi svyset hhid [pweight=fwc2yr], strata(stratacross) /* declare survey data */
	


*******************************************
// FPL - NPMs & NOMs, MULTIPLE IMPUTATION            
*******************************************
*NPMs & NOMs by fpl
foreach var in /*NPMs*/ ex6brstfd housing_0to11 devscreen_9to35 prevdent_1to17 physactiv_6to11 food_0to11 wellvisit_12to17 mhtx_12to17 mentor_12to17 medicalhome_1 medicalhome perdrns_1 perdrns usualsck_1 usualsck famcentcare_1 famcentcare referral_1 referral carecoor_1 carecoor transition_1 transition bullyothers_1 bullyothers arebullied_1  arebullied /*NOM*/hrtl_3to5 toothdecay healthstatus chadolbmi behconduct_6to11 depanx_12to17 systcare_1 flrshyoung flrshchild_1 flrshchild ace2 /*SM*/hhsmoking adqins forgonehlth physactiv_12to17 /*Form 11*/ f11cshcn f11autism f11add {
		mi est: svy: proportion `var', over(povcat_i) percent //need to multiple estimates by 100
		} 
	
* example with subpop option for correct SEs if running a single variable that does not include all children/design information
mi est: svy,subpop(if sc_age_lt6==2 & sc_age_years<=2): proportion ex6brstfd, over(povcat_i) percent
