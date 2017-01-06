The GTAP8.1 Buildstream

Thomas F. Rutherford

Wisconsin Institute for Discovery
Agricultural and Applied Economics Department

University of Wisconsin, Madison
April, 2014

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

\gtapdata\2004
  28-Feb-2014  12:26:50p     68,492,379   gsddat.har
  28-Feb-2014  12:26:50p        327,310   gsdemiss.har
  28-Feb-2014  12:26:50p        151,666   gsdpar.har
  28-Feb-2014  12:26:50p         11,299   gsdset.har
  28-Feb-2014  12:26:50p     11,387,401   gsdtax.har
  28-Feb-2014  12:26:50p     57,260,096   gsdtrade.har
  28-Feb-2014  12:26:50p        792,137   gsdvole.har

and
\gtapdata\2007
  28-Feb-2014  12:27:02p     68,491,775   gsddat.har
  28-Feb-2014  12:27:02p         11,415   gsdset.har
  28-Feb-2014  12:27:02p     11,387,397   gsdtax.har
  28-Feb-2014  12:27:04p        327,126   gsdemiss.har
  28-Feb-2014  12:27:04p        151,722   gsdpar.har
  28-Feb-2014  12:27:04p     57,259,856   gsdtrade.har
  28-Feb-2014  12:27:04p        792,373   gsdvole.har

Ideally a QCP SOLVER such as CPLEX should be used in filter.gms.  It
may also be possible to use CONOPT or PATHNLP for this purpose.

The following sattelite energy data are provided:

	ieo2013\xls

No directories with sattelite energy data are provided in this version
of the build stream.

