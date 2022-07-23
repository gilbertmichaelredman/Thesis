clear
capture log close
set more off

cd "Y:\My Drive\Thesis\Data\Stata"
ssc install eventdd
ssc install matsort
ssc install outreg2
ssc install reghdfe
ssc install estout
net install countyfips, from(https://raw.github.com/cbgoodman/countyfips/master/) replace
ssc install coefplot

/*
use CombinedMaster.dta
drop if county == 0
drop if county>996
drop if state == 02
drop if state == 46 & county ==113
drop if state == 51 & county ==515
drop if age == 998
drop if age == 999
drop if age>=99

*/use cleaned.dta

set logtype text
log using logRedmanAccident.txt, replace
*/

/*

/* Generate time variable
*/ 
gen year_month = mofd(mdy(month, 1, year))
format year_month %tm

/*Generate panel variable*/
sort state county
recast int state
gen fips = (1000 * state) + county
egen panelid = group(fips)

/*gen age bins approx. by quartile*/
tab age, gen(ages)
gen age_017 = 0
gen age_1521 = 0
gen age_1835 = 0
gen age_035 = 0
gen age_3653 = 0
gen age_54118 = 0
replace age_017 = 1 if age<18
replace age_1521 = 1 if age>14 & age<22
replace age_1835 = 1 if age>17 &age<36
replace age_035 = 1 if age<36
replace age_3653 = 1 if age>35 &age<54
replace age_54118 = 1 if age>53

/*gen day of week counts*/
gen sunday = 0
gen monday = 0
gen tuesday = 0
gen wednesday = 0
gen thursday = 0
gen friday = 0
gen saturday = 0
gen weekend = 0
replace sunday = 1 if day_week == 1
replace monday = 1 if day_week == 2
replace tuesday = 1 if day_week == 3
replace wednesday = 1 if day_week == 4
replace thursday = 1 if day_week == 5
replace friday = 1 if day_week == 6
replace saturday = 1 if day_week == 7
replace weekend = 1 if day_week == 1 | day_week ==6 | day_week==7

//Pre-agg graphs
hist age, w(1)




collapse(first)fatals drunk_dr ages* age_* *day weekend fips year_month month state county panelid, by(st_case year)
/*Collapse data into only key variable*/
collapse(sum) fatals drunk_dr  age* *day weekend (first) fips, by(panelid year_month year month state county) 
 


/*Identify panel*/
xtset panelid year_month

/*Fill gaps in panel created by months with 0 traffic fatalites*/
tsfill, full


/*generate state, county, month, year values for 0 fatality months*/
egen state_av = mean(state), by(panelid)
replace state = state_av if state == .
egen county_av = mean(county), by(panelid)
replace county = county_av if county == .
egen fips_av = mean(fips), by(panelid)
replace fips = fips_av if fips == .
egen year_av = mean(year), by(year_month)
replace year = year_av if year == .
egen month_av = mean(month), by(year_month)
replace month = month_av if month == .
replace fatals = 0 if fatals == .
drop state_av county_av fips_av year_av month_av
replace drunk_dr = 0 if drunk_dr ==.
replace age_017 = 0 if age_017 ==.
replace age_1835 = 0 if age_1835 ==.
replace age_3653 = 0 if age_3653 ==.
replace age_54118 = 0 if age_54118 ==.

foreach var of varlist ages*{
	replace `var' = 0 if missing(`var')

}

foreach var of varlist *day weekend{
	replace `var' = 0 if missing(`var')

}

xtset panelid year_month

/*Dropping obs more recently than 2014. Will remove if analysis expands to
more recent years*/
merge m:m year state county using "Y:\My Drive\Thesis\Data\Stata\PopulationEstimates.dta"
drop _merge
merge m:1 year fips using "Y:\My Drive\Thesis\Data\Household Income\MedHHInc.dta"


/*uber value if uber exists in that county at a given time
insample if used in Brazil/Kirk*/
gen uber = 0
gen bk = 0
gen insamp = 0
gen years_since_treatment = 0
*Bronx
replace bk = 1 if state ==36 & county == 005
replace uber = 1 if state==36 & year==2011 & county ==005 & month>5
replace uber = 1 if state==36 & year>2011 & county ==005 
replace years_since_treatment = year - 2011 if state==36 & county==005

*Kings
replace bk = 1 if state ==36 & county == 047
replace uber = 1 if state==36 & year==2011 & county ==047 & month>5
replace uber = 1 if state==36 & year>2011 & county ==047 
replace years_since_treatment = year - 2011 if state==36 & county==047
*New York
replace bk = 1 if state ==36 & county == 061
replace uber = 1 if state==36 & year==2011 & county ==061 & month>5
replace uber = 1 if state==36 & year>2011 & county ==061 
replace years_since_treatment = year - 2011 if state==36 & county==061
*Queens
replace bk = 1 if state ==36 & county == 081
replace uber = 1 if state==36 & year==2011 & county ==081 & month>5
replace uber = 1 if state==36 & year>2011 & county ==081 
replace years_since_treatment = year - 2011 if state==36 & county==081
*Richmond
replace bk = 1 if state ==36 & county == 085
replace uber = 1 if state==36 & year==2011 & county ==085 & month>5
replace uber = 1 if state==36 & year>2011 & county ==085 
replace years_since_treatment = year - 2011 if state==36 & county==085
*Los Angeles
replace bk = 1 if state ==06 & county == 037
replace uber = 1 if state==06 & year==2012 & county ==037 & month>3
replace uber = 1 if state==06 & year>2012 & county ==037 
replace years_since_treatment = year - 2012 if state==06 & county==085
*Chicago
replace bk = 1 if state ==17 & county == 031
replace uber = 1 if state==17 & year==2011 & county ==031 & month>9
replace uber = 1 if state==17 & year>2011 & county ==031 
replace years_since_treatment = year - 2011 if state==17 & county==031
*Dallas
replace bk = 1 if state ==48 & county == 113
replace uber = 1 if state==48 & year==2012 & county ==113 & month>9
replace uber = 1 if state==48 & year>2012 & county ==113 
replace years_since_treatment = year - 2012 if state==48 & county==113
*Philly
replace bk = 1 if state ==42 & county == 101
replace uber = 1 if state==42 & year==2012 & county ==101 & month>6
replace uber = 1 if state==42 & year>2012 & county ==101 
replace years_since_treatment = year - 2012 if state==42 & county==101
*Harris
replace bk = 1 if state ==48 & county == 201
replace uber = 1 if state==48 & year==2014 & county ==201 & month>2
replace uber = 1 if state==48 & year>2014 & county ==201 
replace years_since_treatment = year - 2014 if state==48 & county==201
*DC
replace bk = 1 if state ==11 & county == 001
replace uber = 1 if state==11 & year>2011 & county ==001 
replace years_since_treatment = year - 2011 if state==11 & county==001

*Miami
replace bk = 1 if state ==12 & county == 086
replace uber = 1 if state==12 & year==2014 & county ==086 & month>6
replace uber = 1 if state==12 & year>2014 & county ==086
replace years_since_treatment = year - 2014 if state==12 & county==086
*Atlanta
replace bk = 1 if state ==13 & county == 121
replace uber = 1 if state==13 & year==2012 & county ==121 & month>8
replace uber = 1 if state==13 & year>2012 & county ==121 
replace years_since_treatment = year - 2012 if state==13 & county==121
*Boston
replace bk = 1 if state ==25 & county == 025
replace uber = 1 if state==25 & year==2011 & county ==025 & month>10
replace uber = 1 if state==25 & year>2011 & county ==025 
replace years_since_treatment = year - 2011 if state==025 & county==025
*SF
replace bk = 1 if state ==06 & county == 075
replace uber = 1 if state==06 & year==2010 & county ==075 & month>5
replace uber = 1 if state==06 & year>2010 & county ==075 
replace years_since_treatment = year - 2010 if state==06 & county==075
*Detroit
replace bk = 1 if state ==26 & county == 163
replace uber = 1 if state==26 & year==2013 & county ==163 & month>3
replace uber = 1 if state==26 & year>2013 & county ==163 
replace years_since_treatment = year - 2013 if state==26 & county==163
*Riverside
replace bk = 1 if state ==06 & county == 065
replace uber = 1 if state==06 & year==2014 & county ==065 & month>5
replace uber = 1 if state==06 & year>2014 & county ==065 
replace years_since_treatment = year - 2014 if state==06 & county==065
*Phoenix
replace bk = 1 if state ==04 & county == 013
replace uber = 1 if state==04 & year==2012 & county ==013 & month>11
replace uber = 1 if state==04 & year>2012 & county ==013 
replace years_since_treatment = year - 2012 if state==04 & county==013
*Seattle
replace bk = 1 if state ==53 & county == 033
replace uber = 1 if state==53 & year==2011 & county ==033 & month>8
replace uber = 1 if state==53 & year>2011 & county ==033
replace years_since_treatment = year - 2011 if state==53 & county==033
*Minny
replace bk = 1 if state ==27 & county == 053
replace uber = 1 if state==27 & year==2012 & county ==053 & month>10
replace uber = 1 if state==27 & year>2012 & county ==053
replace years_since_treatment = year - 2012 if state==27 & county==053
*San Diego
replace bk = 1 if state ==06 & county == 073
replace uber = 1 if state==06 & year==2012 & county ==073 & month>6
replace uber = 1 if state==06 & year>2012 & county ==073 
replace years_since_treatment = year - 2012 if state==06 & county==073
*St. Louis
replace bk = 1 if state ==29 & county == 510
replace uber = 1 if state==29 & year==2014 & county ==510 & month>10
replace uber = 1 if state==29 & year>2014 & county ==510 
replace years_since_treatment = year - 2014 if state==29 & county==510
*Tampa
replace bk = 1 if state ==12 & county == 057
replace uber = 1 if state==12 & year==2014 & county ==057 & month>3
replace uber = 1 if state==12 & year>2014 & county ==057
replace years_since_treatment = year - 2014 if state==12 & county==057
*Baltimore
replace bk = 1 if state == 24 & county == 005
replace bk = 1 if state == 24 & county == 510
replace uber = 1 if state==24 & year==2013 & county ==005 & month>2
replace uber = 1 if state==24 & year==2013 & county ==510 & month>2
replace uber = 1 if state==24 & year>2013 & county ==005
replace uber = 1 if state==24 & year>2013 & county ==510
replace years_since_treatment = year - 2013 if state==24 & county==005
replace years_since_treatment = year - 2013 if state==24 & county==510
*Denver
replace bk = 1 if state ==08 & county == 031
replace uber = 1 if state==08 & year==2012 & county ==031 & month>9
replace uber = 1 if state==08 & year>2012 & county ==031
replace years_since_treatment = year - 2012 if state==08 & county==031
*Pittsburgh
replace bk = 1 if state ==42 & county == 003
replace uber = 1 if state==42 & year==2014 & county ==003 & month>3
replace uber = 1 if state==42 & year>2014 & county ==003
replace years_since_treatment = year - 2014 if state==42 & county==003

*Portland
replace insamp = 1 if state == 41 & county == 051
replace uber = 1 if state==41 & year==2015 & county ==051 & month>4
replace uber = 1 if state==41 & year>2015 & county ==051
replace years_since_treatment = year - 2015 if state==41 & county==051

*Charlotte
replace bk = 1 if state ==37 & county == 119
replace uber = 1 if state==37 & year==2013 & county ==119 & month>9
replace uber = 1 if state==37 & year>2013 & county ==119
replace years_since_treatment = year - 2013 if state==37 & county==119
*Sacramento
replace bk = 1 if state ==06 & county == 067
replace uber = 1 if state==06 & year==2013 & county ==067 & month>2
replace uber = 1 if state==06 & year>2013 & county ==067
replace years_since_treatment = year - 2013 if state==06 & county==067
*San Antonio
replace bk = 1 if state ==48 & county == 029
replace uber = 1 if state==48 & year==2014 & county ==029 & month>3
replace uber = 1 if state==48 & year>2014 & county ==029
replace years_since_treatment = year - 2014 if state==48 & county==029
*Orlando
replace bk = 1 if state ==12 & county == 095
replace uber = 1 if state==12 & year==2014 & county ==095 & month>6
replace uber = 1 if state==12 & year>2014 & county ==095
replace years_since_treatment = year - 2014 if state==12 & county==095
*Cincinnati
replace bk = 1 if state ==39 & county == 061
replace uber = 1 if state==39 & year==2014 & county ==061 & month>3
replace uber = 1 if state==39 & year>2014 & county ==061
replace years_since_treatment = year - 2014 if state==39 & county==061
*Cleveland
replace bk = 1 if state ==39 & county == 035
replace uber = 1 if state==39 & year==2014 & county ==035 & month>4
replace uber = 1 if state==39 & year>2014 & county ==035
replace years_since_treatment = year - 2014 if state==39 & county==035
*Kansas City
replace bk = 1 if state ==29 & county == 095
replace uber = 1 if state==29 & year==2014 & county ==095 & month>5
replace uber = 1 if state==29 & year>2014 & county ==095
replace years_since_treatment = year - 2014 if state==29 & county==095
*Vegas
replace insamp = 1 if state == 32 & county == 003
replace uber = 1 if state==32 & year==2014 & county ==003 & month>10
replace uber = 1 if state==32 & year>2014 & county ==003
replace years_since_treatment = year - 2014 if state==32 & county==003

*Columbus
replace bk = 1 if state ==39 & county == 049
replace uber = 1 if state==39 & year>2013 & county ==049 
replace years_since_treatment = year - 2013 if state==39 & county==049
*Indianapolis
replace bk = 1 if state ==18 & county == 097
replace uber = 1 if state==18 & year==2014 & county ==097 & month>6
replace uber = 1 if state==18 & year>2014 & county ==097 
replace years_since_treatment = year - 2014 if state==18 & county==097
*Silicon Valley
replace insamp = 1 if state == 06 & county == 085
replace uber = 1 if state==06 & year==2013 & county ==085 & month>7
replace uber = 1 if state==06 & year>2013 & county ==085
replace years_since_treatment = year - 2013 if state==06 & county==085

*Austin
replace bk = 1 if state ==48 & county == 453
replace uber = 1 if state==48 & year==2014 & county ==453 & month>6
replace uber = 1 if state==48 & year>2014 & county ==453
replace years_since_treatment = year - 2014 if state==48 & county==453
*Virginia Beach
replace bk = 1 if state ==51 & county == 810
replace uber = 1 if state==51 & year==2014 & county ==810 & month>5
replace uber = 1 if state==51 & year>2014 & county ==810
replace years_since_treatment = year - 2014 if state==51 & county==810
*Nashville
replace bk = 1 if state ==47 & county == 037
replace uber = 1 if state==47 & year>2013 & county ==037 
replace years_since_treatment = year - 2013 if state==47 & county==037
*Providence
replace bk = 1 if state ==44 & county == 007
replace uber = 1 if state==44 & year==2013 & county ==007 & month>7
replace uber = 1 if state==44 & year>2013 & county ==007
replace years_since_treatment = year - 2013 if state==44 & county==007
*Milwaukee
replace bk = 1 if state ==55 & county == 079
replace uber = 1 if state==55 & year==2014 & county ==079 & month>4
replace uber = 1 if state==55 & year>2014 & county ==079 
replace years_since_treatment = year - 2014 if state==55 & county==079
*Jacksonville
replace bk = 1 if state ==12 & county == 031
replace uber = 1 if state==12 & year==2014 & county ==031 & month>1
replace uber = 1 if state==12 & year>2014 & county ==031 
replace years_since_treatment = year - 2014 if state==12 & county==031
*Memphis
replace bk = 1 if state ==47 & county == 157
replace uber = 1 if state==47 & year==2014 & county ==157 & month>4
replace uber = 1 if state==47 & year>2014 & county ==157
replace years_since_treatment = year - 2014 if state==47 & county==157
*OKC
replace bk = 1 if state ==40 & county == 109
replace uber = 1 if state==40 & year==2013 & county ==109 & month>10
replace uber = 1 if state==40 & year>2013 & county ==109
replace years_since_treatment = year - 2013 if state==40 & county==109
*Louisville
replace bk = 1 if state ==21 & county == 111
replace uber = 1 if state==21 & year==2014 & county ==111 & month>4
replace uber = 1 if state==21 & year>2014 & county ==111
replace years_since_treatment = year - 2014 if state==21 & county==111
*Hartford
replace bk = 1 if state ==09 & county == 003
replace uber = 1 if state==09 & year==2014 & county ==003 & month>4
replace uber = 1 if state==09 & year>2014 & county ==003
replace years_since_treatment = year - 2014 if state==09 & county==003
*Richmond
replace bk = 1 if state ==51 & county == 159
replace bk = 1 if state ==51 & county == 760
replace uber = 1 if state==51 & year==2014 & county ==159 & month>8
replace uber = 1 if state==51 & year>2014 & county ==159
replace uber = 1 if state==51 & year==2014 & county ==760 & month>8
replace uber = 1 if state==51 & year>2014 & county ==760
replace years_since_treatment = year - 2014 if state==51 & county==159
replace years_since_treatment = year - 2014 if state==51 & county==760
*New Orleans
replace insamp = 1 if state == 22 & county == 071
replace uber = 1 if state==22 & year==2015 & county ==071 & month>4
replace uber = 1 if state==22 & year>2015 & county ==071
replace years_since_treatment = year - 2015 if state==22 & county==071
*Raleigh
replace bk = 1 if state ==37 & county == 183
replace uber = 1 if state==37 & year==2014 & county ==183 & month>6
replace uber = 1 if state==37 & year>2014 & county ==183
replace years_since_treatment = year - 2014 if state==37 & county==183
*Buffalo
replace insamp = 1 if state == 36 & county == 029
replace uber = 1 if state==36 & year==2017 & county ==029 & month>6
replace uber = 1 if state==36 & year>2017 & county ==029
replace years_since_treatment = year - 2017 if state==36 & county==029
*Birmingham
replace insamp = 1 if state == 01 & county == 073
replace uber = 1 if state==01 & year==2016 & county ==073 & month>1
replace uber = 1 if state==01 & year>2016 & county ==073
replace years_since_treatment = year - 2016 if state==01 & county==073
*SLC
replace bk = 1 if state ==49 & county == 035
replace uber = 1 if state==49 & year==2014 & county ==035 & month>5
replace uber = 1 if state==49 & year>2014 & county ==035
replace years_since_treatment = year - 2014 if state==49 & county==035
*Rochester
replace insamp = 1 if state == 36 & county == 055
replace uber = 1 if state==36 & year==2017 & county ==055 & month>6
replace uber = 1 if state==36 & year>2017 & county ==055
replace years_since_treatment = year - 2017 if state==36 & county==055
*Grand Rapids
replace bk = 1 if state ==26 & county == 081
replace uber = 1 if state==26 & year==2014 & county ==081 & month>7
replace uber = 1 if state==26 & year>2014 & county ==081
replace years_since_treatment = year - 2014 if state==26 & county==081
*Tucson
replace bk = 1 if state ==04 & county == 019
replace uber = 1 if state==04 & year==2013 & county ==019 & month>10
replace uber = 1 if state==04 & year>2013 & county ==019
replace years_since_treatment = year - 2013 if state==04 & county==019
*Honolulu
replace bk = 1 if state ==15 & county == 003
replace uber = 1 if state==15 & year==2013 & county ==003 & month>8
replace uber = 1 if state==15 & year>2013 & county ==003
replace years_since_treatment = year - 2013 if state==15 & county==003
*Tulsa
replace bk = 1 if state ==40 & county == 143
replace uber = 1 if state==40 & year==2014 & county ==143 & month>3
replace uber = 1 if state==40 & year>2014 & county ==143
replace years_since_treatment = year - 2014 if state==40 & county==143
*Fresno
replace bk = 1 if state ==06 & county == 019
replace uber = 1 if state==06 & year==2014 & county ==019 & month>2
replace uber = 1 if state==06 & year>2014 & county ==019
replace years_since_treatment = year - 2014 if state==06 & county==019
*Bridgeport
replace bk = 1 if state ==09 & county == 001
replace uber = 1 if state==09 & year==2014 & county ==001 & month>4
replace uber = 1 if state==09 & year>2014 & county ==001
replace years_since_treatment = year - 2014 if state==09 & county==001
*Worcester
replace bk = 1 if state ==25 & county == 027
replace uber = 1 if state==25 & year==2014 & county ==027 & month>10
replace uber = 1 if state==25 & year>2014 & county ==027
replace years_since_treatment = year - 2014 if state==25 & county==027
*Albuquerque
replace bk = 1 if state ==35 & county == 001
replace uber = 1 if state==35 & year==2014 & county ==001 & month>4
replace uber = 1 if state==35 & year>2014 & county ==001
replace years_since_treatment = year - 2014 if state==35 & county==001
*Albany
replace insamp = 1 if state == 36 & county == 001
replace uber = 1 if state==36 & year==2017 & county ==001 & month>6
replace uber = 1 if state==36 & year>2017 & county ==001
replace years_since_treatment = year - 2017 if state==36 & county==001
*Omaha
replace bk = 1 if state ==31 & county == 055
replace uber = 1 if state==31 & year==2014 & county ==055 & month>5
replace uber = 1 if state==31 & year>2014 & county ==055
replace years_since_treatment = year - 2014 if state==31 & county==055
*New Haven
replace bk = 1 if state ==09 & county == 009
replace uber = 1 if state==09 & year==2014 & county ==009 & month>4
replace uber = 1 if state==09 & year>2014 & county ==009
replace years_since_treatment = year - 2014 if state==09 & county==009
*Bakersfield
replace bk = 1 if state ==06 & county == 029
replace uber = 1 if state==06 & year==2014 & county ==029 & month>6
replace uber = 1 if state==06 & year>2014 & county ==029
replace years_since_treatment = year - 2014 if state==06 & county==029
*Knoxville
replace bk = 1 if state ==47 & county == 093
replace uber = 1 if state==47 & year==2014 & county ==093 & month>8
replace uber = 1 if state==47 & year>2014 & county ==093
replace years_since_treatment = year - 2014 if state==47 & county==093
*Greenville
replace bk = 1 if state ==45 & county == 045
replace uber = 1 if state==45 & year==2014 & county ==045 & month>7
replace uber = 1 if state==45 & year>2014 & county ==045
replace years_since_treatment = year - 2014 if state==45 & county==045
*Oxnard
replace bk = 1 if state ==06 & county == 111
replace uber = 1 if state==06 & year==2014 & county ==111 & month>7
replace uber = 1 if state==06 & year>2014 & county ==111
replace years_since_treatment = year - 2014 if state==06 & county==111

*El Paso
replace bk = 1 if state ==48 & county == 141
replace uber = 1 if state==48 & year==2014 & county ==141 & month>6
replace uber = 1 if state==48 & year>2014 & county ==141
replace years_since_treatment = year - 2014 if state==48 & county==141
*Baton Rouge
replace bk = 1 if state ==22 & county == 033
replace uber = 1 if state==22 & year==2014 & county ==033 & month>7
replace uber = 1 if state==22 & year>2014 & county ==033
replace years_since_treatment = year - 2014 if state==22 & county==033
*Dayton
replace bk = 1 if state ==39 & county == 113
replace uber = 1 if state==39 & year==2014 & county ==113 & month>8
replace uber = 1 if state==39 & year>2014 & county ==113
replace years_since_treatment = year - 2014 if state==39 & county==113
*Rio Grande Valley
replace insamp = 1 if state == 48 & county == 215
replace uber = 1 if state==48 & year==2017 & county ==215 & month>6
replace uber = 1 if state==48 & year>2017 & county ==215
replace years_since_treatment = year - 2017 if state==48 & county==215
*Columbia
replace bk = 1 if state ==45 & county == 079
replace uber = 1 if state==45 & year==2014 & county ==079 & month>7
replace uber = 1 if state==45 & year>2014 & county ==079
replace years_since_treatment = year - 2014 if state==45 & county==079
*Greensboro
replace bk = 1 if state ==37 & county == 081
replace uber = 1 if state==37 & year==2014 & county ==081 & month>6
replace uber = 1 if state==37 & year>2014 & county ==081
replace years_since_treatment = year - 2014 if state==37 & county==081
*Sarasota
replace bk = 1 if state ==12 & county == 115
replace uber = 1 if state==12 & year>2014 & county ==115
replace years_since_treatment = year - 2014 if state==12 & county==115
*Akron
replace bk = 1 if state ==39 & county == 153
replace uber = 1 if state==39 & year==2014 & county ==153 & month>8
replace uber = 1 if state==39 & year>2014 & county ==153
replace years_since_treatment = year - 2014 if state==39 & county==153
*Little Rock
replace bk = 1 if state ==05 & county == 119
replace uber = 1 if state==05 & year==2014 & county ==119 & month>11
replace uber = 1 if state==05 & year>2014 & county ==119
replace years_since_treatment = year - 2014 if state==05 & county==119
*Stockton
replace bk = 1 if state ==06 & county == 077
replace uber = 1 if state==06 & year==2014 & county ==077 & month>5
replace uber = 1 if state==06 & year>2014 & county ==077
replace years_since_treatment = year - 2014 if state==06 & county==077
*Charleston
replace bk = 1 if state ==45 & county == 019
replace uber = 1 if state==45 & year==2014 & county ==019 & month>7
replace uber = 1 if state==45 & year>2014 & county ==019
replace years_since_treatment = year - 2014 if state==45 & county==019
*Syracuse
replace insamp = 1 if state == 36 & county == 067
replace uber = 1 if state==36 & year==2017 & county ==067 & month>6
replace uber = 1 if state==36 & year>2017 & county ==067
replace years_since_treatment = year - 2017 if state==36 & county==067
*Colorado Springs
replace bk = 1 if state ==08 & county == 041
replace uber = 1 if state==08 & year==2014 & county ==041 & month>5
replace uber = 1 if state==08 & year>2014 & county ==041
replace years_since_treatment = year - 2014 if state==08 & county==041
*Winston-Salem
replace bk = 1 if state ==37 & county == 067
replace uber = 1 if state==37 & year==2014 & county ==067 & month>6
replace uber = 1 if state==37 & year>2014 & county ==067
replace years_since_treatment = year - 2014 if state==37 & county==067
*Wichita
replace bk = 1 if state ==20 & county == 173
replace uber = 1 if state==20 & year==2014 & county ==173 & month>8
replace uber = 1 if state==20 & year>2014 & county ==173
replace years_since_treatment = year - 2014 if state==20 & county==173
*Springfield, MA
replace insamp = 1 if state == 25 & county == 013
replace uber = 1 if state==25 & year==2015 & county ==013 & month>4
replace uber = 1 if state==25 & year>2015 & county ==013
replace years_since_treatment = year - 2015 if state==25 & county==013
*Fort Myers
replace bk = 1 if state ==12 & county == 071
replace uber = 1 if state==12 & year>2014 & county ==071
replace years_since_treatment = year - 2014 if state==12 & county==071
*Boise
replace insamp = 1 if state == 16 & county == 001
replace uber = 1 if state==16 & year==2014 & county ==001 & month>10
replace uber = 1 if state==16 & year>2014 & county ==001
replace years_since_treatment = year - 2014 if state==16 & county==001
*Toledo
replace bk = 1 if state ==39 & county == 095
replace uber = 1 if state==39 & year==2014 & county ==095 & month>6
replace uber = 1 if state==39 & year>2014 & county ==095
replace years_since_treatment = year - 2014 if state==39 & county==095
*Madison
replace bk = 1 if state ==55 & county == 025
replace uber = 1 if state==55 & year==2014 & county ==025 & month>3
replace uber = 1 if state==55 & year>2014 & county ==025
replace years_since_treatment = year - 2014 if state==55 & county==025
*Lakeland
replace bk = 1 if state ==12 & county == 105
replace uber = 1 if state==12 & year>2014 & county ==105
replace years_since_treatment = year - 2014 if state==12 & county==105
*Ogden
replace insamp = 1 if state == 49 & county == 057
replace uber = 1 if state==49 & year>2015 & county ==057
replace years_since_treatment = year - 2015 if state==49 & county==057
*Daytona
replace bk = 1 if state ==12 & county == 127
replace uber = 1 if state==12 & year>2014 & county ==127
replace years_since_treatment = year - 2014 if state==12 & county==127
*Des Moines
replace insamp = 1 if state == 19 & county == 153
replace uber = 1 if state==19 & year==2015 & county ==153 & month>3
replace uber = 1 if state==19 & year>2015 & county ==153
replace years_since_treatment = year - 2015 if state==19 & county==153
*Jackson
replace bk = 1 if state ==28 & county == 049
replace uber = 1 if state==28 & year>2014 & county ==049
replace years_since_treatment = year - 2014 if state==28 & county==049	
*Augusta
replace insamp = 1 if state == 13 & county == 245
replace uber = 1 if state==13 & year==2015 & county ==245 & month>4
replace uber = 1 if state==13 & year>2015 & county ==245
replace years_since_treatment = year - 2015 if state==13 & county==245
*Youngstown
replace insamp = 1 if state == 39 & county == 099
replace uber = 1 if state==39 & year==2016 & county ==099 & month>6
replace uber = 1 if state==39 & year>2016 & county ==099
replace years_since_treatment = year - 2016 if state==39 & county==099
*Scranton
replace insamp = 1 if state == 42 & county == 069
replace uber = 1 if state==42 & year==2015 & county ==069 & month>2
replace uber = 1 if state==42 & year>2015 & county ==069
replace years_since_treatment = year - 2015 if state==42 & county==069
*Harrisburg
replace insamp = 1 if state == 42 & county == 043
replace uber = 1 if state==42 & year==2015 & county ==043 & month>1
replace uber = 1 if state==42 & year>2015 & county ==043
replace years_since_treatment = year - 2015 if state==42 & county==043
*Melbourne
replace bk = 1 if state ==12 & county == 009
replace uber = 1 if state==12 & year>2014 & county ==009
replace years_since_treatment = year - 2014 if state==12 & county==009
*Provo
replace bk = 1 if state ==37 & county == 063
replace uber = 1 if state==49 & year==2015 & county ==049 & month>9
replace uber = 1 if state==49 & year>2015 & county ==049
replace years_since_treatment = year - 2015 if state==49 & county==049
*Chattanooga
replace bk = 1 if state ==47 & county == 065
replace uber = 1 if state==47 & year==2014 & county ==065 & month>11
replace uber = 1 if state==47 & year>2014 & county ==065
replace years_since_treatment = year - 2014 if state==47 & county==065
*Durham
replace bk = 1 if state ==37 & county == 063
replace uber = 1 if state==37 & year==2014 & county ==063 & month>6
replace uber = 1 if state==37 & year>2014 & county ==063
replace years_since_treatment = year - 2014 if state==37 & county==063

replace insamp = 1 if bk==1

/*drop values not insample for preliminary analysis*/
drop if insamp == 0
drop panelid
egen panelid = group(state county)


gen lags = 0
gen leads = 0
replace lags = years_since_treatment if years_since_treatment > 0
replace leads = years_since_treatment if years_since_treatment < 0
tab lags, gen(lag)
tab leads, gen(lead)
drop lead13
rename lag1 lag0
rename lag2 lag1
rename lag3 lag2
rename lag4 lag3
rename lag5 lag4
rename lag6 lag5 
rename lag7 lag6
rename lag8 lag7
rename lag9 lag8
replace lag0= 0 if leads!=0
rename lead1 lead1212
rename lead12 lead1
rename lead1212 lead12
rename lead2 lead1111
rename lead11 lead2
rename lead1111 lead11
rename lead3 lead1010
rename lead10 lead3
rename lead1010 lead10
rename lead4 lead99
rename lead9 lead4
rename lead99 lead9
rename lead5 lead88
rename lead8 lead5
rename lead88 lead8
rename lead6 lead77
rename lead7 lead6
rename lead77 lead7

save cleaned.dta, replace
*/



//Generate Summary Stats table for with/wo uber
eststo: estpost sum fatals drunk_dr weekend age_1835 if uber==0
esttab using sumstat.tex, cells("mean(fmt(%8.2f)) max " "sd(fmt(%8.2f))") one lines title(Summary Statistics for counties without Uber service) compress replace
eststo: estpost sum fatals drunk_dr weekend age_1835 if uber==1
esttab using sumstat.tex, cells("mean(fmt(%8.2f)) max " "sd(fmt(%8.2f))") one lines title(Summary Statistics for counties with Uber service) compress append


estpost tab year_month
estpost tab state_county



estpost tabstat ages*, s(sum)
esttab using ages.tex, cells(ages1-ages99) replace
estpost tabstat death, s(sum) by(state_county)



//Levels Event Study
eventdd fatals uber i.year_month, timevar(years_since_treatment) method(fe)
eventdd drunk_dr uber i.year_month, timevar(years_since_treatment) method(fe)



/*Baseline*/
eststo: nbreg fatals uber i.year_month i.panelid if bk ==1 & year<2015, irr exposure(popestimate)
eststo: nbreg fatals uber i.year_month i.panelid if year<2015, irr exposure(popestimate)
eststo: nbreg fatals uber i.year_month i.panelid, irr exposure(popestimate)
esttab using baseresults.tex, se keep(uber) eform replace
eststo clear

/*Drunk Driving*/
eststo: nbreg drunk_dr uber i.year_month i.panelid, irr exposure(popestimate)


/*Age Breakdown*/
eststo: nbreg age_1835 uber i.year_month i.panelid , irr exposure(popestimate)
nbreg age_3653 uber i.year_month i.panelid , irr exposure(popestimate)
nbreg age_54118 uber i.year_month i.panelid , irr exposure(popestimate)
outreg2 using agereg, excel

/*Day Breakdown*/
nbreg sunday uber i.year_month i.state_county , irr exposure(popestimate)
nbreg monday uber i.year_month i.state_county , irr exposure(popestimate)
nbreg tuesday uber i.year_month i.state_county , irr exposure(popestimate)
nbreg wednesday uber i.year_month i.state_county , irr exposure(popestimate)
nbreg thursday uber i.year_month i.state_county , irr exposure(popestimate)
nbreg friday uber i.year_month i.panelid , irr exposure(popestimate)
nbreg saturday uber i.year_month i.panelid , irr exposure(popestimate)

eststo: nbreg weekend uber i.year_month i.panelid , irr exposure(popestimate)
esttab using hetresults.tex, se keep(uber) eform replace
eststo clear

/*Individual age breakdown (Ages are lagged 1 so Age of 18 is Age19*/
nbreg ages19 uber i.year_month i.state_county , irr exposure(popestimate)
nbreg ages20 uber i.year_month i.state_county , irr exposure(popestimate)
nbreg ages21 uber i.year_month i.state_county , irr exposure(popestimate)
nbreg ages22 uber i.year_month i.state_county , irr exposure(popestimate)
nbreg ages23 uber i.year_month i.state_county , irr exposure(popestimate)
nbreg ages24 uber i.year_month i.state_county , irr exposure(popestimate)
nbreg ages25 uber i.year_month i.state_county , irr exposure(popestimate)
nbreg ages26 uber i.year_month i.state_county , irr exposure(popestimate)


//Timing Breakdowns
nbreg fatals uber i.year_month i.state_county if year>2013, irr exposure(popestimate)
nbreg fatals uber i.year_month i.state_county if year>2011, irr exposure(popestimate)

nbreg drunk_dr uber i.year_month i.state_county if year>2013, irr exposure(popestimate)
nbreg drunk_dr uber i.year_month i.state_county if year>2011, irr exposure(popestimate)


//Population Breakdowns
eststo: nbreg fatals uber i.year_month i.state_county if popestimate>1078760, irr exposure(popestimate)
eststo: nbreg fatals uber i.year_month i.state_county if popestimate<=738877&popestimate>466997, irr exposure(popestimate)
eststo: nbreg fatals uber i.year_month i.state_county if popestimate<=466997, irr exposure(popestimate)
esttab using popresults.tex, se keep(uber) eform replace


//Event Study
eststo: nbreg fatals uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)
nbreg drunk_dr uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)

nbreg weekend uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)
nbreg friday uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)
nbreg saturday uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)


nbreg age_1835 uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)
nbreg ages19 uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)
nbreg ages22 uber i.year_month i.panelid lead12-lead2 lag0-lag8, irr exposure(popestimate)


//Locations 
//Chicago 581
//NYC 1800 1821 1828 1838 1840
//LA 176
/*
nbreg fatals uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
eststo estfatals
esttab estfatals, se
parmest, saving("tempfatals", replace)
	use "tempfatals", clear
	twoway  (rcap min95 max95 timedimension , color(black) ) (scatter estimate t, legend(off) color(black) xtitle(Months relative to Uber Entry) xlabel(-12(1)8) ytitle(Estimated Effect) yline(0)

	

*/
//Event Study
eststo: nbreg fatals uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5) xline(7.5) yline(1) vertical msymbol(D) graphregion(color(white)) ciopts(lwidth(*3) lcolor(*.6)) coeflabels(lead9 = "-9" lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5") eform xtitle(Years to Treatment) title(IRR for Traffic Fatalities)
graph save Graph "Y:\My Drive\Thesis\Data\Stata\Graphs\baseES.gph", replace

eststo: nbreg drunk_dr uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5) xline(7.5) yline(1) vertical msymbol(D) graphregion(color(white)) ciopts(lwidth(*3) lcolor(*.6)) coeflabels(lead9 = "-9" lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5") eform xtitle(Years to Treatment) title(IRR for Alcohol-Related Fatalities)
graph save Graph "Y:\My Drive\Thesis\Data\Stata\Graphs\drunkES.gph", replace

eststo: nbreg weekend uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5) xline(7.5) yline(1) vertical msymbol(D) graphregion(color(white)) ciopts(lwidth(*3) lcolor(*.6)) coeflabels(lead9 = "-9" lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5") eform xtitle(Years to Treatment) title(IRR for Weekend Fatalities)
graph save Graph "Y:\My Drive\Thesis\Data\Stata\Graphs\wkndES.gph", replace
graph combine drunkES.gph wkndES.gph, graphregion(color(white))

eststo: nbreg age_1835 uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5) xline(7.5) yline(1) vertical msymbol(D) graphregion(color(white)) ciopts(lwidth(*3) lcolor(*.6)) coeflabels(lead9 = "-9" lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5") eform xtitle(Years to Treatment) title(IRR for Age 18-35 Fatalities)
graph save Graph "Y:\My Drive\Thesis\Data\Stata\Graphs\youngES.gph", replace

nbreg age_035 uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5) xline(7.5) yline(1) vertical msymbol(D) graphregion(color(white)) ciopts(lwidth(*3) lcolor(*.6)) coeflabels(lead9 = "-9" lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5") eform xtitle(Years to Treatment) title(IRR for Age 0-35 Fatalities)
graph save Graph "Y:\My Drive\Thesis\Data\Stata\Graphs\035ES.gph", replace

nbreg age_1521 uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5) xline(7.5) yline(1) vertical msymbol(D) graphregion(color(white)) ciopts(lwidth(*3) lcolor(*.6)) coeflabels(lead9 = "-9" lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5") eform xtitle(Years to Treatment) title(IRR for Age 15-21 Fatalities)
graph save Graph "Y:\My Drive\Thesis\Data\Stata\Graphs\1521ES.gph", replace

nbreg age_3653 uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5) xline(7.5) yline(1) vertical msymbol(D) graphregion(color(white))  ciopts(lwidth(*3) lcolor(*.6)) coeflabels(lead9 = "-9" lead8 = "-8" lead7 = "-7" lead6 = "-6" lead5 = "-5" lead4 = "-4" lead3 = "-3" lead2 = "-2" lag0 = "0" lag1 = "1" lag2 = "2" lag3 = "3" lag4 = "4" lag5 = "5") eform xtitle(Years to Treatment) title(IRR for Age 36-53 Fatalities)
graph save Graph "Y:\My Drive\Thesis\Data\Stata\Graphs\3653ES.gph", replace
graph combine youngES.gph 035ES.gph 1521ES.gph 3653ES.gph, graphregion(color(white))

nbreg saturday uber i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)
coefplot, keep(lead12 lead11 lead10 lead9 lead8 lead7 lead6 lead5 lead 4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6 lag7 lag8) xlabel(, angle(vertical)) xline(10.5) yline(1) vertical msymbol(D) mfcolor(white) ciopts(lwidth(*3) lcolor(*.6)) mlabel format(%9.3f) mlabposition(12) mlabgap(*2) eform title(IRR for Friday Fatalities)

nbreg fatals uber uber#i.fips i.year_month i.fips lead12-lead2 lag0-lag8, irr exposure(popestimate)

esttab using ESresults.tex, se eform keep(lead9 lead8 lead7 lead6 lead5 lead4 lead3 lead2 lag0 lag1 lag2 lag3 lag4 lag5 lag6) replace







//Figures
graph bar (sum) uber, over(year) blabel(bar) ytitle(County-Months with Uber) graphregion(color(white))
hist fatals, freq d subtitle("Distribution of Fatality Counts") xtitle("Count of Fatalities") graphregion(color(white))
hist drunk_dr, freq d subtitle("Distribution of Alcohol Fatality Counts") xtitle("Count of Fatalities") graphregion(color(white))
