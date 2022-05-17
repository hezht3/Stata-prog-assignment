* ---------------------------------------------------------------------------------- *
* ------------------------------ 340.600 Assignment 2 ------------------------------ *
* ---------------------------------------------------------------------------------- *


// header code
* log file
capture log close
log using assignment2_zhengtinghe.log, replace

* set up
version 16
clear all
macro drop _all
set more off
set linesize 255


// Question 1
* load dataset
use hw2_pra_hist_2022.dta, clear


////// Question 1. i)
quietly levelsof visit_id, local(levels) 
foreach i of local levels {
	quietly count if !missing(pra) & visit == `i'
	
	if `i' == 1 {              // display table header
		disp "Question 1.i)"
		disp "Visit" _col(20) "Count"
	}
	
	disp `i' _col(20) r(N)      // display visits and count
}


////// Question 1. ii)
bysort px_id hosp_id: egen peak_pra = max(pra)
bysort px_id hosp_id: gen i = [_n]==1
quietly sum peak_pra if i == 1, detail
disp "Question 1.ii): The median (IQR) of peak_pra is " %2.1f r(p50) " (" %2.1f r(p25) "-" %2.1f r(p75) ")."


////// Question 1. iii)
quietly merge m:1 hosp_id using hw2_hosp_2022.dta, keep(match)
bysort region: egen max_pra = max(peak_pra)
bysort region px_id peak_pra: gen j = _n
list region px_id peak_pra if peak_pra == max_pra & j == 1, sepby(region) noobs


// Question 2
capture program drop unilogit
program define unilogit
	syntax varlist [if], outcome(varname)
	
	disp "Significantly associated with " "`outcome'" ":"
	
	foreach v of varlist `varlist' {
		quietly logistic `outcome' `v' `if'
		
		if (1-normal(abs(_b[`v']/_se[`v'])))*2 < 0.05 {
			disp "`v'" _col(10) "(p=" %4.3f (1-normal(abs(_b[`v']/_se[`v'])))*2 ")"
		}
	}
	
end

// Question 3
disp "Question 3: I estimate that it took me three hours to complete this assignment."

log close
