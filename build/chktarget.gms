*-----------------------------------------------------
* Verify consistency of a target argument to aggr
*-----------------------------------------------------

$if declared %1 $goto declared
$error Error: target parameter %1 is undeclared.
$setglobal aggrerror true
$exit

$label declared
$if partype %1 $goto partype
$error Error: target %1 is not a parameter.
$setglobal aggrerror true
$exit

$label partype
$if defined %1 $goto defined
$exit

$label defined
$if dimension %2 %1 $exit
$error Error: target %1 has inconsistent dimension
$setglobal aggrerror true
$exit
