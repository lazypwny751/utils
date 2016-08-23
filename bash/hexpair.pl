#-------------------------------------------#
#!/usr/bin/perl
use MIME::Base64;
use strict;
my @md5 = split "",$ARGV[0];
my @res;
for (my $i = 0 ; $i < 32 ; $i+=2)
{
        my $c = (((hex $md5[$i]) << 4) % 255) | (hex $md5[$i+1]);
        $res[$i/2] = chr $c;
}
print "{MD5}".encode_base64(join "", @res);
##-------------------------------------------#
