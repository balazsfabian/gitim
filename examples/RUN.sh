#!/bin/bash

GROMPP=`which grompp`

GDENS1=`which g_density`
GDENS2=`which ../g_density `

# if a version of g_density is found in the path, let's check if it is ITIM-enabled.
if [ -n  $GDENS1 ] ; then
	TEST=`$GDENS1 -h 2>&1 | grep -c MCnorm`
	if [ $TEST -eq 0 ] ; then
                #if it is not, let's check in the parent folder.
		if [ -n $GDENS2 ] ; then 
			TEST=`$GDENS2 -h 2>&1 | grep -c MCnorm`
			if [ $TEST  -eq 0 ] ; then 	
				echo "No working version of g_density with ITIM support was found neither in the path, not in the parent folder, cannot continue."
			else 
				GDENS=$GDENS2
			fi
		else
			echo "No working version of g_density with ITIM support was found neither in the path, not in the parent folder, cannot continue."
		fi
	else 
		GDENS=$GDENS1
		
 	fi
fi

if [ -z $GROMPP ] ; then 
	echo "could not find grompp in the path, cannot continue." 
	exit
fi

echo "g_density needs a .tpr file, let's create it now...."
grompp -f grompp.mdp -p topol.top -c ccl4-h2o.gro  -maxwarn 10  -o ccl4-h2o.tpr> grompp.log 2>&1 
echo "0 4 5" > masscom.dat
echo "Using $GDENS ..."
if [ -a ccl4-h2o.tpr ] ; then 
        name=dens_H2O_atomic_m ; echo "Intrinsic mass density profile w.r.t. water -> $name.xvg"
	echo "SOL SOL CCl4"  | $GDENS  -intrinsic -dens mass -f ccl4-h2o.gro -ng 3 -center -sl 200 -s ccl4-h2o.tpr  -o $name.xvg  > $name.log 2>&1 
        name=dens_CCl4_atomic_m ; echo "Intrinsic mass density profile w.r.t. ccl4-> $name.xvg"
	echo "CCl4 SOL CCl4" | $GDENS  -intrinsic -dens mass -f ccl4-h2o.gro -ng 3 -center -sl 200 -s ccl4-h2o.tpr  -o $name.xvg  > $name.log   2>&1 
        name=dens_H2O_atomic_n ; echo "Intrinsic number density profile w.r.t. water -> $name.xvg"
	echo "SOL SOL CCl4"  | $GDENS  -intrinsic -dens number -f ccl4-h2o.gro -ng 3 -center -sl 200 -s ccl4-h2o.tpr    -o $name.xvg  > $name.log   2>&1 
        name=dens_CCl4_atomic_n ; echo "Intrinsic number density profile w.r.t. ccl4 -> $name.xvg"
	echo "CCl4 SOL CCl4" | $GDENS  -intrinsic -dens number -f ccl4-h2o.gro -ng 3 -center -sl 200 -s ccl4-h2o.tpr    -o $name.xvg  > $name.log  2>&1 
        name=dens_H2O_atomicMC_m ; echo "Intrinsic mass density profile w.r.t. water with Monte Carlo normalization-> $name.xvg"
	echo "SOL SOL CCl4"  | $GDENS  -intrinsic -MCnorm -dens mass -f ccl4-h2o.gro -ng 3 -center -sl 200 -s ccl4-h2o.tpr  -o $name.xvg  > $name.log 2>&1 
        name=dens_H2O_molecularMC_m ; echo "Intrinsic molecular mass density profile w.r.t. water with Monte Carlo normalization-> $name.xvg"
	echo "SOL SOL CCl4"  | $GDENS  -intrinsic -MCnorm -dens mass -com -f ccl4-h2o.gro -ng 3 -center -sl 200 -s ccl4-h2o.tpr  -o $name.xvg  > $name.log 2>&1 
else 
	echo "Some errors probably occurred running grompp. Please have a look at grompp.log"

fi  


