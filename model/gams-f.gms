$hidden GAMSF  GAMS Function Preprocessor
$log --- Running the GAMS function preprocessor ...

$hidden Define where to put the translated file: the scratch directory

$setlocal output %gams.scrdir%gams-f.scr

$hidden  $show      to dump symbols to listingfile

$call gams-f <"%system.incparent%" >"%output%"
$if not errorlevel 0 $abort "Error in preprocessing by GAMS-F."
$include "%output%"

$hidden The following line can be inserted with GAMS 2.50a and later.
$hidden If you use $stop rather than $exit here, you can skip the $exit
$hidden statement in the calling program.

$stop

$label gamsf_error

$error GAMSF error translating functions.  See the listing file!

$abort MPSGE further processing would be misleading
