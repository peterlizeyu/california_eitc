*****************************************************
* This do-file cleans data for the state EITC's percentage of 
* the federal EITC 
* Input: $data_dir/raw/state_eitc_pctg.xlsx
*        $data_dir/raw/stateeitcdn.xls
* Output: $data_dir/temp/state_eitc_pctg.dta
*         $data_dir/temp/state_eitc_pctg_dt.dta
*         $data_dir/temp/state_eitc_pctg_dt_long.dta
*****************************************************

* Version 1: clean the most recent % of state EITC

import excel $data_dir/raw/state_eitc_pctg.xlsx, sheet("Sheet1") firstrow case(lower) clear

keep state - standardyn

drop if standardyn == "N"

rename fipscode stfips

drop offederal

rename offederalavg offederal

save $data_dir/temp/state_eitc_pctg.dta, replace

* Version 2: all historical % of state EITC

import excel $data_dir/raw/stateeitcdn.xls, sheet("EITC state supp_expanded") firstrow case(lower) clear

keep state ss1986-ss2019

keep if ss2019 != .

forval i = 1986/2019{
	ren ss`i' pctg`i'
}

save $data_dir/temp/state_eitc_pctg_dt.dta, replace

*** Merge with state FIPS code

rename state stname

merge 1:1 stname using $data_dir/raw/stfips.dta
keep if _merge == 3
drop _merge

** Generate a long-form data only for states with conventional EITCs
gen donor = 0

replace donor = 1 if stfips == 01 | stfips == 02 | stfips == 04 | stfips == 05 | stfips == 12 | stfips == 13 | stfips == 16 | stfips == 21 | stfips == 28 | stfips == 29 | stfips == 32 | stfips == 33 | stfips == 37 | stfips == 38 | stfips == 42 | stfips == 46 | stfips == 47 | stfips == 48 | stfips == 49 | stfips == 54 | stfips == 56 


keep if stfips == 6 | stfips == 8 | stfips == 9 |  ///
        stfips == 17 | stfips == 19 | stfips == 20 | stfips == 22 |  ///
        stfips == 25 | stfips == 26 | stfips == 31 |  ///
        stfips == 34 | stfips == 35 | stfips == 36 |  ///
        stfips == 41 | stfips == 50 | donor == 1
				
reshape long pctg, i(stfips) j(year)

keep stfips year pctg

save $data_dir/temp/state_eitc_pctg_dt_long.dta, replace
