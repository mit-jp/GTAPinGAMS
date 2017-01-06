$title	FLEX2GDX.GMS	Read the FLEXAGG dataset gsddat.har and generate gsd.gdx

$set nco2

$if not set nd $set nd 0

scalar nd	Number of decimals /%nd%/;
abort$(nd<>round(nd)) "Number of decimals must be an integer";

$if not set datadir $set datadir "..\data\"
$if not set gtapdatadir $set gtapdatadir "..\gtapdata\"

$if exist %datadir%gsddat.gdx $goto start

*	Translate HAR files into GDX:

$if not exist %gtapdatadir%gsdset.har $goto missingharfiles
$if not exist %gtapdatadir%gsddat.har $goto missingharfiles
$if not exist %gtapdatadir%gsdpar.har $goto missingharfiles
$if not exist %gtapdatadir%gsdvole.har $goto missingharfiles

*	This file comes from GTAP Resouce #1143:
*	See https://www.gtap.agecon.purdue.edu/resources/download/4139.zip
$if not exist %gtapdatadir%gtap_co2_v7.har $goto missingharfiles

$if not set nco2 $goto har2gdx

$if not exist %gtapdatadir%gtp_nco2_mmtceq_v7.har $goto missingharfiles

$label har2gdx
$call 'har2gdx %gtapdatadir%gsdset.har %datadir%gsdset.gdx'
$call 'har2gdx %gtapdatadir%gsddat.har %datadir%gsddat.gdx'
$call 'har2gdx %gtapdatadir%gsdpar.har %datadir%gsdpar.gdx'
$call 'har2gdx %gtapdatadir%gsdvole.har %datadir%gsdvole.gdx'
$call 'har2gdx %gtapdatadir%gtap_co2_v7.har %datadir%gtap_co2_v7.gdx'
$if set nco2 $call 'har2gdx %gtapdatadir%gtp_nco2_mmtceq_v7.har %datadir%gtp_nco2_mmtceq_v7.gdx'

$label start

$if not exist %datadir%gsdset.gdx $goto missinggdxfiles
$if not exist %datadir%gsddat.gdx $goto missinggdxfiles
$if not exist %datadir%gsdpar.gdx $goto missinggdxfiles
$if not exist %datadir%gsdvole.gdx $goto missinggdxfiles
$if not exist %datadir%gtap_co2_v7.gdx $goto missinggdxfiles

$onecho >setx.gms
$gdxin '%datadir%gsdset.gdx'
set	i(*)	Goods;
$load i=prod_comm
set x(*)/c,g,i/;
x(i) = yes;
$offecho
$call gams setx gdx=setx

set	x(*)	All goods plus C - G - i and CGDS;
$gdxin 'setx.gdx'
$load x
$gdxin
$call del /q setx.gdx

set	g(x) 	All goods plus C - G - i /c,g,i/,
	i(x)	Market goods,
	f(*)	Factors,
	r(*)	Regions ;

$gdxin '%datadir%gsdset.gdx'
$load r=reg f=endw_comm i=trad_comm
g(i) =yes;

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
	evfa(f,x,r)	Endowments - firms' purchases at agents' prices,
	vfm(f,x,r)	Endowments - Firms' purchases at market prices,
	vdfa(i,x,r)	Intermediates - firms' domestic purchases at agents' prices,
	vifa(i,x,r)	Intermediates - Firms' imports at agents' prices,
	vdfm(i,x,r)	Intermediates - firms' domestic purchases at market prices,
	vifm(i,x,r)	Intermediates - firms' imports at market prices,
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
	esubd(x)	Elasticity of substitution (M versus D),
	esubva(x)	Elasticity of substitution between factors,
	esubm(x)	Intra-import elasticity of substitution,
	etrae(f)	Elasticity of transformation,
	incpar(x,r)	Expansion parameter in the CDE minimum expenditure function,
	subpar(x,r)	Substitution parameter in CDE minimum expenditure function;

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
vdfa(i,x,r) = scalefactor * vdfa(i,x,r);
vifa(i,x,r) = scalefactor * vifa(i,x,r);
vdfm(i,x,r) = scalefactor * vdfm(i,x,r);
vifm(i,x,r) = scalefactor * vifm(i,x,r);
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

*	Drop tiny numbers:

if (nd>0,
	vdga(i,r) = vdga(i,r)$round(vdga(i,r),nd);
	viga(i,r) = viga(i,r)$round(viga(i,r),nd);
	vdgm(i,r) = vdgm(i,r)$round(vdgm(i,r),nd);
	vigm(i,r) = vigm(i,r)$round(vigm(i,r),nd);
	vdpa(i,r) = vdpa(i,r)$round(vdpa(i,r),nd);
	vipa(i,r) = vipa(i,r)$round(vipa(i,r),nd);
	vdpm(i,r) = vdpm(i,r)$round(vdpm(i,r),nd);
	vipm(i,r) = vipm(i,r)$round(vipm(i,r),nd);
	evoa(f,r) = evoa(f,r)$round(evoa(f,r),nd);
	evfa(f,j,r) = evfa(f,j,r)$round(evfa(f,j,r),nd);
	vfm(f,j,r) = vfm(f,j,r)$round(vfm(f,j,r),nd);
	vdfa(i,x,r) = vdfa(i,x,r)$round(vdfa(i,x,r),nd);
	vifa(i,x,r) = vifa(i,x,r)$round(vifa(i,x,r),nd);
	vdfm(i,x,r) = vdfm(i,x,r)$round(vdfm(i,x,r),nd);
	vifm(i,x,r) = vifm(i,x,r)$round(vifm(i,x,r),nd);
	vims(i,r,s) = vims(i,r,s)$round(vims(i,r,s),nd);
	viws(i,r,s) = viws(i,r,s)$round(viws(i,r,s),nd);
	vims(i,r,s) = vims(i,r,s)$viws(i,r,s);
	vxmd(i,r,s) = vxmd(i,r,s)$round(vxmd(i,r,s),nd);
	vxwd(i,r,s) = vxwd(i,r,s)$round(vxwd(i,r,s),nd);
	vxwd(i,r,s) = vxwd(i,r,s)$vxmd(i,r,s);

	vst(i,r) = vst(i,r)$round(vst(i,r),nd);
	vtwr(i,j,r,s) = vtwr(i,j,r,s)$round(vtwr(i,j,r,s),nd);
	ftrv(f,j,r) = ftrv(f,j,r)$round(ftrv(f,j,r),nd);
	fbep(f,j,r) = fbep(f,j,r)$round(fbep(f,j,r),nd);
	isep(i,j,r,src) = isep(i,j,r,src)$round(isep(i,j,r,src),nd);
	osep(i,r) = osep(i,r)$round(osep(i,r),nd);
	adrv(i,r,s) = adrv(i,r,s)$round(adrv(i,r,s),nd);
	tfrv(i,r,s) = tfrv(i,r,s)$round(tfrv(i,r,s),nd);
	purv(i,r,s) = purv(i,r,s)$round(purv(i,r,s),nd);
	vrrv(i,r,s) = vrrv(i,r,s)$round(vrrv(i,r,s),nd);
	mfrv(i,r,s) = mfrv(i,r,s)$round(mfrv(i,r,s),nd);
	xtrv(i,r,s) = xtrv(i,r,s)$round(xtrv(i,r,s),nd);
);

parameter
	evf_(ec,i,r)	Volume of input purchases by firms (mtoe)
	evh_(ec,r)	Volume of purchases by households (mtoe)
	evt_(ec,r,r)	Volume of bilateral trade (mtoe);

$gdxin '%datadir%gsdvole.gdx'
$load evf_=evf evh_=evh evt_=evt
$gdxin

set	nco2		Non-carbon greenhouse gases /
			n2o	Nitrous oxide,
			ch4	Methane,
			fgas	Fluorocarbons and sulfur hexafluoride /;

parameter
	nc_hh(nco2,i,r)		Non-CO2 greenhouse gas emissions associated with input use by househods (MM ton of C-eq)
	nc_qo(nco2,i,r)		Non-CO2 greenhouse gas emissions associated with industries  (MM ton of C-eq)
	nc_endw(nco2,f,i,r)	Non-CO2 greenhouse gas emissions associated with endowments  (MM ton of C-eq),
	nc_trad(nco2,i,j,r)	Non-CO2 greenhouse gas emissions associated with input use by industry  (MM ton of C-eq);

$if     set nco2 $gdxin '%datadir%gtp_nco2_mmtceq_v7.gdx'

*	Load without domain checking -- version 7.1 drops the MMR region, but this is in the dataset:

$if     set nco2 $load	nc_hh=nc_hh_ceq nc_qo=nc_qo_ceq nc_endw=nc_endw_ceq nc_trad=nc_trad_ceq 
$if not set nco2 nc_hh(nco2,i,r) = 0; nc_qo(nco2,i,r) = 0; nc_endw(nco2,f,i,r) = 0; nc_trad(nco2,i,j,r) = 0;

set	ghg		Greenhouse gases in this dataset /co2/
	fdlabels	Final demand labels /hh,govt/;

parameter	eghg(ghg,ec,*,r)	Emissions of greenhouse gases (Gg);
$gdxin '%datadir%gtap_co2_v7.gdx'
$load eghg

*	Declare some intermediate arrays which are required to 
*	evaluate tax rates:

parameter	vdm(i,r)	Aggregate demand for domestic output,
		vom(x,r)	Total supply at market prices,
		voa(x,r)	Output at producer prices;

vdm(i,r) = vdpm(i,r) + vdgm(i,r) + sum{x, vdfm(i,x,r)};
vom(i,r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);
voa(x,r) = sum(f, evfa(f,x,r)) + sum(i, vdfa(i,x,r) + vifa(i,x,r));

vom("i",r) = voa("cgds",r);

parameter
	rto(i,r)	Output (or income) subsidy rates
	rtf(f,x,r)	Primary factor and commodity rates taxes 
	rtpd(i,r)	Private domestic consumption taxes
	rtpi(i,r)	Private import consumption tax rates
	rtgd(i,r)	Government domestic rates
	rtgi(i,r)	Government import tax rates
	rtfd(i,x,r)	Firms domestic tax rates
	rtfi(i,x,r)	Firms' import tax rates
	rtxs(i,r,s)	Export subsidy rates
	rtms(i,r,s)	Import taxes rates;

rto(i,r)$vom(i,r) = 1 - voa(i,r)/vom(i,r);
rtf(f,j,r)$vfm(f,j,r)  = evfa(f,j,r)/vfm(f,j,r) - 1;
rtpd(i,r)$vdpm(i,r)   = vdpa(i,r)/vdpm(i,r) - 1;
rtpi(i,r)$vipm(i,r)   = vipa(i,r)/vipm(i,r) - 1;
rtgd(i,r)$vdgm(i,r)   = vdga(i,r)/vdgm(i,r) - 1;
rtgi(i,r)$vigm(i,r)   = viga(i,r)/vigm(i,r) - 1;
rtfd(i,x,r)$vdfm(i,x,r) = vdfa(i,x,r)/vdfm(i,x,r) - 1;
rtfi(i,x,r)$vifm(i,x,r) = vifa(i,x,r)/vifm(i,x,r) - 1;
rtxs(i,r,s)$vxwd(i,r,s) = 1-vxwd(i,r,s)/vxmd(i,r,s);
rtms(i,r,s)$vims(i,r,s) = vims(i,r,s)/viws(i,r,s) - 1;

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

*	Translate the dataset to a format which drops vdpm, vipm, rtpd, rtpi, 
*	vdgm, vigm, rtgd, rtgi, vpm and vgm:

vdfm(i,"c",r) = vdpm(i,r);
vifm(i,"c",r) = vipm(i,r);
rtfd(i,"c",r) = rtpd(i,r);
rtfi(i,"c",r) = rtpi(i,r);
vom("c",r) =vpm(r);

vdfm(i,"g",r) = vdgm(i,r);
vifm(i,"g",r) = vigm(i,r);
rtfd(i,"g",r) = rtgd(i,r);
rtfi(i,"g",r) = rtgi(i,r);
vom("g",r) =vgm(r);

*	Transfer investment good CGDS to "i":
*	(Justin 10.2.2010)

vdfm(i,"i",r) = vdfm(i,"CGDS",r);
vifm(i,"i",r) = vifm(i,"CGDS",r);

vdfm(i,"cgds",r) = 0;
vifm(i,"cgds",r) = 0;

rtfd(i,"i",r) = rtfd(i,"cgds",r);
rtfi(i,"i",r) = rtfi(i,"cgds",r);

vb(r) = vpm(r) + vgm(r) + vom("i",r) 
	- sum(f, evom(f,r))
	- sum(j,  vom(j,r)*rto(j,r))
	- sum(x,  sum(i, vdfm(i,x,r)*rtfd(i,x,r) + vifm(i,x,r)*rtfi(i,x,r)))

	+ sum(i, vdfm(i,"c",r)*rtfd(i,"c",r) + vifm(i,"c",r)*rtfi(i,"c",r))
	+ sum(i, vdfm(i,"g",r)*rtfd(i,"g",r) + vifm(i,"g",r)*rtfi(i,"g",r))

	- sum(j,  sum(f, vfm(f,j,r)*rtf(f,j,r)))
	- sum(i, vdpm(i,r)*rtpd(i,r) + vipm(i,r)*rtpi(i,r))
	- sum(i, vdgm(i,r)*rtgd(i,r) + vigm(i,r)*rtgi(i,r))
	- sum((i,s), rtms(i,s,r) *  (vxmd(i,s,r) * (1-rtxs(i,s,r)) + sum(j,vtwr(j,i,s,r))))
	+ sum((i,s), rtxs(i,r,s) * vxmd(i,r,s));

vb("chksum") = sum(r, vb(r));
display vb;

parameter
	eco2(i,*,r)		Emissions of CO2 (Gg),
	enco2(nco2,*,*,r)	Emissions of other greenhouse gases (MM ton C-eq),
	evd(i,*,r)		Volume of energy purchases (mtoe),
	evt(i,r,r)		Volume of energy exports (mtoe);

set ffmap(i,ec)/ely.eely,coa.ecoa,oil.eoil,gas.egas,p_c.ep_c,gdt.egdt/;

eco2(i,j,r)   = sum(ffmap(i,ec),eghg("co2",ec,j,r));
eco2(i,"c",r) = sum(ffmap(i,ec),eghg("co2",ec,"hh",r));
eco2(i,"g",r) = sum(ffmap(i,ec),eghg("co2",ec,"govt",r));

*	Emissions of non-CO2 gases:

$if set nco2	enco2(nco2,i,"c",r) = nc_hh(nco2,i,r);
$if set nco2	enco2(nco2,"process",j,r) = nc_qo(nco2,j,r);
$if set nco2	enco2(nco2,f,j,r) = nc_endw(nco2,f,j,r);
$if set nco2	enco2(nco2,i,j,r) = nc_trad(nco2,i,j,r);

$if not set nco2 enco2(nco2,i,"c",r) = 0;
$if not set nco2 enco2(nco2,"process",j,r) = 0;
$if not set nco2 enco2(nco2,f,j,r) = 0;
$if not set nco2 enco2(nco2,i,j,r) = 0;

loop(ffmap(i,ec),
	evd(i,j,r) = evf_(ec,j,r);
	evd(i,"c",r) = evh_(ec,r);
	evt(i,r,s) = evt_(ec,r,s);
);
if (nd>0,
	eco2(i,g,r) = eco2(i,g,r)$round(eco2(i,g,r), nd);
	evt(i,r,s)  = evt(i,r,s)$round(evt(i,r,s), nd);
	evd(i,g,r)  = evd(i,g,r)$round(evd(i,g,r), nd);
	enco2(nco2,f,j,r) = enco2(nco2,f,j,r)$round(enco2(nco2,f,j,r),nd);
	enco2(nco2,i,g,r) = enco2(nco2,i,g,r)$round(enco2(nco2,i,g,r),nd);
	enco2(nco2,"process",j,r) = enco2(nco2,"process",j,r)$round(enco2(nco2,"process",j,r),nd);
);
if (nd>0,
	execute_unload '%datadir%gsd_%nd%.gdx', r, f, g, i, vfm, vdfm, vifm, vxmd, vst, vtwr, 
		rto, rtf, rtfd, rtfi, rtxs, rtms, esubd, esubva, esubm, etrae, eta, epsilon, evd, evt, enco2, eco2;
else
	execute_unload '%datadir%gsd.gdx',      r, f, g, i, vfm, vdfm, vifm, vxmd, vst, vtwr, 
		rto, rtf, rtfd, rtfi, rtxs, rtms, esubd, esubva, esubm, etrae, eta, epsilon, evd, evt, enco2, eco2;
);

parameter	eprice		Implicit energy prices
		etprice		Energy trade price;

eprice(i,g,r)$evd(i,g,r)  = (vdfm(i,g,r)+vifm(i,g,r))/evd(i,g,r);
etprice(i,r,s)$evt(i,r,s) = vxmd(i,r,s)/evt(i,r,s);
eprice(i,"average",r)$sum(g,evd(i,g,r))  = sum(g,vdfm(i,g,r)+vifm(i,g,r))/sum(g,evd(i,g,r));
etprice(i,r,s)$evt(i,r,s) = vxmd(i,r,s)/evt(i,r,s);
etprice(i,r,"domestic") = eprice(i,"average",r);
etprice(i,"domestic",s) = eprice(i,"average",s);
*.execute_unload 'eprice.gdx',eprice,etprice;	
*.execute 'gdxxrw i=eprice.gdx o=eprice.xls par=eprice rng="eprice!a2" cdim=0 par=etprice rng="etprice!a2" cdim=0';

parameter	co2ratio	Ratio of ghg emissions to energy use;
co2ratio(r,i,g,"value")$eco2(i,g,r) = na;
loop(ffmap(i,ec),
	co2ratio(r,i,g,"value")$(vdfm(i,g,r)+vifm(i,g,r)) = eco2(i,g,r)/(vdfm(i,g,r)+vifm(i,g,r));
	co2ratio(r,i,g,"energy")$evd(i,g,r)               = eco2(i,g,r)/evd(i,g,r);
);
display co2ratio;
*.execute_unload 'co2ratio.gdx',co2ratio;
*.execute 'gdxxrw i=co2ratio.gdx o=co2ratio.xls par=co2ratio rng="pivotdata!a2" cdim=0';

$exit

$label missingharfiles
$log	
$log	*** Error *** Missing HAR files.
$log	
$log	Need to have the following files for this program:
$log		%gtapdatadir%gsdset.har 
$log		%gtapdatadir%gsddat.har 
$log		%gtapdatadir%gsdpar.har 
$log		%gtapdatadir%gsdvole.har 
$log		%gtapdatadir%gtap_co2_v7.har
$log		%gtapdatadir%gtp_nco2_mmtceq_v7.har
$log	
$log	These files are part of the flexagg distribution from GTAP7.
$log
$exit

$label missinggdxfiles
$log	
$log	*** Error *** Missing GDX files.
$log	
$log	One of the following translations seems to have failed:
$log		har2gdx %gtapdatadir%gsdset.har gsdset.gdx
$log		har2gdx %gtapdatadir%gsddat.har gsddat.gdx
$log		har2gdx %gtapdatadir%gsdpar.har gsdpar.gdx
$log		har2gdx %gtapdatadir%gsdvole.har gsdvole.gdx
$log		har2gdx %gtapdatadir%gtap_co2_v7.har gtap_co2_v7.gdx
$log		har2gdx %gtapdatadir%gtp_nco2_mmtceq_v7.har gtp_nco2_mmtceq_v7.gdx
$log	
$log	These files are part of the flexagg distribution from GTAP7.
$log
$exit

