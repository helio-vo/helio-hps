#! /bin/csh -f

#Script file to run sdoss code using an idl runtime binary file

#Directory definitions
set BIN_DIR="../bin"
set DATA_DIR="../data"
set PRODUCT_DIR="../products"

#SDOSS IDL runtime binary file
set SDOSS_BIN = $BIN_DIR"/sdoss_processing.sav"

#Input argument definitions
set FNC=$DATA_DIR'/hmi.ic_45s.2011.05.01_00:00:00_TAI.continuum.fits'
set FNM=$DATA_DIR'/hmi.m_45s.2011.05.01_00:00:00_TAI.magnetogram.fits'
set FEAT_PIX="9"
set ARGS=$FNC" "$FNM" data_dir="$DATA_DIR" output_dir="$PRODUCT_DIR" feat_min_pix="$FEAT_PIX" /CSV /LOG /QUICKLOOK /VERBOSE"

echo "run "$SDOSS_BIN
time /usr/bin/env idl -queue -rt=$SDOSS_BIN -args $ARGS
