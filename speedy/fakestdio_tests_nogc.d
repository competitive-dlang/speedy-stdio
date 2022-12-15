module speedy.fakestdio_tests_nogc;
@safe @nogc:
import speedy.stdio : enforce;
import speedy.fakestdio;

@nogc unittest
{
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
    int[3] a = [1, 2, 3];
    int[2][3] b = [[1, 0], [2, -3], [3, 8]];

    stdout.flush;
    writef!"%d"(123);
    assert(stdout.buffer_contains("123"));

    stdout.flush;
    writefln!"%d"(123);
    assert(stdout.buffer_contains("123\n"));

    stdout.flush;
    writefln!"%s"(a);
    assert(stdout.buffer_contains("[1, 2, 3]\n"));

    stdout.flush;
    writefln!"%(%s %)"(b);
    assert(stdout.buffer_contains("[1, 0] [2, -3] [3, 8]\n"));

    stdout.flush;
    writef!"%s %(%s%)"(a, b);
    assert(stdout.buffer_contains("[1, 2, 3] [1, 0][2, -3][3, 8]"));

    stdout.flush;
    writef!"%s %-(%s%)"(a, b);
    assert(stdout.buffer_contains("[1, 2, 3] [1, 0][2, -3][3, 8]"));

    stdout.flush;
    string[3] s = ["abc", "x", "y"];
    writefln!"%-(%s %)"(s);
    assert(stdout.buffer_contains("abc x y\n"));

    stdout.flush;
    writefln!"hello %d %(%d %% %)"(123, a);
    writefln!"%(%s, %)"(a);
    auto expected_data = "hello 123 1 % 2 % 3\n1, 2, 3\n";
    assert(stdout.buffer_contains(expected_data), "writefln");
}

@nogc unittest
{
    try
    {
        enforce!"test"(1 == 2);
    }
    catch (Exception e)
    {
        assert(e.msg == "test");
    }
}
