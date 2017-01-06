$title	FLEX2GDX.GMS	Read the FLEXAGG dataset gsddat.har and generate gsd.gdx

$if not set datadir $set datadir "c:\work\gtap\Gtap6inGAMS\data\"

$if exist gsddat.gdx $goto start

$if not exist %datadir%gsdset.har $goto missingfiles
$if not exist %datadir%gsddat.har $goto missingfiles
$if not exist %datadir%gsdpar.har $goto missingfiles
$if not exist %datadir%gsdvole.har $goto missingfiles
*$if not exist %datadir%gtap_v6_co2.har $goto missingfiles

$call 'har2gdx %datadir%gsdset.har  %datadir%gsdset.gdx'
$call 'har2gdx %datadir%gsddat.har  %datadir%gsddat.gdx'
$call 'har2gdx %datadir%gsdpar.har  %datadir%gsdpar.gdx'
$call 'har2gdx %datadir%gsdvole.har %datadir%gsdvole.gdx'
*$call 'har2gdx %datadir%gtap_v6_co2.har gsdco2.gdx'

$label start

set	i(*)	Goods
	f(*)	Factors
	r(*)	Regions 

$gdxin '%datadir%gsdset.gdx'
$load r=reg f=endw_comm i=prod_comm

set	trad_comm(i)	Traded commodities (excluding investment)
	cgd(i)		Investment good;

$load trad_comm

cgd(i) = yes$(not trad_comm(i));
abort$(card(cgd) <> 1) "Error -- expected only one investment good.";

set	src	Sources /domestic, imported/,
	rnum(r)	Numeraire region,
	sf(f)	Sluggish primary factors (sector-specific)
	mf(f)	Mobile primary factors
	ec	Energy goods /
		ecoa	Coal,
		eoil	Crude oil,
		egas	Natural gas,
		ep_c	Refined oil products,
		eely	Electricity
		egdt	Gas distribution /;

alias (r,s), (i,j,jj), (f,ff);

parameters
	vdga(i,r)	Government - domestic purchases at agents' prices,
	viga(i,r)	Government - imports at agents' prices,
	vdgm(i,r)	Government - domestic purchases at market prices,
	vigm(i,r)	Government - imports at market prices,
	vdpa(i,r)	Private households - domestic purchases at agents' prices,
	vipa(i,r)	Private households - imports at agents' prices,
	vdpm(i,r)	Private households - domestic purchases at market prices,
	vipm(i,r)	Private households - imports at market prices
	evoa(f,r)	Endowments - output at agents' prices,
	evfa(f,j,r)	Endowments - firms' purchases at agents' prices,
	vfm(f,j,r)	Endowments - Firms' purchases at market prices,
	vdfa(i,j,r)	Intermediates - firms' domestic purchases at agents' prices,
	vifa(i,j,r)	Intermediates - Firms' imports at agents' prices,
	vdfm(i,j,r)	Intermediates - firms' domestic purchases at market prices,
	vifm(i,j,r)	Intermediates - firms' imports at market prices,
	vims(i,r,s)	Trade - bilateral imports at market prices,
	viws(i,r,s)	Trade - bilateral imports at world prices,
	vxmd(i,r,s)	Trade - bilateral exports at market prices,
	vxwd(i,r,s)	Trade - bilateral exports at world prices,
	vst(i,r)	Trade - exports for international transportation
	vtwr(i,j,r,s)	Trade - Margins for international transportation at world prices
	ftrv(f,j,r)	Taxes - factor employment tax revenue,

	fbep(f,j,r)	Protection - factor-based subsidies,
	isep(i,j,r,src) Protection - intermediate input subsidies,
	osep(i,r)	Protection - ordinary output subsidies,
	adrv(i,r,s)	Protection - anti-dumping duty
	tfrv(i,r,s)	Protection - ordinary import duty
	purv(i,r,s)	Protection - price undertaking export tax equivalent,
	vrrv(i,r,s)	Protection - VER export tax equivalent
	mfrv(i,r,s)	Protection - MFA export tax equivalent
	xtrv(i,r,s)	Protection - ordinary export tax;

$gdxin '%datadir%gsddat.gdx'
$load vdga viga vdgm vigm vdpa vipa vdpm vipm evoa evfa vfm vdfa 
$load vifa vdfm vifm vims viws vxmd vxwd vst vtwr=vtwrini ftrv fbep isep 
$load osep adrv=adrev tfrv=tarifrev purv=purev vrrv=verrev mfrv=mfarev xtrv=xtrev
$gdxin

parameter
	esubd(i)	Elasticity of substitution (M versus D),
	esubva(j)	Elasticity of substitution between factors,
	esubm(i)	Intra-import elasticity of substitution,
	etrae(f)	Elasticity of transformation,
	incpar(i,r)	Expansion parameter in the CDE minimum expenditure function,
	subpar(i,r)	Substitution parameter in CDE minimum expenditure function;

$gdxin '%datadir%gsdpar.gdx'
$load esubd esubva esubm etrae incpar subpar
$gdxin

*	Determine which factors are sector-specific 

mf(f) = yes$(etrae(f)=0);
sf(f) = yes$(etrae(f)<0);
display mf,sf;

*	Convert sign of etrae() so that it is non-negative:

etrae(f) = -etrae(f);
etrae(mf) = +inf;

*	Scale the data:

scalar scalefactor /1e-3/;
vdga(i,r) = scalefactor * vdga(i,r);
viga(i,r) = scalefactor * viga(i,r);
vdgm(i,r) = scalefactor * vdgm(i,r);
vigm(i,r) = scalefactor * vigm(i,r);
vdpa(i,r) = scalefactor * vdpa(i,r);
vipa(i,r) = scalefactor * vipa(i,r);
vdpm(i,r) = scalefactor * vdpm(i,r);
vipm(i,r) = scalefactor * vipm(i,r);
evoa(f,r) = scalefactor * evoa(f,r);
evfa(f,j,r) = scalefactor * evfa(f,j,r);
vfm(f,j,r)  = scalefactor * vfm(f,j,r);
vdfa(i,j,r) = scalefactor * vdfa(i,j,r);
vifa(i,j,r) = scalefactor * vifa(i,j,r);
vdfm(i,j,r) = scalefactor * vdfm(i,j,r);
vifm(i,j,r) = scalefactor * vifm(i,j,r);
vims(i,r,s) = scalefactor * vims(i,r,s);
viws(i,r,s) = scalefactor * viws(i,r,s);
vxmd(i,r,s) = scalefactor * vxmd(i,r,s);
vxwd(i,r,s) = scalefactor * vxwd(i,r,s);
vst(i,r)    = scalefactor * vst(i,r);
vtwr(i,j,r,s) = scalefactor * vtwr(i,j,r,s);
ftrv(f,j,r) = scalefactor * ftrv(f,j,r);
fbep(f,j,r) = scalefactor * fbep(f,j,r);
isep(i,j,r,src) = scalefactor * isep(i,j,r,src);
osep(i,r)   = scalefactor * osep(i,r);
adrv(i,r,s) = scalefactor * adrv(i,r,s);
tfrv(i,r,s) = scalefactor * tfrv(i,r,s);
purv(i,r,s) = scalefactor * purv(i,r,s);
vrrv(i,r,s) = scalefactor * vrrv(i,r,s);
mfrv(i,r,s) = scalefactor * mfrv(i,r,s);
xtrv(i,r,s) = scalefactor * xtrv(i,r,s);

parameter
	evf(ec,i,r)	Volume of input purchases by firms (mtoe)
	evh(ec,r)	Volume of purchases by households (mtoe)
	evt(ec,r,r)	Volume of bilateral trade (mtoe);

$gdxin '%datadir%gsdvole.gdx'
$load evf evh evt
$gdxin

*	Read CO2 data if it is present:

set	srcs	Source /dom, imp/
	ghg	Greeenhouse gases /co2/
	as(*)	All sectors (includes i plus HH and GOVT);

$gdxin '%datadir%gsdco2.gdx'
$load as=allsec 

parameter	eghg(ghg,i,srcs,*,r)	Emissions of greenhouse gases (Gg CO2);
$load eghg
$gdxin
eghg(ghg,i,srcs,as,r)$(round(eghg(ghg,i,srcs,as,r),3)<=0.001) = 0;

parameter	co2(*,*)	Carbon dioxide global totals (Gg CO2);
co2(as,i) = sum((ghg,srcs,r), eghg(ghg,i,srcs,as,r));
co2("total",i) = sum(as, co2(as,i));
co2(as,"total") = sum(i, co2(as,i));
co2("total","total") = sum((i,as), co2(as,i));
display co2;

$label calcrates

*	Declare some intermediate arrays which are required to 
*	evaluate tax rates:

parameter	vdm(i,r)	Aggregate demand for domestic output,
		vom(i,r)	Total supply at market prices,
		voa(i,r)	Output at producer prices
		vdim(i,r)	Aggregate investment demand;

vdm(i,r) = vdpm(i,r) + vdgm(i,r) + sum{j, vdfm(i,j,r)};
vom(i,r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);
voa(j,r) = sum(f, evfa(f,j,r)) + sum(i, vdfa(i,j,r) + vifa(i,j,r));
vom(cgd,r) = voa(cgd,r);
vdim(cgd,r) =vom(cgd,r);

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

rto(i,r) = 1 - voa(i,r)/vom(i,r);
rtf(f,j,r)$vfm(f,j,r)  = evfa(f,j,r)/vfm(f,j,r) - 1;
rtpd(i,r)$vdpm(i,r)   = vdpa(i,r)/vdpm(i,r) - 1;
rtpi(i,r)$vipm(i,r)   = vipa(i,r)/vipm(i,r) - 1;
rtgd(i,r)$vdgm(i,r)   = vdga(i,r)/vdgm(i,r) - 1;
rtgi(i,r)$vigm(i,r)   = viga(i,r)/vigm(i,r) - 1;
rtfd(i,j,r)$vdfm(i,j,r) = vdfa(i,j,r)/vdfm(i,j,r) - 1;
rtfi(i,j,r)$vifm(i,j,r) = vifa(i,j,r)/vifm(i,j,r) - 1;
rtxs(i,r,s)$vxwd(i,r,s) = 1-vxwd(i,r,s)/vxmd(i,r,s);
rtms(i,r,s)$viws(i,r,s) = vims(i,r,s)/viws(i,r,s) - 1;

parameter	pvxmd(i,s,r)	Import price (power of benchmark tariff)
		pvtwr(i,s,r)	Import price for transport services;

pvxmd(i,s,r) = (1+rtms(i,s,r)) * (1-rtxs(i,s,r));
pvtwr(i,s,r) = 1+rtms(i,s,r);

parameter	
	vtw(j)		Aggregate international transportation services,
	vpm(r)		Aggregate private demand,
	vgm(r)		Aggregate public demand,
	vim(i,r)	Aggregate imports,
	evom(f,r)	Aggregate factor endowment at market prices,
	vb(*)		Current account balance;

vtw(j) = sum(r, vst(j,r));
vpm(r) = sum(i, vdpm(i,r)*(1+rtpd(i,r)) + vipm(i,r)*(1+rtpi(i,r)));
vgm(r) = sum(i, vdgm(i,r)*(1+rtgd(i,r)) + vigm(i,r)*(1+rtgi(i,r)));
vim(i,r) = vipm(i,r) + vigm(i,r) + sum(j, vifm(i,j,r));
evom(f,r) = sum(j, vfm(f,j,r));
vb(r) = vpm(r) + vgm(r) + sum(cgd,vom(cgd,r)) 
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

parameter	theta(i,r)	Final demand value shares;

theta(i,r) = (vdpm(i,r)*(1+rtpd(i,r))+vipm(i,r)*(1+rtpi(i,r))) /
	sum(j,vdpm(j,r)*(1+rtpd(j,r))+vipm(j,r)*(1+rtpi(j,r)));

parameter	eta(i,r)	Income elasticity of demand,
		epsilon(i,r)	Own-price elasticity of demand;

eta(i,r) = 1-subpar(i,r) - sum(j, theta(j,r)*(1-subpar(j,r))) +
	(1/sum(j,theta(j,r)*incpar(j,r))) * 
	  (incpar(i,r)*subpar(i,r) + sum(j,theta(j,r)*incpar(j,r)*(1-subpar(j,r))));
display eta;

epsilon(i,r)$theta(i,r)
	= (2*(1-subpar(i,r)) 
		- sum(j, theta(j,r)*(1-subpar(j,r))) 
		- (1-subpar(i,r)) / theta(i,r) - eta(i,r)) * theta(i,r);
display epsilon;

*	Define a numeraire region for denominating international
*	transfers:

rnum(r) = yes$(vpm(r)=smax(s,vpm(s)));
display rnum;

execute_unload '%datadir%gsd.gdx', r, f, i, vdgm, vigm, vdpm, vipm, vfm, vdfm, vifm, 
	vdim, vxmd, vst, vtwr, rto, rtf, rtpd, rtpi, rtgd, rtgi, rtfd, rtfi, rtxs, rtms,
	esubd, esubva, esubm, etrae, eta, epsilon, evf, evh, evt, eghg;

$call 'rm gsdset.gdx'
$call 'rm gsddat.gdx'
$call 'rm gsdpar.gdx'
$call 'rm gsdvole.gdx'
$call 'rm gsdco2.gdx'
$exit

$label missingfiles
$log.
$log.
$log.
$log	*** Error *** Missing files.
$log.
$log	Need to have the following files for this program:
$log.
$log		%datadir%gsdset.har 
$log		%datadir%gsddat.har 
$log		%datadir%gsdpar.har 
$log		%datadir%gsdvole.har 
$log		%datadir%gtap_v6_co2.har
$log.
$log	These are part of the flexagg distribution from GTAP6.
$log.
$log.
$log.
