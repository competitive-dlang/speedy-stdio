/+dub.sdl:
dependency "speedy-stdio" version="~>0.2.0"
+/
@safe @nogc:              // note: remove @nogc to compile with the standard "std.stdio"
import speedy.fakestdio;  // this can be also "std.stdio" or "speedy.fakestdio"
const repeats = 100000;   // change this to something much larger when benchmarking

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