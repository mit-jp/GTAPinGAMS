$title	Aggregation Program for the GTAP7 Database

$if not set source $set source gtap8ingams
$if not set target $set target gtap8iea
$if not set output $set output %target%

*.$set energydata
$set ds %source%
$include gtap8data
$include ..\defines\%target%.map

alias (ii,jj), (rr,ss);

set	gg(*)	All goods in aggregate model plus C - G - I /c,g,i/;
gg(ii) = yes;
abort$sum(ii$(sameas(ii,"c") or sameas(ii,"g") or sameas(ii,"i")),1) "Invalid identifier: C, G and I are reserved.";

parameters
	vom_(*,rr)	Aggretate output
	vfm_(ff,jj,rr)	Endowments - Firms' purchases at market prices,
	vdfm_(ii,*,rr)	Intermediates - firms' domestic purchases at market prices,
	vifm_(ii,*,rr)	Intermediates - firms' imports at market prices,
	vxmd_(ii,rr,ss)	Trade - bilateral exports at market prices,
	vst_(ii,rr)	Trade - exports for international transportation
	vtwr_(ii,jj,rr,ss)	Trade - Margins for international transportation at world prices,

	evd_(ii,*,rr)	Volume of energy purchases (mtoe),
	evt_(ii,rr,ss)	Volume of energy trade (mtoe),

	rto_(ii,rr)	Output (or income) subsidy rates
	rtf_(ff,jj,rr)	Primary factor and commodity rates taxes 
	rtfd_(ii,*,rr)	Firms domestic tax rates
	rtfi_(ii,*,rr)	Firms' import tax rates
	rtxs_(ii,rr,ss)	Export subsidy rates
	rtms_(ii,rr,ss)	Import taxes rates,

	esubd_(ii)	Elasticity of substitution (M versus D),
	esubva_(jj)	Elasticity of substitution between factors
	esubm_(ii)	Intra-import elasticity of substitution,
	etrae_(ff)	Elasticity of transformation,
	eta_(ii,rr)	Income elasticity of demand,
	epsilon_(ii,rr)	Own-price elasticity of demand;


alias (i,j), (ii,jj);;
alias (r,s), (rr,ss);
set maps(s,ss), mapj(j,jj), mapg(*,*)/c.c, i.i, g.g/;
maps(r,rr) = mapr(r,rr);
mapj(j,jj) = mapi(j,jj);
mapg(i,ii) = mapi(i,ii);

file ktitle; put ktitle;

put_utility 'title' /"Aggregating vst.";
$batinclude aggr vst  i r   vst_
put_utility 'title' /"Aggregating vom.";
$batinclude aggr vom  g r   vom_
put_utility 'title' /"Aggregating vfm.";
$batinclude aggr vfm  f j r vfm_
put_utility 'title' /"Aggregating vdfm.";
$batinclude aggr vdfm i g r vdfm_
put_utility 'title' /"Aggregating vifm.";
$batinclude aggr vifm i g r vifm_
put_utility 'title' /"Aggregating vxmd.";
$batinclude aggr vxmd i r s vxmd_
put_utility 'title' /"Aggregating evd.";
$batinclude aggr evd  i g r evd_
put_utility 'title' /"Aggregating evt.";
$batinclude aggr evt  i r s evt_
put_utility 'title' /"Aggregating vtwr.";
$batinclude aggr vtwr i j r s vtwr_


*	First, convert tax rates into tax payments:

rto(i,r)    = rto(i,r)*vom(i,r);
rtf(f,j,r)  = rtf(f,j,r) * vfm(f,j,r);
rtfd(i,g,r) = rtfd(i,g,r) * vdfm(i,g,r);
rtfi(i,g,r) = rtfi(i,g,r) * vifm(i,g,r);
rtms(i,r,s) = rtms(i,r,s)*((1-rtxs(i,r,s)) * vxmd(i,r,s) + sum(j,vtwr(j,i,r,s)));
rtxs(i,r,s) = rtxs(i,r,s) * vxmd(i,r,s);


*	Aggregate:

put_utility 'title' /"Aggregating rto.";
$batinclude aggr rto i r   rto_
put_utility 'title' /"Aggregating rtf.";
$batinclude aggr rtf f j r rtf_
put_utility 'title' /"Aggregating rtfd.";
$batinclude aggr rtfd i g r rtfd_
put_utility 'title' /"Aggregating rtfi.";
$batinclude aggr rtfi i g r rtfi_
put_utility 'title' /"Aggregating rtxs.";
$batinclude aggr rtxs i r s rtxs_
put_utility 'title' /"Aggregating rtms.";
$batinclude aggr rtms i r s rtms_

parameter profit;
profit(gg,rr) = vom_(gg,rr)
		- sum(ii, vdfm_(ii,gg,rr) + rtfd_(ii,gg,rr))
		- sum(ii, vifm_(ii,gg,rr) + rtfi_(ii,gg,rr));

profit(jj,rr) = vom_(jj,rr) - rto_(jj,rr) 
		- sum(ii, vdfm_(ii,jj,rr) + rtfd_(ii,jj,rr))
		- sum(ii, vifm_(ii,jj,rr) + rtfi_(ii,jj,rr))
		- sum(ff, vfm_(ff,jj,rr)  + rtf_(ff,jj,rr));
display profit;


*	Convert back to rates:

rto_(ii,rr)$vom_(ii,rr) = rto_(ii,rr)/vom_(ii,rr);
rtf_(ff,jj,rr)$vfm_(ff,jj,rr)  = rtf_(ff,jj,rr) / vfm_(ff,jj,rr);
rtfd_(ii,gg,rr)$ vdfm_(ii,gg,rr) = rtfd_(ii,gg,rr) / vdfm_(ii,gg,rr);
rtfi_(ii,gg,rr)$ vifm_(ii,gg,rr) = rtfi_(ii,gg,rr) / vifm_(ii,gg,rr);
rtxs_(ii,rr,ss)$ vxmd_(ii,rr,ss) = rtxs_(ii,rr,ss) / vxmd_(ii,rr,ss);
rtms_(ii,rr,ss)$((1-rtxs_(ii,rr,ss)) * vxmd_(ii,rr,ss) + sum(jj,vtwr_(jj,ii,rr,ss)))
	 = rtms_(ii,rr,ss)/((1-rtxs_(ii,rr,ss)) * vxmd_(ii,rr,ss) + sum(jj,vtwr_(jj,ii,rr,ss)));

esubd_(ii)$sum(mapi(i,ii), sum((j,r), vdfm(i,j,r)+vifm(i,j,r)))
	= sum(mapi(i,ii), sum((j,r), vdfm(i,j,r)+vifm(i,j,r))*esubd(i)) /
	     sum(mapi(i,ii), sum((j,r), vdfm(i,j,r)+vifm(i,j,r)));
esubva_(jj)$sum(mapi(j,jj), sum((f,r), vfm(f,j,r)))
	= sum(mapi(j,jj), sum((f,r), vfm(f,j,r)*esubva(j))) /
	      sum(mapi(j,jj), sum((f,r), vfm(f,j,r)));
esubm_(ii)$sum((r,mapi(i,ii)), vim(i,r)) 
	= sum((r,mapi(i,ii)), vim(i,r)*esubm(i)) / sum((r,mapi(i,ii)), vim(i,r));

etrae_(ff)$sum(mapf(f,ff)$sf(f), sum((j,r), vfm(f,j,r)))
	   = sum(mapf(f,ff)$sf(f), sum((j,r), vfm(f,j,r)*etrae(f))) /
	     sum(mapf(f,ff)$sf(f), sum((j,r), vfm(f,j,r)));

parameter	vp(i,r)	Value of private expenditure;
vp(i,r) = vdfm(i,"c",r)*(1+rtfd0(i,"c",r)) + vifm(i,"c",r)*(1+rtfi0(i,"c",r));

eta_(ii,rr)$sum((mapr(r,rr),mapi(i,ii)),vp(i,r))
	= sum((mapr(r,rr),mapi(i,ii)),vp(i,r)*eta(i,r)) /
	  sum((mapr(r,rr),mapi(i,ii)),vp(i,r));
epsilon_(ii,rr)$sum((mapr(r,rr),mapi(i,ii)),vp(i,r))
	= sum((mapr(r,rr),mapi(i,ii)),vp(i,r)*epsilon(i,r)) /
	  sum((mapr(r,rr),mapi(i,ii)),vp(i,r));

loop(mapf(mf,ff), etrae_(ff) = +inf;);

execute_unload '%datadir%%output%.gdx', 
	gg=g, rr=r, ff=f, ii=i, 
	vfm_=vfm, vdfm_=vdfm, vifm_=vifm,vxmd_=vxmd, vst_=vst, vtwr_=vtwr, 
	rto_=rto, rtf_=rtf, rtfd_=rtfd, rtfi_=rtfi, rtxs_=rtxs, rtms_=rtms, 
	evd_=evd, evt_=evt, 
	esubd_=esubd, esubva_=esubva, esubm_=esubm, etrae_=etrae, eta_=eta, epsilon_=epsilon;
