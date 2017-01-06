$if not setglobal debug $offlisting offinclude
$onempty
$hidden   Created 4/98 (tfr)
$hidden	  Updated 5/05 (tfr)
$version 89

$hidden   aggr.gms    General purpose parameter aggregation routine
$hidden   
$hidden   $...include aggr [param i [j [k [l]]]]
$hidden   
$hidden         Set identifier arguments define the source set, target
$hidden         set and mapping.  
$hidden   
$hidden         Assuming set arguments "i j k"
$hidden   
$hidden         Source Domain (i,j,k) 
$hidden   
$hidden         Target Domain (ji,jj,kk)
$hidden   
$hidden         Mapping from source to target is provided by mapi(i,ii),
$hidden         mapj(j,jj) and mapk(k,kk).
$hidden   
$hidden   
$hidden   Blank invocation for initialization outside a LOOP or IF block
$hidden 
$hidden   

*------------------------------------------------------------------

*       Skip compilation is there is a pre-existing program error:

$if not errorfree $exit

*       Assign all the args to a single item:

$setargs args

*------------------------------------------------------------------

*       Infer the sets:

$if declared aggrtemp1 $goto start

parameter       aggrtemp1,aggrtemp2,aggrtemp3,aggrtemp4,aggrtrace;
set             aggrerror,aggrset1,aggrset2,aggrset3,aggrset4;
alias           (u__1,u__2,u__3,u__4,*);

*       Make some assignments to avoid spurious symbol warnings:

aggrtrace("aggr") = 0;
aggrtemp1("aggr") = 0;
aggrtemp2("aggr","aggr") = 0;
aggrtemp3("aggr","aggr","aggr") = 0;
aggrtemp4("aggr","aggr","aggr","aggr") = 0;
aggrset1("aggr") = no;
aggrset2("aggr","aggr") = no;
aggrset3("aggr","aggr","aggr") = no;
aggrset4("aggr","aggr","aggr","aggr") = no;

$if errorfree $goto start

$onlisting

*       Error in invocation: $batinclude aggr %args%

*       An error has occured during the invocation of batinclude
*       routine "aggr". There are two reasons than an error may have been 
*       generated here:

*       (i) The first invocation of aggr is inside an IF or LOOP block.
*       The simple solution for this problem is to use initialize with
*       "$batinclude aggr" before entering the LOOP or IF.

*       (ii) User program has used one of the aggr reserved names, 
*       aggrtemp1, aggrtemp2, aggrtemp3 and aggrerror;

$abort 'Error: $batinclude aggr %args%'

*------------------------------------------------------------------

$label start

*       Blank invocation -- nothing to do:

$if "%1"=="" $exit

*------------------------------------------------------------------

*       See that the first argument is a declared and defined parameter:

$if declared %1    $goto declared
$error Error: identfier %1 is undeclared ($batinclude aggr %args%).
$exit

*------------------------------------------------------------------

$label declared
$if defined %1     $goto defined
$error Error: identfier %1 is undefined. ($batinclude aggr %args%)
$exit

*------------------------------------------------------------------

$label defined
$if partype %1 $goto checkdim
$error Error: identfier %1 is not a parameter. ($batinclude aggr %args%)
$exit

*------------------------------------------------------------------

$label checkdim
$if dimension 1 %1 $goto checksets
$if dimension 2 %1 $goto checksets
$if dimension 3 %1 $goto checksets
$if dimension 4 %1 $goto checksets
$error Error: invalid dimension %1. Must be 1,2,3 or 4. ($batinclude aggr %args%)
$exit

*------------------------------------------------------------------

$label checksets

*       checkset

$batinclude checkset %2 
$if setglobal aggrerror $goto error

$set ii %2  
$set i  %2%2  
$set mapi map%2

$if not dimension 1 %1 $goto check3


*------------------------------------------------------------------

*       One dimensional aggregation:

*$onuni
$batinclude domain %1 aggrset1
aggrset1(%ii%) = no;
*aggrset1(u__1) = yes$%1(u__1);  
*.$offuni
abort$card(aggrset1) "Source set for %1 does not include all nonzeros!",aggrset1;

$batinclude chktarget %3 1
$if setglobal aggrerror $goto error

aggrtrace("before") = sum(%ii%, %1(%ii%));
%3(%i%) = sum(%ii%$%mapi%(%ii%,%i%), %1(%ii%));
aggrtrace("after") = sum(%i%, %3(%i%));
$exit

*------------------------------------------------------------------

$label check3

$batinclude checkset %3
$if setglobal aggrerror $goto error

$set jj %3
$set j  %3%3
$set mapj map%3

$if not dimension 2 %1 $goto check4

*------------------------------------------------------------------

*       Two-dimensional aggregation:

$onuni
$batinclude domain %1 aggrset2
*aggrset2(u__1,u__2) = yes$%1(u__1,u__2);
aggrset2(%ii%,%jj%) = no;
$offuni

abort$card(aggrset2) "Source set for %1 does not include all nonzeros!",aggrset2;

$batinclude chktarget %4 2
$if setglobal aggrerror $goto error

aggrtrace("before") = sum((%ii%,%jj%), %1(%ii%,%jj%));
%4(%i%,%j%) = sum((%ii%,%jj%)$(%mapi%(%ii%,%i%)*%mapj%(%jj%,%j%)), %1(%ii%,%jj%));
aggrtrace("after") = sum((%i%,%j%), %4(%i%,%j%));
$exit

*------------------------------------------------------------------

$label check4

$batinclude checkset %4
$if setglobal aggrerror $goto error

$set kk %4
$set k  %4%4
$set mapk map%4

$if not dimension 3 %1 $goto check5

*------------------------------------------------------------------

*       Three dimensional aggregation:

$onuni
$batinclude domain %1 aggrset3
*.aggrset3(u__1,u__2,u__3) = yes$%1(u__1,u__2,u__3);
aggrset3(%ii%,%jj%,%kk%) = no;
$offuni

abort$card(aggrset3) "Source set for %1 does not include all nonzeros!",aggrset3;

$batinclude chktarget %5 3
$if setglobal aggrerror $goto error

aggrtrace("before") = sum((%ii%,%jj%,%kk%), %1(%ii%,%jj%,%kk%));
%5(%i%,%j%,%k%) 
        = sum((%ii%,%jj%,%kk%)$(%mapi%(%ii%,%i%)*%mapj%(%jj%,%j%)*%mapk%(%kk%,%k%)), 
                %1(%ii%,%jj%,%kk%));
aggrtrace("after") = sum((%i%,%j%,%k%), %5(%i%,%j%,%k%));
$exit

*------------------------------------------------------------------

$label check5
$batinclude checkset %5
$if setglobal aggrerror $goto error

$set ll %5
$set l  %5%5
$set mapl map%5

*------------------------------------------------------------------

*       Four-dimensional aggregation:

$onuni
$batinclude domain %1 aggrset4
*.aggrset4(u__1,u__2,u__3,u__4) = yes$%1(u__1,u__2,u__3,u__4);
aggrset4(%ii%,%jj%,%kk%,%ll%) = no;
$offuni

abort$card(aggrset4) "Source set for %1 does not include all nonzeros!",aggrset4;

$batinclude chktarget %6 4
$if setglobal aggrerror $goto error

aggrtrace("before") = sum((%ii%,%jj%,%kk%,%ll%), %1(%ii%,%jj%,%kk%,%ll%));
%6(%i%,%j%,%k%,%l%) 
        = sum((%ii%,%jj%,%kk%,%ll%)$(%mapi%(%ii%,%i%)*%mapj%(%jj%,%j%)*%mapk%(%kk%,%k%)*%mapl%(%ll%,%l%)), 
                %1(%ii%,%jj%,%kk%,%ll%));
aggrtrace("after") = sum((%i%,%j%,%k%,%l%), %6(%i%,%j%,%k%,%l%));
$exit

*------------------------------------------------------------------

$label error
$error  ..\Invocation error: aggr %ags%
$exit
