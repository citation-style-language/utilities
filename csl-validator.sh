#!/usr/bin/env bash

schema_url="https://raw.githubusercontent.com/citation-style-language/schema/v1.0.1/csl.rnc https://raw.githubusercontent.com/citation-style-language/schema/602ad40976b7b455a3ce0b79f5534e8e75f088e9/csl.sch"
validator_url="https://validator.w3.org/nu/"

for command in "jq" "curl"; do
  if ! which "$command" > /dev/null; then
    echo "The utility $command appears not to be installed, please see:"
    echo "https://command-not-found.com/$command"
    echo "for installation instructions, then try again."
    exit 10
  fi
done

usage() {
  echo "USAGE: $0 [-d] [file.csl]"
  echo "  validate citation style language XML using the validation"
  echo "  service from w3.org and the official schema from CSL github."
  echo "  Adapted from:"
  echo "  https://github.com/citation-style-language/csl-validator/blob/gh-pages/libraries/csl-validator.js"
  echo "  Arguments:"
  echo "    -d       -> print out debug messages (default: off)"
  echo "    file.csl -> file to validate (optional, when absent will read stdin)"
}

DEBUG="False"
while getopts "d?" opt; do
  case $opt in
    d) DEBUG="True"
    ;;
    ?) usage
       exit 0
    ;;
    *) echo "Failed to parse command line options."
       usage
       exit 2
    ;;
  esac
done
shift $((OPTIND-1))

file="${1:-/dev/stdin}"

debug() {
  if [[ "$DEBUG" == "True" ]]; then
    echo "$@"
  fi
}

debug "Will now attempt to validate document $file"

debug "Attempting validation on validator $validator_url"

# The line -F "file=@$file" instructs curl to send data from file $file
# From the manual:
# -F, --form <name=content>
  # (HTTP SMTP IMAP) For HTTP protocol family, this lets curl emulate a
  # filled-in form in which a user has pressed the submit button.
  # This causes curl to POST data using the Content-Type
  # multipart/form-data according to RFC 2388. […]
  # This  enables  uploading  of binary files etc. To force the 'content'
  # part to be a file, prefix the file name with an @ sign

if ! server_response="$(curl --silent \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:87.0) Gecko/20100101 Firefox/87.0' \
  -H 'Accept: */*' \
  -H 'Accept-Language: en-US,fr;q=0.8,es;q=0.5,de;q=0.3' \
  -H 'Content-Type: multipart/form-data' \
  -H 'DNT: 1' \
  -H 'Connection: keep-alive' \
  -H "Referer: $validator_url" \
  -H 'Sec-GPC: 1' \
  -X POST \
  -F "schema=$schema_url" \
  -F "parser=xml" \
  -F "laxtype=yes" \
  -F "level=error" \
  -F "out=json" \
  -F "showsource=no" \
  -F "file=@$file" \
  "$validator_url")"
then
  debug "curl returned failure code $?, see output below:"
  debug "$messages"
  exit 20
fi
debug "curl command completed successfully."

messages="$(echo "$server_response" | jq .messages)"
if [[ "$messages" == '[]' ]]; then
  debug "✅ $file is valid CSL!"
  exit 0
fi
debug " ❌ $file contains errors, see below:"
echo "$messages" | jq -c '.[]' | while read -r error_json; do
  line="$(echo "$error_json" | jq .firstLine)"
  column="$(echo "$error_json" | jq .firstColumn)"
  message="$(echo "$error_json" | jq .message)"
  echo "M=$message L=$line C=$column"
done
exit 10
