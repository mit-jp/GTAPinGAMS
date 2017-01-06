$title	BUILD Script for GTAP6inGAMS -- Alternative to the Batch File

*	Use Erwin's little program to see what we run today.

set iopt /Flex2GDX,ZIP2GDX,Filter,GTAPAGGR,IMPOSE/
$onecho >ask.rsp
T=checklistbox 
M="What do you what to build?" 
C="GTAP6INGAMS Build Script"
D="Flex2GDX|ZIP2GDX|Filter|GTAPAGGR|IMPOSE" 
E="Flex2GDX|ZIP2GDX|Filter|GTAPAGGR|IMPOSE" 
R=%s
O=irun.inc
$offecho
* import a set through a checked listbox
$call =ask @ask.rsp
set irun(iopt) /
$include irun.inc
/;


*	FLEX2GDX.GMS --- import a FLEXAGG dataset
*
*	Produce gsd.gdx based on the FLEXAGG distribution files 
*	gsddat.har, gsdpar.har, gsdset.har and gsdvole.HAR, and
*	input GTAP_V6_CO2.har from GTAP	resource 2348.zip.

if (irun("flex2gdx"),	execute 'gams flex2gdx';);

*	ZIP2GDX.GMS --- import a GTAPAGG dataset

*	We next illustrate how to translate a dataset which has 
*	been produced by GTAPAGG.  This statement produces china.gdx
*	from china.zip:

if (irun("zip2gdx"),	execute 'gams zip2gdx --ds=china';);

*	FILTER.GMS --- filter a dataset

*	One problem with using the GTAP data is that there are 
*	too many very small numbers.  These value wreck havoc
*	with factorization routines in PATH and CONOPT.  I
*	have therefore produced a program which "filters" the
*	GTAP data to a specified tolerance.  

*	The larger tolerance produces a sparser dataset.
*	Look at filterlog01.xls for a summary of changes:

if (irun("filter"), execute 'gams filter  --tol=01';);

*	GTAPAGGR.GMS --- aggregate a dataset

*	The following statement illustrates how to aggregate a 
*	gtap6ingams dataset.  The dataset identifier is given
*	on the command line.  

*	--ds=gtap indicates that the target dataset is defined in
*	..\defines\gtapiea.map, and the output dataset is to be
*	written to ..\data\gtapiea.gdx

if (irun("gtapaggr"), execute 'gams gtapaggr --ds=gtapiea';);

*	IMPOSE.GMS ---  adjust a dataset

*	The following statement illustrates how to make adjustments
*	in a gtap6ingams dataset and rebalance the resulting model.
*	In this case, I simply impose a different set of benchmark taxes
*	on gtapiea, but the same procedure could be employed for other
*	types of changes:

if (irun("impose"), execute 'gams impose --ds=gtapiea';);
