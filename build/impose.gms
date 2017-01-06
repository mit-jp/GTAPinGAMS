$title	Impose a new set of tax rates on an existing GTAP Dataset

$if not set ds $set ds gtapiea

$include gtap6data

*	Eliminate all domestic taxes:

rtfi(j,i,r) = 0;
rtfd(j,i,r) = 0;
rtf(f,i,r) = 0;

scalar tol /0.001/;

$set output gtapiea-notax.gdx

$include filter

parameter chk;
chk(i,r,"vdm") = vdm(i,r) - (vdpm(i,r) + vdgm(i,r) + sum(j, vdfm(i,j,r)) + vdim(i,r));
vdm(i,r) = vdpm(i,r) + vdgm(i,r) + sum(j, vdfm(i,j,r)) + vdim(i,r);
chk(i,r,"vxm") = vxm(i,r) - (sum(s, vxmd(i,r,s)) + vst(i,r));
vom(i,r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);

parameter bmkprofit	Benchmark profit rate;
bmkprofit(i,r) = round(vom(i,r)*(1-rto(i,r)) 
		- sum(j, vdfm(j,i,r)*(1+rtfd(j,i,r))+vifm(j,i,r)*(1+rtfi(j,i,r)))
		- sum(f, vfm(f,i,r)*(1+rtf(f,i,r))), 8);
display chk, bmkprofit;

