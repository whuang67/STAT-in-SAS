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
