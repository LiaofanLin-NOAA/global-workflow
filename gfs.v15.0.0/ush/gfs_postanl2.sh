#!/bin/ksh
#####################################################################
echo "------------------------------------------------"
echo " GFS postprocessing job
echo "------------------------------------------------"
echo "History: JULY 97 - First implementation of this new script."
echo "         Modified June 98 to send 00 and 12Z fax file to TPC."
echo "History: Sept 05 - Remove snd2forgn logic."
echo "         Sept 2005 - Remove generation of the 250MB plot and analysis 6-bit format"
echo "                     Replace with GEMPAK verison             "
echo "                     Converted fax graphics to T4 format and stopped writing to the"
echo "                     stat file."
echo "
#####################################################################

cd $DATA

######################
# Set up Here Files.
######################

##########################################
#
# START FLOW OF CONTROL
#
# 1) Make COM dirs.
#
# 2) GENDATA - reads hourly dumps, extracts synoptic, buoy, ship
#    and METAR data. Creates an AFOS plotfile over the tropics and
#    midlatitudes between 50N and 50S.
#
# 3) REDSAT - extracts low level satellite winds from the GFS
#    prepbufr  file and creates a file to be used by program TRPSFCMV.
#
# 4) TRPSFCMV - Plots analyzed wind barbs and temperatures. Contours
#    the 100mb streamfunctions and plots gridded winds.  It uses
#    NCAR graphics to produce a metafile which is rasterized in 
#    subsequent program execution.
#
# 5) RAS2BITY - packs 8-bit color map pizels into 1-bit black and
#    white pixels of the first slice 50S - 20N.
#
# 6) RAS2BITY - packs 8-bit color map pizels into 1-bit black and
#    white pixels of the second slice 40S - 40N.
#
# 7) SIXBITB2 - Reads station pixel coordinates and station wind,
#    temperture, dewpoint, cloud, weather, sky cover and barometer
#    data and plots standard plots on a generic bitmap background.
#
#
#########################################


########################################
set -x
msg="HAS BEGUN!"
postmsg "$jlogfile" "$msg"
########################################

set +x
echo " "
echo "######################################"
echo " Load SYNOP DATA "
echo "######################################"
echo " "
set -x

export FORM=$PDY$cyc
export TIME=$PDY

# This is an ush script version 06/17/2014
# DUMP=${NWROOTp1}/ush/dumpjb
# DUMP=/gpfs/hps/emc/global/noscrub/Boi.Vuong/para_hourly.20160914/dumpjb

#
#  New ush script version v3.2.1 08/10/2015
#  DUMP=${NWROOTp1}/obsproc_dump.v3.2.1/ush/dumpjb

# $DUMP 2016091900 1.5  synop
# export err=$?
# if [ "$err" -ne 0 ]
# then
#   echo "###  No synop data for synop.${PDY}${cyc}! ###"
#   echo "###  Stoping execution of GENDATA          ###"
#   err_chk
#fi

#for TYPE in metar ships lcman mbuoy dbuoy
#do
#   if [ ! -f ${COMINhourly} ]
#   then
#      $DUMP 2016091900 0.5 $TYPE
#   else
#      cp {COMINhourly}  $TYPE.$PDY$cyc
#   fi
# done

# cp /gpfs/hps/emc/global/noscrub/Boi.Vuong/prod_data_20160920/* .
export pgm=gendata
. prep_step

cp ${FIXshared}/graph_pillist1 .
 
export FORT11="synop.$PDY$cyc"
export FORT12="metar.$PDY$cyc"
export FORT13="ships.$PDY$cyc"
export FORT14="lcman.$PDY$cyc"
export FORT15="mbuoy.$PDY$cyc"
export FORT16="dbuoy.$PDY$cyc"
export FORT17="graph_pillist1"
export FORT52="NHPLOT"

startmsg
${GENDATA} <<EOF 2>errfile
$PDY$cyc
  50 -50  00 360 006 006
EOF

export err=$?;err_chk

#########################################################
# Obtain satellite winds
#########################################################
cp $COMIN/gfs.$cycle.prepbufr gfs.$cycle.prepbufr

export pgm=redsat
. prep_step

export FORT11="gfs.$cycle.prepbufr"
export FORT78="satwinds"

startmsg
${REDSAT}  >> $pgmout 2> errfile
export err=$?;err_chk

cp ${COMIN}/gfs.$cycle.pgrb2.1p00.anl .
$CNVGRIB -g21 gfs.$cycle.pgrb2.1p00.anl gfs.$cycle.tmppgrbanl
$COPYGB -xg3 gfs.$cycle.tmppgrbanl gfs.$cycle.pgrbanl
${GRBINDEX} gfs.$cycle.pgrbanl gfs.$cycle.pgrbianl
cp $COMIN/gfs.$cycle.syndata.tcvitals.tm00 tcvitals

export pgm=trpsfcmv
. prep_step

### input files ###
export FORT11="${RUN}.${cycle}.pgrbanl"
export FORT12="${RUN}.${cycle}.pgrbianl"
export FORT38="satwinds"
export FORT31="tcvitals"
export FORT43="NHPLOT"

### output files unit ### i

export FORT44="afosplot"
export FORT74="HBULL"
export FORT87="afosplot"
export FORT88="f88"
export FORT89="f89"

filesize=`cat NHPLOT | wc -c`
echo $filesize >fsize_in

startmsg
${TRPSFCMV} <fsize_in >> $pgmout 2> errfile
export err=$?; err_chk

###########################################################
# Rasterize the map of the first slice 50S-20N
###########################################################
ictrans -d xwd  -fdn 2 -resolution 6912x1728 -e ' zoom   0.0 0.3255555 1.0 0.5755556   ' -e 'plot 1 ' gmeta >f11

###########################################################
# Rasterize the map of the second slice 40S-40N
###########################################################
ictrans -d xwd  -fdn 2 -resolution 6912x1728 -e ' zoom   0.0 0.3755555 1.0 0.6255556   ' -e 'plot 1 ' gmeta >f12

###########################################################
# Pack 8 bit pixels into one bits of the first slice
###########################################################
export pgm=ras2bity
. prep_step

export FORT11="f11"
export FORT59="f59"

fssize=`cat f11 | wc -c `
echo $fssize  >fin
echo 6912 >>fin
echo 1728 >>fin

startmsg
${RAS2BITY} <fin >> $pgmout 2> errfile
export err=$?;err_chk

###############################################################
# Set up the first input image with the header glued at the top
###############################################################
cat ${FIXshared}/graph_ras2bity.header f59 > f59_ras2bity1

cp f59_ras2bity1 image001.pur
cp image001.pur mapback.pur
cp mapback.pur image002.pur

###########################################################
# Pack 8 bit pixels into one bits of the second slice
###########################################################

export pgm=ras2bity
. prep_step

export FORT11="f12"
export FORT59="f59"

fssize=`cat f12 | wc -c `
echo $fssize  >fin
echo 6912 >>fin
echo 1728 >>fin

startmsg
${RAS2BITY} <fin >> $pgmout 2> errfile
export err=$?;err_chk

###############################################################
# Set up the second input image with the header glued at the top
###############################################################
cat ${FIXshared}/graph_ras2bity.header > f59_ras2bity2

cp f59_ras2bity2 image002.pur

###########################################################
# Make NCEP sixbitb map
###########################################################
export pgm=sixbitb2
. prep_step

jobn=`echo $job|sed 's/[jpt]gfs/gfs/'`
FAXOUT=tropc${cycle}"."${cyc}

export DTIME=`cat $DATA/fort.79`
cp f88 fort.13
cat ${FIXshared}/graph_sixbitb.trpsfcmv.all >> fort.13
cat >>fort.13 <<EOF
SHIFT 000020034600000
GULFT 0150001400 TROPICAL SURFACE ANAL. AND OBS.
GULFT  1520 1400 VALID   $DTIME
GULFT  1540 1400 STREAM FUNCTION FROM GFS  ANAL.
GULFT  1500 2400 TROPICAL SURFACE ANAL. AND OBS.
GULFT  1520 2400 VALID  $DTIME
GULFT  1540 2400 STREAM FUNCTION FROM GFS  ANAL.
GULFT  1500 6300 TROPICAL SURFACE ANAL. AND OBS.
GULFT  1520 6300 VALID   $DTIME
GULFT  1540 6300 STREAM FUNCTION FROM GFS  ANAL.
PUTLA 00520 4201 01.0 90.0 060 1 0 0  TROPICAL CYCLONE INFORMATION $DTIME
PUTLA 00620 6411 01.0 90.0 060 1 0 0  TROPICAL CYCLONE INFORMATION $DTIME
EOF
cat HBULL >> fort.13

################
#input files
################

cp ${FIXshared}/graph_sixbitb.generic.f15 .
cp ${FIXshared}/graph_sixbitb.trpsfcmv.$cycle .

export FORT12="mapback.pur"
export FORT12="image002.pur"
export FORT13="fort.13"
export FORT15="graph_sixbitb.generic.f15"
export FORT18="graph_sixbitb.trpsfcmv.$cycle"
export FORT39="f89"
################
#scratch files
################
export FORT60="f60"
export FORT61="f61"
export FORT62="f62"
export FORT63="f63"
export FORT71="ras"
export FORT72="rs2"
export FORT52="x6b"
export FORT55="putlab.55"
################
#output file(s)
################
export FORT81="tropc${cycle}"."${cyc}"

startmsg
# ${SIXBITB2} >> $pgmout 2>errfile
${SIXBITB2}
export err=$?;err_chk

 for KEYW in GDTROPC GDTROPE GDTROPW GDTROP_g
 do

 grep $KEYW ${FIXshared}/identifyfax.tbl | read Keyword sub00 sub06 sub12 sub18 gif toc prt lprt name

 if [ ${cyc} = '00' ]; then submn=$sub00; fi
 if [ ${cyc} = '12' ]; then submn=$sub12; fi

 echo $FAXOUT $submn $name $Keyword $gif $toc $prt $jobn $lprt
 export FAXOUT submn name Keyword gif toc prt jobn lprt
 mk_graphics.sh

 done

#####################################################################
# GOOD RUN
set +x
echo "**************JOB $job COMPLETED NORMALLY ON THE IBM SP"
echo "**************JOB $job COMPLETED NORMALLY ON THE IBM SP"
echo "**************JOB $job COMPLETED NORMALLY ON THE IBM SP"
set -x
#####################################################################

msg="HAS COMPLETED NORMALLY!"
postmsg "$jlogfile" "$msg"
############## END OF SCRIPT #######################
