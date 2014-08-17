DB::ENAMEDICT::Convert
====

## USAGE

```
use DB::ENAMEDICT::Convert;

my $conv = DB::ENAMEDICT::Convert->new({SourcePath});
$conv->convert(
  {DatabasePath},
  \[{FilterType}],
  {YomiType}
);
```

structure of the output database is written to _doc/data_structure/name_parts.md_.

### SourcePath

file path for the ENAMEDICT format file was encoded _UTF-8_.

if not exists, run to `./setup_src.sh`.

### DatabasePath

path for database.

### FilterType

refference of ARRAY.

for data filtering. 

type names is following. if type name's prefix is _!_ that exclude it.

```
s - surname
p - place-name
u - person name, either given or surname, as-yet unclassified
g - given name, as-yet not classified by sex
f - female given name
m - male given name
h - full (usually family plus given) name of a particular person
pr - product name
c - company name
o - organization name
st - stations
wk - work of literature, art, film, etc.
```

### YomiType

param for Yomi format.

if no set, no convert.
if 0 set, convert to Hiragana.
if 1 set, convert to Katakana.

