$title	Read GTAP6 Basedata and Replicate the Benchmark in MPSGE

$if not set ds $set ds asa7x5
$include gtap6data

parameter	vtax(r)	Implicit tax;
vtax(r) = sum(f, evom(f,r)) - (vpm(r) + sum(i,vdim(i,r)));

set	taxbase /rtp,rtms/
set	unif(taxbase,r);
unif(taxbase,r) = no;

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
	hh(r)			! Representative household
	govt(r)			! Representative government

$auxiliary:
	tau(r)$(sum(unif(taxbase,r),1))	! Equal yield tax rate

$prod:y(j,r)$vom(j,r)	s:0    i.tl:esubd(i)  va:esubva(j)
	o:py(j,r)	q:vom(j,r)	a:govt(r)  t:rto(j,r)	
	i:py(i,r)	q:vdfm(i,j,r)	p:(1+rtfd0(i,j,r)) i.tl:  a:govt(r) t:rtfd(i,j,r)
	i:pm(i,r)	q:vifm(i,j,r)	p:(1+rtfi0(i,j,r)) i.tl:  a:govt(r) t:rtfi(i,j,r)
	i:ps(sf,j,r)	q:vfm(sf,j,r)	p:(1+rtf0(sf,j,r))  va:    a:govt(r) t:rtf(sf,j,r)
	i:pf(mf,r)	q:vfm(mf,j,r)	p:(1+rtf0(mf,j,r))  va:    a:govt(r) t:rtf(mf,j,r)

$prod:yt(j)$vtw(j)  s:1
	o:pt(j)		q:vtw(j)
	i:py(j,r)	q:vst(j,r)

$prod:c(r)  s:1  i.tl:esubd(i)
	o:pc(r)		q:vpm(r)
	i:py(i,r)	q:vdpm(i,r)	i.tl: p:(1+rtpd0(i,r)) a:govt(r) t:rtpd(i,r)	
+		n:tau(r)$unif("rtp",r)
	i:pm(i,r)	q:vipm(i,r)	i.tl: p:(1+rtpi0(i,r)) a:govt(r) t:rtpi(i,r)
+		n:tau(r)$unif("rtp",r)

$prod:g(r)  s:0  i.tl:esubd(i)
	o:pg(r)		q:vgm(r)
	i:py(i,r)	q:vdgm(i,r)	i.tl: p:(1+rtgd0(i,r)) a:govt(r) t:rtgd(i,r)
	i:pm(i,r)	q:vigm(i,r)	i.tl: p:(1+rtgi0(i,r)) a:govt(r) t:rtgi(i,r)

$prod:m(i,r)$vim(i,r)	s:esubm(i)  s.tl:0
	o:pm(i,r)	q:vim(i,r)
	i:py(i,s)	q:vxmd(i,s,r)	p:pvxmd(i,s,r) s.tl:
+		a:govt(s) t:(-rtxs(i,s,r))  
+		a:govt(r) t:(rtms(i,s,r)*(1-rtxs(i,s,r)))	
+			n:tau(r)$unif("rtms",r) m:(1-rtxs(i,s,r))$unif("rtms",r)
	i:pt(j)#(s)	q:vtwr(j,i,s,r) p:pvtwr(i,s,r) s.tl:
+		a:govt(r) t:rtms(i,s,r) n:tau(r)$unif("rtms",r)

$prod:ft(sf,r)$evom(sf,r)  t:etrae(sf)
	o:ps(sf,j,r)	q:vfm(sf,j,r)
	i:pf(sf,r)	q:evom(sf,r)

*	Private household:

$demand:hh(r)
	d:pc(r)		q:vpm(r)
	e:py(i,r)	q:(-vdim(i,r))
	e:pf(f,r)	q:evom(f,r)
	e:pc(r)		q:(-vtax(r))

*	Government:

$demand:govt(r)
	d:pg(r)		
	e:pc(r)		q:vtax(r)
	e:pc(rnum)	q:vb(r)

$constraint:tau(r)$(sum(unif(taxbase,r),1))
	g(r) =e= 1;

$offtext
$sysinclude mpsgeset gtap6

tau.lo(r) = -inf;

gtap6.iterlim = 0;
$include gtap6.gen
solve gtap6 using mcp;
gtap6.iterlim = 10000;

parameter	ev		Equivalent variation,
		trate		Requisite tax rate
		rto0(j,r)	Output tax rate;

rto0(j,r) = rto(j,r);

alias (r,rr);
loop(rr,

	unif("rtp",rr) = yes;
	rtpd(i,rr) = 0;
	rtpi(i,rr) = 0;
$include gtap6.gen
	solve gtap6 using mcp;
	unif("rtp",rr) = no;
	rtpd(i,rr) = rtpd0(i,rr);
	rtpi(i,rr) = rtpi0(i,rr);
	ev(rr,"rtp") = 100 * (c.l(rr)-1);
	trate(rr,"rtp") = tau.l(rr);


	unif("rtms",rr) = yes;
	rtms(i,s,rr) = 0;
$include gtap6.gen
	solve gtap6 using mcp;
	rtms(i,s,rr) = rtms0(i,s,rr);
	unif("rtms",rr) = no;
	ev(rr,"rtms") = 100 * (c.l(rr)-1);
	trate(rr,"rtms") = tau.l(rr);

);
display ev, trate;
