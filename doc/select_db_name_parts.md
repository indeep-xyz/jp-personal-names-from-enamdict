select_db_name_parts.pl
====

wrapper for _DB::ENAMDICT::Select_ .

## USAGE

```
./select_db_name_parts.pl [option] [dbname]
```

_dbname_ is requirement. you can pass database name created in _db/_ .

### option

#### -f

include or exclude flag.

order by

- if `1xxxx`, include alnum.
- if `x1xxx`, include Hiragana.
- if `xx1xx`, include Katakana.
- if `xxx1x`, include Kanji.
- if `xxxx1`, include Chouon (ー).

flag's terms are

- 1 is include
- 0 is exclude
- other character or no set, either way

#### -l

limit for get records.

default value is _1_ .

#### -n

regex string for name params

#### -r

flag for random selection.

if no set normal selection, else random selection.

#### -y

regex string for yomi params.

#### -Y

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

