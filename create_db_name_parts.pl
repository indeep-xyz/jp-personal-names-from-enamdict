#!/usr/bin/perl

use 5.0080001;
use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename qw(dirname);
use lib File::Spec->catfile(dirname(__FILE__), 'lib');

use DB::ENAMEDICT::Convert;

# - - - - - - - - - - - - - - - - - - -
# main

my $my_dir_path = dirname(__FILE__);
my $src_path    = File::Spec->catfile($my_dir_path, 'src', 'enamedict.utf8.txt');

my $conv = DB::ENAMEDICT::Convert->new(
  src_path    => $src_path,
  );

my $data_array = [
  {
    dbname      => 'male',
    filter_type => 'm,g,!h'
  },
  {
    dbname      => 'famale',
    filter_type => 'f,!h'
  },
  {
    dbname      => 'surname',
    filter_type => 's,!h'
  },
];

for my $data (@$data_array){

  my $dbname      = $data->{'dbname'};
  my @filter_type = split(/,/, $data->{'filter_type'});

  # progress message
  printf "creating db... (%s)\n", $dbname;

  # create
  $conv->create(
    File::Spec->catfile($my_dir_path, 'db', $dbname),
    \@filter_type
  );
}
