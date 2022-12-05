# speedy-stdio

A faster replacement for a subset of [std.stdio](https://dlang.org/library/std/stdio.html)
functionality from the standard D language library. Tested on Linux/Windows.
Only implements [write](https://dlang.org/library/std/stdio/write.html) and
[writeln](https://dlang.org/library/std/stdio/writeln.html) functions in the
initial release. Does not need GC for printing integers, strings and nested
arrays of integers.

The following [99 bottles of beer](https://www.99-bottles-of-beer.net/lyrics.html)
example can be used as a benchmark (be sure to redirect its output to a file or
to /dev/null):

```D
/+dub.sdl:
dependency "speedy-stdio" version="~>0.1"
+/
@safe: @nogc:
import speedy.stdio;

void print_lyrics() {
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

void main() {
  foreach (i ; 0 .. 100000) {
    print_lyrics;
    writeln;
  }
}
```

Compiled with LDC 1.30.0 on Core i7-860 @2.8GHz:
```
$ time ./speedy-stdio-bottles > /dev/null

real	0m1.242s
user	0m1.242s
sys	0m0.000s

$ time ./std-stdio-bottles > /dev/null

real	0m6.879s
user	0m6.762s
sys	0m0.100s
```
