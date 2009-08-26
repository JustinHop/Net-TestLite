#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  test.pl
#
#        USAGE:  ./test.pl  
#
#  DESCRIPTION:  testing my module
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Justin Hoppensteadt (JH), Justin.Hoppensteadt@umgtemp.com
#      COMPANY:  Universal Music Group
#      VERSION:  1.0
#      CREATED:  08/24/2009 04:26:12 PM
#     REVISION:  ---
#===============================================================================

use lib './lib';

use strict;
use warnings;

use Data::Dumper;
use Net::TestLite;

my $t = Net::TestLite->new();


while (<STDIN>){
    chomp;
    my $query = $_;
    print  $query . "\n" ;#. " authority is " . $t->auth_string($_) . "\n";
    my $u = $t->umg_ns($query);
    print Dumper($u);
}
