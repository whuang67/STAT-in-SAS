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
