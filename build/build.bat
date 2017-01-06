@echo off
cls
title	FLEX2GDX.GMS --- import a FLEXAGG dataset
echo.
echo	Produce gsd.gdx based on the FLEXAGG distribution files 
echo	gsddat.har, gsdpar.har, gsdset.har and gsdvole.HAR, and
echo	input GTAP_V6_CO2.har from GTAP	resource 2348.zip.
echo.
echo	All of the input data files are to be saved in the
echo	..\data directory:
echo.
echo	gams flex2gdx
pause
gams flex2gdx

title	ZIP2GDX.GMS --- import a GTAPAGG dataset
echo.
echo	We next illustrate how to translate a dataset which has 
echo	been produced by GTAPAGG.  This statement produces china.gdx
echo	from china.zip:
echo.
echo	gams zip2gdx --ds=china
pause
gams zip2gdx --ds=china

title	FILTER.GMS --- filter a dataset
echo.
echo	One problem with using the GTAP data is that there are 
echo	too many very small numbers.  These value wreck havoc
echo	with factorization routines in PATH and CONOPT.  I
echo	have therefore produced a program which "filters" the
echo	GTAP data to a specified tolerance.  
echo.
echo	The larger tolerance produces a sparser dataset.
echo	Look at filterlog01.xls for a summary of changes:
echo.
echo	gams filter  --tol=01
pause
gams filter  --tol=01

title	GTAPAGGR.GMS --- aggregate a dataset
echo.	
echo	The following statement illustrates how to aggregate a 
echo	gtap6ingams data.  The mapping file which describes the 
echo	sets and mappings for the target data are stored in 
echo	..\defines\gtapiea.map.  The output dataset is written
echo	to ..\data\gtapiea.gdx
echo.
echo	gams gtapaggr --source=gsd01 --target=gtapiea
pause
gams gtapaggr --ds=gtapiea

title	IMPOSE.GMS ---  adjust a dataset
echo.	
echo	The following statement illustrates how to make adjustments
echo	in a gtap6ingams dataset and rebalance the resulting model.
echo	In this case, I simply impose a different set of benchmark taxes
echo	on gtapiea, but the same procedure could be employed for other
echo	types of changes:
echo.
echo	gams impose --ds=gtapiea
pause
gams impose --ds=gtapiea
