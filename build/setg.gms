$gdxin '..\data\gsdset.gdx'
set	i(*)	Goods;
$load i=prod_comm
set g(*)/c,g,i/;
g(i) = yes;
