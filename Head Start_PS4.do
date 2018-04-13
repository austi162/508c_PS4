************* WWS508c PS3 *************
*  Spring 2018			              *
*  Author : Chris Austin              *
*  Email: chris.austin@princeton.edu  *
***************************************

/* Credit: Somya Bajaj, Joelle Gamble, Anastasia Korolkova, Luke Strathmann, Chris Austin
Last modified by: Chris Austin
Last modified on: 4/7/18 */

clear all

*Set directory, dta file, etc.
*cd "C:\Users\TerryMoon\Dropbox\Teaching Princeton\wws508c 2018S\ps\ps4"
cd "C:\Users\Chris\Documents\Princeton\WWS Spring 2018\WWS 508c\PS4\508c_PS4"
use wws508c_deming

set more off
set matsize 10000
capture log close
pause on
log using PS4.log, replace

*Download outreg2
*ssc install outreg2
*ssc install mdesc

/*foreach var in sibdiff hispanic black male firstborn lninc_0to3 momed dadhome_0to3 //
ppvt_3 lnbw comp_score_5to6 comp_score_7to10 comp_score_11to14 repeat learndis //
hsgrad somecoll idle fphealth HS2_FE90*/

********************************************************************************
**                                   P1                                       **
********************************************************************************
//Summarize the data. What can you say about the backgrounds of children who 
//participated in Head Start?

su

su if head_start == 1

su if head_start == 0

**Most children who attended Head Start had less dad presense (50.3% vs. 71.7%),
**lower scores on average, greater proportion who repeated a grade (40% vs. 29%)
**less proportion who attended some college (27% vs. 33%).

********************************************************************************
**                                   P2                                      **
********************************************************************************
//As a first step, estimate the association between Head Start participation and
//age 5-6 test scores using OLS or a random effects model (with no family fixed 
//effects). If you use OLS, make sure you estimate your standard errors correctly. 
//Experiment with different sets of control variables. If we assumed Head Start 
//participation is exogenous, what would we conclude about the effects of Head 
//Start on test scores? Be sure to explain the magnitude of the estimated effect. 
//Is it reasonable to assume that Head Start participation is exogenous?

local socioecon hispanic black male firstborn lninc_0to3 momed dadhome_0to3

local cognitive ppvt_3 repeat learndis

**Naive regression
reg comp_score_5to6 head_start `socioecon', r cluster(mom_id)

reg comp_score_5to6 head_start `cognitive', r cluster(mom_id)

reg comp_score_5to6 head_start `socioecon' `cognitive', r cluster(mom_id)

**Naive random effects
xtset mom_id

xtreg comp_score_5to6 head_start `socioecon', re

xtreg comp_score_5to6 head_start `cognitive', re

xtreg comp_score_5to6 head_start `socioecon' `cognitive', re


**Going to Head Start decreases your score by 5 points on average, but the effects
**are not statistically significant. We also cannot conclude that signing up for
**head start is exogenous. These are decisions at the family level and most likely
**mean that children who were enrolled were enrolled for various reasons, and were
**most likley more prone to be falling behind in school compared to the avarage
**student.
**Additionally, Random Effects estimates have smaller standard errors, as expected,
**after RE efficiently reweights the variance of the between and within level variance.
**Assuming within family variation is smaller than betwee, the RE model will place
**less weight on between variation and more weight on within variation.

********************************************************************************
**                                   P3                                      **
********************************************************************************
//Now include family (mother) fixed effects. Run regressions both with and 
//without pre-Head Start control variables. Which control variables can you 
//include, and which can’t you include? Why? What do the results imply about the 
//effects of Head Start on test scores? If the fixed effects results are different 
//from those in your answer from question (2), explain why.

**Naive regression
reg comp_score_5to6 head_start `socioecon' i.mom_id

reg comp_score_5to6 head_start `cognitive' i.mom_id

reg comp_score_5to6 head_start `socioecon' `cognitive' i.mom_id

**With fixed effects, the new interpretation is that participating in Head Start
**decreases your 5-6 age test score by about 11.5 points compared to 5.5 before.
**Standard errors are correct because used brute force rather than finesse method. 

********************************************************************************
**                                   P4                                      **
********************************************************************************
//State the assumption necessary to interpret the fixed effects estimator as 
//causal. Can you think of some ways to test that assumption? If so, run the tests. 
//What do your tests suggest about the validity of the fixed effects estimator?

**In order to interpret the fixed effects estimator as appropriate, we need to assume 
**that the group-level error component is correlated with Head Start and test scores.

**In order to interpret the fixed effects estimator as causal, the covariance between
**the individual xi and the individual error term should equal the covariance of 
**the average individual xi and the individual error term.

**That there might be some unobserved family characteristics that are correlated
**with being in the Head Start program (such as being poorer).
**Because we believe that assignment of Head Start is conditioned on falling
**into a lower socioeconomic status, then family-level covariates are important,
**making fixed effects estimation appropriate.



**We can test this by seeing if certain socioeconomic characteristics are more 
**strongly correlated among siblings versus nonsiblings. 

**The test confirm that fixed effects estimator is the appropriate estimator.

********************************************************************************
**                                   P5                                       **
********************************************************************************
//Some advocates for early-childhood education suggest that the effects of programs 
//like Head Start are long-lasting. Carry out fixed effects analyses of test scores 
//at later ages. Does Head Start participation have similar effects on test scores 
//in later childhood, or do the effects fade out with age? Make sure you compare 
//results using comparable test-score units. 

**Naive regression
reg comp_score_7to10 head_start `socioecon' i.mom_id

reg comp_score_7to10 head_start `cognitive' i.mom_id

reg comp_score_7to10 head_start `socioecon' `cognitive' i.mom_id

**Naive regression
reg comp_score_11to14 head_start `socioecon' i.mom_id

reg comp_score_11to14 head_start `cognitive' i.mom_id

reg comp_score_11to14 head_start `socioecon' `cognitive' i.mom_id


********************************************************************************
**                                   P6                                       **
********************************************************************************
//Estimate fixed effects models of the effect of Head Start on longer-term outcomes 
//besides test scores. Many of these outcomes are binary, but you may use linear 
//models. Interpret your results.

********************************************************************************
**                                   P7                                       **
********************************************************************************
//Do the effects of Head Start participation on longer-term outcomes vary by 
//race/ethnicity? By sex?

********************************************************************************
**                                   P8                                       **
********************************************************************************
//In the past, President Obama has spoken of expanding federal funding for 
//early-childhood education programs. Based on your results, do you think this 
//would be a good idea? Would you feel comfortable using your results to predict 
//the effects of such an expansion? Why or why not?

**Talk about internal and specifically external validity.
