$title   Replicate the GTAP9 Benchmark in MPSGE

$if not set yr $set yr 04
$if not set ds $set ds g20
$include ..\build\gtap9data

parameter       esub(g)         Top-level elasticity indemand /C 1/;

$ontext
$model:gtap9

$sectors:
        y(g,r)$vom(g,r)         ! Supply
        m(i,r)$vim(i,r)         ! Imports
        yt(j)$vtw(j)            ! Transportation services
        ft(f,r)$(sf(f) and evom(f,r))   ! Specific factor transformation

$commodities:
        p(g,r)$vom(g,r)         ! Domestic output price
        pm(j,r)$vim(j,r)        ! Import price
        pt(j)$vtw(j)            ! Transportation services
        pf(f,r)$evom(f,r)       ! Primary factors rent
        ps(f,g,r)$(sf(f) and vfm(f,g,r))        ! Sector-specific primary factors

$consumers:
        ra(r)                   ! Representative agent

$prod:y(g,r)$vom(g,r)   s:esub(g)    i.tl:esubd(i)  va:esubva(g)
        o:p(g,r)        q:vom(g,r)      a:ra(r)  t:rto(g,r)
        i:p(i,r)        q:vdfm(i,g,r)   p:(1+rtfd0(i,g,r)) i.tl:  a:ra(r) t:rtfd(i,g,r)
        i:pm(i,r)       q:vifm(i,g,r)   p:(1+rtfi0(i,g,r)) i.tl:  a:ra(r) t:rtfi(i,g,r)
        i:ps(sf,g,r)    q:vfm(sf,g,r)   p:(1+rtf0(sf,g,r))  va:    a:ra(r) t:rtf(sf,g,r)
        i:pf(mf,r)      q:vfm(mf,g,r)   p:(1+rtf0(mf,g,r))  va:    a:ra(r) t:rtf(mf,g,r)

$prod:yt(j)$vtw(j)  s:1
        o:pt(j)         q:vtw(j)
        i:p(j,r)        q:vst(j,r)

$prod:m(i,r)$vim(i,r)   s:esubm(i)  s.tl:0
        o:pm(i,r)       q:vim(i,r)
        i:p(i,s)        q:vxmd(i,s,r)   p:pvxmd(i,s,r) s.tl: a:ra(s) t:(-rtxs(i,s,r)) a:ra(r) t:(rtms(i,s,r)*(1-rtxs(i,s,r)))
        i:pt(j)#(s)     q:vtwr(j,i,s,r) p:pvtwr(i,s,r) s.tl: a:ra(r) t:rtms(i,s,r)

$prod:ft(sf,r)$evom(sf,r)  t:etrae(sf)
        o:ps(sf,j,r)    q:vfm(sf,j,r)
        i:pf(sf,r)      q:evom(sf,r)

$demand:ra(r)
        d:p("c",r)      q:vom("c",r)
        e:p("c",rnum)   q:vb(r)
        e:p("g",r)      q:(-vom("g",r))
        e:p("i",r)      q:(-vom("i",r))
        e:pf(f,r)       q:evom(f,r)

$offtext
$sysinclude mpsgeset gtap9

gtap9.workspace = 256;
gtap9.iterlim = 0;
gtap9.optfile = 1;
$include gtap9.gen
solve gtap9 using mcp;

execute_unload "all_%ds%.gdx";                        

