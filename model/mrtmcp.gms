$title	GTAP7inGAMS Model in GAMS/MCP Algebraic Format

$if not set ds $set ds emfagg
$include ..\build\gtap7data

parameter	esub(g)		Top-level elasticity indemand /C 1/;

alias (j,jj), (g,gg), (f,ff);

nonnegative variables
	Y(g,r)		Supply
	M(i,r)		Imports
	YT(j)		Transportation services
	FT(f,r)		Specific factor transformation

	P(g,r)		Domestic output price
	PM(j,r)		Import price
	PT(j)		Transportation services
	PF(f,r)		Primary factors rent
	PS(f,g,r)	Sector-specific primary factors
	RA(r)		Representative agent;

equations
	prf_y(g,r)		Supply
	prf_m(i,r)		Imports
	prf_yt(j)		Transportation services
	prf_ft(f,r)		Factor transformation

	mkt_p(g,r)		Domestic output price
	mkt_pm(j,r)		Import price
	mkt_pt(j)		Transportation services
	mkt_pf(f,r)		Primary factors
	mkt_ps(f,j,r)		Specific factor

	inc_ra(r)		Representative agent;

*	-----------------------------------------------------------------------------

*	Define some macros which diagnose the functional form:

$macro	Leontief(sigma)		(yes$(round(sigma,2)=0))
$macro	CobbDouglas(sigma)	(yes$(round(sigma-1,2)=0))
$macro	CES(sigma)		(yes$(round(sigma-1,2)<>0 and round(sigma,2)<>0))

*	-------------------------------------------------------------------------------
*	Profit function for production and consumption activities:

* $prod:Y(g,r)$vom(g,r)	s:esub(g)    i.tl:esubd(i)  va:esubva(g)
* 	o:P(g,r)	q:vom(g,r)	a:RA(r)  t:rto(g,r)
* 	i:P(i,r)	q:vdfm(i,g,r)	p:(1+rtfd0(i,g,r)) i.tl:  a:RA(r) t:rtfd(i,g,r)
* 	i:PM(i,r)	q:vifm(i,g,r)	p:(1+rtfi0(i,g,r)) i.tl:  a:RA(r) t:rtfi(i,g,r)
* 	i:PS(sf,g,r)	q:vfm(sf,g,r)	p:(1+rtf0(sf,g,r))  va:   a:RA(r) t:rtf(sf,g,r)
* 	i:PF(mf,r)	q:vfm(mf,g,r)	p:(1+rtf0(mf,g,r))  va:   a:RA(r) t:rtf(mf,g,r)


*	Benchmark value shares:

parameter	thetaf(f,g,r)	Factor share of value added,
		thetad(i,g,r)	Domestic share of intermediate input,
		thetai(i,g,r)	Import share of intermediate input,
		theta_f(g,r)	Value added share of sectoral output;

thetaf(f,g,r) = 1;
thetaf(f,g,r)$sum(ff,vfm(ff,g,r)*(1+rtf0(ff,g,r)))
	= vfm(f,g,r)*(1+rtf0(f,g,r)) / sum(ff,vfm(ff,g,r)*(1+rtf0(ff,g,r)));

thetad(i,g,r) = 1;
thetad(i,g,r)$(vdfm(i,g,r)*(1+rtfd0(i,g,r)) + vifm(i,g,r)*(1+rtfi0(i,g,r)))
	= vdfm(i,g,r)*(1+rtfd0(i,g,r)) / 
		 (vdfm(i,g,r)*(1+rtfd0(i,g,r)) + vifm(i,g,r)*(1+rtfi0(i,g,r)));
thetai(i,g,r) = 1;
thetai(i,g,r)$vom(g,r)
	= (vdfm(i,g,r)*(1+rtfd0(i,g,r)) + vifm(i,g,r)*(1+rtfi0(i,g,r))) / vom(g,r);

theta_f(g,r) = 1;
theta_f(g,r)$vom(g,r) = sum(ff,vfm(ff,g,r)*(1+rtf0(ff,g,r))) / vom(g,r);

*	User cost indices for factors, domestic and imported
*	intermediate inputs:

$macro P_PF(f,g,r) (((PF(f,r)$mf(f)+PS(f,g,r)$sf(f))*(1+rtf(f,g,r)) \
		/ (1+rtf0(f,g,r)))$thetaf(f,g,r)  + 1$(thetaf(f,g,r) = 0))
$macro P_D(i,g,r)  ((P(i,r)*(1+rtfd(i,g,r)) \
		/ (1+rtfd0(i,g,r)))$thetad(i,g,r) + 1$(thetad(i,g,r)=0))
$macro P_I(i,g,r)  ((PM(i,r)*(1+rtfi(i,g,r)) \
		/ (1+rtfi0(i,g,r)))$(1-thetad(i,g,r)) + 1$(thetad(i,g,r)=1))

*	Compensated cost functions:


$if defined f_ $abort "The CF(g,r) macro requires a uniquely defined alias for f."
alias (f,f_);
$macro CF(g,r) ( \ 
	(sum(f_, thetaf(f_,g,r)*P_PF(f_,g,r)))$Leontief(esubva(g)) + \
	(prod(f_, P_PF(f_,g,r)**thetaf(f_,g,r)))$CobbDouglas(esubva(g)) + \
	(sum(f_, thetaf(f_,g,r)*P_PF(f_,g,r)**(1-esubva(g)))**(1/(1-esubva(g))))$CES(esubva(g)))

$macro CI(i,g,r) ( \
	(thetad(i,g,r)*P_D(i,g,r) + (1-thetad(i,g,r))*P_I(i,g,r))$Leontief(esubd(i)) + \
	(P_D(i,g,r)**thetad(i,g,r) * P_I(i,g,r)**(1-thetad(i,g,r)))$CobbDouglas(esubd(i)) + \
	( (thetad(i,g,r) *P_D(i,g,r)**(1-esubd(i)) + \
	(1-thetad(i,g,r))*P_I(i,g,r)**(1-esubd(i)))**(1/(1-esubd(i))))$CES(esubd(i)))

*	Cost function:

$if defined i_ $abort "The CY(g,r) macro requires a uniquely defined alias for i."
alias (i,i_);
$macro CY(g,r) ( \
  ( sum(i_, thetai(i_,g,r)*CI(i_,g,r)) + theta_f(g,r)*CF(g,r))$Leontief(esub(g)) + \
  (prod(i_, CI(i_,g,r)**thetai(i_,g,r))*CF(g,r)**theta_f(g,r))$CobbDouglas(esub(g)) + \
  ((sum(i_, thetai(i_,g,r)*CI(i_,g,r)**(1-esub(g))) + \
            theta_f(g,r)*CF(g,r)**(1-esub(g)))**(1/(1-esub(g))))$CES(esub(g)) )

prf_y(g,r)$vom(g,r)..		CY(g,r) =e= P(g,r) * (1-rto(g,r));

*	Demand functions:

$macro DDFM(i,g,r) (vdfm(i,g,r) * Y(g,r) * \
			(CY(g,r)/CI(i,g,r))**esub(g) * \
			(CI(i,g,r)/P_D(i,g,r))**esubd(i))$vdfm(i,g,r)
$macro DIFM(i,g,r) (vifm(i,g,r) * Y(g,r) * \
			(CY(g,r)/CI(i,g,r))**esub(g) * \
			(CI(i,g,r)/P_I(i,g,r))**esubd(i))$vifm(i,g,r)
$macro DFM(f,g,r)  (vfm(f,g,r)  * Y(g,r) * \
			(CY(g,r)/CF(g,r))**esub(g) * \
			(CF(g,r)/P_PF(f,g,r))**esubva(g))$vfm(f,g,r)

*	Associated tax revenue flows:

$macro REVTO(r)	 (sum(g$vom(g,r),        rto(g,r)   * P(g,r)  * vom(g,r)*Y(g,r)))
$macro REVTFD(r) (sum((i,g)$vdfm(i,g,r), rtfd(i,g,r)* P(i,r)  * DDFM(i,g,r)))
$macro REVTFI(r) (sum((i,g)$vifm(i,g,r), rtfi(i,g,r)* PM(i,r) * DIFM(i,g,r)))
$macro REVTF(r)	 (sum((f,g)$vfm(f,g,r),  rtf(f,g,r) * PF(f,r) * DFM(f,g,r)))

*	-----------------------------------------------------------------------------
*	Profit function for international transportation services:

*	$prod:YT(j)$vtw(j)  s:1
*		o:PT(j)		q:vtw(j)
*		i:P(j,r)	q:vst(j,r)

prf_yt(j)$vtw(j)..
	prod(r, P(j,r)**(vst(j,r)/vtw(j))) =e= PT(j);

*	Demand Function:

$macro DST(j,r)    (vst(j,r)*YT(j)*PT(j)/P(j,r))$vst(j,r)

*	-----------------------------------------------------------------------------
*	Profit function for bilateral trade aggregation:

* $prod:M(i,r)$vim(i,r)	s:esubm(i)  s.tl:0
*	o:PM(i,r)	q:vim(i,r)
*	i:P(i,s)	q:vxmd(i,s,r)	p:pvxmd(i,s,r) s.tl: a:RA(s) t:(-rtxs(i,s,r)) a:ra(r) t:(rtms(i,s,r)*(1-rtxs(i,s,r)))
*	i:PT(j)#(s)	q:vtwr(j,i,s,r) p:pvtwr(i,s,r) s.tl: a:RA(r) t:rtms(i,s,r)

*	User cost indices:

$macro P_M(i,s,r) ((P(i,s)*(1-rtxs(i,s,r))*(1+rtms(i,s,r))/pvxmd(i,s,r))$vxmd(i,s,r) + 1$(vxmd(i,s,r)=0))
$macro P_T(j,i,s,r) (PT(j)*(1+rtms(i,s,r))/pvtwr(i,s,r))$vtwr(j,i,s,r)

parameter	thetavxmd(i,s,r)	Value share of goods in imports,
		thetavtwr(j,i,s,r)	Value share of transportation services,
		thetam(i,s,r)		Bilateral import value share
		vxmt(i,s,r)		Value of imports gross transport cost;

vxmt(i,s,r)			= vxmd(i,s,r)*pvxmd(i,s,r) + sum(j,vtwr(j,i,s,r)*pvtwr(i,s,r));
thetavxmd(i,s,r)$vxmt(i,s,r)	= vxmd(i,s,r)*pvxmd(i,s,r) / vxmt(i,s,r);
thetavtwr(j,i,s,r)$vxmt(i,s,r)	= vtwr(j,i,s,r)*pvtwr(i,s,r) / vxmt(i,s,r);
thetam(i,s,r)$vim(i,r)		= vxmt(i,s,r)/vim(i,r);

*	Price index of bilateral imports (Leontief cost function):

$if defined j1 $abort "The PT_M(i,s,r) macro requires a uniquely defined alias for j."
alias (j,j1);
$macro PT_M(i,s,r) (P_M(i,s,r)*thetavxmd(i,s,r) + sum(j1, P_T(j1,i,s,r)*thetavtwr(j1,i,s,r)))

*	Unit cost function for imports (CES):

$if defined s_ $abort "The CIM(i,r) macro requires a uniquely defined alias for s."
alias (s,s_);
$macro CIM(i,r) ( \
   sum(s_, thetam(i,s_,r) * PT_M(i,s_,r) )$Leontief(esubm(i)) + \
   prod(s_, PT_M(i,s_,r)**thetam(i,s_,r) )$CobbDouglas(esubm(i)) + \
  (sum(s_, thetam(i,s_,r) * PT_M(i,s_,r)**(1-esubm(i)))**(1/(1-esubm(i))))$CES(esubm(i)) )

prf_m(i,r)$vim(i,r)..	CIM(i,r) =e= PM(i,r);

*	Demand function:

$macro DXMD(i,s,r)   ((vxmd(i,s,r)   * M(i,r) * (PM(i,r)/PT_M(i,s,r))**esubm(i))$vxmd(i,s,r))
$macro DTWR(j,i,s,r) ((vtwr(j,i,s,r) * M(i,r) * (PM(i,r)/PT_M(i,s,r))**esubm(i))$vtwr(j,i,s,r))

*	Associated tax revenue:

$macro REVTXS(r) (sum((i,s)$vxmd(i,r,s), -rtxs(i,r,s) * P(i,r) * dxmd(i,r,s)))

$if defined j2 $abort "The REVTMS(r) macro requires a uniquely defined alias for j."
alias (j,j2);
$macro REVTMS(r) (sum((i,s)$vxmd(i,s,r), rtms(i,s,r) * \
	(P(i,s)*(1-rtxs(i,s,r))*DXMD(i,s,r) + sum(j2, PT(j2)*DTWR(j2,i,s,r)))))

*	-----------------------------------------------------------------------------
*	Transforamtion sector for sluggish factors:

*	$prod:FT(sf,r)$evom(sf,r)  t:etrae(sf)
*		o:PS(sf,j,r)	q:vfm(sf,j,r)
*		i:PF(sf,r)	q:evom(sf,r)


parameter	thetavfm(f,j,r)	Value shares of specific factors;
thetavfm(sf,j,r) = vfm(sf,j,r)/evom(sf,r);

$if defined j3 $abort "The PVFM(sf,r) macro requires a uniquely defined alias for j."
alias (j,j3);
$macro PVFM(sf,r) (sum(j3,thetavfm(sf,j3,r)*PS(sf,j3,r)**(1+etrae(sf)))**(1/(1+etrae(sf))))

prf_ft(sf,r)$evom(sf,r)..	PF(sf,r) =e= PVFM(sf,r);

*	-----------------------------------------------------------------------------
*	Income balance consition:

*	$demand:RA(r)
*	d:P("c",r)	q:vom("c",r)
*	e:P("c",rnum)	q:vb(r)
*	e:P("g",r)	q:(-vom("g",r))
*	e:P("i",r)	q:(-vom("i",r))
*	e:PF(f,r)	q:evom(f,r)

inc_ra(r)$(ra.lo(r) < ra.up(r))..	
	RA(r) =e= sum(rnum, P("c",rnum)*vb(r)) 
			- P("g",r)*vom("g",r) 
			- P("i",r)*vom("i",r) 
			+ sum(f, PF(f,r)*evom(f,r))
			+ REVTO(r) + REVTFD(r) + REVTFI(r) 
			+ REVTF(r) + REVTXS(r) + REVTMS(r);

*	-----------------------------------------------------------------------------
*	Market clearance associated with firm output:

mkt_p(g,r)$vom(g,r)..	

	Y(g,r) * vom(g,r) =e= (RA(r)/P(g,r))$sameas(g,"C") + 
		vom(g,r)$(sameas(g,"G") or sameas(g,"I")) +
		sum(i$sameas(i,g),  sum(gg,DDFM(i,gg,r)) + sum(s,DXMD(i,r,s)) + DST(i,r));

*	-----------------------------------------------------------------------------
*	Market clearance associated with imports:

mkt_pm(i,r)$vim(i,r)..	M(i,r) * vim(i,r) =e= sum(g, DIFM(i,g,r));

*	-----------------------------------------------------------------------------
*	Market clearance associated with transport services:

mkt_pt(j)$vtw(j)..	YT(j) * vtw(j) =e= sum((i,s,r), DTWR(j,i,s,r));

*	-----------------------------------------------------------------------------
*	Market clearance associated with primary factors:

mkt_pf(f,r)$evom(f,r)..	evom(f,r) =e= sum(j, DFM(f,j,r))$mf(f) + (evom(f,r)*FT(f,r))$sf(f);

*	-----------------------------------------------------------------------------
*	Market clearance associated with specific factors:

mkt_ps(sf,j,r)$vfm(sf,j,r)..	
	vfm(sf,j,r) * (PS(sf,j,r)/PF(sf,r))**etrae(sf) * FT(sf,r) =e= DFM(sf,j,r);	

model gtap7mcp /
	prf_y.Y,prf_m.M,prf_yt.YT,prf_ft.FT,
	mkt_p.P,mkt_pm.PM,mkt_pt.PT,mkt_pf.PF,mkt_ps.PS,
	inc_ra.RA/;

model gtap7cns /
	prf_y,prf_m,prf_yt,prf_ft,
	mkt_p,mkt_pm,mkt_pt,mkt_pf,mkt_ps,
	inc_ra/;

*	Assign default values:

Y.L(g,r) = 1;
M.L(i,r) = 1;
YT.L(j) = 1;
FT.L(sf,r) = 1;
P.L(g,r) = 1;
PM.L(j,r) = 1;
PT.L(j) = 1;
PF.L(f,r) = 1;
PS.L(sf,j,r) = 1;
RA.L(r) = vom("c",r);

*	Fix variables which should not enter the model:

Y.FX(g,r)$(vom(g,r)=0) = 1;
M.FX(i,r)$(vim(i,r)=0) = 1;
YT.FX(j)$(vtw(j)=0) = 1;
P.FX(j,r)$(vom(j,r)=0) = 1;
PM.FX(j,r)$(vim(j,r)=0) = 1;
PT.FX(j)$(vtw(j)=0) = 1;
PF.FX(f,r)$(evom(f,r)=0) = 1;
PS.FX(f,g,r)$(not i(g)) = 0;
PS.FX(f,j,r)$((not sf(f)) or (vfm(f,j,r)=0)) = 1;
FT.FX(f,r)$((not sf(f)) or (evom(f,r)=0)) = 1;

*	Establish a price normalization using the reference region:

RA.FX(rnum) = RA.L(rnum);

gtap7mcp.iterlim = 0;
solve gtap7mcp using mcp;
gtap7mcp.iterlim = 10000;

$exit

*	Verify benchmark consistency with both MCP and CNS models:

gtap7cns.iterlim = 0;
solve gtap7cns using cns;
gtap7cns.iterlim = 10000;

*	Run a GFT scenario using the MCP model;

rtxs(i,r,s) = 0;
rtms(i,r,s) = 0;

*	Solve with CNS (does not work):
*	solve gtap7cns using cns;

*	Solve the MCP model:

solve gtap7mcp using mcp;
