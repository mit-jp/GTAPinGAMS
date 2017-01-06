set	f	Factors /
	lab	Unskilled labor
	skl	Skilled labor
	cap	Capital
	res	Resources
	lnd	Land /;

set	i	Commodites in the aggregation /
	PDR	"Paddy rice",
	WHT	"Wheat",
	GRO	"Cereal grains nec",
	V_F	"Vegetables, fruit, nuts",
	OSD	"Oil seeds",
	C_B	"Sugar cane, sugar beet",
	PFB	"Plant-based fibers",
	OCR	"Crops nec",
	CTL	"Bovine cattle, sheep and goats, horses",
	OAP	"Animal products nec",
	RMK	"Raw milk",
	WOL	"Wool, silk-worm cocoons",
	FRS	"Forestry",
	FSH	"Fishing",
	COL	"Coal",
	CRU	"Crude Oil",
	GAS	"Gas",
	OMN	"Minerals nec",
	CMT	"Bovine meat products",
	OMT	"Meat products nec",
	VOL	"Vegetable oils and fats",
	MIL	"Dairy products",
	PCR	"Processed rice",
	SGR	"Sugar",
	OFD	"Food products nec",
	B_T	"Beverages and tobacco products",
	TEX	"Textiles",
	WAP	"Wearing apparel",
	LEA	"Leather products",
	LUM	"Wood products",
	PPP	"Paper products, publishing",
	OIL	"Petroleum, coal products",
	CRP	"Chemical, rubber, plastic products",
	NMM	"Mineral products nec",
	I_S	"Ferrous metals",
	NFM	"Metals nec",
	FMP	"Metal products",
	MVH	"Motor vehicles and parts",
	OTN	"Transport equipment nec",
	EEQ	"Electronic equipment",
	OME	"Machinery and equipment nec",
	OMF	"Manufactures nec",
	ELE	"Electricity",
	GDT	"Gas manufacture, distribution",
	WTR	"Water",
	CNS	"Construction",
	TRD	"Trade",
	OTP	"Transport nec",
	WTP	"Water transport",
	ATP	"Air transport",
	CMN	"Communication",
	OFI	"Financial services nec",
	ISR	"Insurance",
	OBS	"Business services nec",
	ROS	"Recreational and other services",
	OSG	"Public Administration, Defense, Education, Health",
	DWE	"Dwellings" /;

set	r	Countries and Regions  /

	AUS	Australia
*		- Australia
*		- Christmas Island
*		- Cocos (Keeling) Islands
*		- Heard Island and McDonald Islands
*		- Norfolk Island
	NZL	New Zealand
	XOC	Rest of Oceania
*		- American Samoa
*		- Cook Islands
*		- Fiji
*		- French Polynesia
*		- Guam
*		- Kiribati
*		- Marshall Islands
*		- Micronesia Federated States of
*		- Nauru
*		- New Caledonia
*		- Niue
*		- Northern Mariana Islands
*		- Palau
*		- Papua New Guinea
*		- Pitcairn
*		- Samoa
*		- Solomon Islands
*		- Tokelau
*		- Tonga
*		- Tuvalu
*		- United States Minor Outlying Islands
*		- Vanuatu
*		- Wallis and Futuna
	CHN	China
	HKG	Hong Kong
	JPN	Japan
	KOR	Korea Republic of
	MNG	Mongolia
	TWN	Taiwan
	XEA	Rest of East Asia
*		- Korea Democratic Peoples Republic of
*		- Macao
	KHM	Cambodia
	IDN	Indonesia
	LAO	Lao People's Democratic Republic
	MYS	Malaysia
	PHL	Philippines
	SGP	Singapore
	THA	Thailand
	VNM	Viet Nam
	XSE	Rest of Southeast Asia
*		- Brunei Darussalam
*		- Myanmar
*		- Timor Leste
	BGD	Bangladesh
	IND	India
	NPL	Nepal
	PAK	Pakistan
	LKA	Sri Lanka
	XSA	Rest of South Asia
*		- Afghanistan
*		- Bhutan
*		- Maldives
	CAN	Canada
	USA	United States of America
	MEX	Mexico
	XNA	Rest of North America
*		- Bermuda
*		- Greenland
*		- Saint Pierre and Miquelon
	ARG	Argentina
	BOL	Plurinational Republic of Bolivia
	BRA	Brazil
	CHL	Chile
	COL	Colombia
	ECU	Ecuador
	PRY	Paraguay
	PER	Peru
	URY	Uruguay
	VEN	Venezuela
	XSM	Rest of South America
*		- Falkland Islands (Malvinas)
*		- French Guiana
*		- Guyana
*		- South Georgia and the South Sandwich Islands
*		- Suriname
	CRI	Costa Rica
	GTM	Guatemala
	HND	Honduras
	NIC	Nicaragua
	PAN	Panama
	SLV	El Salvador
	XCA	Rest of Central America
*		- Belize
	XCB	Caribbean
*		- Anguilla
*		- Antigua & Barbuda
*		- Aruba
*		- Bahamas
*		- Barbados
*		- Cayman Islands
*		- Cuba
*		- Dominica
*		- Dominican Republic
*		- Grenada
*		- Haiti
*		- Jamaica
*		- Montserrat
*		- Netherlands Antilles
*		- Puerto Rico
*		- Saint Kitts and Nevis
*		- Saint Lucia
*		- Saint Vincent and the Grenadines
*		- Trinidad and Tobago
*		- Turks and Caicos Islands
*		- Virgin Islands British
*		- Virgin Islands U.S.
	AUT	Austria
	BEL	Belgium
	CYP	Cyprus
	CZE	Czech Republic
	DNK	Denmark
	EST	Estonia
	FIN	Finland
*		- Aland Islands
*		- Finland
	FRA	France
*		- France
*		- Guadeloupe
*		- Martinique
*		- Reunion
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
*		- Norway
*		- Svalbard and Jan Mayen
	XEF	Rest of EFTA
*		- Iceland
*		- Liechtenstein
	ALB	Albania
	BGR	Bulgaria
	BLR	Belarus
	HRV	Croatia
	ROU	Romania
	RUS	Russian Federation
	UKR	Ukraine
	XEE	Rest of Eastern Europe
*		- Moldova Republic of
	XER	Rest of Europe
*		- Andorra
*		- Bosnia and Herzegovina
*		- Faroe Islands
*		- Gibraltar
*		- Guernsey
*		- Holy See (Vatican City State)
*		- Isle of Man
*		- Jersey
*		- Macedonia the former Yugoslav Republic of
*		- Monaco
*		- Montenegro
*		- San Marino
*		- Serbia
	KAZ	Kazakhstan
	KGZ	Kyrgyzstan
	XSU	Rest of Former Soviet Union
*		- Tajikistan
*		- Turkmenistan
*		- Uzbekistan
	ARM	Armenia
	AZE	Azerbaijan
	GEO	Georgia
	BHR	Bahrain
	IRN	Iran Islamic Republic of
	ISR	Israel
	KWT	Kuwait
	OMN	Oman
	QAT	Qatar
	SAU	Saudi Arabia
	TUR	Turkey
	ARE	United Arab Emirates
	XWS	Rest of Western Asia
*		- Iraq
*		- Jordan
*		- Lebanon
*		- Palestinian Territory Occupied
*		- Syrian Arab Republic
*		- Yemen
	EGY	Egypt
	MAR	Morocco
	TUN	Tunisia
	XNF	Rest of North Africa
*		- Algeria
*		- Libyan Arab Jamahiriya
*		- Western Sahara
	CMR	Cameroon
	CIV	Cote d'Ivoire
	GHA	Ghana
	NGA	Nigeria
	SEN	Senegal
	XWF	Rest of Western Africa
*		- Benin
*		- Burkina Faso
*		- Cape Verde
*		- Gambia
*		- Guinea
*		- Guinea-Bissau
*		- Liberia
*		- Mali
*		- Mauritania
*		- Niger
*		- Saint Helena, Ascension and Tristan Da Cunha
*		- Sierra Leone
*		- Togo
	XCF	Central Africa
*		- Central African Republic
*		- Chad
*		- Congo
*		- Equatorial Guinea
*		- Gabon
*		- Sao Tome and Principe
	XAC	South Central Africa
*		- Angola
*		- Congo the Democratic Republic of the
	ETH	Ethiopia
	KEN	Kenya
	MDG	Madagascar
	MWI	Malawi
	MUS	Mauritius
	MOZ	Mozambique
	TZA	Tanzania United Republic of
	UGA	Uganda
	ZMB	Zambia
	ZWE	Zimbabwe
	XEC	Rest of Eastern Africa
*		- Burundi
*		- Comoros
*		- Djibouti
*		- Eritrea
*		- Mayotte
*		- Rwanda
*		- Seychelles
*		- Somalia
*		- Sudan
	BWA	Botswana
	NAM	Namibia
	ZAF	South Africa
	XSC	Rest of South African Customs Union
*		- Lesotho
*		- Swaziland
	XTW	Rest of the World 
*		- Antarctica
*		- Bouvet Island
*		- British Indian Ocean Territory
*		- French Southern Territories 
	/;
