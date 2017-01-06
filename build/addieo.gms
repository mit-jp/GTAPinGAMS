$title	Program merges the IEO and CIESIN projection data 

*	For the time being we omit: IEA, EPA

set yrs /1751*2100/;

*	Need to add non-CO2 greenhouse gas emissions

$if not set byr	$set byr 2007

*	Read the GTAP dataset:
$if not set ds $set ds gtap9ingams_001

$include gtap9data


*	Read the latest International Energy Outlook (IEO) by the Energy Information Adminstration (EIA) which 
*	provides provides long-term projections for GDP, energy demand, oil prices
*	http://www.eia.gov/forecasts/ieo/more_highlights.cfm


set	scn	IEO scenarios	 /
		ref		Reference case,
		high_oil	High oil price,
		low_oil		Low oil price,
		high_gdp	High GDP growth,
		low_gdp		Low GDP growth /,

	yr	Years			/1990*2100/,
	eg(i)	Final energy goods	/ele,col,oil,gdt,gas/,
	fd	Final demand sectors	/Residential, Commercial, Industrial, ElectricPower, Transportation/,
	ieo_tec	IEO technologies /
			capacity	Generating Capacity
			oilcap		Liquids-Fired Generating Capacity
			gascap		Natural-Gas-Fired Generating Capacity
			colcap		Coal-Fired Generating Capacity
			nuccap		Nuclear Generating Capacity
			hydrocap	Hydroelectric Renewable Generating Capacity,
			windcap		Wind-Powered Generating Capacity,
			geocap		Geothermal Generating Capacity,
			othrnwcap	Other Renewable Generating Capacity,
			solcap		Solar Generating Capacity,
			
			generation	Net Electricity Generation,
			oilgen		Net Liquids-Fired Electricity Generation,
			gasgen		Net Natural-Gas-Fired Electricity Generation,
			colgen		Net Coal-Fired Electricity Generation,
			nucgen		Net Nuclear Electricity Generation,
			hydrogen        Net Hydroelectric Generation,
			windgen	        Net Wind-Powered Electricity Generation,
			geogen	        Net Geothermal Electricity Generation,
			othrnwgen	Net Other Renewable Electricity Generation, 
			solgen		Net Solar Electricity Generation /,
	t	Projected and historical time periods / 
			2004*2050, 2055,2060,2065,2070, 2075, 2080, 2085, 2090, 2095, 2100
			/;

parameter	ieocarbon(scn,*,r,t)		IEO Carbon emissions by scenario (index -- %byr%=1),
		ieogdp(scn,r,t)			IEO GDP by scenario (index -- %byr%=1),
		ieocrude(scn,r,t)		IEO Crude oil equivalent supply (index -- %byr%=1),
		ieoelesup(scn,r,t)		IEO electricity supply (index -- %byr%=1),
		ieoenergy(scn,*,fd,r,t)		IEO energy use by sector (index -- %byr%=1),
		ieoprice(scn,t)			IEO oil prices (index -- %byr%=1), 
		ieoele(scn,ieo_tec,r,t)		IEO electricity generation and capacity (index -- %byr%=1),
		unpop(r,*)			UN population trajectories (in millions);

$gdxin ..\ieo2013\gdx\ieo_gtap9_2100_%byr%.gdx
$loaddc ieocarbon ieogdp ieocrude ieoelesup ieoele ieoenergy ieoprice unpop

*	Scale GDP  proportionally:
parameter ieogdp_;
ieogdp_(scn,r,t) = ieogdp(scn,r,t) * (vom("c",r) + vom("g",r) + vom("i",r) - vb(r));

*	Convert emissions, gdp and crude oil projections to common units:

parameter       cecphys(i)      carbon emission coefficients for physical units 
                                /col 0.024, gas 0.0137, oil 0.0181 /;

set fdmap(g,eg,fd) Correspondence between GTAP sectors and IEO demand categories

*	Use transportation for oil demand:

	/	c.(ele,gas,col).Residential, 
		(otp,wtp,atp,c).oil.Transportation, 
		ele.(col,gas,oil).ElectricPower, 
		(trd,obs,ros,osg,isr,ofi).(ele,col,oil,gas).Commercial/;

fdmap(i,eg,"Industrial")$(sum(fdmap(i,eg,fd),1)=0) = yes;

*	Convert carbon to a scenario and sectorally-indexed parameter:

*	Aggregate domestic and imported CO2 emissions
parameter	eco2(i,g,r)	Composite of domestic and imported CO2 emissions - Mt of CO2 ;
eco2(i,g,r) = eco2d(i,g,r) + eco2i(i,g,r); 


parameter	ieoenergy_(scn,i,g,r,t)	Sectoral energy use;

*	By default energy demand grows with GDP index
ieoenergy(scn,eg(i),fd,r,t)$(ieoenergy(scn,i,fd,r,t) = 0) = ieogdp(scn,r,t);

ieoenergy_(scn,eg(i),g,r,t)	 = evd(i,g,r) * sum(fdmap(g,eg,fd), ieoenergy(scn,i,fd,r,t));

*	Use the growth rate of natural gas emissions to index growth in carbon emissions associated with GDT:
ieocarbon(scn,"gdt",r,t) = ieocarbon(scn,"gas",r,t);
ieocarbon(scn,eg(i),r,t) = sum(g,eco2(i,g,r)) * ieocarbon(scn,i,r,t);

parameter debugchk;
debugchk(eg(i),r,"GTAP")= sum(g, eco2(i,g,r));
debugchk(eg(i),r,"IEO")	= ieocarbon("ref",i,r,"%byr%");
display debugchk;


*	Convert electricty production from growth indices into total values
*	(for subsequent aggregation using aggr.gms)
parameter	eprd	Energy production levels;
eprd(r,i) = max(0,sum(g,(evd(i,g,r) + evi(i,g,r))) + sum(s,evt(i,r,s)-evt(i,s,r)));
display eprd;

parameter ieocrude_	IEO crude oil production;
ieocrude_(scn,r,t) = ieocrude(scn,r,t) * eprd(r,"cru");

ieoelesup(scn,r,t) = eprd(r,"ele")* ieoelesup(scn,r,t); 	



*       Move the dataset into a GDX archive:

$if %byr%==2011	$set app 11
$if %byr%==2007	$set app 07
$if %byr%==2004	$set app 04


execute_unload '..\data%app%\%ds%_e.gdx', 
	g, r, f, i, 
	vfm, vdfm, vifm, vxmd, vst, vtwr,
	evi, evd, evt, eco2d, eco2i, 
	rto, rtf, rtfd, rtfi, rtxs, rtms, 
	esubd, esubva, esubm, etrae, eta, epsilon,
	ieocarbon, ieogdp_=ieogdp, ieocrude_=ieocrude, ieoelesup, ieoenergy_=ieoenergy, ieoprice, ieoele, 
	unpop 
