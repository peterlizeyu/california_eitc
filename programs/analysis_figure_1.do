import excel "$data_dir/raw/eitc_credit_federal_ca.xlsx", sheet("Sheet1") firstrow clear
keep income-credit_total

* Federal

twoway (line credit_fed income,), xtitle("Income ($)") ytitle("Eligible Credit ($)") ysize(3) scale(1.2) scheme(s1mono) saving($dir/outfiles/figures/federal.gph, replace) 
graph export $dir/outfiles/figures/credit_fed.jpg, as(jpg) replace

* CA

twoway (line credit_ca income,lpattern(dash)), xtitle("Income ($)") ytitle("Eligible Credit ($)") ylabel(0(2000)6000) ysize(3) scale(1.2) scheme(s1mono) saving($dir/outfiles/figures/ca.gph, replace) 
graph export $dir/outfiles/figures/credit_ca.jpg, as(jpg) replace


* Combined
twoway (line credit_total income, lpattern(dash))(line credit_fed income,), xtitle("Income ($)") ytitle("Eligible Credit ($)") ysize(3) scale(1.2) legend(off)scheme(s1mono) saving($dir/outfiles/figures/combined.gph, replace) 
graph export $dir/outfiles/figures/credit_sum.jpg, as(jpg) replace
