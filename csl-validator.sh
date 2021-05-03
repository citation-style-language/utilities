#!/usr/bin/env bash

for command in "jq" "curl"; do
  if ! which "$command" > /dev/null; then
    echo "The utility $command appears not to be installed, please see:"
    echo "https://command-not-found.com/$command"
    echo "for installation instructions, then try again."
    exit 10
  fi
done

if [[ $# != 1 ]]; then
  echo "USAGE: $0 file.csl"
  echo "  validate file.csl using the validation"
  echo "  service from w3.org and the official schema from CSL github."
  echo "  Adapted from:"
  echo "  https://github.com/citation-style-language/csl-validator/blob/gh-pages/libraries/csl-validator.js"
  echo "  Arguments:"
  echo "    file.csl   -> the file to validate (required)"
  exit 2
fi

file="$1"

echo "Will now attempt to validate document $file"

schema_url="https://raw.githubusercontent.com/citation-style-language/schema/v1.0.1/csl.rnc https://raw.githubusercontent.com/citation-style-language/schema/602ad40976b7b455a3ce0b79f5534e8e75f088e9/csl.sch"
validator_url="https://validator.w3.org/nu/"

echo "Attempting validation on validator $validator_url"

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
  echo "curl returned failure code $?, see output below:"
  echo "$messages"
  exit 20
fi
echo "curl command completed successfully."

messages="$(echo "$server_response" | jq .messages)"
if [[ "$messages" == '[]' ]]; then
  echo "✅ $file is valid CSL!"
  exit 0
fi
echo " ❌ $file contains errors, see below:"
echo "$messages"
exit 10
