@echo off

:	Read the GTAP master data file gsddat.har and transform it into GAMS data exchange file gsd.gdx

gams flex2gdx --yr=04 o=flex2gdx_04.lst
gams flex2gdx --yr=07 o=flex2gdx_07.lst

:	Run this set of jobs in parallel:

:filter

title	Running filter.gms

set tol=01
start gams filter --yr=04 --tol=%tol%  o=filter04_%tol%.lst qcp=cplex gdx=filter04_%tol%.gdx
start gams filter --yr=07 --tol=%tol%  o=filter07_%tol%.lst qcp=cplex gdx=filter07_%tol%.gdx

set tol=001
start gams filter --yr=04 --tol=%tol%  o=filter04_%tol%.lst qcp=cplex gdx=filter04_%tol%.gdx
start gams filter --yr=07 --tol=%tol%  o=filter07_%tol%.lst qcp=cplex gdx=filter07_%tol%.gdx

set tol=0001
start gams filter --yr=04 --tol=%tol%  o=filter04_%tol%.lst qcp=cplex gdx=filter04_%tol%.gdx
start gams filter --yr=07 --tol=%tol%  o=filter07_%tol%.lst qcp=cplex gdx=filter07_%tol%.gdx

set tol=00001
start gams filter --yr=04 --tol=%tol%  o=filter04_%tol%.lst qcp=cplex gdx=filter04_%tol%.gdx
start gams filter --yr=07 --tol=%tol%  o=filter07_%tol%.lst qcp=cplex gdx=filter07_%tol%.gdx

pause

:	Run these aggregation jobs in parallel:

:gtap8ingams

title	Aggregating the GTAP8inGAMS datasets.

start gams gtapaggr --yr=07 --source=gsd  --target=gtap8ingams o=gtapaggr07.lst --output=gtap8ingams
start gams gtapaggr --yr=04 --source=gsd  --target=gtap8ingams o=gtapaggr04.lst --output=gtap8ingams

set tol=01
start gams gtapaggr --yr=07 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr07.lst --output=gtap8ingams_%tol%
start gams gtapaggr --yr=04 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr04.lst --output=gtap8ingams_%tol%

set tol=001
start gams gtapaggr --yr=07 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr07.lst --output=gtap8ingams_%tol%
start gams gtapaggr --yr=04 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr04.lst --output=gtap8ingams_%tol%

set tol=0001
start gams gtapaggr --yr=07 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr07.lst --output=gtap8ingams_%tol%
start gams gtapaggr --yr=04 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr04.lst --output=gtap8ingams_%tol%

set tol=00001
start gams gtapaggr --yr=07 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr07.lst --output=gtap8ingams_%tol%
start gams gtapaggr --yr=04 --source=gsd_%tol%  --target=gtap8ingams o=gtapaggr04.lst --output=gtap8ingams_%tol%

pause

:g20

title	Aggregating some G20 datasets.

start gams gtapaggr --yr=07 --source=gtap8ingams  --target=g20 
start gams gtapaggr --yr=04 --source=gtap8ingams  --target=g20 

set tol=01
start gams gtapaggr --yr=07 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%
start gams gtapaggr --yr=04 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%

set tol=001
start gams gtapaggr --yr=07 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%
start gams gtapaggr --yr=04 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%

set tol=0001
start gams gtapaggr --yr=07 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%
start gams gtapaggr --yr=04 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%

set tol=00001
start gams gtapaggr --yr=07 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%
start gams gtapaggr --yr=04 --source=gtap8ingams_%tol%  --target=g20 --output=g20_%tol%


pause

:iea

title	Aggregating some IEA datasets.

gams gtapaggr --yr=07 --source=g20  --target=iea 
gams gtapaggr --yr=04 --source=g20  --target=iea 

set tol=01
gams gtapaggr --yr=07 --source=g20_%tol%  --target=iea --output=iea_%tol%
gams gtapaggr --yr=04 --source=g20_%tol%  --target=iea --output=iea_%tol%

set tol=001
gams gtapaggr --yr=07 --source=g20_%tol%  --target=iea --output=iea_%tol%
gams gtapaggr --yr=04 --source=g20_%tol%  --target=iea --output=iea_%tol%

set tol=0001
gams gtapaggr --yr=07 --source=g20_%tol%  --target=iea --output=iea_%tol%
gams gtapaggr --yr=04 --source=g20_%tol%  --target=iea --output=iea_%tol%

set tol=00001
gams gtapaggr --yr=07 --source=g20_%tol%  --target=iea --output=iea_%tol%
gams gtapaggr --yr=04 --source=g20_%tol%  --target=iea --output=iea_%tol%

:end
