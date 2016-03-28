#!/usr/bin/perl
# *-* encoding: utf8 *-*

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw(dirname);
use lib File::Spec->catfile(dirname(__FILE__), 'lib');

use Getopt::Std;
use DB::ENAMDICT::Select;

use Data::Dumper;

binmode(STDOUT, ':utf8');
binmode(STDIN,  ':utf8');

# - - - - - - - - - - - - - - - - - - -
# guard

# require @ARGV
if (@ARGV < 1) {

  die <<'EOT'
require [options] $1 (database name)
EOT
}

# - - - - - - - - - - - - - - - - - - -
# command options

my %opts = ();

# getopts
# - f ... database flags ([.01]{5})
# - l ... limit
# - n ... name regex
# - y ... yomi regex
# - r ... random flag
# - Y ... yomi compact flag
getopts ("f:l:n:y:rY", \%opts);

# initialize
$opts{'f'} ||= '.....';
$opts{'l'} ||= 1;
$opts{'r'} ||= 0;
$opts{'Y'} ||= 0;

# - - - - - - - - - - - - - - - - - - -
# main

my $my_dir_path = dirname(__FILE__);
my $dbpath      = File::Spec->catfile($my_dir_path, 'db', $ARGV[0]);
my $limit       = defined($ARGV[1]) ? $ARGV[1] : 1;
my %query = (

  flags        => $opts{'f'},
  limit        => $opts{'l'},
  random       => $opts{'r'},
  yomi_compact => $opts{'Y'},
);

$query{'yomi_regex'} = $opts{'y'} if defined($opts{'y'});
$query{'name_regex'} = $opts{'n'} if defined($opts{'n'});

# run
my $result = DB::ENAMDICT::Select->select($dbpath, \%query);

# print $result
for (my $i = 0; $i < scalar(@$result); $i++) {
  printf "%s\n", @$result[$i];
}
