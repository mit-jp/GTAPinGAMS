$hidden		GAMS LIBINCLUDE ROUTINE DOMAIN
$hidden
$hidden		Return the full dimensional domain defined by the non-zero 
$hidden		structure of a parameter argument.
$hidden
$hidden		Thomas F. Rutherford
$hidden		January, 2005
$hidden
$hidden		Usage:
$hidden			$libinclude domain p d
$hidden
$hidden		Returns domain of non-zero elements in p to d
$hidden
$hidden		p can have between 1 and 7 dimensions.
$hidden
$hidden
$hidden		Uses identifiers: d_1*d_7,p1*p7,pd_1*pd7.
$hidden
$version 139

$if not declared d_1 alias (d_1,d_2,d_3,d_4,d_5,d_6,d_7,*);
$if not declared p_1 parameter p_1(d_1),p_2(d_1,d_2),p_3(d_1,d_2,d_3),p_4(d_1,d_2,d_3,d_4),
$if not declared p_5 p_5(d_1,d_2,d_3,d_4,d_5),p_6(d_1,d_2,d_3,d_4,d_5,d_6),
$if not declared p_7 p_7(d_1,d_2,d_3,d_4,d_5,d_6,d_7);
$if not declared pd_1 set pd_1(d_1), pd_2(d_1,d_2), pd_3(d_1,d_2,d_3), pd_4(d_1,d_2,d_3,d_4),
$if not declared pd_5 pd_5(d_1,d_2,d_3,d_4,d_5),pd_6(d_1,d_2,d_3,d_4,d_5,d_6),
$if not declared pd_7 pd_7(d_1,d_2,d_3,d_4,d_5,d_6,d_7);

$set p %1
$set d %2

$hidden	Skip out with declarations following a blank invocation:
$if "%p%"=="" $exit

$if dimension 1 %p% $goto dim1
$if dimension 2 %p% $goto dim2
$if dimension 3 %p% $goto dim3
$if dimension 4 %p% $goto dim4
$if dimension 5 %p% $goto dim5
$if dimension 6 %p% $goto dim6
$if dimension 7 %p% $goto dim7

$label dim1
$if not settype %d%	$abort "Error -- row domain argument is not a set: %rd%"
$if not dimension 1 %d% $abort "Error -- expected a one dimensional row domain, but got %d%."
$onuni
	p_1(d_1)=%p%(d_1); 
	option pd_1<p_1; 
	%d%(d_1)=pd_1(d_1);
$offuni
	pd_1(d_1)=no;
$exit

$label dim2
$if not settype %d%	$abort "Error -- row domain argument is not a set: %rd%"
$if not dimension 2 %d% $abort "Error -- expected a two dimensional row domain, but got %d%."
$onuni
	p_2(d_1,d_2)=%p%(d_1,d_2); 
	option pd_2<p_2; 
	%d%(d_1,d_2)=pd_2(d_1,d_2);
$offuni
	pd_2(d_1,d_2)=no;
$exit

$label dim3
$if not settype %d%	$abort "Error -- row domain argument is not a set: %rd%"
$if not dimension 3 %d% $abort "Error -- expected a three dimensional row domain, but got %d%."
$onuni
	p_3(d_1,d_2,d_3)=%p%(d_1,d_2,d_3); 
	option pd_3<p_3; 
	%d%(d_1,d_2,d_3)=pd_3(d_1,d_2,d_3);
$offuni
	pd_3(d_1,d_2,d_3)=no;
$exit

$label dim4
$if not settype %d%	$abort "Error -- row domain argument is not a set: %rd%"
$if not dimension 4 %d% $abort "Error -- expected a four dimensional row domain, but got %d%."
$onuni
	p_4(d_1,d_2,d_3,d_4)=%p%(d_1,d_2,d_3,d_4); 
	option pd_4<p_4; 
	%d%(d_1,d_2,d_3,d_4)=pd_4(d_1,d_2,d_3,d_4);
$offuni
	pd_4(d_1,d_2,d_3,d_4)=no;
$exit

$label dim5
$if not settype %d%	$abort "Error -- row domain argument is not a set: %rd%"
$if not dimension 5 %d% $abort "Error -- expected a five dimensional row domain, but got %d%."
$onuni
	p_5(d_1,d_2,d_3,d_4,d_5)=%p%(d_1,d_2,d_3,d_4,d_5); 
	option pd_5<p_5; 
	%d%(d_1,d_2,d_3,d_4,d_5)=pd_5(d_1,d_2,d_3,d_4,d_5);
$offuni
	pd_5(d_1,d_2,d_3,d_4,d_5)=no;
$exit

$label dim6
$if not settype %d%	$abort "Error -- row domain argument is not a set: %rd%"
$if not dimension 6 %d% $abort "Error -- expected a six dimensional row domain, but got %d%."
$onuni
	p_6(d_1,d_2,d_3,d_4,d_5,d_6)=%p%(d_1,d_2,d_3,d_4,d_5,d_6); 
	option pd_6<p_6; 
	%d%(d_1,d_2,d_3,d_4,d_5,d_6)=pd_6(d_1,d_2,d_3,d_4,d_5,d_6);
$offuni
	pd_6(d_1,d_2,d_3,d_4,d_5,d_6)=no;
$exit

$label dim7
$if not settype %d%	$abort "Error -- row domain argument is not a set: %rd%"
$if not dimension 7 %d% $abort "Error -- expected a seven dimensional row domain, but got %d%."
$onuni
	p_7(d_1,d_2,d_3,d_4,d_5,d_6,d_7)=%p%(d_1,d_2,d_3,d_4,d_5,d_6,d_7); 
	option pd_7<p_7; 
	%d%(d_1,d_2,d_3,d_4,d_5,d_6,d_7)=pd_7(d_1,d_2,d_3,d_4,d_5,d_6,d_7);
$offuni
	pd_7(d_1,d_2,d_3,d_4,d_5,d_6,d_7)=no;
$exit

