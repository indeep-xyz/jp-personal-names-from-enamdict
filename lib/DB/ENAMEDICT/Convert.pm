# *-* encoding: utf8 *-*

package DB::ENAMEDICT::Convert;

use 5.0080001;
use strict;
use warnings;
use utf8;
use Data::Dumper;

binmode(STDOUT, ':utf8');

# = =
# initialize method
#
sub new {

  my $class = shift;
  my $self  = {

    src_path  => '',
    @_
  };

  bless($self, $class);
}

# = =
# convert and write file
#
# args
# $1 ... string
#        DB path for output
#
# $2 ... refference of array
#        type of include in this array, write that
#
sub create {

  my $self              = shift;
  my $output_path       = shift;
  my $filter_type       = shift;
  my $output_count_path = $output_path . '.count';

  # temp paths
  # - base, sorted, optimized
  my $base_temp         = $output_path . '.~base';
  my $sort_temp         = $output_path . '.~sorted';
  my $opt_temp          = $output_path . '.~optimized';

  # guard
  # - die if it fails
  $self->_guard_convert($output_path, $filter_type);

  # create base
  $self->_create_base($base_temp, $filter_type);

  # sort
  `sort -o "$sort_temp" "$base_temp"`;

  # optimize
  $self->_create_optimized($sort_temp, $opt_temp);

  # write count
  $self->_create_count(
    $output_count_path,
    [ $sort_temp, $opt_temp ]
  );

  # update
  rename($opt_temp, $output_path);

  # remove temporary files
  unlink($base_temp);
  unlink($sort_temp);
}

# - - - - - - - - - - - - - - - - - - - - -
# main process

# = =
# create base file
sub _create_base { # {{{5

  my $self           = shift;
  my $output_path    = shift;
  my $filter_type    = shift;

  my $src_path       = $self->{src_path};
  my $cnt = 0;

  # open files handlers
  open(FROM, '<:utf8', $src_path)    or die("read error: $!");
  open(TO,   '>:utf8', $output_path) or die("write error: $!");

  eval {
    while (my $line = <FROM>) {

      my %parsed = $self->_parse($line);
      if (0 == $self->_accept_by_type($filter_type, \@{$parsed{'type'}})){
        next;
      }

      # create line for update
      my $text = $self->_create_line(\%parsed);

      # write
      print TO "$text\n";

      # count up
      $cnt++;

      #last if($cnt++ > 2009);
    }
  };

  # close files handlers
  close(FROM);
  close(TO);

} # }}}5

# = =
# create optimized database
sub _create_optimized { # {{{5

  my $self = shift;
  my $from = shift;
  my $to   = shift;

  my $old_status = '';
  my @name_array = ();

  # open file handlers
  open(FROM, '<:utf8', $from) or die("read error: $!");
  open(TO,   '>:utf8', $to)   or die("write error: $!");

  eval {
    while (my $line = <FROM>) {

      # match to variables
      # - format
      # - (YOMI FLAGS) (NAME)
      $line       =~ m/^([^ ]+ [^ ]+) (.+)$/;
      my $status  =  $1;
      my $name    =  $2;

      # check name queue
      if(@name_array < 1){

        # if empty
        # - update status value for comparison
        $old_status = $status;
      }
      # check difference for status values
      elsif($status ne $old_status){

        # write to file
        printf TO "%s %s\n", $old_status, join('|', @name_array);

        # reset
        # - name queue, status value
        @name_array = ();
        $old_status = $status;
      }

      # push name queue
      push(@name_array, $name);
    }

    # write to file
    # - append leftover data
    if (@name_array > 0) {
      printf TO "%s %s\n", $old_status, join('|', @name_array);
    }
  };

  # close files handlers
  close(FROM);
  close(TO);
} # }}}5

sub _create_count {

  my $self        = shift;
  my $to          = shift;
  my $count_files = shift;
  my @buf_array   = ();

  # count lines from files
  for my $count_file (@$count_files){
    push(@buf_array, $self->_count_lines($count_file));
  }

  # - -
  # write to file

  # open file handlers
  open(TO, '>:utf8', $to) or die("write error: $!");

  eval {
    printf TO "%s", join("\n", @buf_array);
  };

  # close files handlers
  close(TO);
}

# - - - - - - - - - - - - - - - - - - - - -
# parse

sub _parse { # {{{5

  my ($self, $line) = @_;
  my @type;
  my %parsed;

  chomp($line);

  # parse RegExp
  # - NAME [YOMI] /(TYPE,TYPE..) DETAIL/
  if ($line =~ m/^([^ ]+) \[([^\]]+)\] \/\(([^\)]+)\) (.+)\/$/g) {

    $parsed{'name'}   = $1;
    $parsed{'yomi'}   = $2;
    $parsed{'detail'} = $4;

    @type             = split(/,/, $3);
    $parsed{'type'}   = \@type;
  }
  # - NAME /(TYPE,TYPE..) DETAIL/
  elsif ($line =~ m/^([^ ]+) \/\(([^\)]+)\) (.+)\/$/g) {

    $parsed{'name'}   = $1;
    $parsed{'detail'} = $3;

    @type             = split(/,/, $2);
    $parsed{'type'}   = \@type;
  }

  return %parsed;
} # }}}5

# - - - - - - - - - - - - - - - - - - - - -
# filter

# = =
# check for type property
#
# args
# $0 ... array refference
#   search needle
#
#   for include:  h,  m, ...
#   for exclude: !h, !m, ...
#
# $1 ... array refference
#   search target
#
# returner
# 0 .. not match || match for bad filter param
# 1 .. match
sub _accept_by_type { # {{{5

  my $self        = shift;
  my $filter_type = shift;
  my $type        = shift;

  my $exists_flag = 0;

  foreach my $t1(@$filter_type){

    my $exclude_flag;
    my $t1_mod;

    if ($t1 =~ m/^!(.+)/){
      $exclude_flag = 1;
      $t1_mod       = $1;
    }
    else{
      $exclude_flag = 0;
      $t1_mod       = $t1;
    }

    foreach my $t2(@$type){

      # match
      if($t1_mod eq $t2){

        # if the exclude flag is enabled
        # - return failed
        if ($exclude_flag == 1) {
          return 0;
        }

        # update returner
        $exists_flag = 1;
      }
    }
  }

  # not match
  return $exists_flag;
} # }}}5

# = =
# convert from parsed line data
#
# returner
#   string
#   NAME YOMI FALGS
#     FLAGS parts are refference `_create_flag_string`
#
sub _create_line { # {{{5

  my $self      = shift;
  my $parsed    = shift;
  my $name      = $parsed->{'name'};
  my $yomi      = $parsed->{'yomi'};
  my $converted = '';

  # yomi
  $converted .= $yomi || $self->_convert_name_to_yomi($name);
  $converted .= ' ';

  # flags
  $converted .= $self->_create_flag_string($name);
  $converted .= ' ';

  # name
  $converted .= $name;

  # printf "%s\n", $converted;

  return $converted;
} # }}}5

# = =
# create flags from name data
#
# returner
#   string
#     [ALNUM][Hiragana][Katakana][Kanji]
#     1 ... include
#     0 ... none
#
#     example ()
#     1001 ... J太郎
#     0110 ... ザザムさん
#
sub _create_flag_string { # {{{5

  my $self   = shift;
  my $name   = shift;
  my @flag   = ();

  # Alnum & Hankaku Kana
  $flag[0] = ($name =~ /\p{InHalfwidthAndFullwidthForms}/) ? 1 : 0;

  # Hiragana
  $flag[1] = ($name =~ /\p{InHiragana}/) ? 1 : 0;

  # Katakana
  $flag[2] = ($name =~ /\p{InKatakana}/) ? 1 : 0;

  # Kanji (Han)
  $flag[3] = ($name =~ /[〆ヵヶ\p{InCJKUnifiedIdeographs}]/) ? 1 : 0;

  return join('', @flag);
} # }}}5

# = =
# convert name string to yomi string
sub _convert_name_to_yomi { # {{{5

  my $self   = shift;
  my $name   = shift;

  # convert
  # - old character
  $name =~ tr/ゐゑヰヱ/いえイエ/;

  # convert
  # - repeat mark
  $name =~ s/(.)ゝ/$1$1/g;

  # convert
  # - repeat mark (Dakuten)
  if ($name =~ m/(.)ゞ/) {
    my $tmp = chr(ord($1) + 1);
    $name =~ s/(.)ゞ/$1$tmp/g;
  }

  return $name;
} # }}}5

# - - - - - - - - - - - - - - - - - - - - -
# other

sub _guard_convert { # {{{5

  my ($self, $output_path, $filter_type) = @_;

  # guard
  # - check $src_path argument
  if (length($output_path) < 1){

    # if not string, error
    die 'require string for destination path ($1)';
  }

  # guard
  # - check $src_path argument
  if (ref $filter_type eq 'ARRAY'
      && scalar(@$filter_type) < 1){

    # if not string, error
    die 'require array for filtering type ($2)';
  }
} # }}}5

# = =
# count lines in files
# ref: http://perldoc.jp/docs/perl/5.10.1/perlfaq5.pod#How32do32I32count32the32number32of32lines32in32a32file63
#
# args
# $1 ... path for count
sub _count_lines { # {{{5

  my $self = shift;
  my $path = shift;
  my $cnt  = 0;
  my $buf  = '';

  # open file handlers
  open(FILE, '<:utf8', $path) or die("read error: $!");

  eval {
    while (sysread FILE, $buf, 4096) {
      $cnt += ($buf =~ tr/\n//);
    }
  };

  # close files handlers
  close(FILE);

  return $cnt;
} # }}}5

1;
