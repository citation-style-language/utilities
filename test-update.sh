#! /bin/bash
# for testing update.xsl

# Error counter
ERRORS=0


# Set the path to the schema of option provided.
if [ "$1" == "-s" ]; then
  shift
  SCHEMA=$1
  shift
  EXPLICIT_PATH="yes"
else
  SCHEMA=./csl-schema/csl.rnc
fi


# Report various errors to the terminal.
function help () {
  echo Usage: $0 -s path/to/schema.rnc path/to/csl/dir/
  if [ "$NO_FILES" == "yes" ]; then
    echo "ERROR: no csl files found at: $1"
  fi
  if [ "$EXPLICIT_PATH" == "yes" -a ! -f ${SCHEMA} ]; then
    echo "ERROR: schema file not found at: ${SCHEMA}"
  fi
  if [ ! -d $1 ]; then
    echo "ERROR: no directory found at: $1"
  fi
  exit 1
}


# Check for schema and path to files, report an error if either
# not found.
if [ ! -f ${SCHEMA} -o ! -d $1 ]; then
  help $1
fi


# Provide the name of the offending file in the
# event of a validation error.
function oopsie () {
  echo "ERROR: the error above is from the file $i"
  echo $((ERRORS++)) > /dev/null
}
trap oopsie ERR


# Run the tests!
for i in $1/*.csl
do
  if [ "$(echo $i | grep '\*' -c)" -gt 0 ]; then
    NO_FILES="yes"
    help $1
  fi
  xsltproc update.xsl $i | rnv $SCHEMA 
done


# Provide a word of encouragement if everything went ok.
echo
if [ ${ERRORS} -gt 0 ]; then
  echo "Found $ERRORS errors."
else
  echo "ok, no errors found"
fi
echo
