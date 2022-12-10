/+dub.sdl:
dependency "speedy-stdio" version="~>0.2.0"
+/
import std.traits, std.range, std.algorithm, std.conv, std.exception, std.string;

const SIZELIMIT = 20000;

// https://burtleburtle.net/bob/rand/smallprng.html
alias u4 = uint;
alias u8 = ulong;

struct ranctx(T) { T a; T b; T c; T d; }

T1 rot(T1, T2)(T1 x, T2 k) { return (((x)<<(k))|((x)>>((x.sizeof*8)-(k)))); }

u4 ranval(ref ranctx!u4 x) @safe @nogc
{
    u4 e = x.a - rot(x.b, 27);
    x.a = x.b ^ rot(x.c, 17);
    x.b = x.c + x.d;
    x.c = x.d + e;
    x.d = e + x.a;
    return x.d;
}

u8 ranval(ref ranctx!u8 x) @safe @nogc
{
    u8 e = x.a - rot(x.b, 7);
    x.a = x.b ^ rot(x.c, 13);
    x.b = x.c + rot(x.d, 37);
    x.c = x.d + e;
    x.d = e + x.a;
    return x.d;
}

ranctx!T raninit(T)(T seed)
{
    ranctx!T x;
    x.a = 0xf1ea5eed, x.b = x.c = x.d = seed;
    foreach (i ; 0 .. 20)
        x.ranval();
    return x;
}

struct randrange(T)
{
    enum bool empty = false;
    ranctx!(Unsigned!T) ctx;
    this(T seed)
    {
        ctx = raninit(cast(Unsigned!T)seed);
    }
    T front() @safe
    {
        T x = ctx.d;
        return x >> (ctx.b & (T.sizeof * 8 - 1));
    }
    void popFront() @safe
    {
       ctx.ranval;
    }
}

void printer(T, alias write, alias writeln, alias writef, alias writefln)(int seed)
{
    static data = ["da", "ta"];
    auto rng = randrange!T(cast(T)seed);
    auto n = cast(uint)(rng.front) % SIZELIMIT + 2;
    rng.popFront;
    switch (seed & 7)
    {
        case 0:
            writeln("seed=", seed, ", n=", n, ", data=", rng.takeExactly(n));
            break;
        case 1:
            write("seed=", seed, ", n=", n, ", data=", rng.takeExactly(n), '\n');
            break;
        case 2:
            writefln!"seed=%d, n=%d, data=%s"(seed, n, rng.takeExactly(n));
            break;
        case 3:
            writef!"seed=%d, n=%d, data=[%(%s, %)]\n"(seed, n, rng.takeExactly(n));
            break;
        case 4:
            writefln!"seed=%d, n=%d, data=[%(%s, %)]"(seed, n, rng.takeExactly(n));
            break;
        case 5:
            writef!"seed=%d, n=%d, data=[%(%d, %), %-(%s, %)]\n"(
                seed, n, rng.takeExactly(n / 2), rng.drop(n / 2).takeExactly(n - n / 2));
            break;
        case 6:
            writefln!"seed=%d, n=%d, %-(%s%)=[%(%d, %), %(%s, %)]"(
                seed, n, data, rng.takeExactly(n / 2), rng.drop(n / 2).takeExactly(n - n / 2));
            break;
        case 7:
            writef!"seed=%d, n=%d, %-(%s%)=[%-(%d, %), %(%s, %)]\n"(
                seed, n, data.map!(x => x), rng.takeExactly(n / 2), rng.drop(n / 2).takeExactly(n - n / 2));
            break;
        default:
            assert(0);
    }
}

void printer_std_stdio(T)(int cnt)
{
    import std.stdio, std.parallelism;
    auto poolInstance = new TaskPool(2);
    scope(exit) poolInstance.stop();
    foreach (seed; poolInstance.parallel(iota(cnt)))
        printer!(T, std.stdio.write, std.stdio.writeln, std.stdio.writef, std.stdio.writefln)(seed);
}

void printer_speedy_stdio(T)(int cnt)
{
    import speedy.stdio, std.parallelism;
    auto poolInstance = new TaskPool(2);
    scope(exit) poolInstance.stop();
    foreach (seed; poolInstance.parallel(iota(cnt)))
        printer!(T, speedy.stdio.write, speedy.stdio.writeln, speedy.stdio.writef, speedy.stdio.writefln)(seed);
}

void printer_mixed(T)(int cnt)
{
    import std.stdio, speedy.stdio, std.parallelism;
    auto poolInstance = new TaskPool(2);
    scope(exit) poolInstance.stop();
    foreach (seed; poolInstance.parallel(iota(cnt)))
        printer!(T, speedy.stdio.write, std.stdio.writeln, std.stdio.writef, speedy.stdio.writefln)(seed);
}

void printer_speedy_fakestdio(T)(int cnt) @nogc
{
    import speedy.fakestdio;
    foreach (seed; iota(cnt))
        printer!(T, speedy.fakestdio.write, speedy.fakestdio.writeln, speedy.fakestdio.writef, speedy.fakestdio.writefln)(seed);
    speedy.fakestdio.stdout.flush;
}

void checker(T)(int cnt)
{
    import std.stdio, std.format;
    bool[int] tested_seeds;
    foreach (line ; stdin.byLine)
    {
        int seed;
        auto origline = line;
        if (line.formattedRead!"seed=%d"(seed) == 1)
        {
            auto rng = randrange!T(cast(T)seed);
            auto n = cast(uint)(rng.front) % SIZELIMIT + 2;
            rng.popFront;
            auto expected = format!"seed=%d, n=%d, data=%s"(seed, n, rng.takeExactly(n));
            enforce(origline.strip == expected, "corrupted data");
            tested_seeds[seed] = true;
        }
    }
    enforce(tested_seeds.length == cnt, "incomplete or different data");
    return;
}

void help()
{
    import std.stdio;
    stderr.writeln("Usage: mtfuzzer [test] [n]");
    stderr.writeln("Where:");
    stderr.writeln("  testtype - needs to be 'std.stdio', 'speedy.stdio', 'mixed',");
    stderr.writeln("             'speedy.fakestdio' or 'checker'.");
    stderr.writeln("  n        - the number of lines in the generated data.");
    stderr.writeln("");
    stderr.writeln("For example, './mtfuzzer speedy.stdio 1000 | ./mtfuzzer checker 1000'");
    stderr.writeln("will generate a bunch of data and pipe it to itself for checking.");
}

int main(string[] args)
{
    import std.stdio;
    if (args.length < 2)
    {
        help();
        return 1;
    }
    string testtype = args[1].strip;
    int cnt = args.length >= 3 ? max(args[2].to!int, 1) : 1;
    switch (testtype)
    {
        case "std.stdio":
            printer_std_stdio!(int)(cnt);
            break;
        case "speedy.stdio":
            printer_speedy_stdio!(int)(cnt);
            break;
        case "mixed":
            printer_mixed!(int)(cnt);
            break;
        case "speedy.fakestdio":
            printer_speedy_fakestdio!(int)(cnt);
            break;
        case "checker":
            checker!(int)(cnt);
            stderr.writeln("Test successfully completed.");
            break;
        default:
            help();
            return 1;
            break;
    }

    return 0;
}
