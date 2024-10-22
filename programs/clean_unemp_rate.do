*****************************************************
* This do-file cleans the state-by-year unemployment 
* rate data computed from CPS

* Input: $data_dir/raw/ur_cps.xls
* Output: $data_dir/temp/ur_cleaned.dta
*****************************************************

import excel $data_dir/raw/ur_cps.xls, sheet("Annual") firstrow clear
gen year = year(DATE)
order year
drop DATE

xpose, clear varname
local j = 1976
foreach v of varlist v1 - v46{
	gen unemp_`j' = `v'
	local j = `j' + 1
}

gen stfips = substr(_varname, 6, 2)
keep if stfips != "" // Drop the first row (year)
destring stfips, replace
drop v1-v46 _varname
order stfips
reshape long unemp_, i(stfips) j(year)
rename unemp_ ur
save $data_dir/temp/ur_cleaned.dta, replace
