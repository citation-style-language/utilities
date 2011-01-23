#!/bin/bash

# Converts CSL 0.8 styles to the 1.0 format, after
# performing schema validation.


# Die upon error.
set -e


# Trap ctrl-C so we don't get stuck inside case statements
function quit () {
  reset -I
  exit 0
}
trap quit SIGINT


# Always run from the directory in which the script is located.
cd $(dirname $0)


# Declare a couple of arrays
declare -a OPT
declare -a VAL


# FUNCTION: usage note
function usage () {
  echo
  echo "Usage: $0 [options] --csl-out=<path/to/output/dir>"
  echo
  echo "Options (set with --option=<value>):"
  echo "  --jing"
  echo "      Path to the jing validator jar file."
  echo "  --saxon"
  echo "      Path to the saxon jar file."
  echo "  --trang"
  echo "      Path to the trang jar file."
  echo "  --schema08"
  echo "      Path to the CSL 0.8.1 csl.rnc file."
  echo "  --schema10"
  echo "      Path to the CSL 1.0 csl.rnc file."
  echo "  --csl-input"
  echo "      Path to the input directory containing CSL 0.8.1 style files."
  echo "  --csl-output"
  echo "      Path to the output directory for converted CSL 1.0 style files."
  echo "      (required)"
  echo "  --config"
  echo "      Alternative configuration file (default is update-styles.cnf)."
  echo "      (file will be created on save if it does not exist)"
  echo "  --help"
  echo "      This message."
  echo
  echo "(NB: all paths are relative to $(pwd))"
  echo
}


# FUNCTION: initialize the option arrays
function initialize () {
  COUNT=0
  for opt in jing saxon trang schema08 schema10 csl-input config csl-output; do
    OPT[$COUNT]="--$opt"
    VAL[$COUNT]=""
    echo $((COUNT++)) > /dev/null
  done
}


# FUNCTION: set default parameter values.
function defaults () {
  VAL[0]='../jing-20091111/bin/jing.jar'
  VAL[1]='../jing-20091111/bin/saxon.jar'
  VAL[2]='../trang-20091111/trang.jar'
  VAL[3]='../0.8.1/csl.rnc'
  VAL[4]='../1.0/csl.rnc'
  VAL[5]='../csl/'
  VAL[6]='./update-styles.cnf'
  # User must explicitly set option 7 (the output directory)
}


# FUNCTION: set an option
function setopt () {
  for (( x=0; x < ${#OPT[@]}; x++)); do
    if [ "${OPT[$x]}" == "$1" ]; then
      VAL[$x]="$2"
    fi
  done
}


# FUNCTION: get options supplied by the user.
function getopts () {
  while [ "$(echo "$1" | cut -c 1)" == "-" ]; do
    opt=$(echo $1 | sed -e s/=.*//)
    val=$(echo $1 | sed -e s/.*=//)
    case $opt in
    --jing|--saxon|--trang|--schema08|--schema10|--csl-input|--config|--csl-output)
      setopt $opt $val
      shift;
      ;;
    *)
      usage
      echo "ERROR: invalid option: $1"
      exit 1
      ;;
    esac
  done
}


# FUNCTION: save option values used for processing
function saveopts () {
  OPT_DATA=""
  for opt in 0 1 2 3 4 5; do
    OPT_DATA=$(echo -n "${OPT_DATA} ${OPT[$opt]}=./${VAL[$opt]}")
  done
  echo ${OPT_DATA} > ${VAL[6]}
}


# FUNCTION: validate all parameters
function checkopts () {  
  if [ "${VAL[7]}" == "" ]; then
    usage
    echo "ERROR: use --csl-output to provide an explicit path to the output directory"
    exit 1
  fi
  for opt in 0 1 2 3 4; do
    if [ ! -f "${VAL[$opt]}" ]; then
      if [ "$FAIL" != "yes" ]; then
        FAIL="yes"
	usage
      fi        
      echo "ERROR: file for option ${OPT[$opt]} not found: ${VAL[$opt]}"
    fi
  done
  if [ ! -d "${VAL[5]}" ]; then
      if [ "$FAIL" != "yes" ]; then
        FAIL="yes"
	usage
      fi        
      echo "ERROR: directory for option ${OPT[5]} not found: ${VAL[5]}"
  fi
  if [ "${FAIL}" == "yes" ]; then
    exit 1
  fi
}


# FUNCTION: offer to save options
function finalquery () {
  echo "Save options to ${VAL[6]}? (y/n)"
  ans="?"
  while [ "$ans" != "  " ]; do
    read -n 1 -s ans
    case $ans in
    Y|y) 
      ans="  "
      saveopts
      echo "Saved options to ${VAL[6]}"
    ;;
    N|n)
      ans="  "
      echo "Options not saved"
    ;;
    *)
    ;;
    esac
  done
  echo "Bye"
  exit 0
}


#########################
## Set up the options ###
#########################


# Initialize the option arrays
initialize


# Supply options from a config file if present, otherwise
# use the defaults.

# Set defaults
defaults

# Read options from ./update-styles.cnf if it exists.
if [ -f "./update-styles.cnf" ]; then
  getopts $(cat "./update-styles.cnf")
fi

# Read options, to pick up --config option ($VAL[6]), if any.
getopts $@

if [ -f ${VAL[6]} ]; then
  getopts $(cat ${VAL[6]})
fi

# Read options again, to overlay defaults and config-file 
# values with stuff provided on the command line.
getopts $@


# Validate the option values.
checkopts


# Create temporary directory, and provide for its deletion
# on exit.
TMP_DIR=$(mktemp -d -p "./")
function finish () {
  rm -rf ${TMP_DIR}/*
  rmdir ${TMP_DIR}
  #reset
  #echo Hello
}
trap finish EXIT


###########################################################
### Actual file validation and conversion happens below ###
###########################################################

echo "#"
echo "# Input from: ${VAL[5]}"
echo "#"
echo "# Output to: ${VAL[7]}"
echo "#"

# Place CSL 0.8.1 and 1.0 styles in separate directories
tempCSL10="${TMP_DIR}/csl10"
tempCSL081="${TMP_DIR}/csl081"
mkdir ${tempCSL10} 
mkdir ${tempCSL081}
cp ${VAL[5]}/*.csl ${tempCSL081}
grep -l "<style[^>]*version" ${tempCSL081}/*.csl | xargs -I '{}' mv '{}' ${tempCSL10}

echo "Validate input styles? (y/n)"
ans="?"
while [ "$ans" != "  " ]; do
  read -n 1 -s ans
  case $ans in
  Y|y) 
    ans="  "
    echo -n "  processing ... "
    # Be lax when it comes to the contents of the cs:updated element
    SCHEMA_10_DIR=$(dirname ${VAL[4]})
    cp ${SCHEMA_10_DIR}/*.rnc ${TMP_DIR}/
    updatedString='info-updated = element cs:updated { xsd:dateTime }'
    newUpdatedString='info-updated = element cs:updated { text }'
    sed "s#$updatedString#$newUpdatedString#g" ${VAL[3]} > ${TMP_DIR}/csl0.8.1-easyOnUpdated.rnc
  
    #  VAL[0] jing
    #  VAL[1] saxon
    #  VAL[2] trang
    #  VAL[3] csl 0.8.1
    #  VAL[4] csl 1.0
    #  VAL[5] csl-input
    #  VAL[6] config
    #  VAL[7] csl-output
  
    # Jing currently ignores embedded Schematron rules.
    # For this reason, the schema is first converted to
    # RELAX NG XML, after which the Schematron code is
    # extracted and tested separately.
    java -jar ${VAL[2]} ${VAL[4]} ${TMP_DIR}/csl.rng
    java -jar ${VAL[1]} -o ${TMP_DIR}/csl.sch ${TMP_DIR}/csl.rng RNG2Schtrn.xsl
    java -jar ${VAL[0]} ${TMP_DIR}/csl.sch ${VAL[5]}/*.csl
    
    # RELAX NG Compact validation of CSL 0.8.1 styles
    java -jar ${VAL[0]} -c ${TMP_DIR}/csl0.8.1-easyOnUpdated.rnc ${tempCSL081}/*.csl

    if [ -d "${VAL[5]}/dependent" ]; then
      if [ "$(ls ${VAL[5]}/dependent | wc -l)" != "0" ]; then
        java -jar ${VAL[0]} -c ${TMP_DIR}/csl0.8.1-easyOnUpdated.rnc ${VAL[5]}/dependent/*.csl
      fi
    fi
    echo "input styles validated ok"
  ;;
  N|n)
    echo "No actions performed."
    finalquery
  ;;
  *)
  ;;
  esac
done


echo "Convert styles? (y/n)"
ans="?"
while [ "$ans" != "  " ]; do
  read -n 1 -s ans
  case $ans in
  Y|y) 
    ans="  "
    echo -n "  processing ... "
  
    #  VAL[0] jing
    #  VAL[1] saxon
    #  VAL[2] trang
    #  VAL[3] csl 0.8.1
    #  VAL[4] csl 1.0
    #  VAL[5] csl-input
    #  VAL[6] config
    #  VAL[7] csl-output
  
    if [ ! -d ${VAL[7]} ]; then
      mkdir ${VAL[7]}
    fi
    if [ ! -d ${VAL[7]}/dependent ]; then
      mkdir ${VAL[7]}/dependent
    fi
    
    # Copy CSL 1.0 styles to output directory
    cp ${tempCSL10}/*.csl ${VAL[7]}

    # Convert CSL 0.8.1 styles
    java -jar ${VAL[1]} -o ${VAL[7]} ${tempCSL081} update.xsl
    if [ -d "${VAL[5]}/dependent" ]; then
      if [ "$(ls ${VAL[5]}/dependent | wc -l)" != "0" ]; then
        java -jar ${VAL[1]} -o ${VAL[7]}/dependent ${VAL[5]}/dependent update.xsl
      fi
    fi
    # Remove .xml from output file names
    for styleDotCSLDotXML in ${VAL[7]}/*.csl.xml; do
      styleDotCSL=${styleDotCSLDotXML%.xml}
      mv "$styleDotCSLDotXML" "$styleDotCSL"
    done
    if [ -d "${VAL[5]}/dependent" ]; then
      if [ "$(ls ${VAL[5]}/dependent | wc -l)" != "0" ]; then
        for styleDotCSLDotXML in ${VAL[7]}/dependent/*.csl.xml; do
          styleDotCSL=${styleDotCSLDotXML%.xml}
          mv "$styleDotCSLDotXML" "$styleDotCSL"
        done
      fi
    fi
    echo "styles converted ok: ${VAL[7]}"
  ;;
  N|n)
    echo "Not converting styles"
    finalquery
  ;;
  *)
  ;;
  esac
done

echo "Validate output styles? (y/n)"
ans="?"
while [ "$ans" != "  " ]; do
  read -n 1 -s ans
  case $ans in
  Y|y) 
    ans="  "
    echo -n "  processing ... "

    # Be lax when it comes to the contents of the cs:updated element
    SCHEMA_10_DIR=$(dirname ${VAL[4]})
    cp ${SCHEMA_10_DIR}/*.rnc ${TMP_DIR}/
    updatedString='info-updated = element cs:updated { xsd:dateTime }'
    newUpdatedString='info-updated = element cs:updated { text }'
    sed "s#$updatedString#$newUpdatedString#g" ${VAL[4]} > ${TMP_DIR}/csl-easyOnUpdated.rnc
  
    #  VAL[0] jing
    #  VAL[1] saxon
    #  VAL[2] trang
    #  VAL[3] csl 0.8.1
    #  VAL[4] csl 1.0
    #  VAL[5] csl-input
    #  VAL[6] config
    #  VAL[7] csl-output
  
    # Jing currently ignores embedded Schematron rules.
    # For this reason, the schema is first converted to
    # RELAX NG XML, after which the Schematron code is
    # extracted and tested separately.
    java -jar ${VAL[2]} ${VAL[4]} ${TMP_DIR}/csl.rng
    java -jar ${VAL[1]} -o ${TMP_DIR}/csl.sch ${TMP_DIR}/csl.rng RNG2Schtrn.xsl
    java -jar ${VAL[0]} ${TMP_DIR}/csl.sch ${VAL[7]}/*.csl
  
    # RELAX NG Compact validation
    java -jar ${VAL[0]} -c ${TMP_DIR}/csl-easyOnUpdated.rnc ${VAL[7]}/*.csl
    if [ -d "${VAL[5]}/dependent" ]; then
      if [ "$(ls ${VAL[5]}/dependent | wc -l)" != "0" ]; then
        java -jar ${VAL[0]} -c ${TMP_DIR}/csl-easyOnUpdated.rnc ${VAL[7]}/dependent/*.csl
      fi
    fi
    echo "output styles validated ok"
  ;;
  N|n)
    echo "Not validating output styles"
    finalquery
  ;;
  *)
  ;;
  esac
done

finalquery
