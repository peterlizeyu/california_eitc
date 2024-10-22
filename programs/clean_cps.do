*****************************************************
* This do-file cleans the CPS annual data (March files)

* Input: data_dir/raw/cps_annual_8621_poverty.dta
* Output: data_dir/temp/cps_cleaned.dta

*****************************************************

use $data_dir/raw/cps_annual_8621_poverty.dta, clear

rename year syear

gen year = syear - 1 // In CPS-ASEC, the year is actually the survey year, which is next to the actual year of the data period.

*** Geographical Info ***

rename statefip stfips // State FIPS
rename county ctfips // County FIPS

gen donor = . // Donors are states that never have had any supplemental EITC.
replace donor = 0 if stfips == 6 | stfips == 8 | stfips == 9 | stfips == 17 | stfips == 18  | stfips == 19 | stfips == 20 | stfips == 22  | stfips == 25 | stfips == 26 | stfips == 30  | stfips == 31 | stfips == 34 | stfips == 35  | stfips == 36 | stfips == 41 | stfips == 44 | stfips == 50 

replace donor = 1 if stfips == 01 | stfips == 02 | stfips == 04 | stfips == 05 | stfips == 12 | stfips == 13 | stfips == 16 | stfips == 21 | stfips == 28 | stfips == 29 | stfips == 32 | stfips == 33 | stfips == 37 | stfips == 38 | stfips == 42 | stfips == 46 | stfips == 47 | stfips == 48 | stfips == 49 | stfips == 54 | stfips == 56 

// Donor states that never have state EITC

keep if donor != .


*** Demographics ***

gen age_sq = age^2 

gen male = (sex == 1)

gen married = (marst == 1 | marst == 2) if marst != 9

gen black = (race == 200 | race == 801 | race == 805 | race == 806 | race == 807 | race == 810 | race == 811 | race == 814 | race == 816 | race == 818)

gen hispanic = hispan > 0

* edu *

gen below_hs = (educ<=72) if educ >1

gen hs = (educ == 73 | educ == 81) if educ >1
replace hs = (educ == 80 | educ == 90 | educ == 100) if educ >1 & year <=1990

gen some_college = (educ == 91 | educ == 92) if educ >1
replace some_college = (educ == 100) if educ >1 & year <=1990

gen college_grad = educ >= 111 if educ > 1
replace college_grad = educ >= 110 if educ > 1 & year <=1990

gen edu = .
replace edu = 1 if below_hs
replace edu = 2 if hs
replace edu = 3 if some_college
replace edu = 4 if college_grad

label define education 1 "Below HS" 2 "HS degree" 3 "Some college" 4 "College graduate and above"
label values edu education

gen lowed = (edu <= 2) // Low ed indicator: HS or below

gen highed = college_grad // High ed indicator: BA or above

* children under 18 *

foreach v of varlist momloc momloc2 poploc poploc2{
	
preserve

keep if `v' != 0 & age <19 // Data for all children under 18

keep year serial `v' age

bys year serial `v': gen idchild = _n // ID of children sharing one mother

bys year serial `v': egen num_child = max(idchild)

keep year serial `v' num_child

duplicates drop year serial `v' num_child, force

rename `v' pernum

rename num_child num_child_`v'

save $data_dir/temp/child_`v'.dta, replace

restore

}


foreach v of varlist momloc momloc2 poploc poploc2{

merge 1:1 year serial pernum using $data_dir/temp/child_`v'.dta

assert _merge != 2
drop _merge

}


gen num_child = 0

foreach v of varlist momloc momloc2 poploc poploc2{

replace num_child = num_child + num_child_`v' if num_child_`v'!=.
}

egen num_child_max = rowmax(num_child_momloc num_child_momloc2 num_child_poploc num_child_poploc2)
replace num_child_max = 0 if num_child_max==.

assert num_child_max == num_child


* children under 6 *

foreach v of varlist momloc momloc2 poploc poploc2{
	
preserve

keep if `v' != 0 & age <7 // Data for all children under 6

keep year serial `v' age

bys year serial `v': gen idchild = _n // ID of children sharing one mother

bys year serial `v': egen num_child = max(idchild)

keep year serial `v' num_child

duplicates drop year serial `v' num_child, force

rename `v' pernum

rename num_child num_child_`v'_u6

save $data_dir/temp/child_`v'_u6.dta, replace

restore

}


foreach v of varlist momloc momloc2 poploc poploc2{

merge 1:1 year serial pernum using $data_dir/temp/child_`v'_u6.dta

assert _merge != 2
drop _merge

}


gen num_child_u6 = 0

foreach v of varlist momloc momloc2 poploc poploc2{

replace num_child_u6 = num_child_u6 + num_child_`v'_u6 if num_child_`v'_u6!=.
}


gen kid = (num_child > 0) if num_child !=.

*** Employment ***

* employed last year *

gen emp_yr = (workly == 2) if workly != 0 // Employment status last year

replace emp_yr = 100 * emp_yr

* weeks of work *

gen week_worked = wkswork1 if uhrsworkly<=99

gen week_worked_unc = wkswork1

* hours of work *

gen hour_worked = uhrsworkly if uhrsworkly<=99

gen hour_worked_unc = uhrsworkly

replace hour_worked_unc = 0 if uhrsworkly == 999

* Annual hours

gen hour_annual = week_worked*hour_worked

gen hour_annual_unc = week_worked_unc * hour_worked_unc

*** Earning ***

gen income_wage = incwage if incwage < 99999999 & uhrsworkly<=99 // Total personal wage and salary income
gen income_business = incbus if incbus < 99999998 // business income


gen income_wage_bus = income_wage + income_business

replace income_wage_bus=0 if income_wage_bus < 0


gen per_wage = asinh(income_wage_bus*cpi99) if incwage < 99999999 & incbus < 99999998 & uhrsworkly<=99 // Total personal wage and salary income
gen per_income = log(inctot*cpi99) if inctot < 999999998 // Total personal income
gen fam_income =log(ftotval*cpi99) if ftotval < 9999999999 // Total family income


gen per_wage_unc = per_wage
replace per_wage_unc = asinh(0) if incwage >= 99999999 | uhrsworkly >99


*** Poverty ***

gen poverty_org = (poverty == 10) if poverty != 0
gen poverty_ipums = (offpov == 1) if offpov != 99
gen lowincome_org = (poverty <= 22) if poverty != 0


* Define poverty manually

gen poverty_manual = (offtotv < cutoff)
gen poverty_manual_50 =  (offtotv < 0.5 * cutoff)
gen poverty_manual_150 =  (offtotv < 1.5 * cutoff)


foreach v of varlist poverty_org - poverty_manual_150{
	replace `v' = `v' * 100
}


gen missing = 0

foreach var of varlist emp_yr {
	replace missing = 1 if missing(`var')
}

drop if missing


*** Merge CPS with state-by-year unemployment rate ***

merge m:1 stfips year using $data_dir/temp/ur_cleaned.dta
assert _merge != 1
keep if _merge == 3
drop _merge


*** Merge CPS with state EITC information ***

merge m:1 stfips using $data_dir/temp/state_eitc_pctg.dta
drop _merge

save $data_dir/temp/cps_cleaned.dta, replace
