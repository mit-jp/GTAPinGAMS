The GTAP9 Buildstream

Thomas F. Rutherford

Wisconsin Institute for Discovery
Agricultural and Applied Economics Department

University of Wisconsin, Madison
May, 2015

-----------------------------------------------------------------------

This directory contains a GAMS-compatible version of the GTAP9
dataset.  The standard GTAP9inGAMS package is based on the following
directories:

build\ includes the central GAMS routines for data filtering and data
aggregation (see below).  See make.bat for steps included in the
build.  Log files from my build have been included in the directory
for reference.

defines\ includes alternative mapping definitions for aggregation of
regions, sectors, and factors.

model\ includes two canonical static models based on the GTAP model,
one in MGE and the other in MCP format.

data04\, data07\ and data11\ includes the 2004, 2007 and 2011-based
gdx-files that are either used as the source data aggregation or the
target data emerging fro the data aggregation.

To use this build stream the following data files must be copied from
the GTAP9 FLEXAGG directories into gtapdata subdirectories 2004, 2007
and 2011 before the data may be built.  The distribution files which I
have worked with are 

 Directory of d:\gtap9\gtapdata\distrib

05/20/2015  10:29 AM               330 2960.zip
05/20/2015  10:32 AM        70,852,917 flexagg9Y04.zip
05/20/2015  10:30 AM        73,624,898 flexagg9Y07.zip
05/20/2015  10:30 AM        73,226,303 flexagg9Y11.zip
05/20/2015  10:30 AM        68,393,618 GAgg9y04.zip
05/20/2015  10:35 AM        70,339,030 GAgg9y07.zip
05/20/2015  10:37 AM        69,996,952 GAgg9y11.zip
05/20/2015  10:38 AM         9,079,248 TSTRADEv9.zip
               8 File(s)    435,513,296 bytes

The following HAR files have been unzipped and placed in the directories
for each of the three base years:

 Directory of d:\gtap9\gtapdata\2004

05/12/2015  04:04 PM        37,945,254 gsddat.har
05/12/2015  04:04 PM           352,445 gsdemiss.har
05/12/2015  04:12 PM            79,602 gsdpar.har
05/12/2015  05:00 PM             8,280 gsdset.har
05/12/2015  04:04 PM         3,541,900 gsdtax.har
05/12/2015  04:04 PM           893,788 gsdvole.har
05/04/2015  04:41 PM            18,420 metadata.har
               7 File(s)     42,839,689 bytes

 Directory of d:\gtap9\gtapdata\2007

05/12/2015  04:08 PM        39,874,482 gsddat.har
05/12/2015  04:08 PM           352,441 gsdemiss.har
05/12/2015  04:14 PM            79,598 gsdpar.har
05/12/2015  05:02 PM             8,276 gsdset.har
05/12/2015  04:08 PM         5,337,944 gsdtax.har
05/12/2015  04:08 PM        38,574,321 gsdview.har
05/12/2015  04:08 PM           893,784 gsdvole.har
05/04/2015  04:41 PM            18,420 metadata.har
               8 File(s)     85,139,266 bytes

 Directory of d:\gtap9\gtapdata\2011

05/12/2015  04:11 PM        39,517,018 gsddat.har
05/12/2015  04:11 PM           352,441 gsdemiss.har
05/12/2015  04:15 PM            79,598 gsdpar.har
05/12/2015  05:01 PM             8,276 gsdset.har
05/12/2015  04:11 PM         5,363,832 gsdtax.har
05/12/2015  04:11 PM        38,432,833 gsdview.har
05/12/2015  04:11 PM           893,784 gsdvole.har
05/04/2015  04:41 PM            18,420 metadata.har
               8 File(s)     84,666,202 bytes

If you have a QCP SOLVER such as Mosek or CPLEX, then filter.gms runs
smoothly.  It may also be possible to use CONOPT or PATHNLP for this
purpose.


The following sattelite population projection and energy data are
provided:

	ieo2013\xls

See http://www.eia.gov/forecasts/ieo/ for documentation.

The addieo.gms program which is included in the build stream
incorporates data from the IEO in the GTAP9inGAMS datasets.  These
data are read and aggregated with the GTAP data.

Directory of d:\gtap9\data04

05/26/2015  11:31 PM         2,824,622 g20.gdx
05/26/2015  11:26 PM        37,557,331 gsd.gdx
05/20/2015  02:09 PM        79,394,045 gsddat.gdx
05/20/2015  02:09 PM           799,375 gsdemiss.gdx
05/20/2015  02:09 PM           166,533 gsdpar.gdx
05/20/2015  02:09 PM             3,543 gsdset.gdx
05/20/2015  02:09 PM         4,663,982 gsdtax.gdx
05/20/2015  02:09 PM         2,190,327 gsdvole.gdx
05/26/2015  11:28 PM        21,955,497 gsd_001.gdx
05/26/2015  11:29 PM        21,815,061 gtap9ingams_001.gdx
05/26/2015  11:30 PM       100,470,848 gtap9ingams_001_e.gdx
05/26/2015  11:30 PM        20,980,890 implan.gdx
              12 File(s)    292,822,054 bytes
               2 Dir(s)  879,121,506,304 bytes free

irectory of d:\gtap9\data07

05/26/2015  11:31 PM         2,824,622 g20.gdx
05/26/2015  11:26 PM        39,816,021 gsd.gdx
05/20/2015  02:10 PM        81,809,972 gsddat.gdx
05/20/2015  02:10 PM           799,055 gsdemiss.gdx
05/20/2015  02:10 PM           166,533 gsdpar.gdx
05/20/2015  02:09 PM             3,543 gsdset.gdx
05/20/2015  02:10 PM         6,910,768 gsdtax.gdx
05/20/2015  02:10 PM         2,190,327 gsdvole.gdx
05/26/2015  11:28 PM        23,679,633 gsd_001.gdx
05/26/2015  11:29 PM        23,097,649 gtap9ingams_001.gdx
05/26/2015  11:30 PM       100,467,776 gtap9ingams_001_e.gdx
05/26/2015  11:30 PM        22,230,228 implan.gdx

Directory of d:\gtap9\data11

05/26/2015  11:31 PM         2,824,622 g20.gdx
05/26/2015  11:26 PM        39,260,351 gsd.gdx
05/20/2015  02:10 PM        81,360,267 gsddat.gdx
05/20/2015  02:10 PM           785,215 gsdemiss.gdx
05/20/2015  02:10 PM           166,533 gsdpar.gdx
05/20/2015  02:10 PM             3,543 gsdset.gdx
05/20/2015  02:10 PM         6,943,758 gsdtax.gdx
05/20/2015  02:10 PM         2,190,327 gsdvole.gdx
05/26/2015  11:28 PM        23,872,663 gsd_001.gdx
05/26/2015  11:29 PM        23,355,473 gtap9ingams_001.gdx
05/26/2015  11:30 PM       100,677,268 gtap9ingams_001_e.gdx
05/26/2015  11:30 PM        22,467,304 implan.gdx
