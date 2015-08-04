#!/bin/bash

HEADER="000020"
APPLE_URL="gateway.sandbox.push.apple.com:2195"
CERT_FILE=""
KEY_FILE=""
TOKEN=""
MESSAGE=""

function print_help()
{
	echo "Usage: $0 [-c|--cert] <cert_file> [-k|--key] <key_file> --token <token> [-m] <message>"
	echo "	cert_file	- PEM file certificate"
	echo "	key_file	- PEM file key"
	echo "	token		- Apple provided token"
	echo "	message 	- JSON message"
}

if [[ -z "$1" ]]; then
	print_help
	exit 1
fi

while [[ $# > 1 ]]; do
	key="$1"
	shift

	case $key in
		-c|--cert) 	
			CERT_FILE="$1"
			shift
			;;
		-k|--key)
			KEY_FILE="$1"
			shift
			;;
		--token)
			TOKEN="$1"
			shift
			;;
		-m)
			MESSAGE="$1"
			shift
			;;
		*)
			echo "Unexpected param: $key"
			exit 1
			;;
	esac
done

if [[ -z "$CERT_FILE" ]]; then
	echo "Error: specify cert file."
	print_help
	exit 1
fi

if [[ -z "$KEY_FILE" ]]; then
	echo "Error: specify key file."
	print_help
	exit 1
fi

if [[ -z "$TOKEN" ]]; then
	echo "Error: specify token."
	print_help
	exit 1
fi

if [[ ! -f "$CERT_FILE" ]]; then
	echo "Error: $CERT_FILE does not exist."
	exit 1
fi

if [[ ! -f "$KEY_FILE" ]]; then
	echo "Error: $KEY_FILE does not exist."
	exit 1
fi

if [[ -z "$MESSAGE" ]]; then
	echo "Error: message is empty."
	exit 1
fi

echo "Prepareing request..."
MESSAGE="{\"aps\":{\"alert\":\"${MESSAGE}\",\"sound\":\"default\"}}"
REQUEST=$(printf "%04X" ${#MESSAGE})
MESSAGE=$(echo "$MESSAGE" | tr -d '\n' | xxd -u -ps - | tr -d '\n')
REQUEST="${HEADER}${TOKEN}${REQUEST}${MESSAGE}"

echo "$REQUEST" | tr -d '\n' | xxd -r -p - | hexdump -C
echo "$REQUEST" | tr -d '\n' | xxd -r -p - | openssl s_client -connect $APPLE_URL -cert $CERT_FILE -key $KEY_FILE

exit $?

