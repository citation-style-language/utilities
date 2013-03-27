#!/bin/bash

# CSL schema validation

# Always run from the directory in which the script is located.
cd $(dirname $0)

# Die upon error.
set -e

# Create temporary directory, and provide for its deletion
# on exit.
TMP_DIR=$(mktemp -d -t './')
function finish () {
  rm -rf ${TMP_DIR}/*
  rmdir ${TMP_DIR}
  #reset
  #echo Hello
}
trap finish EXIT

# Paths
pathJing='../jing-20091111/bin/jing.jar'
pathSaxon='../jing-20091111/bin/saxon.jar'
pathTrang='../trang-20091111/trang.jar'
pathCSLSchema='../schema/csl.rnc'
pathCSLStyles='../styles/'

echo "# Input from: ${pathCSLStyles}"
echo -n "  processing ... "
  
# Jing currently ignores embedded Schematron rules.
# For this reason, the schema is first converted to
# RELAX NG XML, after which the Schematron code is
# extracted and tested separately.
java -jar ${pathTrang} ${pathCSLSchema} ${TMP_DIR}/csl.rng
java -jar ${pathSaxon} -o ${TMP_DIR}/csl.sch ${TMP_DIR}/csl.rng RNG2Schtrn.xsl
java -jar ${pathJing} ${TMP_DIR}/csl.sch ${pathCSLStyles}/*.csl || true
  
# RELAX NG Compact validation
java -jar ${pathJing} -c ${pathCSLSchema} ${pathCSLStyles}/*.csl || true
java -jar ${pathJing} -c ${pathCSLSchema} ${pathCSLStyles}/dependent/*.csl

echo "styles validated"