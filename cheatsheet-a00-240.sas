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
