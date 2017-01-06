$title	Aggregation Program for the GTAP9 Database

$if not set source $abort	Need to specify a source on command line: --source=xxx
$if not set target $abort	Need to specify a target on command line: --target=yyy
$if not set output $set output %target%

$set ds %source%
$include gtap9data
$include ..\defines\%target%.map

alias (ii,jj), (rr,ss);

set	gg(*)	All goods in aggregate model plus C - G - I /
		c	Household,
		g	Government consumption,
		i	Investment/;
alias (u,*);
gg(u)$ii(u) = ii(u);
abort$sum(ii$(sameas(ii,"c") or sameas(ii,"g") or sameas(ii,"i")),1) "Invalid identifier: C, G and I are reserved.";

parameters
	vom_(*,rr)	Aggretate output
	vfm_(ff,*,rr)	Endowments - Firms' purchases at market prices,
	vdfm_(ii,*,rr)	Intermediates - firms' domestic purchases at market prices,
	vifm_(ii,*,rr)	Intermediates - firms' imports at market prices,
	vxmd_(ii,rr,ss)	Trade - bilateral exports at market prices,
	vst_(ii,rr)	Trade - exports for international transportation
	vtwr_(ii,jj,rr,ss)	Trade - Margins for international transportation at world prices,

	evt_(ii,rr,rr)	Volume of energy trade (mtoe),
	evd_(ii,*,rr)	Domestic energy use (mtoe),
	evi_(ii,*,rr)	Imported energy use (mtoe),
	eco2d_(ii,*,rr)	CO2 emissions in domestic fuels - Mt CO2",
	eco2i_(ii,*,rr)	CO2 emissions in foreign fuels - Mt CO2",

	rto_(*,rr)	Output (or income) subsidy rates
	rtf_(ff,*,rr)	Primary factor and commodity rates taxes 
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
put_utility 'title' /"Aggregating evi.";
$batinclude aggr evi  i g r evi_
put_utility 'title' /"Aggregating evt.";
$batinclude aggr evt  i r s evt_
put_utility 'title' /"Aggregating eco2d.";
$batinclude aggr eco2d  i g r eco2d_
put_utility 'title' /"Aggregating eco2i.";
$batinclude aggr eco2i  i g r eco2i_
put_utility 'title' /"Aggregating vtwr.";
$batinclude aggr vtwr i j r s vtwr_

*	First, convert tax rates into tax payments:

rto(g,r)    = rto(g,r)*vom(g,r);
rtf(f,j,r)  = rtf(f,j,r) * vfm(f,j,r);
rtfd(i,g,r) = rtfd(i,g,r) * vdfm(i,g,r);
rtfi(i,g,r) = rtfi(i,g,r) * vifm(i,g,r);
rtms(i,r,s) = rtms(i,r,s)*((1-rtxs(i,r,s)) * vxmd(i,r,s) + sum(j,vtwr(j,i,r,s)));
rtxs(i,r,s) = rtxs(i,r,s) * vxmd(i,r,s);


*	Aggregate:

put_utility 'title' /"Aggregating rto.";
$batinclude aggr rto g r   rto_
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

profit(gg,rr) = vom_(gg,rr) - rto_(gg,rr) 
		- sum(ii, vdfm_(ii,gg,rr) + rtfd_(ii,gg,rr))
		- sum(ii, vifm_(ii,gg,rr) + rtfi_(ii,gg,rr))
		- sum(ff, vfm_(ff,gg,rr)  + rtf_(ff,gg,rr));
display profit;


*	Convert back to rates:

rto_(gg,rr)$vom_(gg,rr) = rto_(gg,rr)/vom_(gg,rr);
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

$if set energydata $goto energydata

put_utility 'title' /"Unloading dataset.";
execute_unload '%datadir%%output%.gdx', 
	gg=g, rr=r, ff=f, ii=i, 
	vfm_=vfm, vdfm_=vdfm, vifm_=vifm,vxmd_=vxmd, vst_=vst, vtwr_=vtwr, 
	rto_=rto, rtf_=rtf, rtfd_=rtfd, rtfi_=rtfi, rtxs_=rtxs, rtms_=rtms, 
	evd_=evd, evi_=evi, evt_=evt, eco2d_=eco2d, eco2i_=eco2i, 
	esubd_=esubd, esubva_=esubva, esubm_=esubm, etrae_=etrae, eta_=eta, epsilon_=epsilon;
put_utility 'title' /"All done with aggregation.";
$exit

$label energydata
put_utility 'title' /"Unloading dataset.";

parameter
	ieocarbon_(scn,ii,rr,t)		IEO carbon emissions (Mt of CO2)
	ieogdp_(scn,rr,t)		IEO gross domestic product (billion USD)
	ieoenergy_(scn,ii,*,rr,t)	IEO energy use by sector (mtoe)
	ieoele_(scn,ieo_tec, rr,t)	Power production by aggregate generaton technology
	ieocrude_(scn,rr,t)		IEO crude oil supply (mtoe)
	ieoelesup_(scn,rr,t)		IEO electricity generation and capacity (mtoe),
	unpop_(rr,t)			UN population trajectories (millions)

	tmp1(r)				Temporary array for aggregating one-dimensional data,
	tmp2(rr)			Temporary array for aggregating one-dimensional data,

	tmp3(i,r)			Temporary array for aggregating two-dimensional data,
	tmp4(ii,rr)			Temporary array for aggregating two-dimensional data,

	tmp5(i,g,r)			Temporary array for aggregating three-dimensional data,
	tmp6(ii,*,rr)			Temporary array for aggregating three-dimensional data;

loop(t,
	tmp1(r)	= unpop(r,t);
$batinclude aggr tmp1 r  tmp2
	unpop_(rr,t) = tmp2(rr);
);
tmp1(r) = 0; tmp2(rr) = 0;

*.$setglobal debug yes

$log Aggregating IEO Energy Projections...

loop((scn,t,ieo_tec), 
	tmp1(r) = ieoele(scn,ieo_tec,r,t);
$batinclude aggr tmp1 r      tmp2
	ieoele_(scn,ieo_tec,rr,t) = tmp2(rr);
	tmp1(r) = 0; tmp2(rr) = 0;
); 



loop((scn,t),
	tmp1(r) = ieogdp(scn,r,t);
$batinclude aggr tmp1 r      tmp2
	ieogdp_(scn,rr,t) = tmp2(rr);
	tmp1(r) = 0; tmp2(rr) = 0;

	tmp1(r) = ieocrude(scn,r,t);
$batinclude aggr tmp1 r      tmp2
	ieocrude_(scn,rr,t) = tmp2(rr);
	tmp1(r) = 0; tmp2(rr) = 0;

	tmp1(r) = ieoelesup(scn,r,t);
$batinclude aggr tmp1 r      tmp2
	ieoelesup_(scn,rr,t) = tmp2(rr);
	tmp1(r) = 0; tmp2(rr) = 0;

	tmp3(i,r) = ieocarbon(scn,i,r,t);
$batinclude aggr tmp3 i r      tmp4
	ieocarbon_(scn,ii,rr,t) = tmp4(ii,rr);
	tmp3(i,r) = 0; tmp4(ii,rr) = 0;

	tmp5(i,g,r) = ieoenergy(scn,i,g,r,t);
$batinclude aggr tmp5 i g r     tmp6
	ieoenergy_(scn,ii,gg,rr,t) = tmp6(ii,gg,rr);
	tmp5(i,g,r) = 0; tmp6(ii,gg,rr) = 0;
);

execute_unload '%datadir%%output%.gdx', 
	gg=g, rr=r, ff=f, ii=i, 
	vfm_=vfm, vdfm_=vdfm, vifm_=vifm,vxmd_=vxmd, vst_=vst, vtwr_=vtwr, 
	rto_=rto, rtf_=rtf, rtfd_=rtfd, rtfi_=rtfi, rtxs_=rtxs, rtms_=rtms, 
	evd_=evd, evi_=evi, evt_=evt, eco2d_=eco2d, eco2i_=eco2i, 
	esubd_=esubd, esubva_=esubva, esubm_=esubm, etrae_=etrae, eta_=eta, epsilon_=epsilon,
	ieogdp_=ieogdp, ieoenergy_=ieoenergy, ieocrude_=ieocrude, ieoprice, ieocarbon_=ieocarbon, ieoelesup_=ieoelesup, ieoele_=ieoele, 
	unpop_=unpop;


put_utility 'title' /"All done with aggregation.";
