$if not setglobal debug $offlisting offinclude

*-----------------------------------------------------
* Verify consistency of a set argument to aggr
*-----------------------------------------------------

$set ii %1
$set i  %1%1
$set map map%1

$if not "%i%"=="" $goto exists
$error Error: set argument is missing. 
$goto error

$label exists
$if declared %i%  $goto declared
$error Error: set %i% is undeclared. 
$goto error

$label declared
$if defined %i%  $goto defined
$error Error: set %i% is undefined. 
$goto error

$label defined
$if settype %i% $goto setok
$error Error:  %i% is not a set. 
$goto error

$label setok

*-----------------------------------------------------

$if declared %ii%  $goto declared2
$error Error: set %ii% is undeclared.
$goto error

$label declared2
$if defined %ii%  $goto defined2
$error Error: set %ii% is undefined. 
$goto error

$label defined2
$if settype %ii% $goto setok2
$error Error:  %ii% is not a set.
$goto error

$label setok2

*-----------------------------------------------------

$if declared %map%  $goto declared3
$error Error: set %map% is undeclared. 
$goto error

$label declared3
$if defined %map%  $goto defined3
$error Error: set %map% is undefined. 
$goto error

$label defined3
$if settype %map% $goto setok3
$error Error:  %map% is not a set. 
$goto error

$label setok3
$if dimension 2 %map% $goto dimenok
$error Error:  %map% is not a two-dimensional set. 
$goto error

$label dimenok

*       Check the mapping and perform a one-dimensional 
*       aggregation:

aggrerror(%ii%)  = yes$(sum(%i%, 1$%map%(%ii%,%i%)) - 1);
abort$card(aggrerror) "Element of source set %ii% not uniquely assigned:",aggrerror,%map%;

aggrerror(%i%)  = yes$(not sum(%ii%, 1$%map%(%ii%,%i%)));
abort$card(aggrerror) "Element of target set %i% has no assignments:",aggrerror,%map%;

$exit

$label error
$setglobal aggrerror true
$exit


