#!/bin/tcsh

echo "------------------------------------------"
date
echo `date`" - Unpacking idl code to current directory..."
tar zxvf smart_system_test.tar.gz
echo "------------------------------------------"

echo `date`" - Moving to running directory..."
cd smart_system_test
echo "------------------------------------------"

#
# Edit input file
#

echo "------------------------------------------"
echo `date`" - Checking IDL_DIR......"
echo `ls -la /opt/exp_soft/helio/idl/idl/`

echo `date`" - Setting IDL_DIR......"
setenv IDL_DIR '/opt/exp_soft/helio/idl/idl'

echo `date`" - Setting IDL_LICENSE_DIR......"
setenv LM_LICENSE_FILE '/opt/exp_soft/helio/idl/license/license.dat'

echo "------------------------------------------"
echo `date`" - Executing IDL code with the following argument ..."
echo "Start date: "$1
echo "Stop date: "$2
echo "Runname : "$3

echo `date`" - Modifying Job description with current parameters ..."
echo "stage_smart_arg,'$1','$2',runname='$3',/grid\n" >> idl_input.txt
# echo "end" >> idl_input.txt
#
# Executing code for active region extraction ...
#

#echo `date`" - Modifying proxy to proxy.cs.tcd.ie ..."
#setenv http_proxy 'http://proxy.cs.tcd.ie:8080'
echo `date`" - Proxy in use is ..."
echo $http_proxy

echo `date`" - Exceuting SMART ....."
source /opt/exp_soft/helio/ssw/ssw-config.sh < idl_input.txt
echo `date`"..... done"
echo "------------------------------------------"

#
# Now saving the db files into the grid store...
#

echo  `date`" - Saving the db files into the grid store..."

set LOCAL_DB_DIR=`pwd`/data/database
set REMOTE_DB_DIR=/grid/vo.helio-vo.eu/data/smart_output/database

echo $LOCAL_DB_DIR
echo `ls $LOCAL_DB_DIR`

foreach i ( `ls $LOCAL_DB_DIR` )

echo `date`" - Saving db file...."$i

lcg-cr --vo vo.helio-vo.eu file:$LOCAL_DB_DIR/$i -l lfn:$REMOTE_DB_DIR/$i

end
echo `date`".... done"
echo "------------------------------------------"

##
## Now ftp the db files to Paris !!!
##
#echo `date`" - Transfer files to Paris ...."
#cd data/database
#echo "mput '$3'*.csv" >> ../../sendfiles_paris
#lftp -f ../../sendfiles_paris
#echo `date`".... done"
#echo "------------------------------------------"
