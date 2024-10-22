//log using log/analysis, replace

*****************************************************
* This do-file run regressions similar to Neumark and 
* Wascher (2011) to examine the effect of California 
* EITC on employment outcomes
* 

* Input: data/temp/analysis.dta

* Created by Peter Li, March 1, 2023
*****************************************************

use $data_dir/temp/analysis_6.dta, clear
keep if age <=44 & age >=21

tempfile origin
save `origin'

keep if married == 0 & male == 0
tempfile single_women
save `single_women'

/*
use `origin', clear
keep if married == 0 & male == 1
tempfile single_men
save `single_men'

use `origin', clear
keep if married == 0 & male == 0 & (black | hispanic)
tempfile single_minority_women
save `single_minority_women'

*/

use `single_women', clear


global deplist `"emp_yr hour_annual hour_annual_unc per_wage per_wage_unc"'
local covlist_kid "ib1.edu ib0.num_child_u6 ib1.num_child ib3.marst ib0.black ib0.hispanic age age_sq ur"
local covlist_lowed "ib4.edu ib0.num_child_u6 ib0.num_child ib3.marst ib0.black ib0.hispanic age age_sq ur"

do $dir/programs/wbri_se.do // Define procedure for WBRE inference

* ca_X_post_X_kid on lowed

eststo clear

preserve

keep if lowed == 1

tab st

foreach var of global deplist {

    /* call the program to calculate WBRI p-values */
    
    local y "`var'"  /* outcome variable */
    local x "st_X_post_X_kid"  /* variable to calculate p-values for */
    
    /* list all control variables here */
    global CTRL "st_X_kid post_X_kid st_X_post st post kid `covlist_kid'"
    
    local c "CTRL"
    
    local cls "stfips" /* CRVE clustering dimension */
    local bcls "stfips" /* bootstrap clustering dimension - set to WILD by default */
                      /* set to the same as CLS for wild cluster bootstrap */
    
    local B = 1000 /* number of bootstraps - e.g. 999 */
	
	
    local w = 2 /* weight either 2 or 6 */
    local null  "R" /* specify either restricted R or unrestricted U */
    local G1 = 1 /* number of treated clusters */
    local YS = 2010 /* year start */
    local YF = 2019 /* year end */
    local rcls = "stfips"  /* RI cluster */
    
    MWWBRI `y' `x' `c' `cls' `bcls'  `B' `w' `null'  `G1' `YS' `YF' `rcls'
    
    disp "the WBRI-t p-value is `r(wbript)'"
    disp "the WBRI-b p-value is `r(wbripb)'"
    
    local wbrit = r(wbript)
    local wbrib = r(wbripb)
    
    eststo: reg `var' st_X_post_X_kid st_X_kid post_X_kid st_X_post st post kid `covlist_kid' [w=asecwt], cluster(stfips)
    su `var' if e(sample) [w=asecwt]
    
    estadd scalar wbript = `wbrit'
    estadd scalar wbripb = `wbrib'
    
    estadd scalar dep_mean = r(mean)
    estadd scalar r = e(r2)
    estadd local edu "Yes"
    estadd local numchild "Yes"
    estadd local numchildu5 "Yes"
    estadd local marst "Yes"
    estadd local black "Yes"
    estadd local hisp "Yes"
    estadd local age "Yes"
    estadd local ur "Yes"
    
    /* Extract the coefficient and standard error for st_X_post_X_kid */
    matrix list e(b)
    matrix list e(V)
    
    local coef = _b[st_X_post_X_kid]
    local se = _se[st_X_post_X_kid]
	
	/* Calculate p value */
	local t = `coef'/`se'
    local p = 2*ttail(e(df_r), abs(`t'))
    
    local coef_str = string(`coef', "%9.3f")
    local se_str = string(`se', "%9.3f")
    local sig = ""
    
    if `p' <= 0.01 {
        local sig = "***"
    }
    else if `p' <= 0.05 {
        local sig = "**"
    }
    else if `p' <= 0.10 {
        local sig = "*"
    }
    
    if `wbrit' <= 0.10 {
        local sig = "`sig'†"
    }
    
    /* Store the coefficient and significance as a local macro */
    local coef_with_sig = "`coef_str'`sig'"
    
    /* Use estadd to add the modified coefficient */
    estadd local b_st_X_post_X_kid "`coef_with_sig'"
}

esttab * using outfiles/ca_X_post_X_kid_on_lowed.csv, b(3) se(3) /*
*/ stats(edu numchild numchildu5 marst black hisp age ur dep_mean wbript r N, label("Education level" "Number of children" "Number of children under 5" "Marrital status" "Black" "Hispanic" "Quadratic age" "Unemployment rate" "Dependent Mean" "WBRI-t p-value" "R^2" "Observations") fmt(0 0 0 0 0 0 0 0 3 3 3 0)) /*
*/ nocons /*
*/ mtitle("Employment"  "Hours (cond.)" "Hours (unc.)" "Earnings (cond.)" "Earnings (unc.)" "Poverty (org.)" "Poverty (IPUMS)" "Near Poverty" "Extreme Poverty")/*
*/ keep(st_X_post_X_kid st_X_kid post_X_kid st_X_post st post kid) order(st_X_post_X_kid st_X_kid post_X_kid st_X_post st post kid) /*
*/ nonotes /*
*/ replace 

restore
