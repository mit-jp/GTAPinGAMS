@echo off

:	Set a filter tolerance:

set tol=001

:	Read the GTAP master data file gsddat.har and transform it into GAMS data exchange file gsd.gdx

:flex2gdx
title	Translating har files into gdx files.
gams flex2gdx --yr=04 o=flex2gdx_04.lst lf=flex2gdx_04.log lo=2
gams flex2gdx --yr=07 o=flex2gdx_07.lst lf=flex2gdx_07.log lo=2
gams flex2gdx --yr=11 o=flex2gdx_11.lst lf=flex2gdx_11.log lo=2
pause

:filter
title	Running filter.gms
start gams filter --yr=04 --tol=%tol%  o=filter04_%tol%.lst qcp=cplex gdx=filter04_%tol%.gdx lf=filter04_%tol%.log lo=2
start gams filter --yr=07 --tol=%tol%  o=filter07_%tol%.lst qcp=cplex gdx=filter07_%tol%.gdx lf=filter07_%tol%.log lo=2
start gams filter --yr=11 --tol=%tol%  o=filter11_%tol%.lst qcp=cplex gdx=filter11_%tol%.gdx lf=filter11_%tol%.log lo=2
pause

:gtap9ingams
title	Aggregating the GTAP9inGAMS datasets.
start gams gtapaggr --yr=04 --source=gsd_%tol%  --target=gtap9ingams --output=gtap9ingams_%tol% o=gtap9ingams_%tol%_2004.lst lf=gtap9ingams_%tol%_2004.log lo=2
start gams gtapaggr --yr=07 --source=gsd_%tol%  --target=gtap9ingams --output=gtap9ingams_%tol% o=gtap9ingams_%tol%_2007.lst lf=gtap9ingams_%tol%_2007.log lo=2
start gams gtapaggr --yr=11 --source=gsd_%tol%  --target=gtap9ingams --output=gtap9ingams_%tol% o=gtap9ingams_%tol%_2011.lst lf=gtap9ingams_%tol%_2011.log lo=2

pause

:implan
title	Aggregating the GTAP9inGAMS datasets.
start gams gtapaggr --yr=04 --source=gtap9ingams_%tol%  --target=implan --output=implan o=implan_2004.lst lf=implan_2004.log lo=2
start gams gtapaggr --yr=07 --source=gtap9ingams_%tol%  --target=implan --output=implan o=implan_2007.lst lf=implan_2007.log lo=2
start gams gtapaggr --yr=11 --source=gtap9ingams_%tol%  --target=implan --output=implan o=implan_2011.lst lf=implan_2011.log lo=2
pause

:	Up to this point, the dataset is strictly GTAP data.
:	Introduce data from DOE's International Energy Outlook (IEO)

:	This provides a comprehensive GTAP dataset with IEO baseline projections 
:	on future GDP growth and energy demand 

:addieo
title	Running addieo to produce gtap9ingams_e
start gams addieo --byr=2004 lf=addieo_2004.log lo=2
start gams addieo --byr=2007 lf=addieo_2007.log lo=2
start gams addieo --byr=2011 lf=addieo_2011.log lo=2
pause

:	Aggregate a few smaller datasets which include the IEO baseline:

:g20
title	Aggregating some G20 datasets.
gams gtapaggr --yr=04 --source=gtap9ingams_%tol%_e  --target=g20  o=g20.lst lf=g20_2004.log lo=2
gams gtapaggr --yr=07 --source=gtap9ingams_%tol%_e  --target=g20  o=g20.lst lf=g20_2007.log lo=2
gams gtapaggr --yr=11 --source=gtap9ingams_%tol%_e  --target=g20  o=g20.lst lf=g20_2011.log lo=2

