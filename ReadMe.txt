********************************************************************
*  Documentation of GTAP7 buildstream with IEO-IEA-EPA Projections
********************************************************************

------------------------------------------------------------------------
NB
------------------------------------------------------------------------

1. The following files must be copied from a standard GTAP7.1
distribution into the gtapdata directory before the GTAP7 data may be
built:

  17-May-2010  11:55:20a          7,500   gsdset.har
  17-May-2010  11:54:50a         65,374   gsdpar.har
  17-May-2010  11:56:26a     26,088,082   gsdview.har
  17-May-2010  11:54:04a     26,755,027   gsddat.har

2. A QCP solver such as CPLEX is used in filter.gms.  It may be
possible to use CONOPT or PATHNLP for this purpose, but I am not sure.

3. Directories with sattelite energy data are provided, but we have
not yet produced a documented canonical energy-economy model which
employs these data.  Perhaps later in 2011.

4. This version of the build stream is based on the GTAP 7.1 dataset 
from which Myanmar has been removed.
 
------------------------------------------------------------------------

The standard GTAP7inGAMS package is based on three directories

- build: includes the central GAMS routines for data filtering and
data aggregation (see below) 

- data: includes the gdx-files that are either used as the source data
for data aggregation or the target data emerging fro the data
aggregation

- defines: includes alternative mapping definitions for aggregation of
regions, sectors, and factors

-doc: includes documentation for various components of the GTAPinGAMS package.

-model: includes two canonical static models based on the GTAP model,
in in MGE and the other in MCP format.

********************************************************************

For the inclusion of additional data with growth projections, energy
and emission baselines, population growth etc. there are four
additional directories with satellite data:

- ciesin:	UN population statistics
- epa:		EPA data on marginal abatement cost curves and baseline emissions up to 2020 for non-CO2 GHG
- iea2006:	International Energy Annual data by DOE from 1980-2006
- ieo2008:	International Energy Outlook 2008 by DOE up to 2030
- ieo2009:	International Energy Outlook 2009 by DOE up to 2030

Within all the satellite directories (ciesin, epa, iea2006, ieo2009)
there is a uniform structure: The root of the directories features the
routines for extracting and transforming data. Raw (original) data is
i.g. provided within subdirectory XLS. The transformed data is written
into subdirectory GDX.  Documentation on data and routines is provided
in subdirectory DOC.

All steps to produce aggregated datasets from the GTAP raw data set
gsddat.har are processed within the batch routine make.bat.

==> make.bat

We first read in the GTAP master data file gsddat.har and transform it
into the GAMS data exchange file gsd.gdx 

>> gams flex2gdx 

Next we filter the GTAP gdx-file to suppress tiny values that will
create numerical solution problems in standard GTAP model
applications. We can specify a tolerance parameter for filtering the
data The tolerance is provided as a percentage share of some reference
value such as the output value of production (--tol=001 leads to a
tolerance of 0.1 %)

>> gams filter --tol=001  o=debug.lst s=filter_001


We then create a full dimensional version of GTAP7 featuring the whole
database dimensionality.  The generated gdx-output is labeld as
gtap7ingams and dumped into ..\data

>> gams gtapaggr --source=gsd_001 --target=gtap7ingams

Next we introduce the IEO, IEO, and EPA data to produce gtap7ingams_e,
that is we generate a comprehensive GTAP dataset with IEO baseline
projections on future GDP growth and energy demand as well as EPA
projections on non-CO2 GHG marginal abatement cost and baseline
emissions

>> gams addieo

We may then want to generate some more aggregate master file on
energy-emission-economy-data that we use as a source file for
subsequent mappings towards datasets destined for energy policy/
climate policy analysis at different sectoral and regional levels. We
refer to this master file as gtap7iea which reduces the number of
sectors in the original GTAP7 data set from 59 to 24 sectors thereby
keeping track of all the primary and secondary energy sectors as well
as important non-energy energy-intensive sectors.

	set	ii	Goods in the IEA classification /
	GAS	Natural gas works,
	ELE	Electricity and heat ,
	OIL	Refined oil products,
	COL	Coal transformation,
	CRU	Crude oil,
	I_S	Iron and steel industry (IRONSTL),
	CRP	Chemical industry (CHEMICAL),
	NFM	Non-ferrous metals (NONFERR),
	NMM	Non-metallic minerals (NONMET),
	TEQ	Transport equipment (TRANSEQ),
	OME	Other machinery (MACHINE),
	OMN	Mining (MINING),
	FPR	Food products (FOODPRO),
	PPP	Paper-pulp-print (PAPERPRO),
	LUM	Wood and wood-products (WOODPRO),
	CNS	Construction (CONSTRUC),
	TWL	Textiles-wearing apparel-leather (TEXTILES),
	OMF	Other manufacturing (INONSPEC),
	AGR	Agricultural products,
	TRN	Transport,
	ATP	Air transport,
	SER	Commercial and public services,
	DWE	Dwellings,
	CGD	Investment composite /;
	
Note:	We can always go back to the fully disaggregated dataset gtap7ingams_e if
	we prefer a more disaggregate view on some sectors (e.g. agriculture)

>> gams gtapaggr --source=gtap7ingams_e --target=gtap7iea --energydata=yes o=gtap7iea.lst


