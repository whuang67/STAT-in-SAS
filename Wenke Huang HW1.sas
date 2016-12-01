
/* The raw data in seeds_dataset.txt is from
   http://archive.ics.uci.edu/ml/datasets/seeds 
   Bache, K. & Lichman, M. (2013). UCI Machine Learning Repository 
   [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, 
   School of Information and Computer Science.
*/

ods rtf file = "C:\Stat 448\Wenke Huang HW1.rtf";
title "Wenke Huang HW1";

data seeds;
	* modify the file path to match the location of your data files, 
	  then change the path back before submitting your final code;
	infile 'c:\Stat 448\seeds_dataset.txt' expandtabs;
	input area perimeter compactness length width 
		asymmetry groovelength variety $;
	if variety = '1' then variety = 'Kama';
	if variety = '2' then variety = 'Rosa';
 	if variety = '3' then variety = 'Canadian';
run;

/* Preparation */

* sort the whole datasets by the variable "variety" and create a
  new dataset named "sorted_seeds" for the rest of this assignment;
proc sort data = seeds
          out = sorted_seeds;
  by variety;
run;

/* EXERCISE 1 */
/* a */
title2 "part 1(a)";
proc univariate data = sorted_seeds;
  var compactness asymmetry;
  ods select Moments BasicMeasures;
run;

/* b */
title2 "part 1(b)";
proc univariate data = sorted_seeds;
  var compactness asymmetry;
  by variety;
  ods select Moments BasicMeasures;
run;

/* EXERCISE 2 */
/* a */
title2 "part 2(a)";
proc univariate data = sorted_seeds normal;
  var compactness;
  histogram / normal;
  probplot / normal (MU=EST SIGMA=EST);
  ods select TestsForNormality Histogram Probplot;
run;

/* b */
title2 "part 2(b)";
proc univariate data = sorted_seeds normal;
  var compactness;
  by variety;
  histogram / normal;
  probplot / normal (MU=EST SIGMA=EST);
  ods select TestsForNormality Histogram Probplot;
run;

/* EXERCISE 3 */
/* a */
title2 "part 3(a)";
proc univariate data = sorted_seeds mu0 = 0.875;
  var compactness;
  ods select TestsForLocation;
run;

/* b */
title2 "part 3(b)";
* We sorted the dataset "sorted_seeds" in ascending order of the
  variable "vareity". As a result, we need to use lower-tailed
  test because level "Kama" comes in front of "Rosa".;
proc ttest data = sorted_seeds sides = l;
  var compactness;
  class variety;
  where variety ne "Canadian";
  ods select ConfLimits TTests Equality;
run;

/* EXERCISE 4 */
/* a */
title2 "part 4(a)";
proc corr data = sorted_seeds;
  var area length width asymmetry;
  ods select PearsonCorr;
run;

/* b */
title2 "part 4(b)";
proc corr data = sorted_seeds;
  var area length width asymmetry;
  by variety;
  ods select PearsonCorr;
run;

title;
ods rtf close;
