* This file plots histograms of actual weekly hours for single low-ed women: 2014 through 2019.

use $data_dir/temp/analysis_6.dta, clear
keep if age <=44 & age >=21
keep if married == 0 & male == 0
tempfile single_women
save `single_women'
use `single_women', clear
keep if lowed & st
su hour_worked hour_worked_unc

** Hour worked (conditional)

forval yyyy = 2014/2019 {
    histogram hour_worked if year == `yyyy', ///
	    width(5) ///
        xtitle("Usual hours worked each week", size(medium)) xlabel(0(20)100) ///
        ytitle("Density", size(medium)) ylabel(0(0.02)0.12) ///
        legend(off) ///
        graphregion(color(white)) ///
        title("`yyyy'", size(medium)) ///
        plotregion(margin(medium) color(white)) ///
        name(graph`yyyy', replace) ///
		scheme(s1mono)
}

graph combine graph2014 graph2015 graph2016 graph2017 graph2018 graph2019, ///
    rows(3) cols(2) ///
	altshrink iscale(1.5) ///
	scheme(s1mono)

graph export $dir/outfiles/figures/fig_hour_distribution_unc.jpg, as(jpg) replace quality(100)


** Hour worked (unconditional)

forval yyyy = 2014/2019 {
    histogram hour_worked_unc if year == `yyyy', ///
	    width(5) ///
        xtitle("Usual hours worked each week", size(medium)) xlabel(0(20)100) ///
        ytitle("Density", size(medium)) ylabel(0(0.02)0.10) ///
        legend(off) ///
        graphregion(color(white)) ///
        title("`yyyy'", size(medium)) ///
        plotregion(margin(medium) color(white)) ///
        name(graph`yyyy', replace) ///
		scheme(s1mono)
		
	graph export $dir/outfiles/figures/Figure_A1_`yyyy'.jpg, as(jpg) replace quality(100)

}

graph combine graph2014 graph2015 graph2016 graph2017 graph2018 graph2019, ///
    rows(3) cols(2) ///
	altshrink iscale(1.5) ///
	scheme(s1mono)

graph export $dir/outfiles/figures/fig_hour_distribution_con.jpg, as(jpg) replace quality(100)
