@echo off

title	"mrtmge for g20 dataset, 2004"
start gams mrtmge --ds=g20 --yr=04 o=mge_g20_2004.lst lf=mge_g20_2004.log lo=2

title	"mrtmge for g20 dataset, 2007"
start gams mrtmge --ds=g20 --yr=07 o=mge_g20_2007.lst lf=mge_g20_2007.log lo=2

title	"mrtmge for g20 dataset, 2011"
start gams mrtmge --ds=g20 --yr=11 o=mge_g20_2011.lst lf=mge_g20_2011.log lo=2

title	"mrtmcp for g20 dataset, 2004"
start gams mrtmcp --ds=g20 --yr=04 o=mcp_g20_2004.lst lf=mcp_g20_2004.log lo=2

title	"mrtmcp for g20 dataset, 2007"
start gams mrtmcp --ds=g20 --yr=07 o=mcp_g20_2007.lst lf=mcp_g20_2007.log lo=2

title	"mrtmcp for g20 dataset, 2011"
start gams mrtmcp --ds=g20 --yr=11 o=mcp_g20_2011.lst lf=mcp_g20_2011.log lo=2
