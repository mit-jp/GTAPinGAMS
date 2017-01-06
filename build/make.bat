@echo off

:	Read the GTAP master data file gsddat.har and transform it into GAMS data exchange file gsd.gdx
gams flex2gdx 
pause

:	Generate the basic GTAP file while suppressing tiny values:
:filter
title	Running filter.gms
gams filter --tol=001  o=filter_001.lst qcp=cplex 
pause

:gtap7gams
title	Running gtapaggr: gsd_001 to gtap7ingams
gams gtapaggr --source=gsd_001  --target=gtap7ingams

:	Generate an aggregation for mapping to the EPA non-CO2 data:

:epa
gams gtapaggr --source=gsd_001  --target=epa


:	Up to this point, the dataset is strictly GTAP data.

pause

:	Introduce data from DOE's International Energy Outlook (ieo) and 
:	International Energy Annual (iea), and the EPA other greenhouse
:	gas data to produce gtap7ingams_e,

:	This provides a comprehensive GTAP dataset with IEO baseline projections 
:	on future GDP growth and energy demand as well as EPA projections
:	on non-CO2 GHG marginal abatement cost and baseline emissions

:	To invoke addieo from scratch one needs to run
:	1. the EPA extraction routine run.bat within subdirectory /EPA
:	2. the IEO extraction routine translate.bat within the respective IEO subdirectory (IEO2010):

:addieo
title	Running addieo to produce gtap7ingams_e
gams addieo
pause

:	Disaggregate energy sector mapping matching IEA data dimensions

:gtap7iea
title	Running gtapaggr: gtap7ingams_e to gtap7iea
gams gtapaggr --source=gtap7ingams_e --target=gtap7iea --energydata=yes o=gtap7iea.lst


:g20all
gams gtapaggr --source=gtap7ingams_e  --target=g20all --energydata=yes

:g20dis
gams gtapaggr --source=gtap7ingams_e  --target=g20dis --energydata=yes

:g20agg
gams gtapaggr --source=gtap7ingams_e  --target=g20agg --energydata=yes

:EMFall
gams gtapaggr --source=gtap7ingams_e  --target=EMFall --energydata=yes

:EMFdis
gams gtapaggr --source=gtap7ingams_e  --target=EMFdis --energydata=yes

:EMFagg
gams gtapaggr --source=gtap7ingams_e  --target=EMFagg --energydata=yes

