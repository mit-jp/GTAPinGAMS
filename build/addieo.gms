$title	Program merges the IEO, IEA, EPA, and CIESIN projection data 

set yrs /1751*2004/, sortyr /2005*2100/;

*	Read the EPA-consistent dataset:

$if not set ds $set ds gtap7ingams

$include gtap7data

*	Compare these data to the energy totals provided by GTAP:

parameter
	eratio(i)	Energy conversion coefficient,
	mtoetej		MTOE to EJ conversion factor /23.88/
	ejtkwh		EJ TO 10^12 KWH conversion factor;
	
set e(i) /gas,oil,col,ele/;
eratio(e) = 1/mtoetej;
ejtkwh=948/3413;
eratio("ele") = eratio("ele") * ejtkwh;

set column /
	solid		"CO2 emissions from solid fuel consumption",
	liquid		"CO2 emissions from liquid fuel consumption",
	gas		"CO2 emissions from gas fuel consumption",
	cement		"CO2 emissions from cement production",
	flaring		"CO2 emissions from gas flaring" /;

*	Read the CIESIN population data:

set	sresscn	/a1,b1,a2,b2/;

set	tyr	Points in time for CIESIN database 
	/1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025, 2030, 2035, 2040, 2045, 2050, 
	 2055, 2060, 2065, 2070, 2075, 2080, 2085, 2090, 2095, 2100/;

parameter popdata(sresscn,r,tyr) "Population database from http://ciesin.columbia.edu/datasets/downscaled/";
$gdxin '..\ciesin\gdx\ciesin_gtap7.gdx'
$loaddc popdata

*	Read the IEO data:

set	scn		IEO scenarios	 /
		ref		Reference case,
		high		High oil price,
		low		Low oil price,
		high_gdp	High GDP growth,
		low_gdp		Low GDP growth /,

	yr	Years	 / 1990*2100 /,
	eg(i)	Final energy goods /ele,col,oil,gdt,gas/,
	fd	Final demand sectors /Residential, Commercial, Industrial, ElectricPower, Transportation/,
	ieo_gen	IEO generation technologies /oilgen, gasgen, colgen, nucgen, hydrogen, windgen, geogen, othrnwgen/,
	iea_gen IEA generation technologies /thermalgen, hydrogen, rengen, nucleargen/,
	t_ieo	Projected and historical time periods /1990,1995,2000,2004,2005,
		2010,2015,2020,2025,2030,2035,2040,2045,2050
		2055,2060,2065,2070, 2075, 2080, 2085, 2090, 2095, 2100
/;

parameter	ieocarbon(scn,*,r,*)		IEO carbon emissions by scenario (index -- 2004=1),
		ieogdp(scn,r,t_ieo)		IEO GDP by scenario (index -- 2004=1),
		ieocrude(scn,r,t_ieo)		IEO crude oil equivalent supply (index -- 2004=1),
		ieoprice(scn,t_ieo)		IEO oil prices (index -- 2004=1),
		ieoelec(scn,r,t_ieo)		IEO electricity supply (index -- 2004=1),
		ieoenergy(scn,*,fd,r,t_ieo)	IEO energy use by sector (index -- 2004=1),
		ieoelegen_shr(scn,ieo_gen,r,t_ieo)	IEO power generation share by aggregate technology and IEO region, 	

		ieaco2emit(e,r,t_ieo)		Historical carbon emissions by regions as of IEA
		ieaelec(iea_gen,r,*)		Base-year power production by technology and GTAP region as provided by IEA annuals;

$if not set ieoversion $set ieoversion ieo2010


display "%ieoversion%";
$gdxin ..\%ieoversion%\gdx\ieoiean_gtap7_2100.gdx
$loaddc ieocarbon ieogdp ieocrude ieoelec ieoenergy ieoprice ieoelegen_shr ieaco2emit  ieaelec


*	Scale GDP  proportionally:
parameter ieogdp_;
ieogdp_(scn,r,t_ieo) = ieogdp(scn,r,t_ieo) * (vom("c",r) + vom("g",r) + vom("i",r) - vb(r));

*	Convert emissions, gdp and crude oil projections to common units:

parameter       cecphys(i)      carbon emission coefficients for physical units 
                                /col 0.024, gas 0.0137, oil 0.0181 /;

set fdmap(g,eg,fd) Correspondence between GTAP sectors and IEO demand categories

*	Use transportation for oil demand:

	/	c.(ele,gas,col).Residential, 
		(otp,wtp,atp,c).oil.Transportation, 
		ele.(col,gas,oil).ElectricPower, 
		(trd,obs,ros,osg,isr,ofi).(ele,col,oil,gas).Commercial/;

fdmap(i,eg,"Industrial")$(sum(fdmap(i,eg,fd),1)=0) = yes;

*	Convert carbon to a scenario and sectorally-indexed parameter:

parameter	ieoenergy_(scn,i,g,r,t_ieo)	Sectoral energy use;
*.ieogdp("ref",r,t_ieo) = ieogdp("ref",r,t_ieo) + eps;
*.display ieogdp;

*	Take a quick look at carbon which is not associated with

parameter	bycarbon	Base year carbon emissions;
*.bycarbon("iea",r,eg(i)) = cecphys(i) * sum(g,ed(i,g,r)) * 1000;
bycarbon("gtap",r,eg(i)) = sum(g, eco2(i,g,r))/(3.664*1000);
option bycarbon:3:2:1;
display bycarbon;

parameter	CO2inC		Conversion factor from CO2 into C;
CO2inC = 12/44;

ieoenergy(scn,eg(i),fd,r,t_ieo)$(ieoenergy(scn,i,fd,r,t_ieo) = 0) = ieogdp(scn,r,t_ieo);

*	Use GTAP energy and carbon emission statistics:

ieoenergy_(scn,eg(i),g,r,t_ieo)	 = evd(i,g,r) * sum(fdmap(g,eg,fd), ieoenergy(scn,i,fd,r,t_ieo));

*	Use the growth rate of natural gas emissions to index
*	growth in carbon emissions associated with GDT:

ieocarbon(scn,"gdt",r,t_ieo) = ieocarbon(scn,"gas",r,t_ieo);

ieocarbon(scn,eg(i),r,t_ieo) = sum(g,eco2(i,g,r))*co2inc/1e6 * ieocarbon(scn,i,r,t_ieo);

display ieoenergy_, ieocarbon, eco2;

parameter debugchk;
debugchk(eg(i),r,"eco2") = sum(g, eco2(i,g,r))*co2inc/1e6;
debugchk(eg(i),r,"ieocarbon") = ieocarbon("ref",i,r,"2004");
display debugchk;

parameter	eprd	Energy production levels;
eprd(r,i) = max(0,sum(g,evd(i,g,r)) + sum(s,evt(i,r,s)-evt(i,s,r)));
display eprd;

parameter ieocrude_;
ieocrude_(scn,r,t_ieo) = ieocrude(scn,r,t_ieo) * eprd(r,"cru");


*	Read the EPA baseline and MAC data for non-CO2 GHG:
*	Set nco2 includes ch4, n2o and fgas.

set	val	CO2 value per t of gas /0,15,30,45,60/;

set	nco2src		Source of all NCO2 gases (CH4 - N2O - FGAS) /

	entferm		Enteric Fermentation
	oil		Fugitives from oil systems (imputed)
	cru		Fugitives from crude oil extraction (imputed)
	gas		Fugitives from natural gas systems (imputed)
	coal		Fugitives from Coal Mining Activities
	statmob		Stationary and Mobile Combustion
	biocomb		Biomass Combustion
	ind_nonag	Other Industrial Non-Agricultural Sources
	rice		Rice Cultivation
	manure		Manure Management
	othag		Other Agricultural Sources
	lndfl		Landfilling of Solid Waste
	wwter		Wastewater
	nonag		Non-Agricultural Sources (Waste and Other), 
	adipnit		Adipic Acid and Nitric Acid Production
	soil		Agricultural Soils
	humsew		Human Sewage

	aerosols_mdi		"HFC and PFC Emissions from ODS Substitutes - Aerosols (MDI)",
	aerosols_nmdi		"HFC and PFC Emissions from ODS Substitutes - Aerosols (Non-MDI)",
	fire			"HFC and PFC Emissions from ODS Substitutes - Fire Extinguishing",
	foams			"HFC and PFC Emissions from ODS Substitutes - Foams",
	refrige			"HFC and PFC Emissions from ODS Substitutes - Refrigeration/Air Conditioning",
	solvents		"HFC and PFC Emissions from ODS Substitutes - Solvents",
	hcfc_22_1		"HFC-23 Emissions from HCFC-22 Production (Technology-Adoption)",
	hcfc_22_2		"HFC-23 Emissions from HCFC-22 Production (No-Action)",
	elepower_1		"SF6 Emissions from Electric Power Systems (Technology-Adoption)",
	elepower_2		"SF6 Emissions from Electric Power Systems (No-Action)",
	aluminum_1		"PFC Emissions from Primary Aluminum Production (Technology-Adoption)",
	aluminum_2		"PFC Emissions from Primary Aluminum Production (No-Action)",
	semiconductor_1		"HFC, PFC, SF6 Emissions from Semiconductor Manufacturing (Technology-Adoption)",
	semiconductor_2		"HFC, PFC, SF6 Emissions from Semiconductor Manufacturing (No-Action)",
	magnesium_1		"SF6 Emissions from Magnesium Manufacturing (Technology-Adoption)",
	magnesium_2		"SF6 Emissions from Magnesium Manufacturing (No-Action)" /;

parameter	emitsrc(nco2,nco2src,r,t_ieo)	Non-CO2 emissions inventory by source
		mac(nco2,nco2src,r,t_ieo,val)	Marginal abatement cost;
		
$gdxin '..\epa\gdx\epanco2_gtap72100.gdx'
$loaddc emitsrc mac

*	Units of eprd(r,"ele") MTOE ==> Billion KWh

$ontext

Units

Kilo	 = k	 = 10**3	 = Tausend		Tera	= T	 = 10**12	 = Billion
Mega 	 = M	 = 10**6	 = Million		Peta	= P	 = 10**15	 = Billiarde
Giga	 = G	 = 10**9	 = Milliarde		Exa 	= E	 = 10**18	 = Trillion

Unit conversion (from row to column):
					PJ	   Mio. t SKE	Mio. t RÖE	Mrd. kcal	TWh
1 Petajoule (PJ)			-	   0.034	0.024		238.8		0.278  
1 Mio. t  Steinkohleeinheit (SKE)	29.308 	     -		0.7		7,000		8.14  
1 Mio. t Rohöleinheit (RÖE)		41.869 	   1.429  	-		10,000  	11.63  
1 Mrd. Kilokalorien (kcal)		0.0041868  0.000143  	0.0001  	-		0.001163  
1 Terawattstunde (TWh)			3.6	   0.123  	0.0861  	859.8		-

$offtext


parameter comp_ele	Compare base-year electricity production for 2004 in Billion KWh;
comp_ele(r,"GTAP")	= eprd(r,"ele")*11.63;
comp_ele(r,"IEA")	=   ieaelec("thermalgen",r,"2004") 
			  + ieaelec("hydrogen",r,"2004")
			  + ieaelec("rengen",r,"2004")
			  + ieaelec("nucleargen",r,"2004");
display comp_ele;

*	Report base-year electricity producton for 2004 by power technologies 
*	for those regions that have a 1:1 mapping in GTAP7 to IEO

set single_r(r)		/usa, can, mex, jpn, kor, rus, chn, ind, bra/

parameter comp_gen	Comparison of technology-specific power generation for 2004;

loop(r$single_r(r),
	comp_gen(r,"thermal","IEA")   = ieaelec("thermalgen",r,"2004");
	comp_gen(r,"nuclear","IEA")   = ieaelec("nucleargen",r,"2004");
	comp_gen(r,"renewable","IEA") = ieaelec("hydrogen",r,"2004") + ieaelec("rengen",r,"2004");
);		
option comp_gen:1:1:2;
display  comp_gen;

*	Convert electricty production from growth indices into total values
*	(for subsequent aggregation using aggr.gms)
**.ieoelec(scn,r,t_ieo)		 = eprd(r,"ele")* ieoelec(scn,r,t_ieo); 	

*	Here we may rather use the IEA values for electricity production

parameter ieoelec_;
ieoelec_(scn,r,t_ieo) =  [ieaelec("thermalgen",r,"2004")  +  
			  ieaelec("hydrogen",r,"2004")  + 
			  ieaelec("rengen",r,"2004")  + 
			  ieaelec("nucleargen",r,"2004")] * ieoelec(scn,r,t_ieo); 

*	Share out electricty production along baseline across different technologies

parameter ieoelegen_;
ieoelegen_(scn,ieo_gen, r,t_ieo) = ieoelec_(scn,r,t_ieo)*ieoelegen_shr(scn,ieo_gen,r,t_ieo);

*       Move the dataset into a GDX archive:

execute_unload '..\data\%ds%_e.gdx', 
	g, r, f, i, 
	vfm, vdfm, vifm, vxmd, vst, vtwr,
	evd, evt, eco2, enco2,
	emitsrc, mac,
	rto, rtf, rtfd, rtfi, rtxs, rtms, 
	esubd, esubva, esubm, etrae, eta, epsilon,
	ieocarbon, ieogdp_=ieogdp, ieocrude_=ieocrude, ieoelec_=ieoelec, ieoenergy_=ieoenergy, ieoprice, ieoelegen_=ieoelegen, 
	popdata, ieaco2emit, ieaelec;
