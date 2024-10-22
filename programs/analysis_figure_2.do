
*****************************************************
* Figure 2: Event studies for CA 
*****************************************************

use $data_dir/temp/analysis_6.dta, clear

su startyear
local startyear = r(mean)

*******Merge with each year's EITC percentages

merge m:1 state using $data_dir/temp/state_eitc_pctg_dt.dta
drop if _merge == 2
drop _merge

preserve
keep if stateabbr != ""
global stateabbr = stateabbr[1] 
restore
keep if age <=44 & age >=21
keep if married == 0 & male == 0 & lowed

* Pinnning down the lag , start and lead year dummies
egen startyear_missing = max(startyear)
replace startyear = startyear_missing
drop startyear_missing

forval i = 1/5{
gen lagyear`i' = (year == startyear - `i')
gen leadyear`i' = (year == startyear + `i')
}

replace startyear = (year == startyear)

*Pinning down the dummies for being in the treatment group in the lag, start and lead years
 forval i = 1/5{
 gen leadkidst`i' = leadyear`i'* st * kid
 gen lagkidst`i' = lagyear`i'*st*kid 
 gen leadkid`i' = leadyear`i'*kid
 gen lagkid`i' = lagyear`i'*kid 
 gen leadst`i' = leadyear`i'* st
 gen lagst`i' = lagyear`i'* st
}
gen startkidst = startyear * st * kid
gen startkid = startyear*kid
gen startst = startyear*st


*Labelling variables
 forval i = 1/5{
 	local lagi = `startyear' - `i'
	local leadi = `startyear' + `i'
    lab var lagkidst`i' "`lagi'"
    lab var leadkidst`i' "`leadi'"
}

lab var startkidst "`startyear'"
 
* Define the outcomes and their respective y-axis limits
local outcomes "emp_yr hour_annual hour_annual_unc per_wage per_wage_unc"

foreach var of local outcomes {

    * Set the y-axis limits based on the outcome variable
    if "`var'" == "emp_yr" {
        local ylim -40(10)40
    }
    else if "`var'" == "hour_annual" | "`var'" == "hour_annual_unc" {
        local ylim -400(100)400
    }
    else if "`var'" == "per_wage" | "`var'" == "per_wage_unc" {
        local ylim -2(0.5)2
    }

    * Perform regression
    xi: reg `var' lagkidst5 lagkidst4 lagkidst3 lagkidst2 startkidst leadkidst1 leadkidst2 leadkidst3 leadkidst4 lagst5 lagst4 lagst3 lagst2 startst leadst1 leadst2 leadst3 leadst4 lagkid5 lagkid4 lagkid3 lagkid2 startkid leadkid1 leadkid2 leadkid3 leadkid4 st_X_kid st lagyear2 lagyear3 lagyear4 lagyear5 startyear leadyear1 leadyear2 leadyear3 leadyear4 kid ib1.edu ib0.num_child_u6 ib1.num_child ib3.marst ib0.black ib0.hispanic age age_sq ur [w=asecwt], cluster(stfips)  

    * Generating matrices of coefficients
    matrix b_`var' = J(1,10,.)
    matrix colnames b_`var' = lagkidst5 lagkidst4 lagkidst3 lagkidst2 lagkidst1 startkidst ///
                           leadkidst1 leadkidst2 leadkidst3 leadkidst4

    forval i = 1/4 {
        local j = 6 - `i'
        matrix b_`var'[1, `i'] = _b[lagkidst`j']
    }
    matrix b_`var'[1, 5] = 0
    matrix b_`var'[1, 6] = _b[startkidst]
    forval i = 1/4 {
        matrix b_`var'[1, `i' + 6] = _b[leadkidst`i']
    }

    * Generating matrices of standard errors
    matrix stderr_`var' = J(1,10,.)
    matrix colnames stderr_`var' = lagkidst5 lagkidst4 lagkidst3 lagkidst2 lagkidst1 startkidst ///
                                  leadkidst1 leadkidst2 leadkidst3 leadkidst4

    forval i = 1/4 {
        local j = 6 - `i'
        matrix stderr_`var'[1, `i'] = _se[lagkidst`j']^2
    }
    matrix stderr_`var'[1, 5] = 0
    matrix stderr_`var'[1, 6] = _se[startkidst]^2
    forval i = 1/4 {
        matrix stderr_`var'[1, `i' + 6] = _se[leadkidst`i']^2
    }
    matrix V_`var' = diag(stderr_`var')

    * Generating matrices of EITC percentages
    matrix eitc = J(1,10,.)
    matrix colnames eitc = lagkidst5 lagkidst4 lagkidst3 lagkidst2 lagkidst1 startkidst ///
                          leadkidst1 leadkidst2 leadkidst3 leadkidst4

    forval i = 1/10 {
        local j = `i' - 6
        local year = `j' + `startyear'
        su pctg`year'
        mat eitc[1, `i'] = r(mean)
    }

    * Post the matrices
    ereturn post b_`var' V_`var'
    ereturn display 

    * Plotting
    coefplot (, recast(connect) ylabel(`ylim', nogrid axis(1)) label("Treatment Effect")) ///
             (matrix(eitc[1,]), noci recast(line) lp(dash) lcolor(gray) axis(2) ylabel(-0.9(0.2)0.9, nogrid axis(2)) label("EITC Percentage")), ///
             noci vertical graphregion(color(white)) xlabel(,angle(45)) yline(0) ysize(2) scale(1.4) aspect(0.3) legend(off) ytitle("Treatment Effect", axis(1)) ytitle("EITC Percentage", axis(2)) nooff saving($dir/outfiles/figures/`var', replace)
			 }

