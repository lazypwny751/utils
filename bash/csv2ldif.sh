#!/bin/bash


# warn people with this.
warn() {
	echo >&2 "$*"
}

# kill if necessary.
die() {
	warn "$*"
    exit 1
}

parse_csv() {
	while read -r line; do
        first_name=`echo $line | awk -F ',' '{print $2}'`
        last_name=`echo $line | awk -F ',' '{print $3}'`
        if [[ $first_name == *'"'* || $last_name == *'"'* ]]; then
            first_name=$(echo $first_name | sed 's/"//g')
            last_name=$(echo $last_name | sed 's/"//g')
        fi
        username=`echo $line | awk -F ',' '{print $4}'`
        password_hash=`echo $line | awk -F ',' '{print $5}'`
        mail=`echo $line | awk -F ',' '{print $6}'`
        if [[ $password_hash == '' ]]; then
            password_hash=$(echo "$default_pass" | md5sum | awk '{print $1}')
        fi
        build_ldif
    done < $CSV
}

build_ldif() {
	echo $first_name $last_name : $username : $password_hash : $mail
}

main() {
    warn "Parsing file : $CSV ..."
    parse_csv
}

if [[ "$#" -ne 1 ]]; then
	die "$0 only takes one argument, and this should be the CSV file you want to parse."
else
	CSV=$1
    default_pass=$(pwgen 16 -y -c 1)
	main
    warn "$default_pass has been set as a password for passwordless users."
fi
