* PROC MEANS -- Calculate basic statistics;
proc means data = sasuser.b_rise maxdec=4 n mean median std var q1 q3;
  var weight;
  title 'Selected Descriptive Statistics for weight';
run;

* PROC UNIVARIATE -- ;
goptions reset=all fontres=presentation ftext=swissb htext=1.5;
proc univariate data = sasuser.b_rise;
  var weight;
  id idnumber;
  histogram weight;
run;

* PROC BOXPLOT -- ;
data race;
  set sasuser.b_boston;
  Dummy='1';
run;
proc boxplot data=race;
  plot tottime*Dummy / boxstyle=schematic;
run;

* More about MEANS, BOXPLOT and UNIVARIATE;
proc univariate data=sasuser.b_rise;
  var weight;
  id idnumber;
  probplot weight / normal (mu=est sigma=est color=blue w=1); * Blue line with a width of 1;
run;

proc boxplot data=sasuser.b_rise;
  plot weight*brand / cboxes = black boxstyle = schematic;
  /* CBOXES: specifies the color of the box plot
     BOXSTYLE: specifies the type of box plot to be drawn */
run;

proc means data=sasuser.b_rise n mean stderr clm alpha=0.01;
/* CLM: calculates the confidence limits for the mean
   ALPHA: uses different confidence levels */
  var weight;
run;

* Type I error ALPHA: H0 is true but rejected.
  Type II error BETA: H0 is false but not rejected. ;

* Hypothesis Test;
proc univariate data=sasuser.b_rise mu=15;
  var weight;
run;

* pre analysis of ANOVA;
proc univariate data = sasuser.b_cereal;
  class brand;
  var weight;
  probplot weight / normal (mu=est sigma=est color=blue w=1);
run;
proc sort data = sasuser.b_cereal out = b_cereal;
  by brand;
run;
proc boxplot data = b_cereal;
  plot weight*brand / cboxes=black boxstyle=schematic;
run;

* PROC GLM: ANOVA;
options ls=75 ps=45;
proc glm data = sasuser.b_cereal;
  class brand;
  model  weight=brand;
  means brand / hovtest;
  /* HOVTEST: performs Levene's test for homogeneity of variances
     WELCH: is used if variances are not equal */
  output out=check r=resid p=pred;
run;
quit;

goptions reset=all;
proc gplot data = check;
  plot resid*pred / haxis=axis1 vaxis=axis2 vref=0;
  symbol v=star h=3pct;
  axis1 w=2 major=(w=2) minor=none offset=(10pct);
  axis2 w=2 major=(w=2) minor=none;
run;
quit;

proc univariate data = check normal;
  var resid;
  histogram resid / normal;
  probplot resid / normal (mu=est sigma=est color=blue w=1);
run;

* PROC CORR; 
proc corr data=sasuser.b_fitness rank; /* RANK: orders the correlations from highest to lowest in absolute value.
                                          NOSIMPLE: suppresses printing simple descriptive statistics. */
  var runtime age weight run_pulse rest_pulse maximum_pulse performance;
  with oxygen_consumption;
  /* If WITH statement is not specified, we get correlation coefficient matrix.
     If WITH statement is specified, the WITH specifies the row variables. */
run;

* REG: regression;
proc reg data = sasuser.b_fitness;
  model oxygen_consumption = performance;
run;
quit;
/* Coefficient of variation = RMSE/Y-bar * 100% */

data need_predictions;
  input performance @@;
  datalines;
0 3 6 9 12
;
run;
data predoxy;
  set sasuser.b_fitness need_predictions;
run;
proc reg data = predoxy;
  model oxygen_consumption = performance / p;
  /* P: prints the values of response variable, the predicted values and residuals */
  id performance;
  /* ID: specifies a variable to label observations */
run;

data _null_;
  input performance @@;
  oxygen_consumption = 35 + 1.4*performance;
  put performance= oxygen_consumption=;
  datalines;
0 3 6 9 12
;
run;

options ps=50 ls=76;
goptions reset=all fontres=presentation ftext=swissb htext=1.5;
proc reg data=predoxy;
/* LINEPRINTER: creates plots requested as line printer plots */
  model oxygen_consumption = performance / clm cli alpha=0.05;
  /* CLM: produces all P option output, plus standard errors of the predicted values, and upper and lower 95% ci 
          bounds for the mean at each value of the predictor variable.
     CLI: produces all P option output, plus standard errors of the predicted values, and upper and lower 95% ci
          bounds at each value of the predictor variable. */
  id name performance;
  plot oxygen_consumption*performance / conf pred;
  /* CONF: requests overlaid plots of confidence intervals. 
     PRED: requests overlaid plots of prediction intervals */
  symbol1 c=red v=dot;
  symbol2 c=red;
  symbol3 c=blue;
  symbol4 c=blue;
  symbol5 c=green;
  symbol6 c=green;
run;
quit;

* Multivariate Linear Regression;
proc reg data=sasuser.b_fitness;
  ALL_REG: model oxygen_consumption = performance runtime age weight run_pulse rest_pulse maximum_pulse /
                                    selection=rsquare adjrsq cp best=4;
  /* SELECTION: enables you to choose the different selection methods 
                values: RSQUARE FORWARD BACKWARD STEPWISE
     RSQUARE: tells PROC REG to use model's R-square to rank the models from best to worst
     ADJRSQ: prints the Adjusted R-square for each model
     CP: prints Mallows' Cp statistics for each model
     BEST=n: limits the output to only the best n models for a fixed number of variables. */
run;

proc reg data=sasuser.b_fitness;
  PREDICT: model oxygen_consumption = runtime age run_pulse rest_pulse;  /* Cp < p*/
  EXPLAIN: model oxygen_consumption = runtime age run_pulse rest_pulse maximum_pulse; /* Cp < 2p-p_full+1 */
run;


* Dignostic Plots ;
options ps=50 ls=97;
goptions reset=all fontres=presentation ftext=swissb htext=1.5;
proc reg data = sasuser.b_fitness;
  PREDICT: model oxygen_consumption = runtime age run_pulse maximum_pulse;
  plot r.*(p. runtime age run_pulse maximum_pulse);
  plot student. * obs. / vref=3 2 -2 -3
                         haxis=0 to 32 by 1;  /* VREF: specifies where reference lines are to appear
                                                 HAXIS: specifies range and tick marks for the horizontal axis */
  plot student. * nqq.;
  /* R.: residuals
     P.: predicted values
     STUDENT.: student residuals
     NQQ.: normal quantile values
     OBS.: observation number in the dataset*/
  symbol v=dot;
run;
quit;


* Influencial points;
goptions reset=all
proc reg data=sasuser.b_fitness;
  PREDICT: model oxygen_consumption = runtime age run_pulse maximum_pulse / r influence;
  /* R: prints STUDENT residuals and Cook's Distance
     INFLUENCE: prints RSTUDENT residuals and DFFITS */
  id name;
  output out=ck4outliers rstudent=rstud dffits=dfits cookd=cooksd;
  /* |DFFITS| > 2*sqrt(p/n), where p includes intercept
     Rstudent residuals: studentized residual with the i-th observation removed */
run;
quit;

%let numparams=5; *p;
%let numobs=32; *n;
data influential;
  set ck4outliers;
  cutdffits = 2*sqrt(&numparams/&numobs);
  cutcooksd = 4/&numobs;
  
  rstud_i = (abs(rtuid) > 3);
  dfits_i = (abs(dfits) > cutdffits);
  cookd_i = (cooksd > cutcooksd);
  sum_i = rstud_i + dfits_i + cookd_i;
  if sum_i > 0;
run;


* Collinearity;
/* Large R-square and F is highly significant. But few parameters are significant. */
proc reg data=sasuser.b_fitness;
  model oxygen_consumption = performance runtime age weight run_pulse rest_pulse maximum_pulse / vif collin collinoint;
  /* VIF: Variance Inflation Factor 
     COLLIN: generates condition indices and variance proportion statistics INCLUDE intercept 
     COLLINOINT: NOT INCLUDE intercept */
run;
quit;


* Categorical Data;
proc format;
  value purfmt 1 = '$100+'
               0 = '<$100';
run;
proc freq data=sasuser.b_sales;
  tables purchase gender income age gender*purchase income*purchase;
  format purchase purfmt.;
run;

/* Ordering values */
data b_sales_inc;
  set sasuser.b_sales;
  inclevel = 1*(income='Low') + 2*(income='Medium') + 3*(income='High');
run;
proc format;
  value incfmt 1='Low Income'
               2='Medium Income'
               3='High Income';
run;
proc freq data = b_sales_inc;
  tables inclevel*purchase;
  format inclevel incfmt.
         purchase purfmt.;
run;


* Contengency Table -- Chi-Square;
proc freq data =  sasuser.b_sales_inc;
  tables gender*purchase / chisq expected cellchi2 nocol nopercent;
  /* CHISQ: produces Chi-square test of association
     EXPECTED: prints the expected cell frequencies under the hypothesis of no assiciation
     CELLCHI2: print each cell's contribution to the total Chi-square statistics
     NOCOL: suppress printing the column percentages
     NOPERCENTAGE: suppress printing the cell percentages */
run;

* Exact p-value;
proc freq data = sasuser.b_exact;
  tables a*b;
  exact pchi;
  /* EXACT: produce exact p-values for the statistics listed as keywords */
  /* PCHI: request exact p-value for the chi-square statistic, including Cramer's V and other related statistics */
run;

* Spearman correlation statistic;
proc freq data = sasuser.b_sales_inc;
  tables inclevel*purchase / chisq measures cl;
  /* CHISQ: produces the Pearson chi-square, the likelihood-ratio chi-square, and the Mantel-Haenszel chi-square
     MEASURES: produces the Spearman correlation statistic
     CL: produces confidence bounds for the MEASURES statistics */
  format inclevel incfmt.
         purchase purfmt.;
run;


* LOGISTIC: Logistic Regression;
proc logistic data = sasuser.b_sales_inc;
  class gender (param=ref ref='Male');
  /* PARAM: specifies the parameterization method for the classification variable(s) */
  model purchase(event='1')=gender / clodds=pl;
  /* EVENT: specifies the event category for binary response model
     CLODDS=PL: requests profile likelihood confidence intervals */
run;
