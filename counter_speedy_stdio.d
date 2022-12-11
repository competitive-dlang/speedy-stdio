/+dub.sdl:
dependency "speedy-stdio" version="~>0.2.0"
+/
@safe @nogc:         // note: remove @nogc to compile with the standard "std.stdio"
import speedy.stdio; // this can be also "std.stdio" or "speedy.fakestdio"

void main() {
  import std.range;
  100000001.iota.writefln!"%(%d\n%)";
}
