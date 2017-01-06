$title	FLEX2GDX.GMS	Read the FLEXAGG dataset gsddat.har and generate gsd.gdx

$if not set yr $set yr 04
$if not set nd $set nd 0

scalar nd	Number of decimals /%nd%/;
abort$(nd<>round(nd)) "Number of decimals must be an integer";

*	Directory in which to store the GDX file:

$if not set datadir $set datadir "..\data%yr%\"

*	Directory in which to retrieve the GTAP HAR files:

*.$if not set gtapdatadir $set gtapdatadir "..\gtapdistrib\sourcedata\flexagg81Y%yr%\"
$if not set gtapdatadir $set gtapdatadir "..\gtapdata\20%yr%\"


$if exist %datadir%gsddat.gdx $goto start

*	Translate HAR files into GDX:

$label har2gdx

$if not exist %gtapdatadir%gsdset.har   $goto missingharfiles
$if not exist %gtapdatadir%gsddat.har   $goto missingharfiles
$if not exist %gtapdatadir%gsdpar.har   $goto missingharfiles
$if not exist %gtapdatadir%gsdvole.har  $goto missingharfiles
$if not exist %gtapdatadir%gsdemiss.har $goto missingharfiles
$if not exist %gtapdatadir%gsdtax.har   $goto missingharfiles

$call 'har2gdx %gtapdatadir%gsdset.har   %datadir%gsdset.gdx'
$call 'har2gdx %gtapdatadir%gsddat.har   %datadir%gsddat.gdx'
$call 'har2gdx %gtapdatadir%gsdpar.har   %datadir%gsdpar.gdx'
$call 'har2gdx %gtapdatadir%gsdvole.har  %datadir%gsdvole.gdx'
$call 'har2gdx %gtapdatadir%gsdemiss.har %datadir%gsdemiss.gdx'
$call 'har2gdx %gtapdatadir%gsdtax.har   %datadir%gsdtax.gdx'

$label start

$if not exist %datadir%gsdset.gdx $goto missinggdxfiles
$if not exist %datadir%gsddat.gdx $goto missinggdxfiles
$if not exist %datadir%gsdpar.gdx $goto missinggdxfiles
$if not exist %datadir%gsdvole.gdx $goto missinggdxfiles
$if not exist %datadir%gsdemiss.gdx $goto missinggdxfiles

$onecho >setx.gms
$gdxin '%datadir%gsdset.gdx'
set	i(*)	Goods;
$load i=prod_comm
set x(*)/c,g,i/;
x(i) = yes;
$offecho
$call gams setx gdx=setx

set	x(*)	All goods plus C - G - i and CGDS;
$gdxin 'setx.gdx'
$load x
$gdxin
$call del /q setx.*

set	r	Regions  /
AUS	Australia
*	 Australia
*	 Christmas Island
*	 Cocos (Keeling) Islands
*	 Heard Island and McDonald Islands
*	 Norfolk Island
NZL	New Zealand
XOC	Rest of Oceania
*	 American Samoa
*	 Cook Islands
*	 Fiji
*	 French Polynesia
*	 Guam
*	 Kiribati
*	 Marshall Islands
*	 Micronesia Federated States of
*	 Nauru
*	 New Caledonia
*	 Niue
*	 Northern Mariana Islands
*	 Palau
*	 Papua New Guinea
*	 Pitcairn
*	 Samoa
*	 Solomon Islands
*	 Tokelau
*	 Tonga
*	 Tuvalu
*	 United States Minor Outlying Islands
*	 Vanuatu
*	 Wallis and Futuna
CHN	China
HKG	Hong Kong
JPN	Japan
KOR	Korea Republic of
MNG	Mongolia
TWN	Taiwan
XEA	Rest of East Asia
*	 Korea Democratic Peoples Republic of
*	 Macao
BRN	Brunei Darussalam
KHM	Cambodia
IDN	Indonesia
LAO	Lao People's Democratic Republic
MYS	Malaysia
PHL	Philippines
SGP	Singapore
THA	Thailand
VNM	Viet Nam
XSE	Rest of Southeast Asia
*	 Myanmar
*	 Timor Leste
BGD	Bangladesh
IND	India
NPL	Nepal
PAK	Pakistan
LKA	Sri Lanka
XSA	Rest of South Asia
*	 Afghanistan
*	 Bhutan
*	 Maldives
CAN	Canada
USA	United States of America
MEX	Mexico
XNA	Rest of North America
*	 Bermuda
*	 Greenland
*	 Saint Pierre and Miquelon
ARG	Argentina
BOL	Bolivia
BRA	Brazil
CHL	Chile
COL	Colombia
ECU	Ecuador
PRY	Paraguay
PER	Peru
URY	Uruguay
VEN	Venezuela
XSM	Rest of South America
*	 Falkland Islands (Malvinas)
*	 French Guiana
*	 Guyana
*	 South Georgia and the South Sandwich Islands
*	 Suriname
CRI	Costa Rica
GTM	Guatemala
HND	Honduras
NIC	Nicaragua
PAN	Panama
SLV	El Salvador
XCA	Rest of Central America
*	 Belize
DOM	Dominican Republic
JAM	Jamaica
PRI	Puerto Rico
TTO	Trinidad and Tobago
XCB	Caribbean
*	 Anguilla
*	 Antigua & Barbuda
*	 Aruba
*	 Bahamas
*	 Barbados
*	 Cayman Islands
*	 Cuba
*	 Dominica
*	 Grenada
*	 Haiti
*	 Montserrat
*	 Netherlands Antilles
*	 Saint Kitts and Nevis
*	 Saint Lucia
*	 Saint Vincent and the Grenadines
*	 Turks and Caicos Islands
*	 Virgin Islands British 
*	 Virgin Islands U.S.
AUT	Austria
BEL	Belgium
CYP	Cyprus
CZE	Czech Republic
DNK	Denmark
EST	Estonia
FIN	Finland
*	 Aland Islands
*	 Finland
FRA	France
*	 France
*	 Guadeloupe
*	 Martinique
*	 Reunion
DEU	Germany
GRC	Greece
HUN	Hungary
IRL	Ireland
ITA	Italy
LVA	Latvia
LTU	Lithuania
LUX	Luxembourg
MLT	Malta
NLD	Netherlands
POL	Poland
PRT	Portugal
SVK	Slovakia
SVN	Slovenia
ESP	Spain
SWE	Sweden
GBR	United Kingdom
CHE	Switzerland
NOR	Norway
*	 Norway
*	 Svalbard and Jan Mayen
XEF	Rest of EFTA
*	 Iceland
*	 Liechtenstein
ALB	Albania
BGR	Bulgaria
BLR	Belarus
HRV	Croatia
ROU	Romania
RUS	Russian Federation
UKR	Ukraine
XEE	Rest of Eastern Europe
*	 Moldova Republic of
XER	Rest of Europe
*	 Andorra
*	 Bosnia and Herzegovina
*	 Faroe Islands
*	 Gibraltar
*	 Guernsey 
*	 Holy See (Vatican City State)
*	 Isle of Man
*	 Jersey
*	 Macedonia the former Yugoslav Republic of
*	 Monaco
*	 Montenegro
*	 San Marino
*	 Serbia
KAZ	Kazakhstan
KGZ	Kyrgyzstan
XSU	Rest of Former Soviet Union
*	 Tajikistan
*	 Turkmenistan
*	 Uzbekistan
ARM	Armenia
AZE	Azerbaijan
GEO	Georgia
BHR	Bahrain
IRN	Iran Islamic Republic of
ISR	Israel
JOR	Jordan
KWT	Kuwait
OMN	Oman
QAT	Qatar
SAU	Saudi Arabia
TUR	Turkey
ARE	United Arab Emirates
XWS	Rest of Western Asia
*	 Iraq
*	 Lebanon
*	 Palestinian Territory Occupied 
*	 Syrian Arab Republic
*	 Yemen
EGY	Egypt
MAR	Morocco
TUN	Tunisia
XNF	Rest of North Africa
*	 Algeria
*	 Libyan Arab Jamahiriya
*	 Western Sahara
BEN	Benin
BFA	Burkina Faso
CMR	Cameroon
CIV	Cote d'Ivoire
GHA	Ghana
GIN	Guinea
NGA	Nigeria
SEN	Senegal
TGO	Togo
XWF	Rest of Western Africa
*	 Cape Verde
*	 Gambia
*	 Guinea-Bissau
*	 Liberia
*	 Mali
*	 Mauritania
*	 Niger
*	 Saint Helena, ASCENSION AND TRISTAN DA CUNHA
*	 Sierra Leone
XCF	Central Africa
*	 Central African Republic
*	 Chad
*	 Congo
*	 Equatorial Guinea
*	 Gabon
*	 Sao Tome and Principe
XAC	South Central Africa
*	 Angola
*	 Congo the Democratic Republic of the
ETH	Ethiopia
KEN	Kenya
MDG	Madagascar
MWI	Malawi
MUS	Mauritius
MOZ	Mozambique
RWA	Rwanda
TZA	Tanzania United Republic of
UGA	Uganda
ZMB	Zambia
ZWE	Zimbabwe
XEC	Rest of Eastern Africa
*	 Burundi
*	 Comoros
*	 Djibouti
*	 Eritrea
*	 Mayotte
*	 Seychelles
*	 Somalia
*	 Sudan
BWA	Botswana
NAM	Namibia
ZAF	South Africa
XSC	Rest of South African Customs Union
*	 Lesotho
*	 Swaziland
XTW	Rest of the World
*	 Antarctica
*	 Bouvet Island
*	 British Indian Ocean Territory
*	 French Southern Territories
	/;

set	g(x) 	All goods plus C - G - i /c,g,i/,
	i(x)	Market goods,
	f(*)	Factors;

$gdxin '%datadir%gsdset.gdx'
$load f=endw_comm i=trad_comm
g(i) =yes;

set	src	Sources /domestic, imported/,
	rnum(r)	Numeraire region,
	sf(f)	Sluggish primary factors (sector-specific)
	mf(f)	Mobile primary factors
	ec	Energy goods /
		ecoa	Coal,
		eoil	Crude oil,
		egas	Natural gas,
		ep_c	Refined oil products,
		eely	Electricity
		egdt	Gas distribution /;

alias (r,s), (i,j,jj), (f,ff);

parameters
	vdga(i,r)	Government - domestic purchases at agents' prices,
	viga(i,r)	Government - imports at agents' prices,
	vdgm(i,r)	Government - domestic purchases at market prices,
	vigm(i,r)	Government - imports at market prices,
	vdpa(i,r)	Private households - domestic purchases at agents' prices,
	vipa(i,r)	Private households - imports at agents' prices,
	vdpm(i,r)	Private households - domestic purchases at market prices,
	vipm(i,r)	Private households - imports at market prices
	evoa(f,r)	Endowments - output at agents' prices,
	evfa(f,x,r)	Endowments - firms' purchases at agents' prices,
	vfm(f,x,r)	Endowments - Firms' purchases at market prices,
	vdfa(i,x,r)	Intermediates - firms' domestic purchases at agents' prices,
	vifa(i,x,r)	Intermediates - Firms' imports at agents' prices,
	vdfm(i,x,r)	Intermediates - firms' domestic purchases at market prices,
	vifm(i,x,r)	Intermediates - firms' imports at market prices,
	vims(i,r,s)	Trade - bilateral imports at market prices,
	viws(i,r,s)	Trade - bilateral imports at world prices,
	vxmd(i,r,s)	Trade - bilateral exports at market prices,
	vxwd(i,r,s)	Trade - bilateral exports at world prices,
	vst(i,r)	Trade - exports for international transportation
	vtwr(i,j,r,s)	Trade - Margins for international transportation at world prices
	ftrv(f,j,r)	Taxes - factor employment tax revenue,

	vkb(r)		Capital Stock,
	vdep(*)		Capital depreciation,

	fbep(f,j,r)	Protection - factor-based subsidies,
	isep(i,j,r,src) Protection - intermediate input subsidies,
	osep(i,r)	Protection - ordinary output subsidies,
	adrv(i,r,s)	Protection - anti-dumping duty
	tfrv(i,r,s)	Protection - ordinary import duty
	purv(i,r,s)	Protection - price undertaking export tax equivalent,
	vrrv(i,r,s)	Protection - VER export tax equivalent
	mfrv(i,r,s)	Protection - MFA export tax equivalent
	xtrv(i,r,s)	Protection - ordinary export tax;

$gdxin '%datadir%gsddat.gdx'
$load vdga viga vdgm vigm vdpa vipa vdpm vipm evoa evfa vfm vdfa 
$load vifa vdfm vifm vims viws vxmd vxwd vst vtwr=vtmfsd ftrv fbep isep 
$load osep adrv=adrev tfrv=tarifrev purv=purev vrrv=verrev mfrv=mfarev xtrv=xtrev
$load vkb vdep
$gdxin

parameter
	esubd(x)	Elasticity of substitution (M versus D),
	esubva(x)	Elasticity of substitution between factors,
	esubm(x)	Intra-import elasticity of substitution,
	etrae(f)	Elasticity of transformation,
	incpar(x,r)	Expansion parameter in the CDE minimum expenditure function,
	subpar(x,r)	Substitution parameter in CDE minimum expenditure function;

$gdxin '%datadir%gsdpar.gdx'
$load esubd esubva esubm etrae incpar subpar
$gdxin

parameter mdf(i,i,r)	"Emissions in domestic production Mt CO2",
	  mdg(i,r)	"Emissions in domestic public demand, Mt CO2",
	  mdp(i,r)	"Emissions in domestic private demand, Mt CO2",
	  mif(i,i,r)	"Emissions in foreign production Mt CO2",
	  mig(i,r)	"Emissions in foreign public demand, Mt CO2",
	  mip(i,r)	"Emissions in foreign private demand, Mt CO2";

$gdxin '%datadir%gsdemiss.gdx'
$load mdf mdg mdp mif mig mip
$gdxin

*	Determine which factors are sector-specific 

mf(f) = yes$(etrae(f)=0);
sf(f) = yes$(etrae(f)<0);
display mf,sf;

*	Convert sign of etrae() so that it is non-negative:

etrae(f) = -etrae(f);
etrae(mf) = +inf;

*	Scale the data:

scalar scalefactor /1e-3/;
vdga(i,r) = scalefactor * vdga(i,r);
viga(i,r) = scalefactor * viga(i,r);
vdgm(i,r) = scalefactor * vdgm(i,r);
vigm(i,r) = scalefactor * vigm(i,r);
vdpa(i,r) = scalefactor * vdpa(i,r);
vipa(i,r) = scalefactor * vipa(i,r);
vdpm(i,r) = scalefactor * vdpm(i,r);
vipm(i,r) = scalefactor * vipm(i,r);
evoa(f,r) = scalefactor * evoa(f,r);
evfa(f,j,r) = scalefactor * evfa(f,j,r);
vfm(f,j,r)  = scalefactor * vfm(f,j,r);
vdfa(i,x,r) = scalefactor * vdfa(i,x,r);
vifa(i,x,r) = scalefactor * vifa(i,x,r);
vdfm(i,x,r) = scalefactor * vdfm(i,x,r);
vifm(i,x,r) = scalefactor * vifm(i,x,r);
vims(i,r,s) = scalefactor * vims(i,r,s);
viws(i,r,s) = scalefactor * viws(i,r,s);
vxmd(i,r,s) = scalefactor * vxmd(i,r,s);
vxwd(i,r,s) = scalefactor * vxwd(i,r,s);
vst(i,r)    = scalefactor * vst(i,r);
vtwr(i,j,r,s) = scalefactor * vtwr(i,j,r,s);
ftrv(f,j,r) = scalefactor * ftrv(f,j,r);
fbep(f,j,r) = scalefactor * fbep(f,j,r);
isep(i,j,r,src) = scalefactor * isep(i,j,r,src);
osep(i,r)   = scalefactor * osep(i,r);
adrv(i,r,s) = scalefactor * adrv(i,r,s);
tfrv(i,r,s) = scalefactor * tfrv(i,r,s);
purv(i,r,s) = scalefactor * purv(i,r,s);
vrrv(i,r,s) = scalefactor * vrrv(i,r,s);
mfrv(i,r,s) = scalefactor * mfrv(i,r,s);
xtrv(i,r,s) = scalefactor * xtrv(i,r,s);

*	Drop tiny numbers:

if (nd>0,
	vdga(i,r) = vdga(i,r)$round(vdga(i,r),nd);
	viga(i,r) = viga(i,r)$round(viga(i,r),nd);
	vdgm(i,r) = vdgm(i,r)$round(vdgm(i,r),nd);
	vigm(i,r) = vigm(i,r)$round(vigm(i,r),nd);
	vdpa(i,r) = vdpa(i,r)$round(vdpa(i,r),nd);
	vipa(i,r) = vipa(i,r)$round(vipa(i,r),nd);
	vdpm(i,r) = vdpm(i,r)$round(vdpm(i,r),nd);
	vipm(i,r) = vipm(i,r)$round(vipm(i,r),nd);
	evoa(f,r) = evoa(f,r)$round(evoa(f,r),nd);
	evfa(f,j,r) = evfa(f,j,r)$round(evfa(f,j,r),nd);
	vfm(f,j,r) = vfm(f,j,r)$round(vfm(f,j,r),nd);
	vdfa(i,x,r) = vdfa(i,x,r)$round(vdfa(i,x,r),nd);
	vifa(i,x,r) = vifa(i,x,r)$round(vifa(i,x,r),nd);
	vdfm(i,x,r) = vdfm(i,x,r)$round(vdfm(i,x,r),nd);
	vifm(i,x,r) = vifm(i,x,r)$round(vifm(i,x,r),nd);
	vims(i,r,s) = vims(i,r,s)$round(vims(i,r,s),nd);
	viws(i,r,s) = viws(i,r,s)$round(viws(i,r,s),nd);
	vims(i,r,s) = vims(i,r,s)$viws(i,r,s);
	vxmd(i,r,s) = vxmd(i,r,s)$round(vxmd(i,r,s),nd);
	vxwd(i,r,s) = vxwd(i,r,s)$round(vxwd(i,r,s),nd);
	vxwd(i,r,s) = vxwd(i,r,s)$vxmd(i,r,s);

	vst(i,r) = vst(i,r)$round(vst(i,r),nd);
	vtwr(i,j,r,s) = vtwr(i,j,r,s)$round(vtwr(i,j,r,s),nd);
	ftrv(f,j,r) = ftrv(f,j,r)$round(ftrv(f,j,r),nd);
	fbep(f,j,r) = fbep(f,j,r)$round(fbep(f,j,r),nd);
	isep(i,j,r,src) = isep(i,j,r,src)$round(isep(i,j,r,src),nd);
	osep(i,r) = osep(i,r)$round(osep(i,r),nd);
	adrv(i,r,s) = adrv(i,r,s)$round(adrv(i,r,s),nd);
	tfrv(i,r,s) = tfrv(i,r,s)$round(tfrv(i,r,s),nd);
	purv(i,r,s) = purv(i,r,s)$round(purv(i,r,s),nd);
	vrrv(i,r,s) = vrrv(i,r,s)$round(vrrv(i,r,s),nd);
	mfrv(i,r,s) = mfrv(i,r,s)$round(mfrv(i,r,s),nd);
	xtrv(i,r,s) = xtrv(i,r,s)$round(xtrv(i,r,s),nd);
	mdf(i,j,r) = mdf(i,j,r)$round(mdf(i,j,r),nd);
	mdg(i,r) = mdg(i,r)$round(mdg(i,r),nd);
	mdp(i,r) = mdp(i,r)$round(mdp(i,r),nd);
	mif(i,j,r) = mif(i,j,r)$round(mif(i,j,r),nd);
	mig(i,r) = mig(i,r)$round(mig(i,r),nd);
	mip(i,r) = mip(i,r)$round(mip(i,r),nd);

);


parameter

	evt(i,r,r)	Volume of energy trade (mtoe),


	eip(i,r)        Volume of imported purchases by households (mtoe)
	eig(i,r)        Volume of imported purchases by government (mtoe)
	eif(i,i,r)      Volume of imported purchases by firms (mtoe)

	edp(i,r)        Volume of domestic purchases by households (mtoe)
	edg(i,r)        Volume of domestic purchases by government (mtoe)
	edf(i,i,r)      Volume of domestic purchases by firms (mtoe)

$gdxin '%datadir%gsdvole.gdx'
$load evt=exi eip eig eif edp edg edf  
$gdxin




*	Declare some intermediate arrays which are required to 
*	evaluate tax rates:

parameter	vdm(i,r)	Aggregate demand for domestic output,
		vom(x,r)	Total supply at market prices,
		voa(x,r)	Output at producer prices;

vdm(i,r) = vdpm(i,r) + vdgm(i,r) + sum{x, vdfm(i,x,r)};
vom(i,r) = vdm(i,r) + sum(s, vxmd(i,r,s)) + vst(i,r);
voa(x,r) = sum(f, evfa(f,x,r)) + sum(i, vdfa(i,x,r) + vifa(i,x,r));

vom("i",r) = voa("cgds",r);

parameter
	rto(i,r)	Output (or income) subsidy rates
	rtf(f,x,r)	Primary factor and commodity rates taxes 
	rtpd(i,r)	Private domestic consumption taxes
	rtpi(i,r)	Private import consumption tax rates
	rtgd(i,r)	Government domestic rates
	rtgi(i,r)	Government import tax rates
	rtfd(i,x,r)	Firms domestic tax rates
	rtfi(i,x,r)	Firms' import tax rates
	rtxs(i,r,s)	Export subsidy rates
	rtms(i,r,s)	Import taxes rates;

rto(i,r)$vom(i,r) = 1 - voa(i,r)/vom(i,r);
rtf(f,j,r)$vfm(f,j,r)  = evfa(f,j,r)/vfm(f,j,r) - 1;
rtpd(i,r)$vdpm(i,r)   = vdpa(i,r)/vdpm(i,r) - 1;
rtpi(i,r)$vipm(i,r)   = vipa(i,r)/vipm(i,r) - 1;
rtgd(i,r)$vdgm(i,r)   = vdga(i,r)/vdgm(i,r) - 1;
rtgi(i,r)$vigm(i,r)   = viga(i,r)/vigm(i,r) - 1;
rtfd(i,x,r)$vdfm(i,x,r) = vdfa(i,x,r)/vdfm(i,x,r) - 1;
rtfi(i,x,r)$vifm(i,x,r) = vifa(i,x,r)/vifm(i,x,r) - 1;
rtxs(i,r,s)$vxwd(i,r,s) = 1-vxwd(i,r,s)/vxmd(i,r,s);
rtms(i,r,s)$vims(i,r,s) = vims(i,r,s)/viws(i,r,s) - 1;

parameter	pvxmd(i,s,r)	Import price (power of benchmark tariff)
		pvtwr(i,s,r)	Import price for transport services;

pvxmd(i,s,r) = (1+rtms(i,s,r)) * (1-rtxs(i,s,r));
pvtwr(i,s,r) = 1+rtms(i,s,r);

parameter	
	vtw(j)		Aggregate international transportation services,
	vpm(r)		Aggregate private demand,
	vgm(r)		Aggregate public demand,
	vim(i,r)	Aggregate imports,
	evom(f,r)	Aggregate factor endowment at market prices,
	vb(*)		Current account balance;

vtw(j) = sum(r, vst(j,r));
vpm(r) = sum(i, vdpm(i,r)*(1+rtpd(i,r)) + vipm(i,r)*(1+rtpi(i,r)));
vgm(r) = sum(i, vdgm(i,r)*(1+rtgd(i,r)) + vigm(i,r)*(1+rtgi(i,r)));
vim(i,r) = vipm(i,r) + vigm(i,r) + sum(j, vifm(i,j,r));
evom(f,r) = sum(j, vfm(f,j,r));

parameter	theta(i,r)	Final demand value shares;
theta(i,r) = (vdpm(i,r)*(1+rtpd(i,r))+vipm(i,r)*(1+rtpi(i,r))) /
	sum(j,vdpm(j,r)*(1+rtpd(j,r))+vipm(j,r)*(1+rtpi(j,r)));

parameter	eta(i,r)	Income elasticity of demand,
		epsilon(i,r)	Own-price elasticity of demand;

eta(i,r) = 1-subpar(i,r) - sum(j, theta(j,r)*(1-subpar(j,r))) +
	(1/sum(j,theta(j,r)*incpar(j,r))) * 
	  (incpar(i,r)*subpar(i,r) + sum(j,theta(j,r)*incpar(j,r)*(1-subpar(j,r))));
display eta;

epsilon(i,r)$theta(i,r)
	= (2*(1-subpar(i,r)) 
		- sum(j, theta(j,r)*(1-subpar(j,r))) 
		- (1-subpar(i,r)) / theta(i,r) - eta(i,r)) * theta(i,r);
display epsilon;

*	Define a numeraire region for denominating international
*	transfers:

rnum(r) = yes$(vpm(r)=smax(s,vpm(s)));
display rnum;

*	Translate the dataset to a format which drops vdpm, vipm, rtpd, rtpi, 
*	vdgm, vigm, rtgd, rtgi, vpm and vgm:

vdfm(i,"c",r) = vdpm(i,r);
vifm(i,"c",r) = vipm(i,r);
rtfd(i,"c",r) = rtpd(i,r);
rtfi(i,"c",r) = rtpi(i,r);
vom("c",r) =vpm(r);

vdfm(i,"g",r) = vdgm(i,r);
vifm(i,"g",r) = vigm(i,r);
rtfd(i,"g",r) = rtgd(i,r);
rtfi(i,"g",r) = rtgi(i,r);
vom("g",r) =vgm(r);

*	Transfer investment good CGDS to "i":
*	(Justin 10.2.2010)

vdfm(i,"i",r) = vdfm(i,"CGDS",r);
vifm(i,"i",r) = vifm(i,"CGDS",r);

vdfm(i,"cgds",r) = 0;
vifm(i,"cgds",r) = 0;

rtfd(i,"i",r) = rtfd(i,"cgds",r);
rtfi(i,"i",r) = rtfi(i,"cgds",r);

vb(r) = vpm(r) + vgm(r) + vom("i",r) 
	- sum(f, evom(f,r))
	- sum(j,  vom(j,r)*rto(j,r))
	- sum(x,  sum(i, vdfm(i,x,r)*rtfd(i,x,r) + vifm(i,x,r)*rtfi(i,x,r)))

	+ sum(i, vdfm(i,"c",r)*rtfd(i,"c",r) + vifm(i,"c",r)*rtfi(i,"c",r))
	+ sum(i, vdfm(i,"g",r)*rtfd(i,"g",r) + vifm(i,"g",r)*rtfi(i,"g",r))

	- sum(j,  sum(f, vfm(f,j,r)*rtf(f,j,r)))
	- sum(i, vdpm(i,r)*rtpd(i,r) + vipm(i,r)*rtpi(i,r))
	- sum(i, vdgm(i,r)*rtgd(i,r) + vigm(i,r)*rtgi(i,r))
	- sum((i,s), rtms(i,s,r) *  (vxmd(i,s,r) * (1-rtxs(i,s,r)) + sum(j,vtwr(j,i,s,r))))
	+ sum((i,s), rtxs(i,r,s) * vxmd(i,r,s));

vb("chksum") = sum(r, vb(r));
display vb;

parameter
	evd(i,*,r)	Domestic energy use (mtoe),
	evi(i,*,r)	Imported energy use (mtoe),
	eco2d(i,*,r)	CO2 emissions in domestic fuels - Mt CO2",
	eco2i(i,*,r)	CO2 emissions in foreign fuels - Mt CO2";
	

evd(i,j,r) = edf(i,j,r);
evd(i,"c",r) = edp(i,r);
evd(i,"g",r) = edg(i,r);

evi(i,j,r) = eif(i,j,r);
evi(i,"c",r) = eip(i,r);
evi(i,"g",r) = eig(i,r);

eco2d(i,j,r) = mdf(i,j,r);
eco2d(i,"g",r) = mdg(i,r);
eco2d(i,"c",r) = mdp(i,r);

eco2i(i,j,r) = mif(i,j,r);
eco2i(i,"g",r) = mig(i,r);
eco2i(i,"c",r) = mip(i,r);

if (nd>0,
	evt(i,r,s)  = evt(i,r,s)$round(evt(i,r,s), nd);
	evd(i,g,r) = evd(i,g,r)$round(evd(i,g,r), nd);
	evi(i,g,r) = evi(i,g,r)$round(evi(i,g,r), nd);
	eco2d(i,g,r) = eco2d(i,g,r)$round(eco2d(i,g,r), nd);
	eco2i(i,g,r) = eco2i(i,g,r)$round(eco2i(i,g,r), nd);

);


if (nd>0,
	execute_unload '%datadir%gsd_%nd%.gdx', r, f, g, i, vfm, vdfm, vifm, vxmd, vst, vtwr, 
		rto, rtf, rtfd, rtfi, rtxs, rtms, esubd, esubva, esubm, etrae, eta, epsilon, evd, evi, evt, eco2d, eco2i;
else
	execute_unload '%datadir%gsd.gdx',      r, f, g, i, vfm, vdfm, vifm, vxmd, vst, vtwr, 
		rto, rtf, rtfd, rtfi, rtxs, rtms, esubd, esubva, esubm, etrae, eta, epsilon, evd, evi, evt, eco2d, eco2i;
);

parameter	eprice		Implicit energy prices
		etprice		Energy trade price;

eprice(i,g,r)$evd(i,g,r)  = (vdfm(i,g,r)+vifm(i,g,r))/evd(i,g,r);

etprice(i,r,s)$evt(i,r,s) = vxmd(i,r,s)/evt(i,r,s);

eprice(i,"average",r)$sum(g,evd(i,g,r))  = sum(g,vdfm(i,g,r)+vifm(i,g,r))/sum(g,evd(i,g,r));

etprice(i,r,s)$evt(i,r,s) = vxmd(i,r,s)/evt(i,r,s);
etprice(i,r,"domestic") = eprice(i,"average",r);
etprice(i,"domestic",s) = eprice(i,"average",s);

*.execute_unload 'eprice.gdx',eprice,etprice;	
*.execute 'gdxxrw i=eprice.gdx o=eprice.xls par=eprice rng="eprice!a2" cdim=0 par=etprice rng="etprice!a2" cdim=0';

$exit

$label missingharfiles
$log	
$log	*** Error *** Missing HAR files.
$log	
$log	Need to have the following files for this program:
$log		%gtapdatadir%gsdset.har 
$log		%gtapdatadir%gsddat.har 
$log		%gtapdatadir%gsdpar.har 
$log		%gtapdatadir%gsdvole.har 
$log		%gtapdatadir%gsdemiss.har 
$log		%gtapdatadir%gsdtax.har 
$log	
$log	These files are part of the flexagg distribution from GTAP9.
$log
$exit

$label missinggdxfiles
$log	
$log	*** Error *** Missing GDX files.
$log	
$log	One of the following translations seems to have failed:
$log		har2gdx %gtapdatadir%gsdset.har gsdset.gdx
$log		har2gdx %gtapdatadir%gsddat.har gsddat.gdx
$log		har2gdx %gtapdatadir%gsdpar.har gsdpar.gdx
$log		har2gdx %gtapdatadir%gsdvole.har gsdvole.gdx
$log		har2gdx %gtapdatadir%gsdemiss.har gsdemiss.gdx
$log		har2gdx %gtapdatadir%gsdtax.har gsdtax.gdx
$log	
$log	These files are part of the flexagg distribution from GTAP9.
$log
$exit

