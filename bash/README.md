## README.md

a utility script for parsing csv file to ldif

### Usage 

- As a dependency, please install perl and pwgen tools if you want to use this migrate tool.
- Clone the repo, make sure hexpair.pl and csv2ldif.sh is in the same working directory.
- Make sure you change all necessary information like output file name, basedn and ou information in the script (Lines: 5-6-7 ).
- Execute ./csv2ldif.sh csvfile.csv (second_column=>first_name, third_column=>surname,fourth_column=>username,fifth_column=md5hashedpassword,sixth_column=>mail )
- Check the generated ldif file content in the same working directory.
- Example usage :

add all users to openldap via ldapadd : ldapadd  -c -Wx -D "cn=admin,dc=aydintd,dc=net" -f generated_ldif.ldif 


### TODO 

- parse the CSV file given as an argument - DONE
- handle the user fields for a standart ldap implementation - DONE
- handle password fields - getting hash smoothly, encode passwords via base64 - DONE

- Get arguments from the user and set all necessary variables without modifying the script
- CSV format should be specified !? 

## NOTE :

This script is under heavily development. It will possibly not work when you try to parse any other CSV 
file which is different than described above.

Use at your own risk. It won't add anything to your openldap installation but only tries to generate a harmless ldif file from your evil CSV file.
