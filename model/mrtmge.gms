$title	Read GTAP8 Basedata and Replicate the Benchmark in MPSGE

* The following pre-assignment for ds will be used in a $gdxin command in gtap8data.gms
*$if not set ds $set ds iea_001
$if not set ds $set ds eppa6_18

* Sets, parameters declarations and assignments are done in gtap8data.gms (YHC: 20120614)
$include ..\build\gtap8data

parameter	esub(g)		Top-level elasticity indemand /C 1/;

$ontext
$model:gtap8

$sectors:
	y(g,r)$vom(g,r)		          ! Supply
	m(i,r)$vim(i,r)		          ! Imports
	yt(j)$vtw(j)		          ! Transportation services
	ft(f,r)$(sf(f) and evom(f,r))	  ! Specific factor transformation

$commodities:
	p(g,r)$vom(g,r)		          ! Domestic output price	 			 
	pm(j,r)$vim(j,r)		  ! Import price		 		 
	pt(j)$vtw(j)			  ! Transportation services		 
	pf(f,r)$evom(f,r)	          ! Primary factors rent
	ps(f,g,r)$(sf(f) and vfm(f,g,r))  ! Sector-specific primary factors

$consumers:
	ra(r)			          ! Representative agent

$prod:y(g,r)$vom(g,r)	s:esub(g)       i.tl:esubd(i)  va:esubva(g)
	o:p(g,r)	q:vom(g,r)	a:ra(r)  t:rto(g,r)
	i:p(i,r)	q:vdfm(i,g,r)	p:(1+rtfd0(i,g,r))   i.tl:  a:ra(r)  t:rtfd(i,g,r)
	i:pm(i,r)	q:vifm(i,g,r)	p:(1+rtfi0(i,g,r))   i.tl:  a:ra(r)  t:rtfi(i,g,r)
	i:ps(sf,g,r)	q:vfm(sf,g,r)	p:(1+rtf0(sf,g,r))   va:    a:ra(r)  t:rtf(sf,g,r)
	i:pf(mf,r)	q:vfm(mf,g,r)	p:(1+rtf0(mf,g,r))   va:    a:ra(r)  t:rtf(mf,g,r)

$prod:yt(j)$vtw(j)      s:1
	o:pt(j)		q:vtw(j)
	i:p(j,r)	q:vst(j,r)

$prod:m(i,r)$vim(i,r)	s:esubm(i)      s.tl:0
	o:pm(i,r)	q:vim(i,r)
	i:p(i,s)	q:vxmd(i,s,r)	p:pvxmd(i,s,r)       s.tl:  a:ra(s)  t:(-rtxs(i,s,r))  a:ra(r)  t:(rtms(i,s,r)*(1-rtxs(i,s,r)))
	i:pt(j)#(s)	q:vtwr(j,i,s,r) p:pvtwr(i,s,r)       s.tl:  a:ra(r)  t:rtms(i,s,r)

$prod:ft(sf,r)$evom(sf,r)  t:etrae(sf)
	o:ps(sf,j,r)	q:vfm(sf,j,r)
	i:pf(sf,r)	q:evom(sf,r)

$demand:ra(r)
	d:p("c",r)	q:vom("c",r)
	e:p("c",rnum)	q:vb(r)
	e:p("g",r)	q:(-vom("g",r))
	e:p("i",r)	q:(-vom("i",r))
	e:pf(f,r)	q:evom(f,r)

$offtext
$sysinclude mpsgeset gtap8

gtap8.workspace = 128;
*gtap8.iterlim = 0;
gtap8.iterlim = 1000;
$include gtap8.gen
solve gtap8 using mcp;

* Using the following three lines will not output vom (YHC: 20120615)
*$gdxout 'mrtmge.gdx'
*$unload
*$gdxout

parameters

gdp(r)        gdp of region r,
imports(r)    imports of region r,
exports(r)    exports of region r,
nx(r)         net exports of region r
;

imports(r)   = sum(i,sum(s,vxmd(i,s,r)));
exports(r)   = sum(i,sum(s,vxmd(i,r,s)));
nx(r)        = exports(r) - imports(r);

gdp(r)       = vom("c",r)+vom("i",r)+vom("g",r)+nx(r);


execute_unload "mrtmge_18.gdx";
display vom;




