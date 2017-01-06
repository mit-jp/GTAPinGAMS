$title	Generate a Sparse Version of the GTAP Dataset

$if not set tol $set tol 001
$if not set nd $set nd 6
$setglobal tol %tol%

scalar tol	Tolerance parameter for filtering data /0.%tol%/;

$if not set ds $set ds gsd

$include gtap7data

*	Need to pay attention to what matters here:

*	1. "oil" is crude oil, the value of which is negligible outside of the oil producing
*	states.  If filtering the data drops all this use, it is not a big problem.

*	2. Natural gas is represented by "gas+gdt", and many countries have relatively few
*	sources of natural gas.

*	3. Coal is also somewhat small component of emissions in many countries.

*	Bottom line: we may have large percentage changes in certain markets, but changes in
*	overall energy use are small -- below 0.1% for all sectors and fuels.

parameter	adjustment	Resulting adjustment in energy and co2 (%);
adjustment("evd",r,i)$sum(g,evd(i,g,r))   = round(100*sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),	
						evd(i,g,r)) /sum(g,evd(i,g,r)), 1);
adjustment("evd",r,"total")               = round(100*sum(i, sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),	
						evd(i,g,r)))/sum((i,g),evd(i,g,r)), 1);

adjustment("eco2",r,i)$sum(g,eco2(i,g,r)) = round(100*sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),	
						eco2(i,g,r))/sum(g,eco2(i,g,r)), 1) + eps;
adjustment("eco2",r,"total")              = round(100*sum(i, sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),	
						eco2(i,g,r)))/sum((i,g),eco2(i,g,r)), 1);
option adjustment:1:2:1;
display adjustment;


alias (i,ii), (g,gg), (r,rr);

parameter	vxm(g,r)	Export volume (total);
vxm(i,r) =  sum(s, vxmd(i,r,s)) + vst(i,r);

parameter	theta(g,*)	Aggregate value shares;

*	Value shares in global economy:

theta(i,"vxm") = max(1e-5,sum(r,vxm(i,r))/sum((j,r),vxm(j,r)));
theta(i,"vim") = max(1e-5,sum(r,vim(i,r))/sum((j,r),vim(j,r)));
theta(i,"vom") = max(1e-5,sum(r,vom(i,r))/sum((j,r),vom(j,r)));
theta(i,"vigm") = max(1e-5,sum(r,vifm(i,"g",r))/sum((j,r),vifm(j,"g",r)));
theta(i,"vdgm") = max(1e-5,sum(r,vdfm(i,"g",r))/sum((j,r),vdfm(j,"g",r)));
theta(i,"vipm") = max(1e-5,sum(r,vifm(i,"c",r))/sum((j,r),vifm(j,"c",r)));
theta(i,"vdpm") = max(1e-5,sum(r,vdfm(i,"c",r))/sum((j,r),vdfm(j,"c",r)));

set	noevd(i,g,r)		Elements for which evd>0 and vifm+vdfm=0, 
	noevt(i,r,s)		Elements for which evt>0 and vxmd=0, 
	noeco2(i,g,r)		Elements for which eco2>0 and vifm+vdfm=0,
	nonco2(nco2,*,g,r)	Elements for which enco2>0 and vifm+vdfm=0;

noevd(i,g,r)$evd(i,g,r) = yes$(vifm(i,g,r)+vdfm(i,g,r)=0);
noevt(i,r,s)$evt(i,r,s) = yes$(vxmd(i,r,s)=0);
noeco2(i,g,r)$eco2(i,g,r) = yes$(vifm(i,g,r)+vdfm(i,g,r)=0);
nonco2(nco2,i,g,r)$enco2(nco2,i,g,r) = yes$(vifm(i,g,r)+vdfm(i,g,r)=0);
nonco2(nco2,f,g,r)$enco2(nco2,f,g,r) = yes$(vfm(f,g,r)=0);
nonco2(nco2,"process",j,r)$enco2(nco2,"process",j,r) = yes$(vom(j,r)=0);
display "Energy flows dropped -- set ND=0 if you want to retain these:", noevd, noevt, noeco2, nonco2;

parameter	totnco2(*,*,nco2)	NCO2 totals;
totnco2("region",r,nco2) = sum((i,g), enco2(nco2,i,g,r))+sum((f,g), enco2(nco2,f,g,r)) + sum(j, enco2(nco2,"process",j,r));
totnco2("sector",j,nco2) = sum((i,r), enco2(nco2,i,j,r))+sum((f,r), enco2(nco2,f,j,r)) + sum(r, enco2(nco2,"process",j,r));
totnco2("commodity",i,nco2) = sum((g,r), enco2(nco2,i,g,r));
totnco2("factor",f,nco2) = sum((g,r),  enco2(nco2,f,g,r));
display totnco2;

parameter
	evdratio(i,g,r)		Energy demand ratio
	evtratio(i,r,s)		Energy trade ratio
	eco2ratio(i,g,r)	Carbon emissions ratio
	etrace(*,r,*,*)		Energy flow trace
	tevd(i,r)		Total energy volume demanded (mtoe),
	tevt(i,r)		Total energy volume exported (mtoe),
	tco2(i,r)		Total CO2 emissions total (Gg),
	tnco2(nco2,r)		Total NCO2 emissions total (MM ton C-eq);

tevd(i,r) = sum(g,evd(i,g,r));
tevt(i,r) = sum(s,evt(i,r,s));
tco2(i,r) = sum(g, eco2(i,g,r));
tnco2(nco2,r) = sum((i,g), enco2(nco2,i,g,r)) + sum((f,g), enco2(nco2,f,g,r)) + sum(g, enco2(nco2,"process",g,r));
etrace("tevd",r,i,"source") = tevd(i,r);
etrace("tevt",r,i,"source") = tevt(i,r);
etrace("tco2",r,i,"source") = tco2(i,r);
etrace("tnco2",r,nco2,"source") = tnco2(nco2,r);

*	Drop energy flows corresponding to negligible economic 
*	flows:

evd(noevd(i,g,r)) = 0;
evt(noevt(i,r,s)) = 0;
eco2(noeco2(i,g,r)) = 0;
enco2(nonco2(nco2,i,g,r)) = 0;
enco2(nonco2(nco2,"process",j,r)) = 0;
enco2(nonco2(nco2,f,g,r)) = 0;

evdratio(i,g,r)$evd(i,g,r) = evd(i,g,r)/(vifm(i,g,r)+vdfm(i,g,r));
evtratio(i,r,s)$evt(i,r,s) = evt(i,r,s)/vxmd(i,r,s);
eco2ratio(i,g,r)$eco2(i,g,r) = eco2(i,g,r)/(vifm(i,g,r)+vdfm(i,g,r));

tevd(i,r) = sum(g,evd(i,g,r));
tevt(i,r) = sum(s,evt(i,r,s));
tco2(i,r) = sum(g, eco2(i,g,r));
tnco2(nco2,r) = sum((i,g), enco2(nco2,i,g,r)) + sum((f,g), enco2(nco2,f,g,r)) + sum(g, enco2(nco2,"process",g,r));

etrace("tevd",r,i,"filtered") = tevd(i,r);
etrace("tevt",r,i,"filtered") = tevt(i,r);
etrace("tco2",r,i,"filtered") = tco2(i,r);
etrace("tnco2",r,nco2,"filtered") = tnco2(nco2,r);

etrace("tevd",r,i,"adjust")$etrace("tevd",r,i,"source") = (etrace("tevd",r,i,"filtered")/etrace("tevd",r,i,"source")-1);
etrace("tevt",r,i,"adjust")$etrace("tevt",r,i,"source") = (etrace("tevt",r,i,"filtered")/etrace("tevt",r,i,"source")-1);
etrace("tco2",r,i,"adjust")$etrace("tco2",r,i,"source") = (etrace("tco2",r,i,"filtered")/etrace("tco2",r,i,"source")-1);
etrace("tnco2",r,i,"adjust")$etrace("tnco2",r,i,"source") = (etrace("tnco2",r,i,"filtered")/etrace("tnco2",r,i,"source")-1);
option etrace:3:2:1;
display etrace;

*	Filter demand functions except those associated with energy demand or carbon emissions:

vifm(j,i,r)$(evd(j,i,r)=0     and eco2(j,i,r)=0   and vifm(j,i,r) < tol*vom(i,r)) = 0;
vifm(i,"g",r)$(evd(i,"g",r)=0 and eco2(i,"g",r)=0 and vifm(i,"g",r)/sum(j,vifm(j,"g",r)) < 10*tol*theta(i,"vigm")) = 0;
vifm(i,"c",r)$(evd(i,"c",r)=0 and eco2(i,"c",r)=0 and vifm(i,"c",r)/sum(j,vifm(j,"c",r)) < 10*tol*theta(i,"vipm")) = 0;

vdfm(i,j,r)$(evd(j,i,r)=0 and eco2(j,i,r)=0 and vdfm(i,j,r) < tol*vom(j,r)) = 0;
vdfm(i,"g",r)$(evd(i,"g",r)=0 and eco2(i,"g",r)=0 and vdfm(i,"g",r)/sum(j,vdfm(j,"g",r)) < 10*tol*theta(i,"vdgm")) = 0;
vdfm(i,"c",r)$(evd(i,"c",r)=0 and eco2(i,"c",r)=0 and vdfm(i,"c",r)/sum(j,vdfm(j,"c",r)) < 10*tol*theta(i,"vdpm")) = 0;

adjustment("evd",r,i)$sum(g,evd(i,g,r))   = sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),		evd(i,g,r)) /sum(g,evd(i,g,r));
adjustment("evd",r,"total")               = sum(i, sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),	evd(i,g,r)))/sum((i,g),evd(i,g,r));
adjustment("eco2",r,i)$sum(g,eco2(i,g,r)) = sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),		eco2(i,g,r))/sum(g,eco2(i,g,r));
adjustment("eco2",r,"total")              = sum(i, sum(g$(vifm(i,g,r)+vdfm(i,g,r)=0),	eco2(i,g,r)))/sum((i,g),eco2(i,g,r));
display adjustment;

set dropexports(i,r);

*	Drop exports if a given region exports as a fraction of total
*	exports is much smaller than the share of that commodity exports in
*	the total:

dropexports(i,r) = yes$(vxm(i,r)/sum(j,vxm(j,r)) < 10*tol*theta(i,"vxm"));

*	Drop imports if regional imports are very small relative to 
*	the import share in the world:

set dropimports(i,r);
dropimports(i,r) = yes$(vim(i,r)/sum(j,vim(j,r)) < 10*tol*theta(i,"vim"));
dropimports(i,r)$(not dropimports(i,r)) = yes$(sum(g,vifm(i,g,r))=0);

*	Drop production if the production share is small relative to the 
*	world share:

set dropprod(i,r) /(gdt,gas).chn /;
dropprod(i,r)$(not dropprod(i,r)) = yes$(vom(i,r)/sum(j,vom(j,r)) < 10*tol*theta(i,"vom"));
dropprod(i,r)$(not dropprod(i,r)) = yes$(vxm(i,r)+sum(g$(not sameas(i,g)),vdfm(i,g,r))=0);
dropexports(dropprod(i,r)) = yes;

parameter     regtotals       Regional totals - echo print
	      regtrade        Regional bilateral trade echo print
	      sectotals       Sectoral totals -- echo print
	      sectrade        Sectoral bilateral trade echo print;

regtotals(r,"vom0") = sum(i$vom(i,r),1);
regtotals(r,"vom3") = sum(i,vom(i,r));
regtotals(r,"vxm0") = sum(i$vxm(i,r),1);
regtotals(r,"vxm3") = sum(i,vxm(i,r));
regtotals(r,"vim0") = sum(i$vim(i,r),1);
regtotals(r,"vim3") = sum(i,vim(i,r));

sectotals(i,"vom0") = sum(r$vom(i,r),1);
sectotals(i,"vom3") = sum(r,vom(i,r));
sectotals(i,"vxm0") = sum(r$vxm(i,r),1);
sectotals(i,"vxm3") = sum(r,vxm(i,r));
sectotals(i,"vim0") = sum(r$vim(i,r),1);
sectotals(i,"vim3") = sum(r,vim(i,r));

regtrade(r,"vxmd_m0") = sum((i,s)$vxmd(i,s,r),1);
regtrade(r,"vxmd_x0") = sum((i,s)$vxmd(i,r,s),1);
regtrade(r,"vxmd_m3") = sum((i,s), vxmd(i,s,r));
regtrade(r,"vxmd_x3") = sum((i,s), vxmd(i,r,s));

sectrade(i,"vxmd0") = sum((r,s)$vxmd(i,s,r),1);
sectrade(i,"vxmd3") = sum((r,s), vxmd(i,s,r));

parameter       regstat         Filtering Statistics -- Regions,
		comstat         Filtering Statistics -- Commodities;

regstat(r,"vxm#") = 100 * sum(dropexports(i,r),1)/card(i);
regstat(r,"vxm%") = 100 * sum(dropexports(i,r),vxm(i,r))/sum(j,vxm(j,r));

comstat(i,"vxm#") = 100 * sum(dropexports(i,r),1)/card(r);
comstat(i,"vxm%")$sum(r,vxm(i,r)) = 100 * sum(dropexports(i,r),vxm(i,r))/sum(r,vxm(i,r));

vxmd(i,r,s)$dropexports(i,r) = 0;
vtwr(j,i,r,s)$dropexports(i,r) = 0;
rtxs(i,r,s)$dropexports(i,r) = 0;
rtms(i,r,s)$dropexports(i,r) = 0;

parameter       ndropped        Number of items to be dropped;
ndropped("prod") = 0;
ndropped("imports") = 0;

*	Now do the filtering, with a subsequent sparsity check at each stage:

while ((ndropped("prod")<>card(dropprod)) and (ndropped("imports")<>card(dropimports)),

      ndropped("prod") = card(dropprod);
      ndropped("imports") = card(dropimports);

      vdfm(i,"g",r)$dropprod(i,r) = 0;
      vdfm(i,"c",r)$dropprod(i,r) = 0;
      vxmd(i,r,s)$dropprod(i,r) = 0;
      vtwr(j,i,r,s)$dropprod(i,r) = 0;
      rtxs(i,r,s)$dropprod(i,r) = 0;
      rtms(i,r,s)$dropprod(i,r) = 0;
      vst(i,r)$dropprod(i,r) = 0;
      vfm(f,i,r)$dropprod(i,r) = 0;
      vdfm(j,i,r)$dropprod(i,r) = 0;
      vifm(j,i,r)$dropprod(i,r) = 0;

      dropimports(i,r)$(not dropimports(i,r)) = yes$(sum(g,vifm(i,g,r))=0);

      vxm(i,r) =  sum(s, vxmd(i,r,s)) + vst(i,r);
      vxmd(i,s,r)$dropimports(i,r) = 0;
      vtwr(j,i,s,r)$dropimports(i,r) = 0;
      rtxs(i,s,r)$dropimports(i,r) = 0;
      rtms(i,s,r)$dropimports(i,r) = 0;

      dropprod(i,r)$(not dropprod(i,r)) = yes$(vxm(i,r)+sum(g$(not sameas(g,i)),vdfm(i,g,r))=0);
);
regstat(r,"vim%") = 100 * sum(dropimports(i,r),vim(i,r))/sum(j,vim(j,r));
regstat(r,"vim#") = 100 * sum(dropimports(i,r),1)/card(i);
regstat(r,"vom%") = 100 * sum(dropprod(i,r),vom(i,r))/sum(j,vom(j,r));
regstat(r,"vom#") = 100 * sum(dropprod(i,r),1)/card(i);

comstat(i,"vim%")$sum(r,vim(i,r)) = 100 * sum(dropimports(i,r),vim(i,r))/sum(r,vim(i,r));
comstat(i,"vim#") = 100 * sum(dropimports(i,r),1)/card(r);
comstat(i,"vom%")$sum(r,vom(i,r)) = 100 * sum(dropprod(i,r),vom(i,r))/sum(r,vom(i,r));
comstat(i,"vom#") = 100 * sum(dropprod(i,r),1)/card(r);

vxm(i,r) =  sum(s, vxmd(i,r,s)) + vst(i,r);
vim(i,r) = sum(s,(vxmd(i,s,r)*(1-rtxs(i,s,r))+sum(j,vtwr(j,i,s,r)))*(1+rtms(i,s,r)));

set droptrade;
droptrade(i,r,s)$vxmd(i,r,s) = yes$(evt(i,r,s)=0 and vxmd(i,r,s) < tol/10 * min( vxm(i,r), vim(i,s)));

regstat(r,"vxmd_x#") = 100 * sum(droptrade(i,r,s),1)/sum((i,s)$vxmd(i,r,s), 1);
regstat(r,"vxmd_x%") = 100 * sum(droptrade(i,r,s),vxmd(i,r,s))/sum((i,s), vxmd(i,r,s));
regstat(r,"vxmd_m#") = 100 * sum(droptrade(i,s,r),1)/sum((i,s)$vxmd(i,s,r), 1);
regstat(r,"vxmd_m%") = 100 * sum(droptrade(i,s,r),vxmd(i,s,r))/sum((i,s), vxmd(i,s,r));

comstat(i,"vxmd_x#")$sum((r,s)$vxmd(i,r,s), 1) = 100 * sum(droptrade(i,r,s),1)/sum((r,s)$vxmd(i,r,s), 1);
comstat(i,"vxmd_x%")$sum((r,s), vxmd(i,r,s)) = 100 * sum(droptrade(i,r,s),vxmd(i,r,s))/sum((r,s), vxmd(i,r,s));
comstat(i,"vxmd_m#")$sum((r,s)$vxmd(i,s,r), 1) = 100 * sum(droptrade(i,s,r),1)/sum((r,s)$vxmd(i,s,r), 1);
comstat(i,"vxmd_m%")$sum((r,s), vxmd(i,s,r)) = 100 * sum(droptrade(i,s,r),vxmd(i,s,r))/sum((r,s), vxmd(i,s,r));
display regstat,comstat;

*	Zero out the arrays which are not to be included:

vxmd(i,r,s)$droptrade(i,r,s) = 0;
vtwr(j,i,r,s)$droptrade(i,r,s) = 0;
rtxs(i,r,s)$droptrade(i,r,s) = 0;
rtms(i,r,s)$droptrade(i,r,s) = 0;
vim(i,r)$(sum(s,vxmd(i,s,r))=0) = 0;
vifm(i,g,r)$(vim(i,r)=0) = 0;

*       Aggregate value of imports:

vim(i,r) = sum(s,(vxmd(i,s,r)*(1-rtxs(i,s,r))+sum(j,vtwr(j,i,s,r)))*(1+rtms(i,s,r)));

*       Rescale transport demand:

vst(i,r)$sum(s,vst(i,s)) = vst(i,r) * sum((j,s,rr), vtwr(i,j,s,rr)) / sum(s, vst(i,s));
vxm(i,r) =  sum(s, vxmd(i,r,s)) + vst(i,r);

set     rb(r)   Region to be balanced;

variables
      obj             Objective function;

positive variables
      vdm_(g,r)       Calibrated value of vdm,
      vifm_(i,g,r)    Calibrated value of vifm,
      vdfm_(i,g,r)    Calibrated value of vifm,
      vfm_(f,g,r)     Calibrated value of vfm;

equations       objbal, profit, dommkt, impmkt;

scalar  target /1/, penalty /1e3/;

parameter	weight(i,g,r)	Weight applied on demand function adjustments;

weight(i,g,r) = 1 + 99$(evd(i,g,r)>0 or eco2(i,g,r)>0);

objbal..        obj =e= sum((r,i)$rb(r),
      sum(f, (vfm(f,i,r)  * sqr(vfm_(f,i,r) /vfm(f,i,r) -1))$vfm(f,i,r)) +
      sum(g, (weight(i,g,r)*vifm(i,g,r) * sqr(vifm_(i,g,r)/vifm(i,g,r)-1))$vifm(i,g,r) +
             (weight(i,g,r)*vdfm(i,g,r) * sqr(vdfm_(i,g,r)/vdfm(i,g,r)-1))$vdfm(i,g,r)))$target +

*       Use linear penalty term to impose sparsity:

      penalty * sum((r,i)$rb(r),	sum(f,	vfm_(f,i,r)$(vfm(f,i,r)=0)) +
					sum(g,	vifm_(i,g,r)$(vifm(i,g,r)=0) +
						vdfm_(i,g,r)$(vdfm(i,g,r)=0)));

profit(g,r)$(rb(r) and (vdm_.up(g,r)+vxm(g,r)>0)).. (vdm_(g,r)+vxm(g,r))*(1-rto(g,r)) =e=
      sum(i, vifm_(i,g,r)*(1+rtfi(i,g,r)) + vdfm_(i,g,r)*(1+rtfd(i,g,r))) + sum(f, vfm_(f,g,r)*(1+rtf(f,g,r)));

dommkt(i,r)$(rb(r) and vdm_.up(i,r)>0)..     vdm_(i,r) =e= sum(g, vdfm_(i,g,r));
impmkt(i,r)$(rb(r) and vim(i,r)>0)..     vim(i,r)  =e= sum(g, vifm_(i,g,r));
model calib /all/;

vdm_.l(g,r)    = vdm(g,r);
vfm_.l(f,i,r)  = vfm(f,i,r);
vifm_.l(i,g,r) = vifm(i,g,r);
vdfm_.l(i,g,r) = vdfm(i,g,r);

vdm_.fx(i,r)$(vdm_.l(i,r)=0) = 0;
vfm_.fx(f,g,r)$(vfm_.l(f,g,r)=0) = 0;
vifm_.fx(i,g,r)$(vifm_.l(i,g,r)=0) = 0;
vdfm_.fx(i,g,r)$(vdfm_.l(i,g,r)=0) = 0;
vdfm_.fx(i,i,r) = vdfm_.l(i,i,r);
vdfm_.fx(i,g,r)$(vdm_.up(i,r)=0) = 0;
vifm_.fx(i,g,r)$(vim(i,r)=0) = 0;

vdfm_.fx(i,g,r)$(vdm_.up(g,r)+vxm(g,r)=0) = 0;
vifm_.fx(i,g,r)$(vdm_.up(g,r)+vxm(g,r)=0) = 0;
vfm_.fx(f,g,r)$(vdm_.up(g,r)+vxm(g,r)=0) = 0;

parameter	edchk	Cross check on energy demands;
edchk(i,r)$sum(g,evd(i,g,r)+eco2(i,g,r)) = vim(i,r) - sum(g, vifm(i,g,r));
display edchk;


parameter       feas    Feasibility check;
feas(r,g) = (vdm_.l(g,r)+vxm(g,r))*(1-rto(g,r)) - ( sum(i, vifm_.l(i,g,r)*(1+rtfi(i,g,r))
	      + vdfm_.l(i,g,r)*(1+rtfd(i,g,r))) + sum(f, vfm_.l(f,g,r)*(1+rtf(f,g,r))));
display feas;

*	Define scaling to improve numerics:

vdm_.scale(g,r)$round(vdm(g,r),5)       = vdm(g,r);
vfm_.scale(f,i,r)$round(vfm(f,i,r),5)   = vfm(f,i,r);
vifm_.scale(i,g,r)$round(vifm(i,g,r),5) = vifm(i,g,r);
vdfm_.scale(i,g,r)$round(vdfm(i,g,r),5) = vdfm(i,g,r);

profit.scale(g,r)$(round(vdm(g,r)+vxm(g,r),5))  = (vdm(g,r)+vxm(g,r))*(1-rto(g,r));
dommkt.scale(i,r)$round(vdm(i,r),5) = vdm(i,r);
impmkt.scale(i,r)$round(vim(i,r),5) = vim(i,r);
calib.scaleopt = 1;

file title_ /'title.cmd'/; title_.nd=0; title_.nw=0;

parameter       itrlog          Iteration log,
		echop           Echoprint of target values;

$set stime %time%
alias (r,rr);

parameter	vidfm(*,i,g)	Aggregate of imported plus domestic demand;

calib.solvelink = 2;
loop(rr,

      rb(rr) = yes;

      vidfm("base",i,g) = vifm(i,g,rr)+vdfm(i,g,rr);
      vidfm("vifm",i,g) = vifm(i,g,rr);
      vidfm("vdfm",i,g) = vdfm(i,g,rr);

*       Update the title bar with the status prior to the solve:

      putclose title_ '@title Balancing  ',rr.tl, '  (',(round(100*(ord(rr)-1)/card(rr))),' %% complete)  ',
		      'Start time: %stime%, Current time: %time% -- Ctrl-S to pause'/;
      execute 'title.cmd';

      echop(i,"vxm") = vxm(i,rr);
      echop(i,"vim") = vim(i,rr);
      echop(i,"vdm") = vdm(i,rr);
      echop(g,"vafm") = sum(i, vifm(i,g,rr)*(1+rtfi(i,g,rr))+vdfm(i,g,rr)*(1+rtfd(i,g,rr)));
      echop(i,"vfm") = sum(f, vfm(f,i,rr)*(1+rtf(f,i,rr)));
      echop(i,"vifm") = sum(g, vifm(i,g,rr));
      echop(i,"vdfm") = sum(g, vdfm(i,g,rr));

*	We have a bug with holdfixed:

$if not set holdfixed $set holdfixed yes
      calib.holdfixed=%holdfixed%;

      calib.solprint = no;
      calib.limrow = 0;
      calib.limcol = 0;
      solve calib using qcp minimizing obj;

      if(     (calib.solvestat <> 1) or
	      (calib.modelstat > 2),

	display "Infeasibility encountered for region: ", rb;

	vdm_.l(g,rr)    = vdm(g,rr);
	vfm_.l(f,i,rr)  = vfm(f,i,rr);
	vifm_.l(i,g,rr) = vifm(i,g,rr);
	vdfm_.l(i,g,rr) = vdfm(i,g,rr);

*	We had a previous failure -- try to solve it with the NLP code:

	calib.solprint = yes;
	calib.limrow = 1000;
	calib.limcol = 1000;
	solve calib using nlp minimizing obj;
	if(   (calib.solvestat <> 1) or
	      (calib.modelstat > 2),
	      vdfm(i,g,r)$(not sameas(r,rr)) = 0;
	      vifm(i,g,r)$(not sameas(r,rr)) = 0;
	      abort "Calibration routine fails:",rb,echop,vdfm,vifm;
      ));

      loop(rb(r),
	vdm(g,r) = vdm_.l(g,r);
	vfm(f,i,r) = vfm_.l(f,i,r);
	vifm(i,g,r) = vifm_.l(i,g,r);
	vdfm(i,g,r) = vdfm_.l(i,g,r);
	vom(g,r) = vdm(g,r);
	vom(i,r) = vdm(i,r) +sum(s, vxmd(i,r,s)) + vst(i,r);
      );
      rb(rr) = no;

      vidfm("adjusted",i,g) = vifm(i,g,rr)+vdfm(i,g,rr);
      vidfm("%diff",i,g)$vidfm("adjusted",i,g) = 100 * (vidfm("adjusted",i,g)/vidfm("base",i,g) - 1);
      vidfm("vifm*",i,g) = vifm(i,g,rr);
      vidfm("vdfm*",i,g) = vdfm(i,g,rr)
);
putclose title_ '@title Balancing complete'/;
execute 'title.cmd';
execute 'del /q "title.cmd"';


*	Drop energy demand and trade flows for which economic data are
*	missing:

evd(i,g,r)  = (vifm(i,g,r)+vdfm(i,g,r)) * evdratio(i,g,r);
evt(i,r,s)  =               vxmd(i,r,s) * evtratio(i,r,s);
eco2(i,g,r) = (vifm(i,g,r)+vdfm(i,g,r)) * eco2ratio(i,g,r);


parameter	evscale(i,r)		Scale factor for adjustment of energy and carbon demands,
		ereport(*,*,i,r)	Report of adjustments in energy and carbon flows;

evscale(i,r)$tevd(i,r) = sum(g,evd(i,g,r))/tevd(i,r);
evd(i,g,r)$evscale(i,r) = evd(i,g,r)/evscale(i,r);
ereport("pct","evd",i,r)$evscale(i,r) =  100 * (1/evscale(i,r)-1);
ereport("diff","evd",i,r) = sum(g,evd(i,g,r)) - tevd(i,r);
evscale(i,r) = 0;

evscale(i,r)$tevt(i,r) = sum(s,evt(i,r,s))/tevt(i,r);
evt(i,r,s)$evscale(i,r) = evt(i,r,s)/evscale(i,r);
ereport("pct","evt",i,r)$evscale(i,r) =  100 * (1/evscale(i,r)-1);
ereport("diff","evt",i,r) = sum(s,evt(i,r,s)) - tevt(i,r);
evscale(i,r) = 0;

evscale(i,r)$tco2(i,r) = sum(g,eco2(i,g,r))/tco2(i,r);
eco2(i,g,r)$evscale(i,r) = eco2(i,g,r)/evscale(i,r);
ereport("pct","eco2",i,r)$evscale(i,r) =  100 * (1/evscale(i,r)-1);
ereport("diff","eco2",i,r) = sum(g,eco2(i,g,r)) - tco2(i,r);
evscale(i,r) = 0;

*.execute_unload 'ereport.gdx',ereport;
*.execute 'gdxxrw i=ereport.gdx o=ereport.xls par=ereport rng="pivotdata!a2" cdim=0';

*	Adjust income and price elasticities:

eta(i,r)$(vdfm(i,"c",r)*(1+rtfd0(i,"c",r))+vifm(i,"c",r)*(1+rtfi0(i,"c",r)) = 0) = 0;
epsilon(i,r)$(vdfm(i,"c",r)*(1+rtfd0(i,"c",r))+vifm(i,"c",r)*(1+rtfi0(i,"c",r)) = 0) = 0;

execute_unload '%datadir%%ds%_%tol%.gdx', r, f, g, i, 
		vfm,
		vdfm,vifm,vxmd,vst,vtwr,
		rto,rtf,rtfd,rtfi,rtxs,rtms,
		esubd,esubva,esubm,etrae,eta,epsilon, evd, evt, eco2, enco2;

regtotals(r,"vom1") = sum(i$vom(i,r),1);
regtotals(r,"vxm1") = sum(i$vxm(i,r),1);
regtotals(r,"vim1") = sum(i$vim(i,r),1);
sectotals(i,"vom1") = sum(r$vom(i,r),1);
sectotals(i,"vxm1") = sum(r$vxm(i,r),1);
sectotals(i,"vim1") = sum(r$vim(i,r),1);

regtotals(r,"vom2")$regtotals(r,"vom0") = 100 * (regtotals(r,"vom1")/regtotals(r,"vom0")-1);
regtotals(r,"vxm2")$regtotals(r,"vxm0") = 100 * (regtotals(r,"vxm1")/regtotals(r,"vxm0")-1);
regtotals(r,"vim2")$regtotals(r,"vim0") = 100 * (regtotals(r,"vim1")/regtotals(r,"vim0")-1);

sectotals(i,"vom2")$sectotals(i,"vom0") = 100 * (sectotals(i,"vom1")/sectotals(i,"vom0")-1);
sectotals(i,"vxm2")$sectotals(i,"vxm0") = 100 * (sectotals(i,"vxm1")/sectotals(i,"vxm0")-1);
sectotals(i,"vim2")$sectotals(i,"vim0") = 100 * (sectotals(i,"vim1")/sectotals(i,"vim0")-1);

regtotals(r,"vom3")$regtotals(r,"vom3") = 100 * (sum(i,vom(i,r))/regtotals(r,"vom3")-1);
regtotals(r,"vxm3")$regtotals(r,"vxm3") = 100 * (sum(i,vxm(i,r))/regtotals(r,"vxm3")-1);
regtotals(r,"vim3")$regtotals(r,"vim3") = 100 * (sum(i,vim(i,r))/regtotals(r,"vim3")-1);

sectotals(i,"vom3")$sectotals(i,"vom3") = 100 * (sum(r,vom(i,r))/sectotals(i,"vom3")-1);
sectotals(i,"vxm3")$sectotals(i,"vxm3") = 100 * (sum(r,vxm(i,r))/sectotals(i,"vxm3")-1);
sectotals(i,"vim3")$sectotals(i,"vim3") = 100 * (sum(r,vim(i,r))/sectotals(i,"vim3")-1);

regtrade(r,"vxmd_m1") = sum((i,s)$vxmd(i,s,r),1);
regtrade(r,"vxmd_x1") = sum((i,s)$vxmd(i,r,s),1);

regtrade(r,"vxmd_m2")$regtrade(r,"vxmd_m0") = 100 * (regtrade(r,"vxmd_m1")/regtrade(r,"vxmd_m0")-1);
regtrade(r,"vxmd_x2")$regtrade(r,"vxmd_x0") = 100 * (regtrade(r,"vxmd_x1")/regtrade(r,"vxmd_x0")-1);

regtrade(r,"vxmd_m3") = 100 * (sum((i,s), vxmd(i,s,r)) / regtrade(r,"vxmd_m3") - 1);
regtrade(r,"vxmd_x3") = 100 * (sum((i,s), vxmd(i,r,s)) / regtrade(r,"vxmd_x3") - 1);

sectrade(i,"vxmd1") = sum((r,s)$vxmd(i,s,r),1);
sectrade(i,"vxmd2")$sectrade(i,"vxmd0") = 100 * (sectrade(i,"vxmd1")/sectrade(i,"vxmd0")-1);
sectrade(i,"vxmd4") = sectrade(i,"vxmd3");
sectrade(i,"vxmd3")$sectrade(i,"vxmd3") = 100 * (sum((r,s), vxmd(i,s,r)) / sectrade(i,"vxmd3") - 1);

*.display regtotals,regtrade,sectotals,sectrade;

execute_unload 'filter.gdx',regtotals,regtrade,sectotals,sectrade,r,i;

$onecho >filterlog.rsp
set=r         rng=RegionalTrade!a6 cdim=0 
set=r         rng=RegionalTotals!a6 cdim=0 
set=i         rng=SectoralTrade!a6 cdim=0 
set=i         rng=SectoralTotals!a6 cdim=0 
par=regtotals cdim=1 clear EpsOut="0" rng=RegionalTotals!a5
par=sectotals cdim=1 clear EpsOut="0" rng=SectoralTotals!a5
par=regtrade  cdim=1 clear EpsOut="0" rng=RegionalTrade!a5
par=sectrade  cdim=1 clear EpsOut="0" rng=SectoralTrade!a5
$offecho

*.execute 'copy filterlog.xls filterlog%tol%.xls';
*.execute 'gdxxrw i=filter.gdx o=filterlog%tol%.xls @filterlog.rsp';
