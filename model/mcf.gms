$title	Read GTAP6 Basedata and Replicate the Benchmark in MPSGE

*	Define the dataset:

$set ds asa7x5

*	Read the data and model:

$include mrtmge

*	Evaluate the marginal cost of funds:

alias (r,rr),(j,jj);
gtap6.iterlim = 10000;
$include gtap6.gen
solve gtap6 using mcp;

parameter	g0(r)	Reference level of government output,
		c0(r)	Reference level of private demand
		pnum	Price level;

pnum = sum(rnum,pc.l(rnum));
g0(r) = g.l(r)*vgm(r)*pg.l(r)/pnum;
c0(r) = c.l(r)*vpm(r)*pc.l(r)/pnum;

parameter	mcf(r,j)	Marginal cost of funds;

loop(rr,
	loop(jj,

	  rtms(jj,s,rr) = rtms(jj,s,rr) + 0.01;

$include gtap6.gen
	  solve gtap6 using mcp;

	  rtms(jj,s,rr) = rtms(jj,s,rr) - 0.01;

	  pnum = sum(rnum,pc.l(rnum));

	  if (g.l(rr)*vgm(rr)*pg.l(rr)/pnum > g0(rr),
	    mcf(rr,jj) = (c0(rr) - c.l(rr)*vpm(rr)*pc.l(rr)/pnum) /
		         (g.l(rr)*vgm(rr)*pg.l(rr)/pnum - g0(rr));
	  else
	    mcf(rr,jj) = +inf;
	  );

));

parameter	tariffrates	Benchmark tariff rates (%);
tariffrates(j,r,s) = round(100 * rtms0(j,r,s));
option tariffrates:0:1:1;


display tariffrates, mcf;
