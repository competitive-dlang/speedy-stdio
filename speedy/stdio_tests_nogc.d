module speedy.stdio_tests_nogc;
@safe @nogc:

import speedy.stdio;

@nogc unittest
{
    stdout.silenced = true;
    stdout.flush;
    writeln(1);
    write(2);
    write("hello");
    writeln(7, "xyz");
    int[3] a = [1, -2, 3];
    write(true);
    write(a);
    int[2][2] b = [[7, 8], [9, 10]];
    write(b);
    write(1 > 2);
    auto expected_data = "1\n2hello7xyz\ntrue[1, -2, 3][[7, 8], [9, 10]]false";
    assert(stdout.buffer_contains(expected_data));
}

@nogc unittest
{
    stdout.silenced = true;
    stdout.flush;
    writeln(int.min);
    writeln(int.max);
    writeln(uint.min);
    writeln(uint.max);
    writeln(long.min);
    writeln(long.max);
    writeln(ulong.min);
    writeln(ulong.max);
    auto expected_data = "-2147483648\n2147483647\n0\n4294967295\n" ~
        "-9223372036854775808\n9223372036854775807\n" ~
        "0\n18446744073709551615\n";
    assert(stdout.buffer_contains(expected_data));
}

@nogc unittest
{
    stdout.silenced = true;
    stdout.flush;
    int[3] a = [1, 2, 3];
    writefln!"%d"(123);
    writefln!"hello %d %(%d %% %)"(123, a);
    writefln!"%(%s, %)"(a);
    auto expected_data = "123\nhello 123 1 % 2 % 3\n1, 2, 3\n";
    assert(stdout.buffer_contains(expected_data), "writefln");
}
