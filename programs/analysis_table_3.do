*****************************************************
* This do-file run regressions similar to Neumark and 
* Wascher (2011) to examine the effect of California 
* EITC on employment outcomes

* Input: data/temp/analysis.dta
*****************************************************

use $data_dir/temp/analysis_nw.dta, clear
set seed 12345
drop if stfips == 6
unique stfips
encode st_kid, gen(st_kid_num)
encode year_kid, gen(year_kid_num)

keep if age <=44 & age >=21
tempfile origin
save `origin'

use `origin', clear
keep if married == 0 & male == 0 & lowed
tempfile single_women_lowed
save `single_women_lowed'

global deplist `"emp_yr hour_annual hour_annual_unc per_wage per_wage_unc"'
local covlist_kid "ib1.edu ib0.num_child_u6 ib1.num_child ib3.marst ib0.black ib0.hispanic age age_sq ur"
local covlist_lowed "ib4.edu ib0.num_child_u5 ib0.num_child_u5#lowed ib0.num_child ib0.num_child#lowed ib3.marst ib3.marst#lowed ib0.black ib0.black#lowed ib0.hispanic ib0.hispanic#lowed age age_sq c.age#lowed c.age_sq#lowed ur c.ur#lowed"
local covlist_dddd "ib4.edu ib4.edu#kid ib0.num_child_u5 ib0.num_child_u5#lowed ib0.num_child ib0.num_child#lowed ib3.marst ib3.marst#kid ib3.marst#lowed ib3.marst#lowed#kid ib0.black ib0.black#kid ib0.black#lowed ib0.black#kid#lowed ib0.hispanic ib0.hispanic#kid ib0.hispanic#lowed ib0.hispanic#lowed#kid age age_sq c.age#kid c.age_sq#kid c.age#lowed c.age_sq#lowed c.age#kid#lowed c.age_sq#kid#lowed ur c.ur#kid c.ur#lowed c.ur#kid#lowed"

eststo clear 

foreach var in emp_yr hour_worked per_wage{
	foreach sample in single_women_lowed{
	use ``sample'', clear
	eststo: wildbootstrap reg `var' EITC EITC_X_kids `covlist_kid' i.st_kid_num i.year_kid_num i.stfips i.year [w=asecwt], cluster(stfips) coef(EITC_X_kids) reps(1000)
	su `var' if e(sample) [w=asecwt]
    estadd scalar dep_mean = r(mean)
    estadd scalar r = e(r2)
}

esttab * using $dir/outfiles/rep_nw.csv, b(3) se(3) /*
	*/ nocons /*
	*/ mtitle("Employment" "Hours" "Earnings")/*
    */ stats(dep_mean r N, label("Dependent Mean" "R^2" "Observations") fmt(3 3 0)) /*
	*/ keep(EITC_X_kids EITC) order(EITC_X_kids EITC) label/*
	*/ nonotes /*
	*/ replace
}



