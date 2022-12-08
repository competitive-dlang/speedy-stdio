module speedy.stdio_tests;
@safe:

import speedy.stdio;

unittest
{
    stdout.silenced = true;
    stdout.flush;
    string[2] a = ["abc", "xyz"];
    writeln(a);
    auto expected_data = "[\"abc\", \"xyz\"]\n";
    assert(stdout.buffer_contains(expected_data));
}

unittest
{
    stdout.silenced = true;
    stdout.flush;
    wchar c = 'ß';
    dstring s = "ÄÖÜ";
    writeln(c, s);
    auto expected_data = "ßÄÖÜ\n";
    assert(stdout.buffer_contains(expected_data));
}

unittest
{
    stdout.silenced = true;
    stdout.flush;
    wchar[2] a;
    a[0] = 'ß';
    a[1] = 'Ä';
    auto b = new dchar[3];
    b[0] = 'Ä';
    b[1] = 'Ö';
    b[2] = 'Ü';
    writeln(a, b);
    auto expected_data = "ßÄÄÖÜ\n";
    assert(stdout.buffer_contains(expected_data));
}

unittest
{
    import std.typecons : tuple;

    stdout.silenced = true;
    stdout.flush;
    writeln(tuple(int.min, int.max), ' ', int.min, ' ', int.max);
    auto expected_data = "Tuple!(int, int)(-2147483648, 2147483647) -2147483648 2147483647\n";
    assert(stdout.buffer_contains(expected_data));
}

@system unittest
{
    import std.parallelism, std.range;
    stdout.silenced = true;
    stdout.flush;
    int n = 1000;
    foreach (i; taskPool.parallel(iota(n)))
       writeln('[', ']');
    auto expected_data = "[]\n".replicate(n);
    assert(stdout.buffer_contains(expected_data), "multithreaded test");
}

unittest
{
    stdout.silenced = true;
    stdout.flush;
    writef!"%d %d"(12, 34);
    writef(" %d %d", 56, 78);
    auto expected_data = "12 34 56 78";
    assert(stdout.buffer_contains(expected_data), "writef failed");
}
