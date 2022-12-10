module speedy.fakestdio;
import speedy.stdio;

alias write = speedy.stdio.unsafe_write;
alias writeln = speedy.stdio.unsafe_writeln;
alias writef = speedy.stdio.unsafe_writef;
alias writefln = speedy.stdio.unsafe_writefln;

private struct SpeedyFakeStdout
{
    version (unittest)
    {
        static bool buffer_contains()(string expected_data)
        {
            return speedy.stdio.unsafe_stdout_buffer_contains(expected_data);
        }
    }

    static void flush()()
    {
        speedy.stdio.unsafe_stdout_flush;
    }
}

SpeedyFakeStdout stdout;
