#!/usr/bin/perl
# *-* encoding: utf8 *-*

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw(dirname);
use lib File::Spec->catfile(dirname(__FILE__), 'lib');

use DB::ENAMEDICT::Select;

binmode(STDOUT, ':utf8');
binmode(STDIN, ':utf8');

# - - - - - - - - - - - - - - - - - - -
# guard

# require @ARGV
if (@ARGV < 1) {

  die <<'EOT'
require $1 (database name)
EOT
}


# - - - - - - - - - - - - - - - - - - -
# main

my $my_dir_path = dirname(__FILE__);
my $dbpath      = File::Spec->catfile($my_dir_path, 'db', $ARGV[0]);
my %query = (

  limit => 5,
  #random => 4,
  yomi_regex => 'オ',
  #flag_hiragana => 0,
  #flag_katakana => 1,
  #flag_kanji => 0,
);

DB::ENAMEDICT::Select->select(
  $dbpath,
  \%query,
);

