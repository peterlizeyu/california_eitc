
use $data_dir/temp/cps_cleaned.dta, clear

/*

*** Merge CPS with state-by-year unemployment rate ***

// Drop DC for now because (1) it is not a donor state (2) we do not have the unemployment rate data
drop if stfips == 11 

merge m:1 stfips year using $data_dir/temp/ur_cleaned.dta
assert _merge != 1
keep if _merge == 3
drop _merge
*/

*** Define variables ***

* DD

gen post = year >= 2015

* By MW changes

gen p16 = year >= 2016
gen p17 = year >= 2017
gen p18 = year >= 2018
gen p19 = year >= 2019


* By edu level

* (Already defined as HS, some college, and college)
gen ca = stfips == 6

gen ca_X_post_X_kid_X_lowed = ca*post*kid*lowed

gen ca_X_post_X_kid = ca*post*kid

gen ca_X_post_X_lowed = ca*post*lowed

gen ca_X_kid_X_lowed = ca*kid*lowed

gen post_X_kid_X_lowed = post*kid*lowed

gen ca_X_kid = ca*kid

gen post_X_kid = post*kid

gen ca_X_post = ca*post

gen ca_X_lowed = ca*lowed

gen post_X_lowed = post*lowed

gen kid_X_lowed = kid*lowed

* Interactions by MW changes

foreach v of varlist p16 p17 p18 p19{
	gen ca_X_`v'_X_kid_X_lowed = ca*`v'*kid*lowed
	gen ca_X_`v'_X_kid = ca*`v'*kid
	gen ca_X_`v'_X_lowed = ca*`v'*lowed
	gen `v'_X_kid_X_lowed = `v'*kid*lowed
	gen `v'_X_kid = `v'*kid
	gen ca_X_`v' = ca*`v'
	gen `v'_X_lowed = `v'*lowed
}

* Interactions by edu

foreach v of varlist below_hs hs some_college{
	gen ca_X_post_X_`v' = ca*post*`v'
	gen ca_X_post_X_kid_X_`v' = ca*post*kid*`v'
	gen ca_X_kid_X_`v' = ca*kid*`v'
	gen post_X_kid_X_`v' = post*kid*`v'
	gen ca_X_`v' = ca*`v'
	gen post_X_`v' = post*`v'
	gen kid_X_`v' = kid*`v'
}

	
label var ca_X_post_X_kid_X_lowed "CA \times post \times kids \times low ed"

label var ca_X_post_X_kid "CA \times post \times kids"
label var ca_X_post_X_lowed "CA \times post \times low ed"
label var ca_X_kid_X_lowed "CA \times kids \times low ed"
label var post_X_kid_X_lowed "Post \times kids \times low ed"

label var ca_X_kid "CA \times kids"
label var ca_X_lowed "CA \times low ed"
label var ca_X_post "CA \times post"
label var post_X_kid "Post \times kids"
label var post_X_lowed "Post \times low ed"
label var kid_X_lowed "Kids \times low ed"

label var ca "CA"
label var post "Post"
label var kid "Kids"
label var lowed "Low ed"


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


* Keep CA and donors only

keep if donor == 1 | ca == 1
keep if year >= 2010 & year <= 2019

rename ca st
rename ca_X_post st_X_post

rename ca_X_kid st_X_kid
renam ca_X_post_X_kid st_X_post_X_kid


save $data_dir/temp/analysis_6.dta, replace


