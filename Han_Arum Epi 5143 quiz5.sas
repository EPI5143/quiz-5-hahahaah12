
*making the library where the datasets are saved;
libname clasdat "C:\SAS\epi5143 classdata";

**QUIZ #5
	*1. Determine the proportion of admissions which recorded a diagnosis of diabetes for admissions between January 1st, 2003 and December 31st, 2004;
	*2. Generate a frequency table of frequency of diabetes diagnoses, with the denominator being the 
        total number of admissions between January 1st, 2003 and December 31st, 2004.; 

* creating a spine dataset: new data set which conatins only unque admissions (hraEndWid) with admit dates (hraAdmDtm) between Jan 1st 2003 and dec 31 2004. ;
data clasdat.quiz5; 
set clasdat.nhrabstracts;
run;

proc contents data =clasdat.quiz5;
run;
*only year 2003 and 2004 and keepingn only hraencwid;
data quiz5; 
set clasdat.quiz5;
if year(datepart(hraadmdtm)) = 2003 or year(datepart(hraadmdtm)) =  2004;
keep hraEncWID;
run; *observation 2230;

proc print data=quiz5;
run;
*sorting and removing duplicates;
proc sort data = quiz5 out = abstracts nodupkey;
by hraencwid;
run;*there was no duplicates ;

*from nrhdiagnosis dataset - determining encuonter with diagnosis codes;

*making diagnosis table to modify;
data clasdat.quiz5_diag; 
set clasdat.nhrdiagnosis;
run;


*creating a flag for diabetes = DM and flatfiling using dataset ;

data diabetesct;
set clasdat.quiz5_diag;
by hdgHraEncWID;
if first.hdgHraEncWID then do;
	dm=0; count = 0;
	end;

if hdgcd in:('250' 'E10' 'E11') then do;
	dm = 1; count = count+1; *dm = flag for the diabetes diagnosis, count = number of diabetes diagnosis;
	end;
if last.hdgHraEncWID then output;
retain dm count;
run;
proc freq data=diabetesct;
tables dm count;
run;

*linking datasets;

*sorting first by encwid variable for each dataset ;
proc sort data = quiz5;
by hraencwid;
run;
proc sort data=diabetesct;
by hdgHraEncWID;
run;

*left join - reference dataset as the spine dataset (quiz5);
data merged;
merge quiz5 (in=a) diabetesct (in=b rename = (hdgHraEncWID = hraencwid));
by hraencwid;
if a; *left join;
if dm =. then  dm =0; *coding missing values as 0 for diabetes to include in the denominator;
if count =. then  count =0; *coding missing as 0 to include in denominator;
run;
*checking the merged dataset;
proc print data =merged;
run;

*proportion of admissions with diabetes diagnosis;
proc freq data=merged;
tables dm;
run;
*proportion of admissions which recorded a diagnosis of 
diabetes for admissions between January 1st, 2003 and December 31st, 2004;
	* there we re 2230 admissions between 2003 and 2003. 83 admissions out of 2230 (between 2003 and 2004) had a diagnosis of diabetes = 3.72%;

*frequency of diabetes diagnosis per encounterid;
proc freq data=merged;
tables count;
run;
	* 2147 admissions out of 2230, or 96.28% of them did not have any diabetes diagnosis ;
	* 83 admissions out of 2230, or 3.72% of them had 1 diagnosis diagnosis;
	* none of them had 2 or diagnosis diagnosis -  meaning that there is no duplicates of encounterid or admission ;

*saving in permanent dataset;
data clasdat.quiz5_abs;
set quiz5;
run;

data clasdat.quiz5diag_dm;
set diabetesct;
run;

data clasdat.quiz5merged;
set merged;
run;









 * practice: creating a flatfiling - practicel - second approach;   
data flatfile;
set clasdat.quiz5_diag;
dm = 0;
if hdgcd in:('250' 'E10' 'E11') then dm = 1;
run;

proc means data = flatfile;
class hdgHraEncWID;
types hdgHraEncWID;
var dm;
output out=flatfile2 max(dm) = diabetes n(dm) = count sum(dm) = dm_count;
run;

proc freq data=flatfile2;
tables diabetes count dm_count; 
run; 







