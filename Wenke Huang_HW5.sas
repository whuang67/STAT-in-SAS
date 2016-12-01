/* The raw data in seeds_dataset.txt is from
   http://archive.ics.uci.edu/ml/datasets/seeds 
   Bache, K. & Lichman, M. (2013). UCI Machine Learning Repository 
   [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, 
   School of Information and Computer Science.
*/

ods rtf file="c:\Stat 448\HW5_WenkeHuang.rtf";

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

/* Exercise 1 */
proc princomp data = seeds plots= score(ellipse ncomp=2);
  var area perimeter compactness length width 
	  asymmetry groovelength;
  id variety;
run;

/* Exercise 2 */
proc princomp data = seeds plots= score(ellipse ncomp=2)
                           covariance;
  var area perimeter compactness length width 
	  asymmetry groovelength;
  id variety;
run;

/* Exercise 3 */
proc cluster data = seeds plots(maxpoints = 211)
                          method=average
                          print = 15
                          ccc
                          pseudo
                          outtree = treeThree;
  var area perimeter compactness length width 
	  asymmetry groovelength;
  copy variety;
run;

proc tree data = treeThree ncl=3 out = outThree;
   copy area perimeter compactness length width 
	    asymmetry groovelength variety;
run;

proc freq data=outThree;
  tables cluster*variety/ nopercent norow nocol;
run;

/* Exercise 4 */
proc cluster data = seeds plots(maxpoints = 211)
                          method=average
                          print=15
                          ccc
                          pseudo
                          standard
                          outtree=treeFour;
  var area perimeter compactness length width 
	  asymmetry groovelength;
  copy variety;
run;

proc tree data = treeFour ncl=4 out = outFour;
   copy area perimeter compactness length width 
	    asymmetry groovelength variety;
run;

proc freq data=outFour;
  tables cluster*variety/ nopercent norow nocol;
run;

ods rtf close;
