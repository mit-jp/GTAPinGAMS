$title	Rebalance -- an include file for rebalancing domestic flows in a GTAP database

alias (r,rr);

$if not declared vxm   parameter  vxm(i,r)	Aggregate exports;

*	Aggregate value of imports:

vim(i,r) = sum(s,(vxmd(i,s,r)*(1-rtxs(i,s,r))+sum(j,vtwr(j,i,s,r)))*(1+rtms(i,s,r)));

*	Rescale transport demand:

vst(i,r)$sum(s,vst(i,s)) = vst(i,r) * sum((j,s,rr), vtwr(i,j,s,rr)) / sum(s, vst(i,s));
vxm(i,r) =  sum(s, vxmd(i,r,s)) + vst(i,r);

set	rb(r)	Region to be balanced;

variables	
	obj		Objective function;

positive variables
	vdm_(i,r)	Calibrated value of vdm,
	vifm_(i,j,r)	Calibrated value of vifm, 
	vdfm_(i,j,r)	Calibrated value of vifm, 
	vdgm_(i,r)	Calibrated value of vdgm,
	vdpm_(i,r)	Calibrated value of vdpm,
	vigm_(i,r)	Calibrated value of vigm,
	vipm_(i,r)	Calibrated value of vipm,
	vfm_(f,i,r)	Calibrated value of vfm;

equations	objbal, profit, dommkt, impmkt;

scalar penalty /1000/;

objbal..        obj =e= 1e-5 * sum((r,i)$rb(r),
		(vdpm(i,r) * sqr(vdpm_(i,r)/vdpm(i,r)-1))$vdpm(i,r) +
		(vipm(i,r) * sqr(vipm_(i,r)/vipm(i,r)-1))$vipm(i,r) +
		(vdgm(i,r) * sqr(vdgm_(i,r)/vdgm(i,r)-1))$vdgm(i,r) +
		(vigm(i,r) * sqr(vigm_(i,r)/vigm(i,r)-1))$vigm(i,r) +
	sum(f,	(vfm(f,i,r)  * sqr(vfm_(f,i,r) /vfm(f,i,r) -1))$vfm(f,i,r)) + 
	sum(j,	(vifm(i,j,r) * sqr(vifm_(i,j,r)/vifm(i,j,r)-1))$vifm(i,j,r) +
		(vdfm(i,j,r) * sqr(vdfm_(i,j,r)/vdfm(i,j,r)-1))$vdfm(i,j,r))) 

*	Use linear penalty term to impose sparsity:

	+ penalty * sum((r,i)$rb(r),
			vdpm_(i,r)$(vdpm(i,r)=0) +
			vipm_(i,r)$(vipm(i,r)=0) +
			vdgm_(i,r)$(vdgm(i,r)=0) +
			vigm_(i,r)$(vigm(i,r)=0) +
			sum(f, vfm_(f,i,r)$(vfm(f,i,r)=0)) +
			sum(j, vifm_(i,j,r)$(vifm(i,j,r)=0) +
			       vdfm_(i,j,r)$(vdfm(i,j,r)=0)));

profit(i,r)$rb(r).. (vdm_(i,r)+vxm(i,r))*(1-rto(i,r)) =e=  
	sum(j, vifm_(j,i,r)*(1+rtfi(j,i,r)) + vdfm_(j,i,r)*(1+rtfd(j,i,r)))  
      + sum(f, vfm_(f,i,r)*(1+rtf(f,i,r)));

dommkt(i,r)$rb(r)..
	vdm_(i,r) =e= vdgm_(i,r) + vdpm_(i,r) + sum(j,vdfm_(i,j,r)) + vdim(i,r);

impmkt(i,r)$rb(r)..
	vim(i,r)  =e= vigm_(i,r) + vipm_(i,r) + sum(j, vifm_(i,j,r));

model calib /all/;
calib.holdfixed=yes;
calib.solvelink=2;

vdm_.l(i,r)    = vdm(i,r);
vfm_.l(f,i,r)  = vfm(f,i,r);
vifm_.l(i,j,r) = vifm(i,j,r);
vdfm_.l(i,j,r) = vdfm(i,j,r);
vdgm_.l(i,r)   = vdgm(i,r);
vdpm_.l(i,r)   = vdpm(i,r);
vigm_.l(i,r)   = vigm(i,r);
vipm_.l(i,r)   = vipm(i,r);

vdm_.fx(i,r)$(vdm_.l(i,r)=0) = 0;
vdgm_.fx(i,r)$(vdgm_.l(i,r)=0) = 0;
vdpm_.fx(i,r)$(vdpm_.l(i,r)=0) = 0;
vigm_.fx(i,r)$(vigm_.l(i,r)=0) = 0;
vipm_.fx(i,r)$(vipm_.l(i,r)=0) = 0;
vfm_.fx(f,i,r)$(vfm_.l(f,i,r)=0) = 0;
vifm_.fx(i,j,r)$(vifm_.l(i,j,r)=0) = 0;
vdfm_.fx(i,j,r)$(vdfm_.l(i,j,r)=0) = 0;
vdfm_.fx(i,i,r) = vdfm_.l(i,i,r);

parameter	profitchk	Benchmark profit check,
		dommktchk	Benchmark domestic market check,
		impmktchk	Benchmark import market check;


$set updatetitle no
$if %system.filesys%==MSNT $set updatetitle yes
file title_ /'%gams.scrdir%title.cmd'/; title_.nd=0; title_.nw=0; 

parameter	itrlog		Iteration log;
alias (r,rr);
loop(rr,

	rb(rr) = yes;

$ontext
	loop(rb(r),
	  profitchk(i,"output") = (vdm_.l(i,r)+vxm(i,r))*(1-rto(i,r));
	  profitchk(i,"vifm") = sum(j, vifm_.l(j,i,r)*(1+rtfi(j,i,r))); 
	  profitchk(i,"vdfm") = sum(j, vdfm_.l(j,i,r)*(1+rtfd(j,i,r)));  
	  profitchk(i,"vfm") = sum(f, vfm_.l(f,i,r)*(1+rtf(f,i,r)));
	  profitchk(i,"deviation") = (vdm_.l(i,r)+vxm(i,r))*(1-rto(i,r)) - (
	  	sum(j, vifm_.l(j,i,r)*(1+rtfi(j,i,r)) + vdfm_.l(j,i,r)*(1+rtfd(j,i,r)))  
	      + sum(f, vfm_.l(f,i,r)*(1+rtf(f,i,r))) );

	  dommktchk(i,"vdm") = vdm_.l(i,r);
	  dommktchk(i,"vdgm") = vdgm_.l(i,r);
	  dommktchk(i,"vdpm") = vdpm_.l(i,r);
	  dommktchk(i,"vdfm") = sum(j,vdfm_.l(i,j,r));
	  dommktchk(i,"vdim") = vdim(i,r);
	  dommktchk(i,"deviation") =  vdm_.l(i,r) - (vdgm_.l(i,r) + vdpm_.l(i,r) 
				+ sum(j,vdfm_.l(i,j,r)) + vdim(i,r));

	  impmktchk(i,"vim") = vim(i,r);
	  impmktchk(i,"vigm") = vigm_.l(i,r);
	  impmktchk(i,"vipm") = vigm_.l(i,r);
	  impmktchk(i,"vifm") = sum(j, vifm_.l(i,j,r));
	  impmktchk(i,"deviation") = vim(i,r) - (vigm_.l(i,r) + vipm_.l(i,r) 
				+ sum(j, vifm_.l(i,j,r)));
	);
	display	profitchk, dommktchk, impmktchk;
$offtext



*	Update the title bar with the status prior to the solve:

	if (%updatetitle%,
	  putclose title_ '@title Balancing  ',rr.tl,
	  '  (',(round(100*(ord(rr)-1)/card(rr))),' %% complete)  ',
	  'Start time: %system.time%, Current time: %time% -- Ctrl-S to pause'/; 
	  execute '%gams.scrdir%title.cmd';
	);

	obj.l = 0;
	solve calib using nlp minimizing obj;

	if(	(calib.solvestat <> 1) or
		(calib.modelstat > 2),
	  vdm_.up(i,rr) = inf;
	  vdgm_.up(i,rr) = inf;
	  vdpm_.up(i,rr) = inf;
	  vigm_.up(i,rr) = inf;
	  vipm_.up(i,rr) = inf;
	  vfm_.up(f,i,rr) = inf;
	  vifm_.up(i,j,rr) = inf;
	  vdfm_.up(i,j,rr) = inf;
	  vdfm_.up(i,i,rr) = inf;
	  obj.l = 0;
	  solve calib using nlp minimizing obj;
	  if(	(calib.solvestat <> 1) or
		(calib.modelstat > 2),
		abort "Calibration routine fails:",rb;
	));

	loop(rb(r),
	  vdm(i,r) = vdgm_.l(i,r) + vdpm_.l(i,r) + sum(j,vdfm_.l(i,j,r)) + vdim(i,r);
	  vfm(f,i,r) = vfm_.l(f,i,r);
	  vifm(i,j,r) = vifm_.l(i,j,r);
	  vdfm(i,j,r) = vdfm_.l(i,j,r);
	  vdgm(i,r) = vdgm_.l(i,r);
	  vdpm(i,r) = vdpm_.l(i,r);
	  vigm(i,r) = vigm_.l(i,r);
	  vipm(i,r) = vipm_.l(i,r);
	  vom(i,r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);
	);
	rb(rr) = no;
);
execute 'rm "%gams.scrdir%title.cmd"';
