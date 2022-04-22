* ---------------------------------------------------------------------------------- *
* ------------------------------ 340.600 Assignment 1 ------------------------------ *
* ---------------------------------------------------------------------------------- *

* log file
capture log close
log using assignment1_zhengtinghe.log, replace

* set up
clear all
macro drop _all
set more off
set linesize 255

* load dataset
quietly import delimited "assignment1_data_2022.txt", clear 

* ----------------------------------- Question 1 ----------------------------------- *
quietly summarize fake_id
disp "Question 1: There are " r(N) " records in the dataset."

* ----------------------------------- Question 2 ----------------------------------- *
* summary statistics for male
quietly summarize init_age if female == 0 & !(missing(init_age)), detail
local p50_m = r(p50)
local p25_m = r(p25)
local p75_m = r(p75)

* summary statistics for female
quietly summarize init_age if female == 1 & !(missing(init_age)), detail
local p50_f = r(p50)
local p25_f = r(p25)
local p75_f = r(p75)

disp "Question 2: The median [IQR] age is " ///
     %2.0f `p50_m' " [" %2.0f `p25_m' "-" %2.0f `p75_m' "] among males and " ///
	 %2.0f `p50_f' " [" %2.0f `p25_f' "-" %2.0f `p75_f' "] among females."

* ----------------------------------- Question 3 ----------------------------------- *
quietly proportion prev if female == 0   // proportion for male
local prop_m = e(b)[1,2]*100

quietly proportion prev if female == 1   // proportion for female
local prop_f = e(b)[1,2]*100

disp "Question 3: " %2.1f `prop_m' "% among males and " ///
     %2.1f `prop_f' "% among females have history of previous transplant."
	 
* ----------------------------------- Question 4 ----------------------------------- *
gen htn = 0
quietly replace htn = 1 if dx == "4=Hypertensive"

label define htn_label 1 "Yes" 0 "No"  // define label
label values htn htn_label

tab htn

* ----------------------------------- Question 5 ----------------------------------- *
capture program drop table1
program define table1
	
	* table header
	quietly {
	    quietly sum female if female == 0   // male
		local N_m = r(N)

		quietly sum female if female == 1   // female
		local N_f = r(N)
	}
    disp "Question 5"  _col(30) ///
	     "Males (N="  %3.0f `N_m' ")" _col(60) ///
		 "Females (N=" %3.0f `N_f' ")"
		 
	* `Age'
	quietly {
		summarize init_age if female == 0 & !(missing(init_age)), detail   // male
		local median_m = r(p50)
		local p25_m = r(p25)
		local p75_m = r(p75)
		
		summarize init_age if female == 1 & !(missing(init_age)), detail   // female
		local median_f = r(p50)
		local p25_f = r(p25)
		local p75_f = r(p75)
	}
	disp "Age, median (IQR)" _col(30) ///
	     %2.0f `median_m' " (" %2.0f `p25_m' "-" %2.0f `p75_m' ")" _col(60) ///
		 %2.0f `median_f' " (" %2.0f `p25_f' "-" %2.0f `p75_f' ")"
	
	* `Previous transplant'
	quietly {
	    quietly proportion prev if female == 0   // male
		local prop_m = e(b)[1,2]*100

		quietly proportion prev if female == 1   // female
		local prop_f = e(b)[1,2]*100
	}
	disp "Previous transplant, %" _col(30) ///
	     %2.1f `prop_m' "%" _col(60) ///
         %2.1f `prop_f' "%"
		 
    * `Cause of ESRD'
	quietly {
	    quietly sum female if female == 0   // male
		global N_m = r(N)

		quietly sum female if female == 1   // female
		global N_f = r(N)
	}
	disp "Cause of ESRD:"
	quietly tab dx female, matcell(x)
	disp "Glomerular, %" _col(30) ///
	     %2.1f x[1,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[1,2]*100/`N_f' "%"
	disp "Diabetes, %" _col(30) ///
	     %2.1f x[2,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[2,2]*100/`N_f' "%"
	disp "PKD, %" _col(30) ///
	     %2.1f x[3,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[3,2]*100/`N_f' "%"
	disp "Hypertensive, %" _col(30) ///
	     %2.1f x[4,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[4,2]*100/`N_f' "%"
	disp "Renovascular, %" _col(30) ///
	     %2.1f x[5,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[5,2]*100/`N_f' "%"
	disp "Congenital, %" _col(30) ///
	     %2.1f x[6,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[6,2]*100/`N_f' "%"
	disp "Tubulo, %" _col(30) ///
	     %2.1f x[7,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[7,2]*100/`N_f' "%"
	disp "Neoplasm, %" _col(30) ///
	     %2.1f x[8,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[8,2]*100/`N_f' "%"
	disp "Other, %" _col(30) ///
	     %2.1f x[9,1]*100/`N_m' "%" _col(60) ///
		 %2.1f x[9,2]*100/`N_f' "%"
end

table1

* ----------------------------------- Question 6 ----------------------------------- *
quietly logistic received_kt init_age female

capture program drop logitdisp
program define logitdisp
    disp "Question 6"
	disp "Variable" _col(20) "OR" _col(40) "(95% CI)"
    disp "Age" _col(20) %3.2f exp(_b[init_age]) _col(40) ///
	     "(" %3.2f exp(_b[init_age]+invnormal(0.025)*_se[init_age]) "-" ///
		     %3.2f exp(_b[init_age]+invnormal(0.975)*_se[init_age]) ")"
	disp "Female" _col(20) %3.2f exp(_b[female]) _col(40) ///
	     "(" %3.2f exp(_b[female]+invnormal(0.025)*_se[female]) "-" ///
		     %3.2f exp(_b[female]+invnormal(0.975)*_se[female]) ")"
end

logitdisp
	
* ----------------------------------- Question 7 ----------------------------------- *
quietly logistic received_kt init_age female
local N_logit = e(N)

quietly summarize fake_id
local N_total = r(N)

disp "Question 7: This regression included " `N_logit' " observations whereas the study dataset has " `N_total' " observations in total."

* ----------------------------------- Question 8 ----------------------------------- *
disp "Question 8: I estimate that it took me 4 hours to complete this assignment."

log close