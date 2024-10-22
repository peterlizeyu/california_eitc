*****************************************************
* Input: data_dir/raw/cps_8621_nw.dta
* Output: data_dir/temp/cps_cleaned_nw.dta
*****************************************************

use $data_dir/raw/cps_8621_nw.dta, clear

*** Geographical Info ***

rename statefip stfips // State FIPS
rename county ctfips // County FIPS

*** Family ID

gen fid=(serial*100)+famid  // NW Notes: Good within year, so have to collapse on fid and year below;

*** Demographics ***

replace year = year - 1

gen age_sq = age^2 

gen male = (sex == 1)

gen married = (marst == 1 | marst == 2) if marst != 9  // NIU?

gen black = (race == 200 | race == 801 | race == 805 | race == 806 | race == 807 | race == 810 | race == 811 | race == 814 | race == 816 | race == 818)

gen hispanic = hispan > 0

* edu *

gen below_hs = (educ<=71) if educ >1
gen hs = (educ == 73 | educ == 81) if educ >1
gen some_college = (educ == 91 | educ == 92) if educ >1
gen college_grad = educ >= 111 if educ >1

gen edu = .
replace edu = 1 if below_hs
replace edu = 2 if hs
replace edu = 3 if some_college
replace edu = 4 if college_grad

label define education 1 "Below HS" 2 "HS degree" 3 "Some college" 4 "College graduate and above"
label values edu education

gen lowed = (edu <= 2) // Low ed indicator: HS or below

gen highed = college_grad // High ed indicator: BA or above

* children *

* children under 18 * (updated because NW paper uses different definitions from the raw variables)

gen ch18ex=(age==18 & famrel==3 & marst==6)
su ch18ex

preserve 

keep if ch18ex

keep year fid ch18ex
bys year fid: gen idch18ex = _n
bys year fid: egen num_ch18ex = max(idch18ex)

keep year fid num_ch18ex
duplicates drop year fid num_ch18ex, force

save $data_dir/temp/nch18ex.dta, replace

restore

merge m:1 year fid using $data_dir/temp/nch18ex.dta
assert _merge != 2
drop _merge

replace num_ch18ex = 0 if num_ch18ex == .

gen num_child = uh_child18_a3 + num_ch18ex
gen num_child_u6 = uh_child6_a2
gen kid = (num_child > 0) if num_child !=.
gen one = num_child == 1
gen twoplus = (num_child >=2) 

*** Employment ***

* employed last year *

gen emp_yr = (uh_workyn_a2 == 1) if uh_workyn_a2 != 0 // Employment status last year
gen lfp = (labforce == 2) if labforce != 0
replace lfp = 100 * lfp

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

* Earnings

gen rincwage = incwage
replace rincwage = 1 if incwage == 0
gen per_wage = log(rincwage) if incwage < 99999999 // Total personal wage and salary income
gen per_income = log(inctot) if inctot < 999999998 // Total personal income
gen fam_income =log(ftotval) if ftotval < 9999999999 // Total family income

gen missing = 0

foreach var of varlist emp_yr lfp{
	replace missing = 1 if missing(`var')
}

drop if missing

* Merge CPS with state-by-year unemployment rate

merge m:1 stfips year using $data_dir/temp/ur_cleaned.dta
// assert _merge != 1
keep if _merge == 3
drop _merge

drop if year == 1985

* Merge CPS with state-by-year eitc rate

merge m:1 stfips year using $data_dir/temp/eitc_cleaned.dta
keep if _merge == 3
drop _merge

* variables for DD

gen EITC = eitc
gen EITC_X_kids = eitc*kid
gen EITC_X_lowed = eitc*lowed

label var EITC_X_kids "EITC * kid"
label var EITC_X_lowed "EITC * low ed"

* FE

tostring stfips, gen(stfips_str)
tostring year, gen(year_str)
tostring kid, gen(kid_str)
tostring lowed, gen(lowed_str)

gen st_year_kid = stfips_str + year_str + kid_str
gen st_year_lowed = stfips_str + year_str + lowed_str
gen st_kid_lowed = stfips_str + kid_str + lowed_str
gen year_kid_lowed = year_str + kid_str + lowed_str

gen st_year = stfips_str + year_str 
gen st_kid = stfips_str + kid_str
gen st_lowed = stfips_str + lowed_str
gen year_kid = year_str + kid_str
gen year_lowed = year_str + lowed_str
gen kid_lowed = kid_str + lowed_str

save $data_dir/temp/analysis_nw.dta, replace

