$gdxin '..\data\gsdset.gdx'
set	i(*)	Goods;
$load i=prod_comm
set x(*)/c,g,i/;
x(i) = yes;
