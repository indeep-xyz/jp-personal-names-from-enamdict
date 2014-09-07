#!/usr/bin/perl
# *-* encoding: utf8 *-*

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw(dirname);

use Getopt::Std;

use Data::Dumper;

binmode(STDOUT, ':utf8');
binmode(STDIN,  ':utf8');

# - - - - - - - - - - - - - - - - - - -
# guard

# require @ARGV
if (@ARGV < 2) {

  die <<'EOT'
require [options] $1 $2

$1 ... name
$2 ... database name
EOT
}

# - - - - - - - - - - - - - - - - - - -
# command options

my %opts = ();

# getopts
# - f ... database flags ([.01]{5})
getopts ("f:", \%opts);

# initialize
$opts{'f'} ||= '.....';

# - - - - - - - - - - - - - - - - - - -
# main

my $my_dir_path = dirname(__FILE__);
my $name        = $ARGV[0];
my $dbname      = $ARGV[1];
my %query = (

  limit  => 5000,
  flags  => $opts{'f'},
);

$query{'name_regex'} = $opts{'n'} if defined($opts{'n'});

# run
my $result = DB::ENAMEDICT::Select->select($dbpath, \%query);

# print $result
for (my $i = 0; $i < scalar(@$result); $i++) {
  printf "%s\n", @$result[$i];
}
