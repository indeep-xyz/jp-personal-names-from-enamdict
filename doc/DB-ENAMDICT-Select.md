DB::ENAMDICT::Select
====

## USAGE

```
use DB::ENAMDICT::Select;

my ${returner} = use DB::ENAMDICT::Select->select(
  {DatabasePath},
  \{
    limit         => {Limit},
    random        => {RandomFlag},
    yomi_compact  => {YomiCompactFlag},
    flags         => '.....',
    flag_alnum    => {Flags},
    flag_hiragana => {Flags},
    flag_katakana => {Flags},
    flag_kanji    => {Flags},
    flag_chouon   => {Flags},
  }
);
```


### Limit

limit for get records.

### RandomFlag

flag for random selection.

if _0_ or no set, normal selection.
else random selection.

### YomiCompactFlag

flag for yomi compact.

if set, compact the result string to one line by yomi param.

example is in the following.

```
# no set
NAME-A YOMI
NAME-A YOMI
NAME-A YOMI
NAME-A YOMI
NAME-A YOMI

# set
NAME-A YOMI|YOMI|YOMI|YOMI|YOMI
```

### Flags

which you can pass params of either _flags_ or _flag_{FlagName}_ .

#### flags

- if set `1xxxx` , include alnum
- if set `x1xxx` , include Hiragana
- if set `xx1xx` , include Katakana
- if set `xxx1x` , include Kanji
- if set `xxxx1` , include Chouon

term flags

- 1 is include
- 0 is exclude
- other or no set, either way

#### flag_{FlagName}

- flag_alnum    => {Flags}
- flag_hiragana => {Flags}
- flag_katakana => {Flags}
- flag_kanji    => {Flags}
- flag_chouon   => {Flags}


### returner

returner is reference of ARRAY.

if you want to echo names, following.

```
for (my $i = 0; $i < scalar(@$returner); $i++) {
  printf "%s\n", @$returner[$i];
}
```
