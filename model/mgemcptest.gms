$title	Read GTAP6 Basedata and MPSGE

$if not set ds $set ds asa7x5

*	Invoke the function preprocessor to help with equations:

$sysinclude gams-f

$include gtap6data

$ontext
$model:gtap6

$sectors:
	c(r)			! Consumption
	g(r)			! Government demand
	y(i,r)$vom(i,r)		! Supply
	m(i,r)$vim(i,r)		! Imports
	yt(j)$vtw(j)		! Transportation services
	ft(f,r)$(sf(f) and evom(f,r))	! Specific factor transformation

$commodities:
	pc(r)			! Private consumption price index
	pg(r)			! Public consumption price index
	py(j,r)$vom(j,r)	! Domestic output price
	pm(j,r)$vim(j,r)	! Import price
	pt(j)$vtw(j)		! Transportation services
	pf(f,r)$evom(f,r)	! Primary factors rent
	ps(f,j,r)$(sf(f) and vfm(f,j,r))	! Sector-specific primary factors

$consumers:
	ra(r)			! Representative agent

$prod:y(j,r)$vom(j,r)	s:0    i.tl:esubd(i)  va:esubva(j)
	o:py(j,r)	q:vom(j,r)	a:ra(r)  t:rto(j,r)
	i:py(i,r)	q:vdfm(i,j,r)	p:(1+rtfd0(i,j,r)) i.tl:  a:ra(r) t:rtfd(i,j,r)
	i:pm(i,r)	q:vifm(i,j,r)	p:(1+rtfi0(i,j,r)) i.tl:  a:ra(r) t:rtfi(i,j,r)
	i:ps(sf,j,r)	q:vfm(sf,j,r)	p:(1+rtf0(sf,j,r))  va:    a:ra(r) t:rtf(sf,j,r)
	i:pf(mf,r)	q:vfm(mf,j,r)	p:(1+rtf0(mf,j,r))  va:    a:ra(r) t:rtf(mf,j,r)

$prod:yt(j)$vtw(j)  s:1
	o:pt(j)		q:vtw(j)
	i:py(j,r)	q:vst(j,r)

$prod:c(r)  s:1  i.tl:esubd(i)
	o:pc(r)		q:vpm(r)
	i:py(i,r)	q:vdpm(i,r)	i.tl: p:(1+rtpd0(i,r)) a:ra(r) t:rtpd(i,r)
	i:pm(i,r)	q:vipm(i,r)	i.tl: p:(1+rtpi0(i,r)) a:ra(r) t:rtpi(i,r)

$prod:g(r)  s:0  i.tl:esubd(i)
	o:pg(r)		q:vgm(r)
	i:py(i,r)	q:vdgm(i,r)	i.tl: p:(1+rtgd0(i,r)) a:ra(r) t:rtgd(i,r)
	i:pm(i,r)	q:vigm(i,r)	i.tl: p:(1+rtgi0(i,r)) a:ra(r) t:rtgi(i,r)

$prod:m(i,r)$vim(i,r)	s:esubm(i)  s.tl:0
	o:pm(i,r)	q:vim(i,r)
	i:py(i,s)	q:vxmd(i,s,r)	p:pvxmd(i,s,r) s.tl:
+		a:ra(s) t:(-rtxs(i,s,r))
+		a:ra(r) t:(rtms(i,s,r)*(1-rtxs(i,s,r)))
	i:pt(j)#(s)	q:vtwr(j,i,s,r) p:pvtwr(i,s,r) s.tl:
+		a:ra(r) t:rtms(i,s,r)

$prod:ft(sf,r)$evom(sf,r)  t:etrae(sf)
	o:ps(sf,j,r)	q:vfm(sf,j,r)
	i:pf(sf,r)	q:evom(sf,r)

$demand:ra(r)
	d:pc(r)		q:vpm(r)
	e:pc(rnum)	q:vb(r)
	e:pg(r)		q:(-vgm(r))
	e:py(i,r)	q:(-vdim(i,r))
	e:pf(f,r)	q:evom(f,r)

$offtext
$sysinclude mpsgeset gtap6

gtap6.iterlim = 0;
$include gtap6.gen
solve gtap6 using mcp;

alias (j,jj);

positive variables
	c(r)		Consumption
	g(r)		Government demand
	y(i,r)		Supply
	m(i,r)		Imports
	yt(j)		Transportation services
	ft(f,r)		Specific factor transformation

	pc(r)		Private consumption price index
	pg(r)		Public consumption price index
	py(j,r)		Domestic output price
	pm(j,r)		Import price
	pt(j)		Transportation services
	pf(f,r)		Primary factors
	ps(f,j,r)	Sector-specific primary factors

	ra(r)		Representative agent;

equations
	prf_c(r)		Consumption
	prf_g(r)		Government demand
	prf_y(i,r)		Supply
	prf_m(i,r)		Imports
	prf_yt(j)		Transportation services
	prf_ft(f,r)		Factor transformation

	mkt_pc(r)		Private consumption price index
	mkt_pg(r)		Public consumption price index
	mkt_py(j,r)		Domestic output price
	mkt_pm(j,r)		Import price
	mkt_pt(j)		Transportation services
	mkt_pf(f,r)		Primary factors
	mkt_ps(f,j,r)		Specific factor

	inc_ra(r)		Representative agent;

*	-----------------------------------------------------------------------------
*	Profit function for firms:

*	Value shares for firm inputs of factors and goods:

parameter	thetaf(f,j,r)	Factor share of value added,
		thetad(i,j,r)	Domestic share of intermediate input,
		thetai(i,j,r)	Import share of intermediate input,
		theta_f(j,r)	Value added share of sectoral output;

alias (f,ff);
thetaf(f,j,r)$sum(ff,vfm(ff,j,r)*(1+rtf0(ff,j,r)))
	= vfm(f,j,r)*(1+rtf0(f,j,r)) / sum(ff,vfm(ff,j,r)*(1+rtf0(ff,j,r)));
thetad(i,j,r)$(vdfm(i,j,r)*(1+rtfd0(i,j,r)) + vifm(i,j,r)*(1+rtfi0(i,j,r)))
	= vdfm(i,j,r)*(1+rtfd0(i,j,r)) / 
		 (vdfm(i,j,r)*(1+rtfd0(i,j,r)) + vifm(i,j,r)*(1+rtfi0(i,j,r)));

thetai(i,j,r)$vom(j,r)
	= (vdfm(i,j,r)*(1+rtfd0(i,j,r)) + vifm(i,j,r)*(1+rtfi0(i,j,r))) / vom(j,r);

theta_f(j,r)$vom(j,r) = sum(ff,vfm(ff,j,r)*(1+rtf0(ff,j,r))) / vom(j,r);

*	User cost indices for factors, domestic and imported
*	intermediate inputs:

p_pf(f,j,r) == (pf(f,r)$mf(f)+ps(f,j,r)$sf(f))*(1+rtf(f,j,r))/(1+rtf0(f,j,r));
p_d(i,j,r) == py(i,r)*(1+rtfd(i,j,r))/(1+rtfd0(i,j,r));
p_i(i,j,r) == pm(i,r)*(1+rtfi(i,j,r))/(1+rtfi0(i,j,r));

*	Compensated (CES) cost functions:

cf(j,r) == sum(f$thetaf(f,j,r), thetaf(f,j,r) * p_pf(f,j,r)**(1-esubva(j)))**(1/(1-esubva(j)));
ci(i,j,r) == ( (thetad(i,j,r) * p_d(i,j,r)**(1-esubd(i)) +
	     (1-thetad(i,j,r)) * p_i(i,j,r)**(1-esubd(i)) )**(1/(1-esubd(i))) )$thetai(i,j,r);

*	Leontief cost function:

cy(j,r) == sum(i$thetai(i,j,r), thetai(i,j,r) * ci(i,j,r)) + (theta_f(j,r)*cf(j,r))$theta_f(j,r);


prf_y(j,r)$vom(j,r)..		cy(j,r) =e= py(j,r) * (1-rto(j,r));

*	$prod:y(j,r)$vom(j,r)	s:0    i.tl:esubd(i)  va:esubva(j)
*		o:py(j,r)	q:vom(j,r)	a:ra(r)  t:rto(j,r)
*		i:py(i,r)	q:vdfm(i,j,r)	p:(1+rtfd0(i,j,r)) i.tl:  a:ra(r) t:rtfd(i,j,r)
*		i:pm(i,r)	q:vifm(i,j,r)	p:(1+rtfi0(i,j,r)) i.tl:  a:ra(r) t:rtfi(i,j,r)
*		i:pf(f,r)	q:vfm(f,j,r)	p:(1+rtf0(f,j,r))  va:    a:ra(r) t:rtf(f,j,r)
*	-----------------------------------------------------------------------------
*	Profit function for international transportation services:

prf_yt(j)$vtw(j)..
	prod(r, py(j,r)**(vst(j,r)/vtw(j))) =e= pt(j);


*	$prod:yt(j)$vtw(j)  s:1
*		o:pt(j)		q:vtw(j)
*		i:py(j,r)	q:vst(j,r)
*	-----------------------------------------------------------------------------
*	Profit function for private consumption (Cobb-Douglas):

parameter	thetadpm(i,r)	Domestic share of private demand
		thetaipm(i,r)	Import share of private demand
		thetapm(i,r)	Value share of good in in private demand;

thetadpm(i,r)$(vdpm(i,r)*(1+rtpd0(i,r))+vipm(i,r)*(1+rtpi0(i,r)))
	= vdpm(i,r)*(1+rtpd0(i,r)) / 
		(vdpm(i,r)*(1+rtpd0(i,r))+vipm(i,r)*(1+rtpi0(i,r)));
thetaipm(i,r)$(vdpm(i,r)*(1+rtpd0(i,r))+vipm(i,r)*(1+rtpi0(i,r)))
	= vipm(i,r)*(1+rtpi0(i,r)) /
		(vdpm(i,r)*(1+rtpd0(i,r))+vipm(i,r)*(1+rtpi0(i,r)));
thetapm(i,r) = (vdpm(i,r)*(1+rtpd0(i,r))+vipm(i,r)*(1+rtpi0(i,r))) / vpm(r);


*	User cost price indicies:

p_dc(i,r) == py(i,r) * (1+rtpd(i,r)) / (1+rtpd0(i,r));
p_ic(i,r) == pm(i,r) * (1+rtpi(i,r)) / (1+rtpi0(i,r));

*	Unit cost functions (CES):

p_c(i,r) == (thetadpm(i,r)*p_dc(i,r)**(1-esubd(i)) +
	     thetaipm(i,r)*P_ic(i,r)**(1-esubd(i)))**(1/(1-esubd(i)));

prf_c(r)..	prod(i$thetapm(i,r), p_c(i,r)**thetapm(i,r)) =e= pc(r);


*	$prod:c(r)  s:1  i.tl:esubd(i)
*		o:pc(r)		q:vpm(r)
*		i:py(i,r)	q:vdpm(i,r)	i.tl: p:(1+rtpd0(i,r)) a:ra(r) t:rtpd(i,r)
*		i:pm(i,r)	q:vipm(i,r)	i.tl: p:(1+rtpi0(i,r)) a:ra(r) t:rtpi(i,r)
*	-----------------------------------------------------------------------------
*	Profit function for public consumption (Leontief):

parameter	thetadgm(i,r)	Domestic value share in government demand
		thetaigm(i,r)	Import value share in government demand
		thetagm(i,r)	Aggregate value share in government demand;

thetadgm(i,r)$(vdgm(i,r)*(1+rtgd0(i,r))+vigm(i,r)*(1+rtgi0(i,r)))
	= vdgm(i,r)*(1+rtgd0(i,r)) / 
		(vdgm(i,r)*(1+rtgd0(i,r))+vigm(i,r)*(1+rtgi0(i,r)));
thetaigm(i,r)$(vdgm(i,r)*(1+rtgd0(i,r))+vigm(i,r)*(1+rtgi0(i,r)))
	= vigm(i,r)*(1+rtgi0(i,r)) /
		(vdgm(i,r)*(1+rtgd0(i,r))+vigm(i,r)*(1+rtgi0(i,r)));
thetagm(i,r) = (vdgm(i,r)*(1+rtgd0(i,r))+vigm(i,r)*(1+rtgi0(i,r))) / vgm(r);

*	User cost price indices:

p_dg(i,r) == py(i,r) * (1+rtgd(i,r)) / (1+rtgd0(i,r));
p_ig(i,r) == pm(i,r) * (1+rtgi(i,r)) / (1+rtgi0(i,r));

*	Unit cost functions (CES):

p_g(i,r) == (thetadgm(i,r)*p_dg(i,r)**(1-esubd(i)) +
	     thetaigm(i,r)*p_ig(i,r)**(1-esubd(i)))**(1/(1-esubd(i)));

*	Leontief unit cost function:

prf_g(r)..	sum(i,	thetagm(i,r) * p_g(i,r) ) =e= pg(r);


*	$prod:g(r)  s:0  i.tl:esubd(i)
*		o:pg(r)		q:vgm(r)
*		i:py(i,r)	q:vdgm(i,r)	i.tl: p:(1+rtgd0(i,r)) a:ra(r) t:rtgd(i,r)
*		i:pm(i,r)	q:vigm(i,r)	i.tl: p:(1+rtgi0(i,r)) a:ra(r) t:rtgi(i,r)

*	-----------------------------------------------------------------------------
*	Profit function for bilateral trade aggregation:

*	User cost indices:

py_m(i,s,r) == py(i,s) * (1-rtxs(i,s,r))*(1+rtms(i,s,r)) / pvxmd(i,s,r);
pt_m(j,i,s,r) == pt(j) * (1+rtms(i,s,r)) / pvtwr(i,s,r);

parameter	thetavxmd(i,s,r)	Value share of goods in imports,
		thetavtwr(j,i,s,r)	Value share of transportation services,
		thetam(i,s,r)		Bilateral import value share;

thetavxmd(i,s,r)$(vxmd(i,s,r)*pvxmd(i,s,r) + sum(j,vtwr(j,i,s,r)*pvtwr(i,s,r)))
	= vxmd(i,s,r)*pvxmd(i,s,r) / 
		(vxmd(i,s,r)*pvxmd(i,s,r) + sum(j,vtwr(j,i,s,r)*pvtwr(i,s,r)));
thetavtwr(j,i,s,r)$(vxmd(i,s,r)*pvxmd(i,s,r) + sum(jj,vtwr(jj,i,s,r)*pvtwr(i,s,r)))
	= vtwr(j,i,s,r)*pvtwr(i,s,r) /
		(vxmd(i,s,r)*pvxmd(i,s,r) + sum(jj,vtwr(jj,i,s,r)*pvtwr(i,s,r)));
thetam(i,s,r)$vim(i,r) 
	= (vxmd(i,s,r)*pvxmd(i,s,r) + sum(j,vtwr(j,i,s,r)*pvtwr(i,s,r)))/vim(i,r);

*	Price index of bilateral imports (Leontief cost function):

pyt_m(i,s,r) == py_m(i,s,r)*thetavxmd(i,s,r) + sum(j, pt_m(j,i,s,r)*thetavtwr(j,i,s,r));

*	Unit cost function for imports (CES):

cim(i,r) == sum(s$thetam(i,s,r), thetam(i,s,r) * pyt_m(i,s,r)**(1-esubm(i)))**(1/(1-esubm(i)));

prf_m(i,r)$vim(i,r)..	cim(i,r) =e= pm(i,r);


*	$prod:m(i,r)$vim(i,r)	s:esubm(i)  s.tl:0
*		o:pm(i,r)	q:vim(i,r)
*		i:py(i,s)	q:vxmd(i,s,r)	p:pvxmd(i,s,r) s.tl:
*	+		a:ra(s) t:(-rtxs(i,s,r))
*	+		a:ra(r) t:(rtms(i,s,r)*(1-rtxs(i,s,r)))
*		i:pt(j)#(s)	q:vtwr(j,i,s,r) p:pvtwr(i,s,r) s.tl:
*	+		a:ra(r) t:rtms(i,s,r)
*	-----------------------------------------------------------------------------
parameter	thetavfm(f,j,r)	Value shares of specific factors;
thetavfm(sf,j,r) = vfm(sf,j,r)/evom(sf,r);

pvfm(sf,j,r) == sum(j, thetavfm(sf,j,r) * ps(sf,j,r)**(1+etrae(sf)))**(1/(1+etrae(sf)));

prf_ft(sf,r)$evom(sf,r)..	pf(sf,r) =e= pvfm(sf,j,r);

*	$prod:ft(sf,r)$evom(sf,r)  t:etrae(sf)
*		o:ps(sf,j,r)	q:vfm(sf,j,r)
*		i:pf(sf,r)	q:evom(sf,r)
*	-----------------------------------------------------------------------------
*	Demand functions:
*
ddfm(i,j,r) == (vdfm(i,j,r)*y(j,r)*(ci(i,j,r)/p_d(i,j,r))**esubd(i))$vdfm(i,j,r);
difm(i,j,r) == (vifm(i,j,r)*y(j,r)*(ci(i,j,r)/p_i(i,j,r))**esubd(i))$vifm(i,j,r);
dfm(f,j,r)  == (vfm(f,j,r)*y(j,r)*(cf(j,r)/p_pf(f,j,r))**esubva(j))$vfm(f,j,r);
dst(j,r)    == (vst(j,r)*yt(j)*pt(j)/py(j,r))$vst(j,r);
ddpm(i,r)   == (vdpm(i,r)*c(r)*(p_c(i,r)/p_dc(i,r))**esubd(i)*(pc(r)/p_c(i,r)))$vdpm(i,r);
dipm(i,r)   == (vipm(i,r)*c(r)*(p_c(i,r)/p_ic(i,r))**esubd(i)*(pc(r)/p_c(i,r)))$vipm(i,r);
ddgm(i,r)   == (vdgm(i,r)*g(r)*(p_g(i,r)/p_dg(i,r))**esubd(i))$vdgm(i,r);
digm(i,r)   == (vigm(i,r)*g(r)*(p_g(i,r)/p_ig(i,r))**esubd(i))$vigm(i,r);
dxmd(i,s,r) == (vxmd(i,s,r)*m(i,r)*(pm(i,r)/pyt_m(i,s,r))**esubm(i))$vxmd(i,s,r);
dtwr(j,i,s,r) == (vtwr(j,i,s,r)*m(i,r)*(pm(i,r)/pyt_m(i,s,r))**esubm(i))$vtwr(j,i,s,r);

*	-----------------------------------------------------------------------------
*	Regional tax revenue by tax instrument:

revto(r) == sum(j$vom(j,r), rto(j,r) * vom(j,r) * py(j,r) * y(j,r));
revtfd(r) == sum((i,j)$vdfm(i,j,r), rtfd(i,j,r)*py(i,r)*ddfm(i,j,r));
revtfi(r) == sum((i,j)$vifm(i,j,r), rtfi(i,j,r)*pm(i,r)*difm(i,j,r));
revtf(r) == sum((f,j)$vfm(f,j,r), rtf(f,j,r)*pf(f,r)*dfm(f,j,r));
revtpd(r) == sum(i$vdpm(i,r), rtpd(i,r) * py(i,r) * ddpm(i,r));
revtpi(r) == sum(i$vipm(i,r), rtpi(i,r) * pm(i,r) * dipm(i,r));
revtgd(r) == sum(i$vdgm(i,r), rtgd(i,r) * py(i,r) * ddgm(i,r));
revtgi(r) == sum(i$vigm(i,r), rtgi(i,r) * pm(i,r) * digm(i,r));
revtxs(r) == sum((i,s)$vxmd(i,r,s), -rtxs(i,r,s) * py(i,r) * dxmd(i,r,s));
revtms(r) == sum((i,s)$thetam(i,s,r), rtms(i,s,r) * 
	(py(i,s)*(1-rtxs(i,s,r))*dxmd(i,s,r) + sum(j, pt(j) * dtwr(j,i,s,r))));

*	-----------------------------------------------------------------------------
*	Income balance consition:

inc_ra(r)$(ra.lo(r) < ra.up(r))..	
	ra(r) =e= sum(rnum, pc(rnum)*vb(r)) - pg(r)*vgm(r) 
			- sum(i, py(i,r) * vdim(i,r))
			+ sum(f, pf(f,r)*evom(f,r))
			+ revto(r) 
			+ revtfd(r)
			+ revtfi(r)
			+ revtf(r)
			+ revtpd(r)
			+ revtpi(r)
			+ revtgd(r)
			+ revtgi(r)
			+ revtxs(r)
			+ revtms(r);

*	$demand:ra(r)
*		d:pc(r)		q:vpm(r)
*		e:pc(rnum)	q:vb(r)
*		e:pg(r)		q:(-vgm(r))
*		e:py(i,r)	q:(-vdim(i,r))
*		e:pf(f,r)	q:evom(f,r)

*	-----------------------------------------------------------------------------
*	Market clearance associated with private consumption:

mkt_pc(r)..		c(r) * vpm(r) * pc(r) =e= ra(r);

*	-----------------------------------------------------------------------------
*	Market clearance associated with public consumption:

mkt_pg(r)..		g(r) =e= 1;

*	-----------------------------------------------------------------------------
*	Market clearance associated with firm output:

mkt_py(i,r)$vom(i,r)..	

	y(i,r) * vom(i,r) =e= sum(j, ddfm(i,j,r)) 
		+ ddpm(i,r) + ddgm(i,r) + sum(s, dxmd(i,r,s)) + dst(i,r) + vdim(i,r);

*	-----------------------------------------------------------------------------
*	Market clearance associated with imports:

mkt_pm(i,r)$vim(i,r)..	m(i,r) * vim(i,r) =e= 
			sum(j, difm(i,j,r)) 
			+ dipm(i,r)
			+ digm(i,r);


*	-----------------------------------------------------------------------------
*	Market clearance associated with transport services:

mkt_pt(j)$vtw(j)..	yt(j) * vtw(j) =e= sum((i,s,r), dtwr(j,i,s,r));


*	-----------------------------------------------------------------------------
*	Market clearance associated with primary factors:

mkt_pf(f,r)$evom(f,r)..	evom(f,r) =e= sum(j, dfm(f,j,r))$mf(f) + (evom(f,r)*ft(f,r))$sf(f);

*	-----------------------------------------------------------------------------
*	Market clearance associated with specific factors:

mkt_ps(sf,j,r)$vfm(sf,j,r)..	
	vfm(sf,j,r) * (ps(sf,j,r)/pf(sf,r))**etrae(sf) =e= dfm(sf,j,r);	

model gtap6mcp /
	prf_c.c,prf_g.g,prf_y.y,prf_m.m,prf_yt.yt,prf_ft.ft,
	mkt_pc.pc,mkt_pg.pg,mkt_py.py,mkt_pm.pm,mkt_pt.pt,mkt_pf.pf,mkt_ps.ps,
	inc_ra.ra/;

model gtap6cns /
	prf_c.c,prf_g.g,prf_y.y,prf_m.m,prf_yt.yt,prf_ft.ft,
	mkt_pc.pc,mkt_pg.pg,mkt_py.py,mkt_pm.pm,mkt_pt.pt,mkt_pf.pf,mkt_ps.ps,
	inc_ra.ra/;

*	Fix variables which should not enter the model:

y.fx(i,r)$(vom(i,r)=0) = 1;
m.fx(i,r)$(vim(i,r)=0) = 1;
yt.fx(j)$(vtw(j)=0) = 1;
py.fx(j,r)$(vom(j,r)=0) = 1;
pm.fx(j,r)$(vim(j,r)=0) = 1;
pt.fx(j)$(vtw(j)=0) = 1;
pf.fx(f,r)$(evom(f,r)=0) = 1;
ps.fx(f,j,r)$((not sf(f)) or (vfm(f,j,r)=0)) = 1;
ft.fx(f,r)$((not sf(f)) or (evom(f,r)=0)) = 1;

*	Establish a price normalization using the reference region:
ra.fx(rnum) = ra.l(rnum);

gtap6mcp.iterlim = 0;
solve gtap6mcp using mcp;

gtap6cns.iterlim = 0;
solve gtap6cns using cns;


*	Run a GFT scenario using the MCP model;

rtxs(i,r,s) = 0;
rtms(i,r,s) = 0;

gtap6cns.iterlim = 10000;
solve gtap6cns using cns;

*	Check the solution as an MCP:

gtap6mcp.iterlim = 0;
solve gtap6mcp using mcp;

*	Then verify consistency with the MPSGE model:

gtap6.iterlim = 0;
$include gtap6.gen
solve gtap6 using mcp;
