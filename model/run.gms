$title	RUN Script for some Sample Models

*	Install GAMS-F if it is not already there:

$if not exist "%gams.sysdir%gams-f.gms" $call 'cp gams-f.gms "%gams.sysdir%\gams-f.gms"'


$onecho >ask.rsp
T=checklistbox
C="GTAP6INGAMS  Sample Programs" 
M="What do you what to run?"
D=MRTMCP|MRTMGE|MGEMCPTEST|UNIFORM|MCF|OPTTARIFF|FTA
E=MRTMCP|MRTMGE|MGEMCPTEST|UNIFORM|MCF|OPTTARIFF|FTA
O=irun.inc
R=%s
$offecho
$call =ask @ask.rsp

set iopt /MRTMCP,MRTMGE,MGEMCPTEST,UNIFORM,MCF,OPTTARIFF,FTA/;
set irun(iopt) /
$include irun.inc
/;

if (irun("mrtmcp"),	execute 'gams mrtmcp';);
if (irun("mrtmge"),	execute 'gams mrtmge';);
if (irun("mgemcptest"), execute 'gams mgemcptest';);
if (irun("uniform"),	execute 'gams uniform';);
if (irun("mcf"),	execute 'gams mcf';);
if (irun("opttariff"),	execute 'gams opttariff';);
if (irun("fta"),	execute 'gams fta';);


