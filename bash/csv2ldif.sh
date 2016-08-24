#!/bin/bash

# Please set these values whatever you want.

LDIF='generated_ldif.ldif' # Output file
OU_DN='ou=People' # The organizational unit dn e.g ou=people,dc=base,dc=dn
BASE_DN='dc=aydintd,dc=net' # Base DN definition e.g dc=base,dc=dn
PASSWDLESS='passwordless_users.txt'

# warn people with this.
warn() {
    echo >&2 "$*"
}

# kill if necessary.
die() {
    warn "$*"
    exit 1
}

# Parsing CSV file, get md5 password hashes field, if exists
# use hexpair.pl script to present all hashes with hexpair presentation
# if does not exist (empty passwords), generate a 16 char long password
# in run-time and hash the newly generated password with md5 for openldap via slappasswd.

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
            default_pass=$(pwgen 16 -y -c 1)
            echo "Passwordless $username will be set as $default_pass" >> $PASSWDLESS
            password_encoded=$(slappasswd -h {md5} -s "$default_pass")
        else
            warn "Modifying MD5 password hash for $username to use in OpenLDAP..."
            password_encoded=$(perl ./hexpair.pl $password_hash)
        fi
        build_ldif
    done < $CSV
}

# Build LDIF file for importing the users.

build_ldif() {
    warn "Generating LDIF content for $username..."
    echo -e "dn: uid=$username,$OU_DN,$BASE_DN
    uid: $username
    mail: $mail
    sn: $last_name
    cn: $username
    givenName: $first_name
    objectClass: inetOrgPerson
    objectClass: organizationalPerson
    objectClass: person
    objectClass: top
    userPassword: $password_encoded \n
    " >> $LDIF
    # echo $first_name $last_name : $username : $password_encoded : $mail
}

main() {
    warn "Parsing file : $CSV ..."
    parse_csv
    warn "Modifying freshly generated LDIF file..."
    sed -i 's/ //g' $LDIF
    warn "Done. Please check $LDIF file content."
    warn "Check the $PASSWDLESS file to check out what password has been set for each passwordless user"
    warn "If there are any duplicated user information in the given CSV file,
    Please use ldapadd -c -Wx -D 'cn=admin,dc=base,dc=dn' -f $LDIF command to import newly
    generated users."
    exit 0
}

if [[ "$#" -ne 1 ]]; then
    die "$0 only takes one argument, and this should be the CSV file you want to parse."
else
    CSV=$1
    main
fi
