# for testing update.xsl

SCHEMA=../csl-schema/csl.rnc

for i in $1*.csl 
do
  xsltproc $i | rnv $SCHEMA $i
done
