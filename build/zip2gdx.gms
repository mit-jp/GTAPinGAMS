$title	ZIP2GDX  -- Read a GTAPAGG zip file and write out data in GDX format

$if not set energydata $set energydata no 

*	Initial creation data: 2 August 2005 (tfr)

*	Updates:

*	3 August 2005 - Introduced sets define sector-specific factors 
*	sf(f) and mobile factors mf(f) on the basis of elasticity 
*	etrae(f) which is read from default.prm.


$if not set ds $set ds china
$if not set datadir $set datadir "..\data\"

*	Extract files from the dataset, retrieve the GDX file
*	and then cleanup:

$if not exist "%datadir%%ds%.zip" $goto missingfile

$if exist "gsdvole.gdx" $call rm gsdvole.gdx

$call 'gmsunzip -C -o "%datadir%%ds%.zip" Basedata.har Default.prm'
$call 'har2gdx Basedata.har'
$call 'har2gdx Default.prm'
$if exist gsdvole.gdx $call 'rm gsdvole.gdx'
$if %energydata%=="yes" $call 'gmsunzip -C -o "%datadir%%ds%.zip"  gsdvole.har
$if %energydata%=="yes" $call 'har2gdx gsdvole.har'
$call 'gmszip -f -m "%datadir%%ds%" *.har'
$call 'gmszip -f -m "%datadir%%ds%" *.prm'

set	i(*)	Goods
	f(*)	Factors
	r(*)	Regions 

$gdxin 'basedata.gdx'
$load r=reg f=endw_comm i=prod_comm

set	cgd(i)		Investment good,
	trad_comm(i)	Traded commodities (non-investment);

$load trad_comm
cgd(i) = yes$(not trad_comm(i));
abort$(card(cgd) <> 1) "Error -- expecting a single investment good.";

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

alias (r,s), (i,j), (f,ff);

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

$load vdga viga vdgm vigm vdpa vipa vdpm vipm evoa evfa vfm vdfa 
$load vifa vdfm vifm vims viws vxmd vxwd vst vtwr fbep isep 
$load osep adrv tfrv purv vrrv mfrv xtrv 

$load ftrv 
$if errorfree $goto allread

$log *** ftrv not found in HAR file. Value set to zero.
$log *** Ignore the following error message and warning
$clearerror
ftrv(f,j,r) = 0;
$label allread

$gdxin
$call 'rm basedata.gdx'

parameter
	esubd(i)	Elasticity of substitution (M versus D),
	esubva(j)	Elasticity of substitution between factors
	esubm(i)	Intra-import elasticity of substitution,
	etrae(f)	Elasticity of transformation,
	incpar(i,r)	Expansion parameter in the CDE minimum expenditure function,
	subpar(i,r)	Substitution parameter in CDE minimum expenditure function;

$gdxin 'default.gdx'
$load esubd esubva esubm etrae incpar subpar
$gdxin

$call 'rm default.gdx'

*	Determine which factors are sector-specific 

mf(f) = yes$(etrae(f)=0);
sf(f) = yes$(etrae(f)<0);
display mf,sf;

*	Convert sign of etrae() so that it is non-negative:

etrae(f) = -etrae(f);
etrae(mf) = +inf;

*	Scale the data:

scalar scalefactor /1e-6/;
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
vfm(f,j,r) = scalefactor * vfm(f,j,r);
vdfa(i,j,r) = scalefactor * vdfa(i,j,r);
vifa(i,j,r) = scalefactor * vifa(i,j,r);
vdfm(i,j,r) = scalefactor * vdfm(i,j,r);
vifm(i,j,r) = scalefactor * vifm(i,j,r);
vims(i,r,s) = scalefactor * vims(i,r,s);
viws(i,r,s) = scalefactor * viws(i,r,s);
vxmd(i,r,s) = scalefactor * vxmd(i,r,s);
vxwd(i,r,s) = scalefactor * vxwd(i,r,s);
vst(i,r) = scalefactor * vst(i,r);
vtwr(i,j,r,s) = scalefactor * vtwr(i,j,r,s);
ftrv(f,j,r) = scalefactor * ftrv(f,j,r);
fbep(f,j,r) = scalefactor * fbep(f,j,r);
isep(i,j,r,src) = scalefactor * isep(i,j,r,src);
osep(i,r) = scalefactor * osep(i,r);
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

*	No energy data:

$if not exist gsdvole.gdx evf(ec,i,r) = 0; evh(ec,r) = 0; evt(ec,r,r) = 0;

*	Energy data:

$if exist gsdvole.gdx $goto nodata
$if exist gsdvole.gdx $gdxin 'gsdvole.gdx'
$if exist gsdvole.gdx $load evf evh evt
$if exist gsdvole.gdx $gdxin
$if exist gsdvole.gdx $call 'rm gsdvole.gdx'

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

execute_unload '%datadir%%ds%.gdx', r, f, i, cgd, vdgm, vigm, vdpm, vipm, vfm, vdfm, vifm, 
	vdim, vxmd, vst, vtwr, rto, rtf, rtpd, rtpi, rtgd, rtgi, rtfd, rtfi, rtxs, rtms,
	esubd, esubva, esubm, etrae, eta, epsilon, evf, evh, evt;

$exit
$label missingfile
$log	*** Error *** Missing file.
$log.
$log	Need to have the following file for this program:
$log.
$log		%datadir%%ds%.zip
$log.
$log	This file is expected be produced by gtapagg.
