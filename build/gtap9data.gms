$title	GAMS Code to Read a GTAP 9 Dataset

$if not set nd $set nd 0

scalar nd	Number of decimals /%nd%/;
abort$(nd<>round(nd)) "Number of decimals must be an integer";

$if not set ds $set ds gsd
$if not set yr $set yr 07
$if not set datadir $set datadir "..\data%yr%\"
$setglobal datadir %datadir%

set	g(*)	Goods plus C and G;
$if exist     %ds%.gdx $gdxin "%ds%.gdx"
$if not exist %ds%.gdx $gdxin "%datadir%%ds%.gdx"
$load g

set	i(g)	Goods
	f(*)	Factors;
$load f i 
$if declared hs6 $load hs6
$if not defined r	set r(*)	Regions;
$if not defined r	$load r


set	rnum(r)	Numeraire region,
	sf(f)	Sluggish primary factors (sector-specific),
	mf(f)	Mobile primary factors;

alias (r,s), (i,j);

display r;
parameters
	vfm(f,g,r)	Endowments - Firms' purchases at market prices,
	vdfm(i,g,r)	Intermediates - firms' domestic purchases at market prices,
	vifm(i,g,r)	Intermediates - firms' imports at market prices,
	vxmd(i,r,s)	Trade - bilateral exports at market prices,
	vst(i,r)	Trade - exports for international transportation
$if declared hs6	viws_hs6(i,hs6,r,s)	Bilateral trade at world prices (HS6 goods)
	vtwr(i,j,r,s)	Trade - Margins for international transportation at world prices;

$load vfm vdfm vifm vxmd vst vtwr 
$if declared hs6 $load viws_hs6 

if (nd>0,
	vfm(f,g,r) = vfm(f,g,r)$round(vfm(f,g,r),nd);
	vdfm(i,g,r) = vdfm(i,g,r)$round(vdfm(i,g,r),nd);
	vifm(i,g,r) = vifm(i,g,r)$round(vifm(i,g,r),nd);
	vxmd(i,r,s) = vxmd(i,r,s)$round(vxmd(i,r,s),nd);
	vst(i,r) = vst(i,r)$round(vst(i,r),nd);
	vtwr(i,j,r,s) = vtwr(i,j,r,s)$round(vtwr(i,j,r,s),nd);
$if declared hs6	viws_hs6(i,hs6,r,s) = viws_hs6(i,hs6,r,s)$round(viws_hs6(i,hs6,r,s),nd);
);

parameter
	evt(i,r,r)	Volume of energy trade (mtoe),
	evd(i,g,r)	Domestic energy use (mtoe),
	evi(i,g,r)	Imported energy use (mtoe),
	eco2d(i,g,r)	CO2 emissions in domestic fuels - Mt CO2",
	eco2i(i,g,r)	CO2 emissions in foreign fuels - Mt CO2";

$loaddc evd evi evt eco2d eco2i
if (nd>0,
	evt(i,r,s)  = evt(i,r,s)$round(evt(i,r,s), nd);
	evd(i,g,r) = evd(i,g,r)$round(evd(i,g,r), nd);
	evi(i,g,r) = evi(i,g,r)$round(evi(i,g,r), nd);
	eco2d(i,g,r) = eco2d(i,g,r)$round(eco2d(i,g,r), nd);
	eco2i(i,g,r) = eco2i(i,g,r)$round(eco2i(i,g,r), nd);
);

parameter
	rto(g,r)	Output (or income) subsidy rates
	rtf(f,g,r)	Primary factor and commodity rates taxes 
	rtfd(i,g,r)	Firms domestic tax rates
	rtfi(i,g,r)	Firms' import tax rates
	rtxs(i,r,s)	Export subsidy rates
$if declared hs6	rtms_hs6(hs6,r,s)	Bilateral tariff rates
	rtms(i,r,s)	Import taxes rates;

$load rto rtf rtfd rtfi rtxs rtms 
$if declared hs6 $load rtms_hs6

if (nd>0,
	rto(g,r) = rto(g,r)$round(rto(g,r),nd);
	rtf(f,g,r) = rtf(f,g,r)$round(rtf(f,g,r),nd);
	rtfd(i,g,r) = rtfd(i,g,r)$round(rtfd(i,g,r),nd);
	rtfi(i,g,r) = rtfi(i,g,r)$round(rtfi(i,g,r),nd);
	rtxs(i,r,s) = rtxs(i,r,s)$round(rtxs(i,r,s),nd);
	rtms(i,r,s) = rtms(i,r,s)$round(rtms(i,r,s),nd);
$if declared hs6  rtms_hs6(hs6,r,s) = rtms_hs6(hs6,r,s)$round(rtms_hs6(hs6,r,s),nd);
);
parameter
	esubd(i)	Elasticity of substitution (M versus D),
	esubva(g)	Elasticity of substitution between factors
	esubm(i)	Intra-import elasticity of substitution,
	etrae(f)	Elasticity of transformation,
	eta(i,r)	Income elasticity of demand,
	epsilon(i,r)	Own-price elasticity of demand;

$load esubd esubva esubm etrae eta epsilon

*	Declare some intermediate arrays which are required to 
*	evaluate tax rates:

parameter	vdm(g,r)	Aggregate demand for domestic output,
		vom(g,r)	Total supply at market prices;

vdm(i,r) = sum(g, vdfm(i,g,r));
vom(i,r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);

parameter
	rtf0(f,g,r)	Primary factor and commodity rates taxes 
	rtfd0(i,g,r)	Firms domestic tax rates
	rtfi0(i,g,r)	Firms' import tax rates
	rtxs0(i,r,s)	Export subsidy rates
	rtms0(i,r,s)	Import taxes rates;

rtf0(f,g,r) = rtf(f,g,r);
rtfd0(i,g,r) = rtfd(i,g,r);
rtfi0(i,g,r) = rtfi(i,g,r);
rtxs0(i,r,s) = rtxs(i,r,s);
rtms0(i,r,s) = rtms(i,r,s);

parameter	pvxmd(i,s,r)	Import price (power of benchmark tariff)
		pvtwr(i,s,r)	Import price for transport services;

pvxmd(i,s,r) = (1+rtms0(i,s,r)) * (1-rtxs0(i,s,r));
pvtwr(i,s,r) = 1+rtms0(i,s,r);

parameter	
	vtw(j)		Aggregate international transportation services,
	vpm(r)		Aggregate private demand,
	vgm(r)		Aggregate public demand,
	vim(i,r)	Aggregate imports,
	evom(f,r)	Aggregate factor endowment at market prices,
	vb(*)		Current account balance;

vtw(j) = sum(r, vst(j,r));
vom("c",r) = sum(i, vdfm(i,"c",r)*(1+rtfd0(i,"c",r)) + vifm(i,"c",r)*(1+rtfi0(i,"c",r)))/(1-rto("c",r));
vom("g",r) = sum(i, vdfm(i,"g",r)*(1+rtfd0(i,"g",r)) + vifm(i,"g",r)*(1+rtfi0(i,"g",r)))/(1-rto("g",r));
vom("i",r) = sum(i, vdfm(i,"i",r)*(1+rtfd0(i,"i",r)) + vifm(i,"i",r)*(1+rtfi0(i,"i",r)))/(1-rto("i",r));

vdm("c",r) = vom("c",r);
vdm("g",r) = vom("g",r);
vim(i,r) =  sum(g, vifm(i,g,r));
evom(f,r) = sum(g, vfm(f,g,r));
vb(r) = vom("c",r) + vom("g",r) + vom("i",r) 
	- sum(f, evom(f,r))
	- sum(g,  vom(g,r)*rto(g,r))
	- sum(g,  sum(i, vdfm(i,g,r)*rtfd(i,g,r) + vifm(i,g,r)*rtfi(i,g,r)))
	- sum(g,  sum(f, vfm(f,g,r)*rtf(f,g,r)))
	- sum((i,s), rtms(i,s,r) *  (vxmd(i,s,r) * (1-rtxs(i,s,r)) + sum(j,vtwr(j,i,s,r))))
	+ sum((i,s), rtxs(i,r,s) * vxmd(i,r,s));

vb("chksum") = sum(r, vb(r));
display vb;

*	Determine which factors are sector-specific 

mf(f) = yes$(1/etrae(f)=0);
sf(f) = yes$(1/etrae(f)>0);
display mf,sf;

parameter       mprofit Zero profit for m,
                yprofit Zero profit for y;

mprofit(i,r) = vim(i,r) - sum(s, pvxmd(i,s,r)*vxmd(i,s,r)+sum(j, vtwr(j,i,s,r))*pvtwr(i,s,r));
mprofit(i,r) = round(mprofit(i,r),5);
display mprofit;

yprofit(g,r) = vom(g,r)*(1-rto(g,r))
	- sum(i, vdfm(i,g,r)*(1+rtfd0(i,g,r))
               + vifm(i,g,r)*(1+rtfi0(i,g,r))) 
        - sum(f, vfm(f,g,r)*(1+rtf0(f,g,r)));

yprofit(g,r) = round(yprofit(g,r),6)
display yprofit;

*	Define a numeraire region for denominating international
*	transfers:

rnum(r) = yes$(vom("c",r)=smax(s,vom("c",s)));
display rnum;

$if not set energydata $exit

*	Read the IEO energy statistics and baseline growth path:

*.$if not defined ieoscn set ieoscn	IEO scenarios	 /ref,high_oil,low_oil,high_gdp,low_gdp/;

set	t	Projected and historical time periods / 2004*2050, 2055,2060,2065,2070, 2075, 2080, 2085, 2090, 2095, 2100 /,

	scn	IEO scenarios	 /
		ref		Reference case,
		high_oil	High oil price,
		low_oil		Low oil price,
		high_gdp	High GDP growth,
		low_gdp		Low GDP growth /,

*.	eg(i)	Final energy goods	/ele,col,oil,gdt,gas/,
	eg(i)	Final energy goods	/ele,col,oil,gas/,

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
			solgen		Net Solar Electricity Generation /;


parameter	
	ieocarbon(scn,*,r,t)		IEO carbon emissions by scenario (index -- %byr%=1),
	ieogdp(scn,r,t)			IEO GDP by scenario (index -- %byr%=1),
	ieocrude(scn,r,t)		IEO crude oil supply (index -- %byr%=1),
	ieoelesup(scn,r,t)		IEO electricity supply (index -- %byr%=1),
	ieoenergy(scn,i,g,r,t)		IEO energy use by sector (index -- %byr%=1),
	ieoprice(scn,t)			IEO oil price (index -- %byr%=1), 
	ieoele(scn,ieo_tec,r,t)		IEO electricity generation and capacity (index -- %byr%=1),
	unpop(r,*)			UN population trajectories (in millions);

$load ieocarbon ieogdp ieocrude ieoelesup ieoprice ieoenergy ieoele unpop

