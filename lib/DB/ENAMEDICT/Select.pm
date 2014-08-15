# *-* encoding: utf8 *-*

package DB::ENAMEDICT::Select;

use 5.0080001;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use List::Util qw/shuffle/;

use Encode;
binmode(STDOUT, ':utf8');
binmode(STDIN, ':utf8');

# = =
# initialize method
#
sub new {

  my $class = shift;
  my $self  = {

    @_
  };

  bless($self, $class);
}

sub select {

  my $class  = shift;
  my $dbpath = shift;
  my $q      = shift;

  my $result;

  # guard
  # - die if it fails
  $class->_init_select_arguments($dbpath, $q);

  # initialize query arguments
  $class->_init_query($q);

  # run query
  $result = ($q->{'random'} == 0)
      ? $class->_select_normal($dbpath, $q)
      : $class->_select_random($dbpath, $q);

  printf "%d\n", $q->{'limit'};
  printf "%d\n", defined($q->{'limit'});
  printf "%d\n", defined($q->{'limt'});

  printf "%s\n", scalar(@$result);

  for (my $i = 0; $i < scalar(@$result); $i++) {
    printf "%s\n", @$result[$i];
  }
}

# - - - - - - - - - - - - - - - - - - - - -

# select main

sub _select_normal{

  my $class   = shift;
  my $dbpath  = shift;
  my $q       = shift;

  my $limit   = $q->{'limit'};
  my $records = $class->_load_database($dbpath, $q, 1);
  my @ret     = splice(@$records, 1, $limit);

  return \@ret;
}

sub _select_random{

  my $class   = shift;
  my $dbpath  = shift;
  my $q       = shift;

  my $limit   = $q->{'limit'};
  my $cnt     = 0;
  my $records = $class->_load_database($dbpath, $q, 1);

  # initialize count array
  # - [0] = count of YOMI and FLAGS and NAME
  # - [1] = count of YOMI and FLAGS
  #my $size = $class->_load_count_file("${dbpath}.count");

  my @shuffle = shuffle(@$records);
  my @ret     = splice(@shuffle, 1, $limit);

  return \@ret;
}

# - - - - - - - - - - - - - - - - - - - - -
# load database

# = =
# load from database
#
# args
# $dbpath ... path for database
# $q      ... hash for query
# $flag   ... if defined, non limit
#
# returner
#   [ [NAME YOMI], [NAME YOMI], [NAME YOMI], ... ]
sub _load_database {

  my $class  = shift;
  my $dbpath = shift;
  my $q      = shift;
  my $limit  = defined($_[0]) ? 0 : $q->{'limit'};

  my $cnt    = 0;
  my @ret    = ();

  # open file handler
  open(DB, '<:utf8', $dbpath) or die("write error: $!");
  eval {
    while(my $record = <DB>){

      chomp($record);
      my $parsed = $class->_parse_record($record, $q);

      # check array length
      if(scalar(@$parsed) > 0){

        # if exists
        # - add to returner
        foreach my $f (@$parsed){
          push(@ret, $f);

          $cnt++;
          last if($limit > 0 && $limit < $cnt);
        }
      }
    }
  };

  # close file handler
  close(DB);

  return \@ret;
}

# = =
#
#
# returner
#   [ [NAME YOMI], [NAME YOMI], [NAME YOMI], ... ]
sub _parse_record {

  my $class  = shift;
  my $record = shift;
  my $q      = shift;
  my @ret    = ();

  # match & guard
  # - regex for record syntax
  if(! ($record =~ m/^([^ ]+) ([^ ]+) (.+)$/)){

    # not match
    # - return empty array
    return \@ret;
  }

  my $yomi  = $1;
  my $flags = $2;
  my @names = split(/\|/, $3);

  my $yomi_regex = $q->{'yomi_regex'};
  my $name_regex = $q->{'name_regex'};
  my $flags_q    = $q->{'flags'};

  # guard
  # - yomi, flags
  if(($class->_regex_wrapper($yomi, $yomi_regex)) == 0
      || ! ($flags =~ /^${flags_q}$/)
      ){

    # return empty array
    return \@ret;
  }

  # guard and push
  # - name
  foreach my $name (@names){

    if(($class->_regex_wrapper($name, $name_regex)) == 0){

      next;
    }

    push(@ret, "$name $yomi");
  }

  return \@ret;
}

# = =
#
sub _regex_wrapper { # {{{5

  my $class        = shift;
  my $str          = shift;
  my $regex        = shift;
  my $ret          = 0;

  # check include regexp
  if (length($regex) < 1 || $str =~ /$regex/){

    $ret = 1;
  }

  return $ret;
} # }}}5

# - - - - - - - - - - - - - - - - - - - - -
# config

sub _load_count_file {

  my $class = shift;
  my $path  = shift;
  my @ret   = ();

  # open file handler
  open(FILE, '<:utf8', $path) or die("write error: $!");

  eval {
    while(my $line = <FILE>){
      chomp($line);
      push(@ret, $line);
    }
  };

  # close file handler
  close(FILE);

  return \@ret;
}

# - - - - - - - - - - - - - - - - - - - - -
# other

# = =
# check arguments for `select` (public method)
#
# returner
# 1 ... 
# 0 ... flag
sub _init_select_arguments { # {{{5

  my $class  = shift;
  my $dbpath = shift;
  my $q      = shift;

  # guard
  # - check $dbpath
  if (! -f $dbpath){

    # if not string, error
    die 'require string for database path ($1)';
  }

  # guard
  # - check query hash
  if (ref $q ne 'HASH'){

    # if not array, error
    die 'require HASH for query ($2)';
  }
} # }}}5

# = =
# initialize the query hash variable
sub _init_query {

  my $class = shift;
  my $q     = shift;
  my $ret;

  # random
  $q->{'random'} = ($q->{'random'}) ? 1 : 0;

  # limit
  if (!defined($q->{'limit'})
      || $q->{'limit'} =~ /[^0-9]/){

    $q->{'limit'} = ($q->{'random'}) ? 1 : 0;
  }

  # texts
  # - follow in the qw/.../
  for my $idx (qw/yomi_regex name_regex/){
    $q->{$idx} = defined($q->{$idx}) ? $q->{$idx} : '';
  }

  # flags
  # - use as regex
  $q->{'flags'} = '';
  for my $idx (qw/flag_alnum flag_hiragana flag_katakana flag_kanji/){

    # check flag property
    if(defined($q->{$idx}) && $q->{$idx} =~ m/^([01])$/){

      # if 0 or 1, add the number
      $q->{'flags'} .= $1;
    }
    else{

      # if other, add the '.'
      $q->{'flags'} .= '.';
    }
  }

  printf "%s@", $q->{'flags'};
}

1;
