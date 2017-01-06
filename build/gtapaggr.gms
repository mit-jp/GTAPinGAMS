$if not set ds $set ds asa7x5

$include ..\defines\%ds%.map
$set target %ds%

$if not setglobal source $log "Error -- source dataset is not specified."
$if not setglobal source $abort "Error -- source dataset is not specified."

$set ds %source%

$include gtap6data

alias (ii,jj), (rr,ss);

parameters
	vom_(ii,rr)	Aggretate output
	vdgm_(ii,rr)	Government - domestic purchases at market prices,
	vigm_(ii,rr)	Government - imports at market prices,
	vdpm_(ii,rr)	Private households - domestic purchases at market prices,
	vipm_(ii,rr)	Private households - imports at market prices
	vdim_(ii,rr)	Investment demand
	vfm_(ff,jj,rr)	Endowments - Firms' purchases at market prices,
	vdfm_(ii,jj,rr)	Intermediates - firms' domestic purchases at market prices,
	vifm_(ii,jj,rr)	Intermediates - firms' imports at market prices,
	vxmd_(ii,rr,ss)	Trade - bilateral exports at market prices,
	vst_(ii,rr)	Trade - exports for international transportation
	vtwr_(ii,jj,rr,ss)	Trade - Margins for international transportation at world prices,

	evf_(eec,ii,rr)	Volume of input purchases by firms (mtoe)
	evh_(eec,rr)	Volume of purchases by households (mtoe)
	evt_(eec,rr,rr)	Volume of bilateral trade (mtoe)
	eghg_(ghg,ii,srcs,*,rr)	Greenhouse gas emissions (Gg)

	rto_(ii,rr)	Output (or income) subsidy rates
	rtf_(ff,jj,rr)	Primary factor and commodity rates taxes 
	rtpd_(ii,rr)	Private domestic consumption taxes
	rtpi_(ii,rr)	Private import consumption tax rates
	rtgd_(ii,rr)	Government domestic rates
	rtgi_(ii,rr)	Government import tax rates
	rtfd_(ii,jj,rr)	Firms domestic tax rates
	rtfi_(ii,jj,rr)	Firms' import tax rates
	rtxs_(ii,rr,ss)	Export subsidy rates
	rtms_(ii,rr,ss)	Import taxes rates,

	esubd_(ii)	Elasticity of substitution (M versus D),
	esubva_(jj)	Elasticity of substitution between factors
	esubm_(ii)	Intra-import elasticity of substitution,
	etrae_(ff)	Elasticity of transformation
	eta_(ii,rr)	Income elasticity of demand,
	epsilon_(ii,rr)	Own-price elasticity of demand;

alias (e,ec), (ee,eec), (i,j), (ii,jj);;
alias (r,s), (rr,ss);
set maps(s,ss), mapj(j,jj);
maps(r,rr) = mapr(r,rr);
mapj(j,jj) = mapi(j,jj);

$batinclude aggr vst i r vst_
$batinclude aggr vtwr i j r s vtwr_
$batinclude aggr vom i r vom_
$batinclude aggr vdgm i r vdgm_
$batinclude aggr vigm i r vigm_
$batinclude aggr vdpm i r vdpm_
$batinclude aggr vipm i r vipm_
$batinclude aggr vdim i r vdim_
$batinclude aggr vfm f j r vfm_
$batinclude aggr vdfm i j r vdfm_
$batinclude aggr vifm i j r vifm_
$batinclude aggr vxmd i r s vxmd_
$batinclude aggr evf e i r evf_
$batinclude aggr evh e r evh_
$batinclude aggr evt e r s evt_

*	First, convert tax rates into tax payments:

rto(i,r) = rto(i,r)*vom(i,r);
rtf(f,j,r)  = rtf(f,j,r) * vfm(f,j,r);
rtpd(i,r)   = rtpd(i,r) * vdpm(i,r);
rtpi(i,r)   = rtpi(i,r) * vipm(i,r);
rtgd(i,r)   = rtgd(i,r) * vdgm(i,r);
rtgi(i,r)   = rtgi(i,r) * vigm(i,r);
rtfd(i,j,r) = rtfd(i,j,r) * vdfm(i,j,r);
rtfi(i,j,r) = rtfi(i,j,r) * vifm(i,j,r);
rtms(i,r,s) = rtms(i,r,s)*((1-rtxs(i,r,s)) * vxmd(i,r,s) + sum(j,vtwr(j,i,r,s)));
rtxs(i,r,s) = rtxs(i,r,s) * vxmd(i,r,s);

*	Aggregate:

$batinclude aggr rto i r   rto_
$batinclude aggr rtf f j r rtf_
$batinclude aggr rtpd i r  rtpd_
$batinclude aggr rtpi i r  rtpi_
$batinclude aggr rtgd i r  rtgd_
$batinclude aggr rtgi i r  rtgi_
$batinclude aggr rtfd i j r rtfd_
$batinclude aggr rtfi i j r rtfi_
$batinclude aggr rtxs i r s rtxs_
$batinclude aggr rtms i r s rtms_

*	Convert back to rates:

rto_(ii,rr)$vom_(ii,rr) = rto_(ii,rr)/vom_(ii,rr);
rtf_(ff,jj,rr)$vfm_(ff,jj,rr)  = rtf_(ff,jj,rr) / vfm_(ff,jj,rr);
rtpd_(ii,rr)$ vdpm_(ii,rr)   = rtpd_(ii,rr) / vdpm_(ii,rr);
rtpi_(ii,rr)$ vipm_(ii,rr)   = rtpi_(ii,rr) / vipm_(ii,rr);
rtgd_(ii,rr)$ vdgm_(ii,rr)   = rtgd_(ii,rr) / vdgm_(ii,rr);
rtgi_(ii,rr)$ vigm_(ii,rr)   = rtgi_(ii,rr) / vigm_(ii,rr);
rtfd_(ii,jj,rr)$ vdfm_(ii,jj,rr) = rtfd_(ii,jj,rr) / vdfm_(ii,jj,rr);
rtfi_(ii,jj,rr)$ vifm_(ii,jj,rr) = rtfi_(ii,jj,rr) / vifm_(ii,jj,rr);
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
vp(i,r) = vdpm(i,r)*(1+rtpd0(i,r)) + vipm(i,r)*(1+rtpi0(i,r));

eta_(ii,rr)$sum((mapr(r,rr),mapi(i,ii)),vp(i,r))
	= sum((mapr(r,rr),mapi(i,ii)),vp(i,r)*eta(i,r)) /
	  sum((mapr(r,rr),mapi(i,ii)),vp(i,r));
epsilon_(ii,rr)$sum((mapr(r,rr),mapi(i,ii)),vp(i,r))
	= sum((mapr(r,rr),mapi(i,ii)),vp(i,r)*epsilon(i,r)) /
	  sum((mapr(r,rr),mapi(i,ii)),vp(i,r));


set fd /hh,govt/;
eghg_(ghg,ii,srcs,jj,rr) = 0;
if (%ghgdata%,
	eghg_(ghg,ii,srcs,jj,rr) = 
		sum((mapr(r,rr),mapi(i,ii),mapj(j,jj)), eghg(ghg,i,srcs,j,r));
	eghg_(ghg,ii,srcs,fd,rr) = 
		sum((mapr(r,rr),mapi(i,ii)), eghg(ghg,i,srcs,fd,r));
);		

loop(mapf(mf,ff), etrae_(ff) = +inf;);

display esubd_, esubva_, esubm_, etrae_;

execute_unload '%datadir%%target%.gdx', rr=r, ff=f, ii=i, vdgm_=vdgm, vigm_=vigm, 
	vdim_=vdim,
	vdpm_=vdpm, vipm_=vipm, vfm_=vfm, vdfm_=vdfm, vifm_=vifm,vxmd_=vxmd, vst_=vst, 
	vtwr_=vtwr, rto_=rto, rtf_=rtf, rtpd_=rtpd, rtpi_=rtpi, rtgd_=rtgd, rtgi_=rtgi, 
	rtfd_=rtfd, rtfi_=rtfi, rtxs_=rtxs, rtms_=rtms,evf_=evf, evh_=evh, evt_=evt, 
	eghg_=eghg, esubd_=esubd, esubva_=esubva, esubm_=esubm, etrae_=etrae,
	eta_=eta, epsilon_=epsilon;

