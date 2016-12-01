* ods rtf file = "C:\Stat 448\HW6_Wenke Huang.rtf";

/* The raw data in glass.data is from the UCI Machine Learning Repository
Lichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. 
Irvine, CA: University of California, School of Information and Computer Science. 

The data, variables and original source are described on the following URL
http://archive.ics.uci.edu/ml/datasets/Glass+Identification
*/
data glassid;
	infile "C:\Stat 448\glass.data" dlm=',' missover;
	input id RI Na Mg Al Si K Ca Ba Fe type;
	groupedtype = "buildingwindow";
	if type in(3,4) then groupedtype="vehiclewindow";
	if type in(5,6) then groupedtype="glassware";
	if type = 7 then groupedtype="headlamps";
	drop id type;
run;

/* Exercise 1 */
/* a */
proc cluster data = glassid method=average
                            print=15
                            standard
                            plots(maxpoints=215)
                            ccc
                            pseudo
                            outtree = glassidTree;
  var Na Mg Al Si K Ca Ba Fe;
  copy RI groupedtype;
run;

/* b */
proc tree data=glassidTree out=clusters n=11 noprint;
  copy RI Na Mg Al Si K Ca Ba Fe groupedtype;
run;

proc freq data=clusters;
  tables cluster*groupedtype / nopercent nocol norow;
run;

/* Exercise 2 */
/* a */
proc sort data = clusters
          out = sorted_clusters;
  by cluster;
run;

proc univariate data = sorted_clusters normal;
  var RI;
  by cluster;
  histogram / normal;
  probplot / normal (MU=EST SIGMA=EST);
  where cluster in (1, 2);
  ods select TestsForNormality Histogram Probplot;
run;

proc anova data = clusters;
  class cluster;
  model RI = cluster;
  where cluster in (1, 2);
  means cluster / hovtest cldiff tukey;
  ods Select OverallANOVA CLDiffs HOVFTest;
run;

/* Exercise 3 */
/* a */
proc stepdisc data=glassid sle=.05 sls=.05;
  class groupedtype;
  var Na Mg Al Si K Ca Ba Fe;
  ods Select Summary;
run;

/* b */
proc discrim data=glassid pool=test crossvalidate method=normal manova;
  class groupedtype;
  priors proportional;
  var Mg Ca Ba K Si;
run;


/* Exercise 4 */
/* a */
/* b */
data glassid_new;
  set glassid;
  if groupedtype = "glassware" 
    then newgroupedtype="glassware";
  else if groupedtype = "headlamps"
    then newgroupedtype="headlamps";
  else if groupedtype in ("buildingwindow", "vehiclewindow")
    then newgroupedtype = "window";
run;

proc stepdisc data = glassid_new sle=.05 sls=.05;
  class newgroupedtype;
  var Na Mg Al Si K Ca Ba Fe;
  ods Select Summary;
run;

proc discrim data=glassid_new pool=test crossvalidate method=normal manova;
  class newgroupedtype;
  priors proportional;
  var Mg Ca Ba K Si;
run;

* ods rtf close;
