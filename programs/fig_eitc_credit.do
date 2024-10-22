*****************************************************
* This do-file produces Figure 1 in Neumark-Li

* Input: data_dir/raw/cps_annual_8621_poverty.dta
* Output: data_dir/temp/cps_cleaned.dta

*****************************************************

import excel $data_dir/raw/eitc_credit_federal_ca, sheet("Sheet1") firstrow

keep income-credit_total

* Federal

twoway (line credit_fed income,), xtitle("Income ($)") ytitle("Eligible Credit ($)") ysize(3) scale(1.2) scheme(s1mono) saving($dir/outfiles/figure/federal.gph, replace) 
graph export $dir/outfiles/figure/credit_fed.jpg, as(jpg) replace

* CA

twoway (line credit_ca income,lpattern(dash)), xtitle("Income ($)") ytitle("Eligible Credit ($)") ylabel(0(2000)6000) ysize(3) scale(1.2) scheme(s1mono) saving($dir/outfiles/figure/ca.gph, replace) 
graph export $dir/outfiles/figure/credit_ca.jpg, as(jpg) replace


* Combined
twoway (line credit_total income, lpattern(dash))(line credit_fed income,), xtitle("Income ($)") ytitle("Eligible Credit ($)") ysize(3) scale(1.2) legend(off)scheme(s1mono) saving($dir/outfiles/figure/combined.gph, replace) 
graph export $dir/outfiles/figure/credit_sum.jpg, as(jpg) replace
