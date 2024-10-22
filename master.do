clear all
cap log close
set more off
set matsize 10000

***********************************************************************
* This is the master do-file that produces all the results in the paper
* "TOO MUCH OF A GOOD THING? HOW NARROW TARGETING AND POLICY * INTERACTIONS INFLUENCE RESPONSES TO CALIFORNIA'S EITC" by David Neumark and Zeyu Li
***********************************************************************

* Set file directory

global dir "## YOUR PROGRAM DIRECTORY ##"
global data_dir "## YOUR DATA DIRECTORY ##"

cd $dir // Set current directory
log using $dir/master, replace // Set up the log file


* Clean data

do programs/clean_unemp_rate.do                 // Clean unemployment data 
do programs/clean_state_eitc_pctg.do            // Clean state EITC policy data
do programs/clean_cps.do                        // Clean CPS data (IPUMS)
do programs/gen_data_for_reg_ca                 // Generate final dataset for analysis
do programs/clean_cps_nw.do                     // Clean CPS data for analysis in Table 3

* Table 2

do programs/analysis_table_2.do

* Table 3

do programs/analysis_table_3.do

* Figure 1

do programs/analysis_figure_1.do

* Figure 2

do programs/analysis_figure_2.do

* Appendix Figure A1

do programs/analysis_figure_a1.do

************************************************************************

log close
translate $dir/master.smcl $dir/master.pdf, replace

