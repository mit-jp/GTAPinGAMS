$title	Aggregation Program for the GTAP7 Database

$if not set source $set source gtap7ingams_e
$if not set target $set target gtap7iea
$if not set output $set output %target%

*.$set energydata
$set ds %source%
$include gtap7data
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
	eco2_(ii,*,rr)	Volume of carbon emissions,
	enco2_(nco2,*,*,rr)	Volume of non-carbon ghg emissions,

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

$batinclude aggr vst i r vst_
$batinclude aggr vtwr i j r s vtwr_
$batinclude aggr vom g r vom_
$batinclude aggr vfm f j r vfm_
$batinclude aggr vdfm i g r vdfm_
$batinclude aggr vifm i g r vifm_
$batinclude aggr vxmd i r s vxmd_
$batinclude aggr evd i g r evd_
$batinclude aggr evt i r s evt_
$batinclude aggr eco2 i g r eco2_

parameter	enco2tmp(*,*,*)	Temporary array to aggregate enco2,
		enco2tmp_(*,*,*)	Temporary array to aggregate enco2;

loop(nco2,
	enco2tmp(i,g,r) = enco2(nco2,i,g,r);
$batinclude aggr enco2tmp i g r enco2tmp_
	enco2_(nco2,ii,gg,rr) = enco2tmp_(ii,gg,rr);
	enco2tmp_(ii,gg,rr) = 0;
	enco2tmp(i,g,r) = 0;

	enco2tmp(f,g,r) = enco2(nco2,f,g,r);
$batinclude aggr enco2tmp f g r enco2tmp_
	enco2_(nco2,ff,gg,rr) = enco2tmp_(ff,gg,rr);
	enco2tmp_(ff,gg,rr) = 0;
	enco2tmp(f,g,r) = 0;
);
set jrmap(j,jj,r,rr);
jrmap(j,jj,r,rr)$(mapj(j,jj) and mapr(r,rr)) = yes;
enco2_(nco2,"process",jj,rr) = sum(jrmap(j,jj,r,rr), enco2(nco2,"process",j,r));


*	First, convert tax rates into tax payments:

rto(i,r)    = rto(i,r)*vom(i,r);
rtf(f,j,r)  = rtf(f,j,r) * vfm(f,j,r);
rtfd(i,g,r) = rtfd(i,g,r) * vdfm(i,g,r);
rtfi(i,g,r) = rtfi(i,g,r) * vifm(i,g,r);
rtms(i,r,s) = rtms(i,r,s)*((1-rtxs(i,r,s)) * vxmd(i,r,s) + sum(j,vtwr(j,i,r,s)));
rtxs(i,r,s) = rtxs(i,r,s) * vxmd(i,r,s);

*	Aggregate:

$batinclude aggr rto i r   rto_
$batinclude aggr rtf f j r rtf_
$batinclude aggr rtfd i g r rtfd_
$batinclude aggr rtfi i g r rtfi_
$batinclude aggr rtxs i r s rtxs_
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

$if set energydata $goto energydata

execute_unload '%datadir%%output%.gdx', 
	gg=g, rr=r, ff=f, ii=i, 
	vfm_=vfm, vdfm_=vdfm, vifm_=vifm,vxmd_=vxmd, vst_=vst, vtwr_=vtwr, 
	rto_=rto, rtf_=rtf, rtfd_=rtfd, rtfi_=rtfi, rtxs_=rtxs, rtms_=rtms, 
	evd_=evd, evt_=evt, eco2_=eco2, enco2_=enco2,
	esubd_=esubd, esubva_=esubva, esubm_=esubm, etrae_=etrae, eta_=eta, epsilon_=epsilon;

$exit

$label energydata

**.set	ieo_gen	Generation technologies /oilgen, gasgen, colgen, nucgen, hydrogen, windgen, geogen, othrnwgen/;
**.	iea_gen IEA generation technologies /thermalgen, hydrogen, rengen, nucleargen/;


parameter
	ieocarbon_(ieoscn,ii,rr,ieot)	     Emissions by fossil fuel (mmt co2)
	ieoenergy_(ieoscn,ii,*,rr,ieot)	     Energy demand (mtoe)
	ieogdp_(ieoscn,rr,ieot)		     Gross domestic product (index -- 2004=1)
	ieoelegen_(ieoscn,ieo_gen, rr,ieot)  Power production by aggregate generaton technology
	ieocrude_(ieoscn,rr,ieot)	     Crude oil production (index -- 2004=1)
	ieoelec_(ieoscn,rr,ieot)	     IEO electricity supply (index -- 2004=1),
	popdata_(sresscn,rr,ieot)	     CIESIN population data (millions)

	ieaco2emit_(ii,rr,ieot)		     Carbon dioxide emissions  mmt CO2 (IEO 2008),
	ieaelec_(iea_gen,rr,*)		     Base-year power production by technology and GTAP region as provided by IEA annuals


	ieotmp1(r)	 Temporary array for aggregating ieogdp and ieocrude,
	ieotmp2(rr)	 Temporary array for aggregating ieogdp and ieocrude,
	ieotmp3(i,r)	 Temporary array for aggregating ieocarbon,
	ieotmp4(ii,rr)	 Temporary array for aggregating ieocarbon
	ieotmp5(i,g,r)	 Temporary array for aggregating ieoenergy,
	ieotmp6(ii,*,rr) Temporary array for aggregating ieoenergy;


parameter 
	poptmp1(r)	Temporary array for aggregating population data,
	poptmp2(rr)	Temporary array for aggregating population data;
		
poptmp1(r) = 1;
$batinclude aggr poptmp1 r poptmp2
loop((sresscn,ieot),
	poptmp1(r)	= popdata(sresscn,r,ieot);
$batinclude aggr poptmp1 r  poptmp2
	popdata_(sresscn,rr,ieot) = poptmp2(rr);
);

parameter
	ieatmp1(i,r)		Temporary array for aggregating ieaco2emit
	ieatmp2(ii,rr)		Temporary array for aggregating ieaco2emit;

loop(ieot,
	ieatmp1(i,r) = ieaco2emit(i,r,ieot);
$batinclude aggr ieatmp1 i r      ieatmp2
	ieaco2emit_(ii,rr,ieot) = ieatmp2(ii,rr);
     );	


*.$setglobal debug yes

$log Aggregating IEO Energy Projections...

loop((ieoscn,ieot,ieo_gen), 
	ieotmp1(r) = ieoelegen(ieoscn,ieo_gen,r,ieot);
$batinclude aggr ieotmp1 r      ieotmp2
	ieoelegen_(ieoscn,ieo_gen,rr,ieot) = ieotmp2(rr);
); 


loop((ieot,iea_gen), 
	ieotmp1(r) = ieaelec(iea_gen,r,ieot);
$batinclude aggr ieotmp1 r      ieotmp2
	ieaelec_(iea_gen,rr,ieot) = ieotmp2(rr);
); 


loop((ieoscn,ieot),
	ieotmp1(r) = ieogdp(ieoscn,r,ieot);
$batinclude aggr ieotmp1 r      ieotmp2
	ieogdp_(ieoscn,rr,ieot) = ieotmp2(rr);

	ieotmp1(r) = ieocrude(ieoscn,r,ieot);
$batinclude aggr ieotmp1 r      ieotmp2
	ieocrude_(ieoscn,rr,ieot) = ieotmp2(rr);

	ieotmp1(r) = ieoelec(ieoscn,r,ieot);
$batinclude aggr ieotmp1 r      ieotmp2
	ieoelec_(ieoscn,rr,ieot) = ieotmp2(rr);

	ieotmp3(i,r) = ieocarbon(ieoscn,i,r,ieot);
$batinclude aggr ieotmp3 i r      ieotmp4
	ieocarbon_(ieoscn,ii,rr,ieot) = ieotmp4(ii,rr);

	ieotmp5(i,g,r) = ieoenergy(ieoscn,i,g,r,ieot);
$batinclude aggr ieotmp5 i g r     ieotmp6
	ieoenergy_(ieoscn,ii,gg,rr,ieot) = ieotmp6(ii,gg,rr);
);

parameter	emitsrc_(nco2,nco2src,*,ieot)	Non-CO2 emissions inventory by source
		mac_(nco2,nco2src,*,ieot,val)	Marginal abatement (percentage);

parameter	nco2tmp(r)	Temporary array for aggregation,
		nco2tmp2(rr)	Temporary array for aggregation;

loop((nco2,nco2src,ieot)$sum(r,emitsrc(nco2,nco2src,r,ieot)),
	nco2tmp(r) = emitsrc(nco2,nco2src,r,ieot);
$batinclude aggr nco2tmp r nco2tmp2
	emitsrc_(nco2,nco2src,rr,ieot) = nco2tmp2(rr);

*	Convert from percentages to levels and then back to aggregate:
	loop(val$sum(r,mac(nco2,nco2src,r,ieot,val)),
	  nco2tmp(r) = mac(nco2,nco2src,r,ieot,val)*emitsrc(nco2,nco2src,r,ieot);
$batinclude aggr nco2tmp r nco2tmp2
	  mac_(nco2,nco2src,rr,ieot,val)$emitsrc_(nco2,nco2src,rr,ieot) 
		= nco2tmp2(rr) / emitsrc_(nco2,nco2src,rr,ieot);
	);
);

nco2tmp(r) = 0; nco2tmp2(rr) = 0;

execute_unload '%datadir%%output%.gdx', 
	gg=g, rr=r, ff=f, ii=i, 
	vfm_=vfm, vdfm_=vdfm, vifm_=vifm,vxmd_=vxmd, vst_=vst, vtwr_=vtwr, 
	evd_=evd, evt_=evt, eco2_=eco2, enco2_=enco2,
	emitsrc_=emitsrc, mac_=mac,
	rto_=rto, rtf_=rtf, rtfd_=rtfd, rtfi_=rtfi, rtxs_=rtxs, rtms_=rtms, 
	esubd_=esubd, esubva_=esubva, esubm_=esubm, etrae_=etrae, eta_=eta, epsilon_=epsilon,
	ieocarbon_=ieocarbon, ieogdp_=ieogdp, ieocrude_=ieocrude, ieoelec_=ieoelec, ieoenergy_=ieoenergy, ieoprice,
	popdata_=popdata, ieaco2emit_=ieaco2emit, ieoelegen_=ieoelegen, ieaelec_=ieaelec ;
