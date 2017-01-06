$title	Read GTAP6 Basedata and Replicate the Benchmark in MPSGE

$set ds asa7x5
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
gtap6.iterlim = 20000;


alias (r,rr);
set	lvl /0*10/;

parameter	ev	Equivalent variation in welfare;
loop(rr,
	loop(lvl,
	  rtms(i,s,rr) = 2 * (ord(lvl)-1)/(card(lvl)-1) * rtms0(i,s,rr);
	  rtxs(i,s,rr) = 2 * (ord(lvl)-1)/(card(lvl)-1) * rtxs0(i,s,rr);

$include gtap6.gen
	  solve gtap6 using mcp;

	  ev(lvl,rr) = 100 * (c.l(rr)-1);
	);
	rtms(i,s,rr) = rtms0(i,s,rr);
	rtxs(i,s,rr) = rtxs0(i,s,rr);
);
set lbl(lvl) /0 0, 2 40, 4 80, 6 120, 8 160, 10 200/;
$setglobal domain lvl
$setglobal labels lbl

*	Remove this exit if you have GNUPLOT installed:

$if exist "%gams.ldir%plot.gms" $libinclude plot ev
