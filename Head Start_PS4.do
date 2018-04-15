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

local socioecon hispanic black male firstborn momed dadhome_0to3

local cognitive ppvt_3 lnbw

**Naive regression
reg comp_score_5to6 head_start `socioecon', r cluster(mom_id)

pause

reg comp_score_5to6 head_start `cognitive', r cluster(mom_id)

pause

reg comp_score_5to6 head_start `socioecon' `cognitive', r cluster(mom_id)

pause

**The effect from our naive regression is attending Head Start results in a 1.9 
**point decrease in test score. This is statistically insignificant at the 90% CI.


**Naive random effects regression
xtset mom_id

xtreg comp_score_5to6 head_start `socioecon', re

pause

xtreg comp_score_5to6 head_start `cognitive', re

pause

xtreg comp_score_5to6 head_start `socioecon' `cognitive', re

pause


**We also cannot conclude that signing up for head start is exogenous. These are 
**decisions at the family level and most likely mean that children who were enrolled 
**were enrolled for various reasons, and were most likley more prone to be falling 
**behind in school compared to the avarage student. 

**As a result, after clustering and running RE to account for serial correlation 
**within families, we find that Head Start still decreases test scores, although 
**the effect is still statistically insignificant at the 90% CI.

**Additionally, Random Effects estimates have smaller standard errors, as expected,
**as RE efficiently reweights the variance of the between and within level variance.
**Assuming within family variation is smaller than between, the RE model will place
**less weight on between variation and more weight on within variation.



********************************************************************************
**                                   P3                                      **
********************************************************************************
//Now include family (mother) fixed effects. Run regressions both with and 
//without pre-Head Start control variables. Which control variables can you 
//include, and which can’t you include? Why? What do the results imply about the 
//effects of Head Start on test scores? If the fixed effects results are different 
//from those in your answer from question (2), explain why.


**Naive FE regression
xtreg comp_score_5to6 head_start `socioecon' i.mom_id, r

pause

**This returns positive effect significant at the 99% CI. Attending Head Start
**increases test scores by 7.6 points on average. 

reg comp_score_5to6 head_start `cognitive' i.mom_id, r

pause

reg comp_score_5to6 head_start `socioecon' `cognitive' i.mom_id, r

pause

**Interestingly, adding individual cognitive scores decreases the significance and
**implies that Head Start decreases test scores. This is statisticall insignificant
**at the 95% CI.

**To whether FE or RE is appropriate, we will run the Hausman test to determine 
**if the estimated coefficients are jointly significantly different from zero. 

xtreg comp_score_5to6 head_start `socioecon' `cognitive', re

estimates store re

xtreg comp_score_5to6 head_start `socioecon' `cognitive' , fe

estimates store fe

hausman fe re

**We confirm that Fixed Effects is the appropriate model to use.
**Running the Hausman test, we reject the null hypothesis that B = 0. This means
**that the because B is not equal to zero, the covariance between the group level
**error term and  x_ij are also not equal to zero. This means that B from RE would 
**be an inconsistent estimator. Therefore, we will use FE.

pause

********************************************************************************
**                                   P4                                      **
********************************************************************************
//State the assumption necessary to interpret the fixed effects estimator as 
//causal. Can you think of some ways to test that assumption? If so, run the tests. 
//What do your tests suggest about the validity of the fixed effects estimator?

**In order to interpret the fixed effects estimator as causal, the covariance between
**the individual xi and the individual error term should equal the covariance of 
**the average individual xi and the individual error term. To test this, I will
**compare the intentionally excluded IQ test score to test whether they are equal.

egen mean_head_start = mean(head_start), by(mom_id)

corr head_start ppvt, covariance

corr mean_head_start ppvt, covariance

**Covariance between Head Start and the IQ test is -.75, and the covariance between
**mean Head Start within families and the IQ test is -.90, this implies that 
**FE may be an unbiased estimator. Still need to determine whether these two 
**covariances are statistically different. Can we conduct some sort of t-test?

**We can conduct Box's M Test to determine whether two covariance matrices are
**equal.

mvtest covariances head_start mean_head_start, by(ppvt)


********************************************************************************
**                                   P5                                       **
********************************************************************************
//Some advocates for early-childhood education suggest that the effects of programs 
//like Head Start are long-lasting. Carry out fixed effects analyses of test scores 
//at later ages. Does Head Start participation have similar effects on test scores 
//in later childhood, or do the effects fade out with age? Make sure you compare 
//results using comparable test-score units. 

local socioecon hispanic black male firstborn momed dadhome_0to3

local cognitive ppvt_3 lnbw

**FE reg on 7-10 test score
reg comp_score_7to10 head_start `socioecon' i.mom_id, r

**It appears that Head Start is less effective at improving later stage test scores.
**It only increases test scores by 4 points compared to 7.6 before. This result
**is not statistically significant. 

pause

**FE reg on 11-14 test score
reg comp_score_11to14 head_start `socioecon' i.mom_id, r

**It appears that Head Start is effective at improving later stage test scores 11-14.
**Although it increases test scores by 5.4 points compared to 7.6 before. This 
**result is statistically significant at the 90% CI. 

pause


********************************************************************************
**                                   P6                                       **
********************************************************************************
//Estimate fixed effects models of the effect of Head Start on longer-term outcomes 
//besides test scores. Many of these outcomes are binary, but you may use linear 
//models. Interpret your results.

local socioecon hispanic black male firstborn momed dadhome_0to3

**FE reg on HS Grad
xtreg hsgrad head_start `socioecon', fe

**FE reg on Self-Reported Health Status
xtreg fphealth head_start `socioecon', fe

**Participating in Head Start led to a 13% increase in the probability of graduating
**High School.

**Participating in Head Start led to an 8.3% decrease in the probability that you
**identified as poor health later in life.

pause 

********************************************************************************
**                                   P7                                       **
********************************************************************************
//Do the effects of Head Start participation on longer-term outcomes vary by 
//race/ethnicity? By sex?

local socioecon hispanic black male firstborn momed dadhome_0to3

**Interaction between HS and race/ gender on HS graduation.
xtreg hsgrad head_start `socioecon' i.head_start##i.black, fe
**not significant.

xtreg hsgrad head_start `socioecon' i.head_start##i.hispanic, fe
**not significant

xtreg hsgrad head_start `socioecon' i.head_start##i.male, fe
**not significant.

pause

**Interaction between HS and race/ gender on health status.
xtreg fphealth head_start `socioecon' i.head_start##i.black, fe
**not significant.

xtreg fphealth head_start `socioecon' i.head_start##i.male, fe
**not signiciant.

pause

********************************************************************************
**                                   P8                                       **
********************************************************************************
//In the past, President Obama has spoken of expanding federal funding for 
//early-childhood education programs. Based on your results, do you think this 
//would be a good idea? Would you feel comfortable using your results to predict 
//the effects of such an expansion? Why or why not?

**See submitted writeup.
