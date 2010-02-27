#!/bin/bash

# Converts CSL 0.8 styles to the 1.0 format, after
# performing schema validation.

jing='../jing-20091111/bin/jing.jar'
saxon='../jing-20091111/bin/saxon.jar'
trang='../trang-20091111/trang.jar'
CSLschema='../csl-schema/'
CSLstyles='../csl/'
temp='./temp/'
# Destination for converted styles
CSLconvertedStyles='../csl10/'

echo "Validate input styles? (y/n)"
read ans
case $ans in
Y|y) 
  if [ ! -d $temp ]
  then
    mkdir $temp
  fi
  # Be lax when it comes to the contents of the cs:updated element
  updatedString='info-updated = element cs:updated { xsd:dateTime }'
  newUpdatedString='info-updated = element cs:updated { text }'
  sed "s#$updatedString#$newUpdatedString#g" ${CSLschema}csl0.8.1.rnc > ${temp}csl0.8.1-easyOnUpdated.rnc

  # Jing currently ignores embedded Schematron rules.
  # For this reason, the schema is first converted to
  # RELAX NG XML, after which the Schematron code is
  # extracted and tested separately.
  java -jar $trang ${CSLschema}csl.rnc ${temp}csl.rng
  java -jar $saxon -o ${temp}csl.sch ${temp}csl.rng RNG2Schtrn.xsl
  java -jar $jing ${temp}csl.sch ${CSLstyles}/*.csl

  # RELAX NG Compact validation
  java -jar $jing -c ${temp}csl0.8.1-easyOnUpdated.rnc ${CSLstyles}*.csl
  java -jar $jing -c ${temp}csl0.8.1-easyOnUpdated.rnc ${CSLstyles}dependent/*.csl
  ;;
N|n) ;;
*)
esac

echo "Convert styles? (y/n)"
read ans
case $ans in
Y|y) 
  if [ ! -d $CSLconvertedStyles ]
  then
    mkdir $CSLconvertedStyles
  fi
  if [ ! -d ${CSLconvertedStyles}dependent ]
  then
    mkdir ${CSLconvertedStyles}dependent
  fi
  java -jar $saxon -o $CSLconvertedStyles $CSLstyles update.xsl
  java -jar $saxon -o ${CSLconvertedStyles}dependent ${CSLstyles}dependent update.xsl
  # Remove .xml from output file names
  for styleDotCSLDotXML in $CSLconvertedStyles*.csl.xml; do
    styleDotCSL=${styleDotCSLDotXML%.xml}
    mv "$styleDotCSLDotXML" "$styleDotCSL"
  done
  for styleDotCSLDotXML in ${CSLconvertedStyles}dependent/*.csl.xml; do
    styleDotCSL=${styleDotCSLDotXML%.xml}
    mv "$styleDotCSLDotXML" "$styleDotCSL"
  done
;;
N|n) ;;
*)
esac

echo "Validate output styles? (y/n)"
read ans
case $ans in
Y|y) 
  if [ ! -d $temp ]
  then
    mkdir $temp
  fi
  # Be lax when it comes to the contents of the cs:updated element
  cp ${CSLschema}*.rnc $temp/
  updatedString='info-updated = element cs:updated { xsd:dateTime }'
  newUpdatedString='info-updated = element cs:updated { text }'
  sed "s#$updatedString#$newUpdatedString#g" ${CSLschema}csl.rnc > ${temp}csl-easyOnUpdated.rnc

  # Jing currently ignores embedded Schematron rules.
  # For this reason, the schema is first converted to
  # RELAX NG XML, after which the Schematron code is
  # extracted and tested separately.
  java -jar $trang ${CSLschema}csl.rnc ${temp}csl.rng
  java -jar $saxon -o ${temp}csl.sch ${temp}csl.rng RNG2Schtrn.xsl
  java -jar $jing ${temp}csl.sch ${CSLconvertedStyles}/*.csl

  # RELAX NG Compact validation
  java -jar $jing -c ${temp}csl-easyOnUpdated.rnc ${CSLconvertedStyles}*.csl
  java -jar $jing -c ${temp}csl-easyOnUpdated.rnc ${CSLconvertedStyles}dependent/*.csl
  ;;
N|n) ;;
*)
esac