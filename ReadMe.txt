The GTAP8 Buildstream

Thomas F. Rutherford

Wisconsin Institute for Discovery
Agricultural and Applied Economics Department

University of Wisconsin, Madison
April, 2012

-----------------------------------------------------------------------

This directory contains a GAMS-compatible version of the GTAP8
dataset.  The standard GTAP8inGAMS package is based on the following
directories:

build\ includes the central GAMS routines for data filtering and
data aggregation (see below).  See make.bat for steps included 
in the build.

defines\ includes alternative mapping definitions for aggregation of
regions, sectors, and factors

model\ includes two canonical static models based on the GTAP model,
in in MGE and the other in MCP format.

data04\ includes the 2004-based gdx-files that are either used as the
source data aggregation or the target data emerging fro the data
aggregation

data07\ includes the 2007-based gdx-files that are either used as the
source data aggregation or the target data emerging fro the data
aggregation

doc\ includes documentation for the core GTAPinGAMS build stream and
model (currently with GTAP7 details).

To use this build stream the following data files must be copied from
the GTAP8 flexagg8Y04 and flexagg8Y07 directories into gtapdata04 and
gtapdata07 directories before the GTAP8 data may be built:

   5-Mar-2012  12:26:20p          9,966   gsdset.har
   5-Mar-2012  12:29:58p     41,108,279   gsddat.har
   5-Mar-2012  12:37:14p        791,297   gsdvole.har
   5-Mar-2012   2:22:04p        168,310   gsdpar.har

and

   5-Mar-2012  11:37:34a        791,533   gsdvole.har
   5-Mar-2012   1:25:34p     40,955,659   gsddat.har
   5-Mar-2012   1:26:12p         10,082   gsdset.har
   5-Mar-2012   1:41:02p        168,426   gsdpar.har


Ideally a QCP SOLVER such as CPLEX should be used in filter.gms.  It
may also be possible to use CONOPT or PATHNLP for this purpose.

No directories with sattelite energy data are provided in this version
of the build stream.

