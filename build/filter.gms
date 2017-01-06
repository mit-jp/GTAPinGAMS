$title	Generate a Sparse Version of the GTAP Dataset

$if not set tol $set tol 01
$set ghgdata yes
$if not set ds $set ds gsd
$if not set output $set output gsd%tol%.gdx
$if not defined tol scalar tol	Tolerance parameter for filtering data /0.%tol%/;

$if not defined vdm $include gtap6data

alias (i,ii);

parameter	vdpm0,vipm0,vdgm0,vigm0,vfm0,vifm0,vdfm0,vdm0;
vdm0(i,r) = vdm(i,r);
vdpm0(i,r) = vdpm(i,r);
vipm0(i,r) = vipm(i,r);
vdgm0(i,r) = vdgm(i,r);
vigm0(i,r) = vigm(i,r);
vfm0(f,i,r) = vfm(f,i,r);
vifm0(i,j,r) = vifm(i,j,r);
vdfm0(i,j,r) = vdfm(i,j,r);

parameter	vxm(i,r)	Export volume,
		gdp(r)		Scale factor
		nz		Count of non-zeros
		trace		Submatrix totals
		ndropped	Number of nonzeros dropped;

ndropped("prod") = 0;
ndropped("imports") = 0;
gdp(r) = sum(i, vdim(i,r)+vdgm(i,r)+vigm(i,r)+vdpm(i,r)+vigm(i,r));
display gdp;

set	dropexports(i,r)	"Logical flag for set vxm(i,r) to zero", 
	dropimports(i,r)	"Logical flag for set vim(i,r) to zero",  
	dropprod(i,r)		"Logical flag for set vom(i,r) to zero", 
	droptrade(i,r,s)	"Logical flag for set vxmd(i,r) to zero"; 

dropexports(i,r) = no;
dropimports(i,r) = no;
dropprod(i,r)	 = no;
droptrade(i,r,s) = no;

alias (r,rr);

set	rb(r)	Region to be balanced;

variables	
	obj		Objective function
	vz		Value of zero values;

positive variables
	vdm_(i,r)	Calibrated value of vdm,
	vifm_(i,j,r)	Calibrated value of vifm, 
	vdfm_(i,j,r)	Calibrated value of vifm, 
	vdgm_(i,r)	Calibrated value of vdgm,
	vdpm_(i,r)	Calibrated value of vdpm,
	vigm_(i,r)	Calibrated value of vigm,
	vipm_(i,r)	Calibrated value of vipm,
	vfm_(f,i,r)	Calibrated value of vfm;

scalar	lsqr /1/, entropy /0/;

equations	objbal, vzdef, profit, dommkt, impmkt;

scalar penalty /100/;

objbal..        obj =e= sum((r,i)$rb(r), (1/gdp(r)) * (
		  (sqr(vdpm_(i,r)-vdpm0(i,r))/vdpm0(i,r))$(vdpm(i,r)<>0)
		+ (sqr(vipm_(i,r)-vipm0(i,r))/vipm0(i,r))$(vipm(i,r)<>0)
		+ (sqr(vdgm_(i,r)-vdgm0(i,r))/vdgm0(i,r))$(vdgm(i,r)<>0)
		+ (sqr(vigm_(i,r)-vigm0(i,r))/vigm0(i,r))$(vigm(i,r)<>0)
		+ sum(f$(vfm(f,i,r)<>0),  sqr(vfm_(f,i,r)-vfm0(f,i,r))  /vfm0(f,i,r))
		+ sum(j$(vifm(i,j,r)<>0), sqr(vifm_(i,j,r)-vifm0(i,j,r))/vifm0(i,j,r))
		+ sum(j$(vdfm(i,j,r)<>0), sqr(vdfm_(i,j,r)-vdfm0(i,j,r))/vdfm0(i,j,r))))
		+ penalty * vz;

*	Use linear penalty term to impose sparsity:

vzdef..		vz =e= sum((r,i)$rb(r), (1/gdp(r)) * (
			vdpm_(i,r)$(vdpm(i,r)=0) +
			vipm_(i,r)$(vipm(i,r)=0) +
			vdgm_(i,r)$(vdgm(i,r)=0) +
			vigm_(i,r)$(vigm(i,r)=0) +
			sum(f, vfm_(f,i,r)$(vfm(f,i,r)=0)) +
			sum(j, vifm_(i,j,r)$(vifm(i,j,r)=0) +
			       vdfm_(i,j,r)$(vdfm(i,j,r)=0))));

profit(i,r)$(rb(r) and vom(i,r)<>0).. 
	(vdm_(i,r)+vxm(i,r))*(1-rto(i,r)) =e=  
		sum(j,	vifm_(j,i,r)*(1+rtfi(j,i,r)) + 
			vdfm_(j,i,r)*(1+rtfd(j,i,r)))  
		+ sum(f, vfm_(f,i,r)*(1+rtf(f,i,r)));

dommkt(i,r)$(rb(r) and vdm(i,r)<>0)..
	vdm_(i,r) =e= vdgm_(i,r) + vdpm_(i,r) 
		+ sum(j,vdfm_(i,j,r)) + vdim(i,r);

impmkt(i,r)$(rb(r) and vim(i,r)<>0)..
	vim(i,r)  =e= vigm_(i,r) + vipm_(i,r) + sum(j, vifm_(i,j,r));

*	Define default scale factorsfor both benchmark values and
*	equilibrium constraints:

vdm_.scale(i,r) = vdm(i,r);
vifm_.scale(i,j,r) = vifm(i,j,r);
vdfm_.scale(i,j,r) = vdfm(i,j,r);
vdgm_.scale(i,r) = vdgm(i,r);
vdpm_.scale(i,r) = vdpm(i,r);
vigm_.scale(i,r) = vigm(i,r);
vipm_.scale(i,r) = vipm(i,r);
vfm_.scale(f,i,r) = vfm(f,i,r);
profit.scale(i,r) = vom(i,r);
dommkt.scale(i,r) = vdm(i,r);
impmkt.scale(i,r) = vim(i,r);

model calib /all/;
model lpfeas /impmkt,dommkt,profit,vzdef/;

calib.holdfixed=yes;
calib.solvelink=2;
lpfeas.holdfixed=2;
lpfeas.solvelink=2;

file title_ /'%gams.scrdir%title.cmd'/; title_.nd=0; title_.nw=0; title_.lw=0;

$set updatetitle no
$if %system.filesys%==MSNT $set updatetitle yes

set	itr	Calibration steps /itr0*itr8/,
	dsitem	Data set items to be balanced
		/vfm,vxmd,vtwr,vifm,vdfm,vipm,vigm,vdpm,vdgm/;

parameter	itrlog		Iteration log,
		nzcount		Non-zero count /0/,
		solvefeas	Solve the feasibility/0/;

loop(itr$(nzcount<>card(vxmd)+card(vtwr)+card(vifm)+card(vdfm)+
		card(vipm)+card(vigm)+card(vdpm)+card(vdgm)+card(vfm)),

	nzcount = card(vxmd)+card(vtwr)+card(vifm)+card(vdfm)+
		card(vipm)+card(vigm)+card(vdpm)+card(vdgm)+card(vfm);

*	Aggregate value of imports:

	vim(i,r) = sum(s,(vxmd(i,s,r)*(1-rtxs(i,s,r))+sum(j,vtwr(j,i,s,r)))*(1+rtms(i,s,r)));

*	Rescale transport demand:

	vst(i,r)$sum(s, vst(i,s)) = vst(i,r) * sum((j,s,rr), vtwr(i,j,s,rr)) / sum(s, vst(i,s));

*	Value of exports:

	vxm(i,r) =  sum(s, vxmd(i,r,s)) + vst(i,r);

*	Production for the domestic market:

	vdm(i,r) = vdpm(i,r) + vdgm(i,r) + sum(j, vdfm(i,j,r)) + vdim(i,r);

*	Aggregate production:

	vom(i,r) = vdm(i,r) + vxm(i,r);

*	Record nonzero counts:

	nz("vfm","count") = card(vfm);
	nz("vxmd","count") = card(vxmd);
	nz("vtwr","count") = card(vtwr);
	nz("vifm","count") = card(vifm);
	nz("vdfm","count") = card(vdfm);
	nz("vipm","count") = card(vipm);
	nz("vigm","count") = card(vigm);
	nz("vdpm","count") = card(vdpm);
	nz("vdgm","count") = card(vdgm);

*	Filter small values here:

	vifm(j,i,r)$(vifm(j,i,r) < tol/10 * vom(i,r)) = 0;
	vdfm(j,i,r)$(vdfm(j,i,r) < tol/10 * vom(i,r)) = 0;
	vipm(i,r)$(vipm(i,r)     < tol/10 * vpm(r)) = 0;
	vdpm(i,r)$(vdpm(i,r)     < tol/10 * vpm(r)) = 0;
	vigm(i,r)$(vigm(i,r)     < tol/10 * vgm(r)) = 0;
	vdgm(i,r)$(vdgm(i,r)     < tol/10 * vgm(r)) = 0;
	vdim(i,r)$(vdim(i,r)     < tol/10 * sum(j,vdim(j,r))) = 0;

*	Decide whether to drop trade and prouduction:

	vim(i,r) = sum(j,vifm(i,j,r)) + vipm(i,r) + vigm(i,r);
	vdm(i,r) = vdgm(i,r)+vdim(i,r)+vdpm(i,r) + sum(j,vdfm(i,j,r));
	dropexports(i,r)$(vxm(i,r) < tol/10*sum(j,vxm(j,r)) and 
		    (smax(s$(vim(i,s)+vdm(i,s)), 
		      (vxmd(i,r,s)*(1-rtxs(i,r,s))+sum(j,vtwr(j,i,r,s)))*(1+rtms(i,r,s)) /
			(vim(i,s)+vdm(i,s))) < tol/10) ) = yes;

	vxmd(i,r,s)$dropexports(i,r) = 0;
	vtwr(j,i,r,s)$dropexports(i,r) = 0;
	rtxs(i,r,s)$dropexports(i,r) = 0;
	rtms(i,r,s)$dropexports(i,r) = 0;

	dropimports(i,r)$( (vim(i,r) < tol/10*sum(j,vim(j,r))) and
		    (smax(s$vom(i,s), vxmd(i,s,r)/vom(i,s)) < tol/10) ) = yes;
	dropimports(i,r)$(vigm(i,r)+vipm(i,r)+sum(j,vifm(i,j,r))=0) = yes;

	vim(i,r)$dropimports(i,r) = 0;

	dropprod(i,r)$(vom(i,r)-vdfm(i,i,r)<tol/10*sum(j,vom(j,r)-vdfm(j,j,r))) = yes;
	dropprod(i,r)$(vxm(i,r)+vdgm(i,r)+vdim(i,r)+vdpm(i,r)
			+sum(j$(not sameas(i,j)),vdfm(i,j,r))=0) = yes;

	while (	(ndropped("prod")   <>card(dropprod)) and 
		(ndropped("imports")<>card(dropimports)),

		ndropped("prod")    = card(dropprod);
		ndropped("imports") = card(dropimports);

		vdm(i,r)$dropprod(i,r) = 0;
		vdgm(i,r)$dropprod(i,r) = 0;
		vdpm(i,r)$dropprod(i,r) = 0;
		vxmd(i,r,s)$dropprod(i,r) = 0;
		vtwr(j,i,r,s)$dropprod(i,r) = 0;
		rtxs(i,r,s)$dropprod(i,r) = 0;
		rtms(i,r,s)$dropprod(i,r) = 0;
		vst(i,r)$dropprod(i,r) = 0;
		vfm(f,i,r)$dropprod(i,r) = 0;
		vdfm(j,i,r)$dropprod(i,r) = 0;
		vifm(j,i,r)$dropprod(i,r) = 0;
		vdfm(i,j,r)$dropprod(i,r) = 0;
		vdim(i,r)$dropprod(i,r) = 0;

		dropimports(i,r)$(not dropimports(i,r))
			= yes$(vigm(i,r)+vipm(i,r)+sum(j,vifm(i,j,r))=0);

		vxm(i,r) = sum(s, vxmd(i,r,s)) + vst(i,r);
		vxmd(i,s,r)$dropimports(i,r) = 0;
		vtwr(j,i,s,r)$dropimports(i,r) = 0;
		rtxs(i,s,r)$dropimports(i,r) = 0;
		rtms(i,s,r)$dropimports(i,r) = 0;
		vipm(i,r)$dropimports(i,r) = 0;
		vigm(i,r)$dropimports(i,r) = 0;
		vifm(i,j,r)$dropimports(i,r) = 0;

		dropprod(i,r)$(not dropprod(i,r)) = yes$(vxm(i,r)+vdgm(i,r)+vdpm(i,r)+vdim(i,r)
					+sum(j$(not sameas(j,i)),vdfm(i,j,r))=0);
	);
	display ndropped;

	vxm(i,r) = sum(s, vxmd(i,r,s)) + vst(i,r);
	vdm(i,r) = vdgm(i,r)+vdim(i,r)+vdpm(i,r) + sum(j,vdfm(i,j,r));
	vim(i,r) = sum(s,(vxmd(i,s,r)*(1-rtxs(i,s,r))+sum(j,vtwr(j,i,s,r)))*(1+rtms(i,s,r)));
	droptrade(i,r,s)$vxmd(i,r,s) = yes$(vxmd(i,r,s)<tol * min( vxm(i,r), vim(i,s)));

	vxmd(i,r,s)$droptrade(i,r,s) = 0;
	vtwr(j,i,r,s)$droptrade(i,r,s) = 0;
	rtxs(i,r,s)$droptrade(i,r,s) = 0;
	rtms(i,r,s)$droptrade(i,r,s) = 0;

	vim(i,r)$(sum(s,vxmd(i,s,r))=0) = 0;
	vim(i,r) = sum(s,(vxmd(i,s,r)*(1-rtxs(i,s,r))+sum(j,vtwr(j,i,s,r)))*(1+rtms(i,s,r)));
	vipm(i,r)$(vim(i,r)=0) = 0;
	vigm(i,r)$(vim(i,r)=0) = 0;
	vifm(i,j,r)$(vim(i,r)=0) = 0;

*	Rescale transport demand:

	vst(i,r)$sum(s,vst(i,s)) = vst(i,r) * sum((j,s,rr), vtwr(i,j,s,rr)) / sum(s, vst(i,s));
	vxm(i,r) =  sum(s, vxmd(i,r,s)) + vst(i,r);

*	Fix own-use:

	calib.solvelink=2;
	calib.holdfixed=1;
	option limrow=0,limcol=0,solprint=off;
*.option limrow=1000,limcol=1000;

$set updatetitle no
$if %system.filesys%==MSNT $set updatetitle yes

	trace("vdm",r,"before") = sum(i, vdm(i,r));
	trace("vfm",r,"before") = sum((f,i), vfm(f,i,r));
	trace("vifm",r,"before") = sum((i,j), vifm(i,j,r));
	trace("vdfm",r,"before") = sum((i,j), vdfm(i,j,r));
	trace("vigm",r,"before") = sum(i, vigm(i,r));
	trace("vdgm",r,"before") = sum(i, vdgm(i,r));
	trace("vipm",r,"before") = sum(i, vipm(i,r));
	trace("vdpm",r,"before") = sum(i, vdpm(i,r));
	trace("vxmd",r,"before") = sum((i,s), vxmd(i,r,s));
	trace("vtwr",r,"before") = sum((j,i,s), vtwr(j,i,r,s));

	option nlp=conopt3;
*.option nlp=pathnlp;
	loop(rr,

		rb(rr) = yes;

*	Update the title bar with the status prior to the solve:

		if (%updatetitle%,
		  putclose title_,'@title ',itr.tl,', region  ',rr.tl,' (',(round(100*(ord(rr)-1)/card(rr))),' %%)  ',		'%system.time%/%time% -- Ctrl-S to pause'/; 
		  execute '%gams.scrdir%title.cmd';
		);

		vdm_.l(i,rr)    = vdm(i,rr);
		vfm_.l(f,i,rr)  = vfm(f,i,rr);
		vifm_.l(i,j,rr) = vifm(i,j,rr);
		vdfm_.l(i,j,rr) = vdfm(i,j,rr);
		vdgm_.l(i,rr)   = vdgm(i,rr);
		vdpm_.l(i,rr)   = vdpm(i,rr);
		vigm_.l(i,rr)   = vigm(i,rr);
		vipm_.l(i,rr)   = vipm(i,rr);

*	Set some bounds to avoid numerical problems (Arne keeps us on a
*	short leash):

		vdm_.lo(i,rr)    = 0;	vdm_.up(i,rr)    = gdp(rr);
		vfm_.lo(f,i,rr)  = 0;	vfm_.up(f,i,rr)  = gdp(rr);
		vifm_.lo(i,j,rr) = 0;	vifm_.up(i,j,rr) = gdp(rr);
		vdfm_.lo(i,j,rr) = 0;	vdfm_.up(i,j,rr) = gdp(rr);
		vdgm_.lo(i,rr)   = 0;	vdgm_.up(i,rr)   = gdp(rr);
		vdpm_.lo(i,rr)   = 0;	vdpm_.up(i,rr)   = gdp(rr);
		vigm_.lo(i,rr)   = 0;	vigm_.up(i,rr)   = gdp(rr);
		vipm_.lo(i,rr)   = 0;	vipm_.up(i,rr)   = gdp(rr);

*	Fix to zero any flows associated with omitted markets:

		vdm_.fx(i,rr)$(vdm(i,rr)=0) = 0;
		vdfm_.fx(i,j,rr)$(vdm(i,rr)=0) = 0;
		vdgm_.fx(i,rr)$(vdm(i,rr)=0) = 0;
		vdpm_.fx(i,rr)$(vdm(i,rr)=0) = 0;

		vdm_.fx(i,rr)$(vom(i,rr)=0) = 0;
		vfm_.fx(f,i,rr)$(vom(i,rr)=0) = 0;
		vdfm_.fx(j,i,rr)$(vom(i,rr)=0) = 0;
		vifm_.fx(j,i,rr)$(vom(i,rr)=0) = 0;

		vifm_.fx(i,j,rr)$(vim(i,rr)=0) = 0;
		vigm_.fx(i,rr)$(vim(i,rr)=0) = 0;
		vipm_.fx(i,rr)$(vim(i,rr)=0) = 0;

*	If necessary, we can begin at a feasible point:

		option lp=conopt;
		solve lpfeas using lp minimizing vz;
		if(	(lpfeas.solvestat<>1) or
			(lpfeas.modelstat>2),
			abort "Feasibility model fails:",rb;
		);

		solve calib using nlp minimizing obj;
		if(	(calib.solvestat<>1) or
			(calib.modelstat>2),
			abort "Calibration model fails:",rb;
		);

		vdm(i,rb) = vdgm_.l(i,rb) + vdpm_.l(i,rb) + sum(j,vdfm_.l(i,j,rb)) + vdim(i,rb);
		vfm(f,i,rb)  = vfm_.l(f,i,rb);
		vifm(i,j,rb) = vifm_.l(i,j,rb);
		vdfm(i,j,rb) = vdfm_.l(i,j,rb);
		vdgm(i,rb) = vdgm_.l(i,rb);
		vdpm(i,rb) = vdpm_.l(i,rb);
		vigm(i,rb) = vigm_.l(i,rb);
		vipm(i,rb) = vipm_.l(i,rb);
		vom(i,rb)  = vdm(i,rb) + sum(s, vxmd(i,rb,s)) + vst(i,rb);
		vxm(i,rb)  =  sum(s, vxmd(i,rb,s)) + vst(i,rb);

		rb(rr) = no;
	);
	execute 'rm "%gams.scrdir%title.cmd"';

	nz("vfm","change") = card(vfm) - nz("vfm","count");
	nz("vxmd","change") = card(vxmd) - nz("vxmd","count");
	nz("vtwr","change") = card(vtwr) - nz("vtwr","count");
	nz("vifm","change") = card(vifm) - nz("vifm","count");
	nz("vdfm","change") = card(vdfm) - nz("vdfm","count");
	nz("vipm","change") = card(vipm) - nz("vipm","count");
	nz("vigm","change") = card(vigm) - nz("vigm","count");
	nz("vdpm","change") = card(vdpm) - nz("vdpm","count");
	nz("vdgm","change") = card(vdgm) - nz("vdgm","count");
	option nz:0;
	display nz;

	trace("vdm",r,"after") = sum(i, vdm(i,r));
	trace("vfm",r,"after") = sum((f,i), vfm(f,i,r));
	trace("vifm",r,"after") = sum((i,j), vifm(i,j,r));
	trace("vdfm",r,"after") = sum((i,j), vdfm(i,j,r));
	trace("vigm",r,"after") = sum(i, vigm(i,r));
	trace("vdgm",r,"after") = sum(i, vdgm(i,r));
	trace("vipm",r,"after") = sum(i, vipm(i,r));
	trace("vdpm",r,"after") = sum(i, vdpm(i,r));
	trace("vxmd",r,"after") = sum((i,s), vxmd(i,r,s));
	trace("vtwr",r,"after") = sum((j,i,s), vtwr(j,i,r,s));
	option trace:3:1:1;
	display trace;

	itrlog("nonzeros",itr,dsitem) = nz(dsitem,"count");
	itrlog("change",itr,dsitem) = nz(dsitem,"change");
	itrlog("trace",itr,dsitem) = sum(r,trace(dsitem,r,"before"));
);

option itrlog:3:2:1;
display itrlog;

*	Remove emissions and energy flows for inactive links:

eghg(ghg,i,"dom",j,r)$(vdfm(i,j,r)=0) = 0;
eghg(ghg,i,"imp",j,r)$(vdfm(i,j,r)=0) = 0;
eghg(ghg,i,"dom","hh",r)$(vdpm(i,r)=0) = 0;
eghg(ghg,i,"imp","hh",r)$(vipm(i,r)=0) = 0;
eghg(ghg,i,"dom","govt",r)$(vdgm(i,r)=0) = 0;
eghg(ghg,i,"imp","govt",r)$(vigm(i,r)=0) = 0;

eta(i,r)$(vdpm(i,r)*(1+rtpd0(i,r))+vipm(i,r)*(1+rtpi0(i,r)) = 0) = 0;
epsilon(i,r)$(vdpm(i,r)*(1+rtpd0(i,r))+vipm(i,r)*(1+rtpi0(i,r)) = 0) = 0;

execute_unload '%datadir%%output%',i, r, f, 
		vdgm,vigm,vdpm,vipm,vdim,vfm,
		vdfm,vifm,vxmd,vst,vtwr,
		evf,evh,evt,evq,eghg,
		rto,rtf,rtpd,rtpi,rtgd,rtgi,rtfd,rtfi,rtxs,rtms,
		esubd,esubva,esubm,etrae,eta,epsilon;
