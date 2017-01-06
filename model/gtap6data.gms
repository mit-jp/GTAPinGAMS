$title	GTAP6DATA.GMS	Read a GTAP 6 dataset

*	Initial creation data: 2 August 2005 (tfr)

*	Updates:

*	3 August 2005 - Introduced sets define sector-specific factors 
*	sf(f) and mobile factors mf(f) on the basis of elasticity 
*	etrae(f) which is read from default.prm.


$if not set ds $set ds china
$if not set datadir $set datadir "..\data\"
$setglobal datadir %datadir%
$if not set ghgdata $set ghgdata no
$setglobal ghgdata %ghgdata%

set	i(*)	Goods
	f(*)	Factors
	r(*)	Regions 

$if exist %ds%.gdx $gdxin '%ds%.gdx'
$if not exist %ds%.gdx $gdxin '%datadir%%ds%.gdx'
$load r f i

set
	rnum(r)	Numeraire region,
	sf(f)	Sluggish primary factors (sector-specific)
	mf(f)	Mobile primary factors
	src	Sources /domestic, imported/,
	ec	Energy goods /
		ecoa	Coal,
		eoil	Crude oil,
		egas	Natural gas,
		ep_c	Refined oil products,
		eely	Electricity,
		egdt	Gas distribution /;

alias (r,s), (i,j);

parameters
	vdgm(i,r)	Government - domestic purchases at market prices,
	vigm(i,r)	Government - imports at market prices,
	vdpm(i,r)	Private households - domestic purchases at market prices,
	vipm(i,r)	Private households - imports at market prices
	vdim(i,r)	Investment demand
	vfm(f,j,r)	Endowments - Firms' purchases at market prices,
	vdfm(i,j,r)	Intermediates - firms' domestic purchases at market prices,
	vifm(i,j,r)	Intermediates - firms' imports at market prices,
	vxmd(i,r,s)	Trade - bilateral exports at market prices,
	vst(i,r)	Trade - exports for international transportation
	vtwr(i,j,r,s)	Trade - Margins for international transportation at world prices;

$load vdgm vigm vdpm vipm vfm vdim
$load vdfm vifm vxmd vst vtwr 

parameter
	evf(ec,i,r)	Volume of input purchases by firms (mtoe)
	evh(ec,r)	Volume of purchases by households (mtoe)
	evt(ec,r,r)	Volume of bilateral trade (mtoe)
	evq(ec,r)	Energy production (mtoe);

$load evf evh evt
evq(ec,r) = sum(i, evf(ec,i,r)) + evh(ec,r) + sum(s, evt(ec,r,s)-evt(ec,s,r));

set	srcs	Source /dom, imp/,
	ghg	Greenhouse gases /co2/;

parameter	eghg(ghg,i,srcs,*,r)	Emissions of greenhouse gases (Gg CO2);
$if not %ghgdata%==no $load eghg
$if %ghgdata%==no eghg(ghg,i,srcs,j,r)=0; eghg(ghg,i,srcs,"hh",r)=0; eghg(ghg,i,srcs,"govt",r)=0;
display eghg;

parameter
	rto(i,r)	Output (or income) subsidy rates
	rtf(f,j,r)	Primary factor and commodity rates taxes 
	rtpd(i,r)	Private domestic consumption taxes
	rtpi(i,r)	Private import consumption tax rates
	rtgd(i,r)	Government domestic rates
	rtgi(i,r)	Government import tax rates
	rtfd(i,j,r)	Firms domestic tax rates
	rtfi(i,j,r)	Firms' import tax rates
	rtxs(i,r,s)	Export subsidy rates
	rtms(i,r,s)	Import taxes rates;

$load rto rtf rtpd rtpi rtgd rtgi rtfd rtfi rtxs rtms 

parameter
	esubd(i)	Elasticity of substitution (M versus D),
	esubva(j)	Elasticity of substitution between factors
	esubm(i)	Intra-import elasticity of substitution,
	etrae(f)	Elasticity of transformation,
	eta(i,r)	Income elasticity of demand,
	epsilon(i,r)	Own-price elasticity of demand;

$load esubd esubva esubm etrae eta epsilon

*	Declare some intermediate arrays which are required to 
*	evaluate tax rates:

parameter	vdm(i,r)	Aggregate demand for domestic output,
		vom(i,r)	Total supply at market prices;

vdm(i,r) = vdpm(i,r) + vdgm(i,r) + sum(j, vdfm(i,j,r)) + vdim(i,r);
vom(i,r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);

parameter
	rtf0(f,j,r)	Primary factor and commodity rates taxes 
	rtpd0(i,r)	Private domestic consumption taxes
	rtpi0(i,r)	Private import consumption tax rates
	rtgd0(i,r)	Government domestic rates
	rtgi0(i,r)	Government import tax rates
	rtfd0(i,j,r)	Firms domestic tax rates
	rtfi0(i,j,r)	Firms' import tax rates
	rtxs0(i,r,s)	Export subsidy rates
	rtms0(i,r,s)	Import taxes rates;

rtf0(f,j,r) = rtf(f,j,r);
rtpd0(i,r) = rtpd(i,r);
rtpi0(i,r) = rtpi(i,r);
rtgd0(i,r) = rtgd(i,r);
rtgi0(i,r) = rtgi(i,r);
rtfd0(i,j,r) = rtfd(i,j,r);
rtfi0(i,j,r) = rtfi(i,j,r);
rtxs0(i,r,s) = rtxs(i,r,s);
rtms0(i,r,s) = rtms(i,r,s);

parameter	pvxmd(i,s,r)	Import price (power of benchmark tariff)
		pvtwr(i,s,r)	Import price for transport services;

pvxmd(i,s,r) = (1+rtms0(i,s,r)) * (1-rtxs0(i,s,r));
pvtwr(i,s,r) = 1+rtms0(i,s,r);

parameter	bmkprofit(i,r)	Zero profit check;

bmkprofit(i,r) = round(vom(i,r)*(1-rto(i,r)) 
		- sum(j, vdfm(j,i,r)*(1+rtfd(j,i,r))+vifm(j,i,r)*(1+rtfi(j,i,r)))
		- sum(f, vfm(f,i,r)*(1+rtf(f,i,r))), 8);
display bmkprofit;

parameter	
	vtw(j)		Aggregate international transportation services,
	vpm(r)		Aggregate private demand,
	vgm(r)		Aggregate public demand,
	vim(i,r)	Aggregate imports,
	evom(f,r)	Aggregate factor endowment at market prices,
	vb(*)		Current account balance;

vtw(j) = sum(r, vst(j,r));
vpm(r) = sum(i, vdpm(i,r)*(1+rtpd0(i,r)) + vipm(i,r)*(1+rtpi0(i,r)));
vgm(r) = sum(i, vdgm(i,r)*(1+rtgd0(i,r)) + vigm(i,r)*(1+rtgi0(i,r)));
vim(i,r) = vipm(i,r) + vigm(i,r) + sum(j, vifm(i,j,r));
evom(f,r) = sum(j, vfm(f,j,r));
vb(r) = vpm(r) + vgm(r) + sum(i,vdim(i,r)) 
	- sum(f, evom(f,r))
	- sum(j,  vom(j,r)*rto(j,r))
	- sum(j,  sum(i, vdfm(i,j,r)*rtfd(i,j,r) + vifm(i,j,r)*rtfi(i,j,r)))
	- sum(j,  sum(f, vfm(f,j,r)*rtf(f,j,r)))
	- sum(i, vdpm(i,r)*rtpd(i,r) + vipm(i,r)*rtpi(i,r))
	- sum(i, vdgm(i,r)*rtgd(i,r) + vigm(i,r)*rtgi(i,r))
	- sum((i,s), rtms(i,s,r) *  (vxmd(i,s,r) * (1-rtxs(i,s,r)) + sum(j,vtwr(j,i,s,r))))
	+ sum((i,s), rtxs(i,r,s) * vxmd(i,r,s));

vb("chksum") = sum(r, vb(r));
display vb;

*	Determine which factors are sector-specific 

mf(f) = yes$(1/etrae(f)=0);
sf(f) = yes$(1/etrae(f)>0);
display mf,sf;

*	Define a numeraire region for denominating international
*	transfers:

rnum(r) = yes$(vpm(r)=smax(s,vpm(s)));
display rnum;
