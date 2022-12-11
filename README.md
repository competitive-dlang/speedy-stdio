# speedy-stdio

**Note: it's a very new library in its eary days and may contain bugs. Bugreports are welcome!**

Do you have a program implemented in D programming language, which somehow needs to read and parse gigantic
amounts of text from *stdin* and then write gigantic amounts of text to *stdout*? If the answer is "yes",
then this library may be interesting for you.

[![Dub version](https://img.shields.io/dub/v/speedy-stdio.svg)](https://code.dlang.org/packages/speedy-stdio)
[![Dub downloads](https://img.shields.io/dub/dt/speedy-stdio.svg)](https://code.dlang.org/packages/speedy-stdio)
[![License](https://img.shields.io/dub/l/speedy-stdio.svg)](https://code.dlang.org/packages/speedy-stdio)
[![dmd and ldc](https://github.com/ssvb/speedy-stdio/actions/workflows/main.yml/badge.svg)](https://github.com/ssvb/speedy-stdio/actions/workflows/main.yml)
[![gdc](https://github.com/ssvb/speedy-stdio/actions/workflows/gdc.yml/badge.svg)](https://github.com/ssvb/speedy-stdio/actions/workflows/gdc.yml)

The **speedy.stdio** module extends [std.stdio](https://dlang.org/library/std/stdio.html) by substituting functions
[write](https://dlang.org/library/std/stdio/write.html), [writeln](https://dlang.org/library/std/stdio/writeln.html), 
[writef](https://dlang.org/library/std/stdio/writef.html) and [writefln](https://dlang.org/library/std/stdio/writefln.html)
with faster replacements. These replacements are optimized to handle only the most basic format variants
(decimal integers and non-escaped strings), but do it very fast. They are also compatible with the
[@nogc](https://dlang.org/spec/function.html#nogc-functions) attribute as an extra bonus.
More complicated format variants are still handled transparently via having a fallback to
[std.format.write.formattedWrite](https://dlang.org/library/std/format/write/formatted_write.html)
for full compatibility with Phobos (but whenever such fallbacks are used, the performance and @nogc
compatibility is lost).

Another bundled **speedy.fakestdio** module only *imitates* the API of std.stdio, but cuts some extra corners
for additional speed. It is not thread-safe and it also assumes that it has exclusive monopoly to access stdout
(doesn't play nice together with [printf](https://dlang.org/library/core/stdc/stdio/printf.html) or with
the original functions from the real std.stdio inside of the same program). Also it only imitates
[stdout.flush](https://dlang.org/library/std/stdio/file.flush.html) and has no support for the
other methods of [std.stdio.File](https://dlang.org/library/std/stdio/file.html). Use with caution!
But this is good enough for use in solutions submitted to competitive programming platforms, such
as [Codeforces](https://codeforces.com/) or [AtCoder](https://atcoder.jp/).

## Example

A [99 bottles of beer](https://www.99-bottles-of-beer.net/lyrics.html) example code,
intentionally using different varieties of functions:

```D
/+dub.sdl:
dependency "speedy-stdio" version="~>0.2.0"
+/
@safe @nogc:         // note: remove @nogc to compile with the standard "std.stdio"
import speedy.stdio; // this can be also "std.stdio" or "speedy.fakestdio"
const repeats = 1;   // change this to something much larger when benchmarking

void main() {
  foreach (i ; 0 .. repeats) {
    auto bottles(int n) { return n == 1 ? " bottle" : " bottles"; }
    foreach_reverse(n ; 1 .. 100) {
      writefln!"%d%s of beer on the wall, %d%s of beer."(n, bottles(n), n, bottles(n));
      static immutable a = ["Take", "one", "down", "and", "pass", "it", "around"];
      a.writef!"%-(%s %), ";
      if (n - 1 <= 0)
        write("no more bottles");
      else
        write(n - 1, bottles(n - 1));
      writeln(" of beer on the wall.");
      writeln;
    }
    writeln("No more bottles of beer on the wall, no more bottles of beer.");
    writeln("Go to the store and buy some more, 99 bottles of beer on the wall.");
  }
}
```

Install the [DUB package manager](https://github.com/dlang/dub) and run the example in a [script-like fashion](https://dub.pm/advanced_usage):
```
$ dub bottles.d
```

Or compile an optimized binary using the [LDC compiler](https://github.com/ldc-developers/ldc/releases):
```
$ dub build --build release --single --compiler=ldc2 bottles.d
```

## Performance

Changing "repeats" to 100000 in the "99 bottles of beer" example above and running it
on a 64-bit Linux system with Intel Core i7-860 @2.8GHz processor produces the
following results (redirected to /dev/null):

| used module      | test code          | repeats   | LDC 1.30.0 | DMD 2.099.1 |
|:----------------:|:------------------:|:---------:|:----------:|:-----------:|
| std.stdio        | 99 bottles of beer | 100000    |    17.874s |     34.777s |
| speedy.stdio     | 99 bottles of beer | 100000    |     4.749s |      9.132s |
| speedy.fakestdio | 99 bottles of beer | 100000    |     1.749s |      5.403s |

Another benchmark is just printing numbers from 0 to 100M on each line (redirected to /dev/null):

```D
/+dub.sdl:
dependency "speedy-stdio" version="~>0.2.0"
+/
@safe @nogc:         // note: remove @nogc to compile with the standard "std.stdio"
import speedy.stdio; // this can be also "std.stdio" or "speedy.fakestdio"

void main() {
  import std.range;
  100000001.iota.writefln!"%(%d\n%)";
}
```

| used module      | test code       | compiler   | LDC 1.30.0 |
|:----------------:|:---------------:|:----------:|:----------:|
| std.stdio        | count to 100M   | LDC 1.30.0 |    17.520s |
| speedy.stdio     | count to 100M   | LDC 1.30.0 |     2.349s |
| speedy.fakestdio | count to 100M   | LDC 1.30.0 |     1.809s |
