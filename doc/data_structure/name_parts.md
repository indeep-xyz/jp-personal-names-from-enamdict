data structure (name parts)
====

## files

- db/famale
- db/male
- db/surname

## syntax

```
YOMI FLAGS NAME|NAME|NAME|NAME...
YOMI FLAGS NAME|NAME|NAME|NAME...
...
```

### FLAGS

_1_ is true, _0_ is false.

descript the flag in descending order.

- if `1xxxx`, include alphabet and numeric.
- if `x1xxx`, include Hiragana.
- if `xx1xx`, include Katakana.
- if `xxx1x`, include Kanji.
- if `xxxx1`, include Chouon (ー).

## example

```
この 00010 楽|古乃|鼓之|瑚暖|瑚乃|心乃|葉乃
この 00110 木ノ
この 01000 この
このあ 00010 倖愛|心愛|心杏|心海
このあ 01000 このあ
このえ 00010 近愛|近衛|九重|好永|紺衣|子|時恵|小乃恵|木兄
このえ 00110 木ノ重
このえ 01000 このえ|このゑ
このか 00010 琴乃香|湖香|湖乃果|湖乃香|胡乃花|胡乃香|鼓乃歌|鼓乃香|瑚香|瑚乃華|瑚乃香|光音歌|光暖香|光乃花|光乃香|好伽|好夏|好花|好華|好香|好乃夏|好乃香|幸乃歌|幸望可|幸望果|幸望叶|幸望香|紅乃香|紅野花|香花|香乃果|香乃花|香風|子夏|樹夏|樹花|樹香|樹日|小乃佳|小野華|心音香|心花|心華|心樺|心香|心暖香|心乃歌|心乃花|心乃香|心乃奏|心楓|超乃佳|虹音香|虹暖花|虹乃香|木香|木乃花|木乃香|来暖花|来望叶|恋伽|恋乃花|恋乃華
このか 00110 子ノ香|木ノ香
```
