# speedy-stdio

[![Dub version](https://img.shields.io/dub/v/speedy-stdio.svg)](https://code.dlang.org/packages/speedy-stdio)
[![Dub downloads](https://img.shields.io/dub/dt/speedy-stdio.svg)](https://code.dlang.org/packages/speedy-stdio)
[![License](https://img.shields.io/dub/l/speedy-stdio.svg)](https://code.dlang.org/packages/speedy-stdio)
[![dmd and ldc](https://github.com/ssvb/speedy-stdio/actions/workflows/main.yml/badge.svg)](https://github.com/ssvb/speedy-stdio/actions/workflows/main.yml)
[![gdc](https://github.com/ssvb/speedy-stdio/actions/workflows/gdc.yml/badge.svg)](https://github.com/ssvb/speedy-stdio/actions/workflows/gdc.yml)

A somewhat faster replacement for a subset of [std.stdio](https://dlang.org/library/std/stdio.html)
functionality from the standard D language library. The primary purpose is to speed up
stdin/stdout as much as possible for optimal use on the competitive programming platforms,
such as [Codeforces](https://codeforces.com/) or [AtCoder](https://atcoder.jp/).

Only implements [write](https://dlang.org/library/std/stdio/write.html) and
[writeln](https://dlang.org/library/std/stdio/writeln.html) functions in the
initial 0.1.2 release. Does not need GC for printing integers, strings and nested
arrays of integers.

A [99 bottles of beer](https://www.99-bottles-of-beer.net/lyrics.html) example code:

```D
/+dub.sdl:
dependency "speedy-stdio" version="~>0.1.2"
+/
@safe @nogc:
import speedy.stdio;

void main() {
  auto bottles(int n) { return n == 1 ? " bottle" : " bottles"; }
  foreach_reverse(n ; 1 .. 100) {
    write(n, bottles(n), " of beer on the wall, ");
    writeln(n, bottles(n), " of beer.");
    write("Take one down and pass it around, ");
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
```

Install the [DUB package manager](https://github.com/dlang/dub) and run the example in a [script-like fashion](https://dub.pm/advanced_usage):
```
$ dub bottles.d
```

Or compile an optimized binary using the [LDC compiler](https://github.com/ldc-developers/ldc/releases):
```
$ dub build --build release --single --compiler=ldc2 bottles.d
```

# benchmarks

<details>
<summary>Running the 99 bottles of beer example code 100K times in a loop</summary>

```D
/+dub.sdl:
dependency "speedy-stdio" version="~>0.1.2"
+/
@safe @nogc:
import speedy.stdio;

void main() {
  foreach (i ; 0 .. 100000) {
    auto bottles(int n) { return n == 1 ? " bottle" : " bottles"; }
    foreach_reverse(n ; 1 .. 100) {
      write(n, bottles(n), " of beer on the wall, ");
      writeln(n, bottles(n), " of beer.");
      write("Take one down and pass it around, ");
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
Test on a Linux system with Intel Core i7-860 @2.8GHz processor and using LDC 1.30.0 as a compiler:
```
$ dub build --build release --single --compiler=ldc2 speedy_stdio_100000x99_bottles.d
$ time ./speedy_stdio_100000x99_bottles > /dev/null

real    0m1.407s
user    0m1.367s
sys     0m0.040s
```
For comparison, using the standard `std.stdio` module makes this code much slower:
```D
/+dub.sdl:
+/
import std.stdio;

void main() {
  foreach (i ; 0 .. 100000) {
    auto bottles(int n) { return n == 1 ? " bottle" : " bottles"; }
    foreach_reverse(n ; 1 .. 100) {
      write(n, bottles(n), " of beer on the wall, ");
      writeln(n, bottles(n), " of beer.");
      write("Take one down and pass it around, ");
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
```
$ dub build --build release --single --compiler=ldc2 std_stdio_100000x99_bottles.d
$ time ./std_stdio_100000x99_bottles > /dev/null

real    0m6.879s
user    0m6.762s
sys     0m0.100s
```
</details>
