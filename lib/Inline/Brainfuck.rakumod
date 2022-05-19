use Term::termios;

my sub brainfuck(Str:D $code) is export {
    check-matching-loop $code;
    my $saved-term;
    try {
        $saved-term = Term::termios.new(:1fd).getattr;
        given Term::termios.new(:1fd).getattr {
            .makeraw;
            .setattr(:DRAIN);
        }
    };
    LEAVE { try $saved-term.setattr(:DRAIN) }

    my @code   = $code.comb: /<[-<\>+.,[\]]>/;
    my int $ꜛ;
    my int $cursor;
    my $stack := Buf[uint8].new: 0;
    loop {
        given @code[$cursor] {
            when '>' { $stack.append: 0 if $stack.elems == ++$ꜛ;       }
            when '<' { $ꜛ--; fail "Negative cell pointer\n" if $ꜛ < 0; }
            when '+' { $stack[$ꜛ]++;               }
            when '-' { $stack[$ꜛ]--;               }
            when '.' { $stack[$ꜛ].chr.print;       }
            when ',' { $stack[$ꜛ] = $*IN.getc.ord; }
            when '[' {
                $cursor++; next if $stack[$ꜛ];
                loop {
                    state $level = 1;
                    $level++ if @code[$cursor] eq '[';
                    $level-- if @code[$cursor] eq ']';
                    last unless $level;
                    $cursor++;
                }
            }
            when ']' {
                unless $stack[$ꜛ] { $cursor++; next }
                loop {
                    state $level = 1;
                    $cursor--;
                    $level-- if @code[$cursor] eq '[';
                    $level++ if @code[$cursor] eq ']';
                    last unless $level;
                }
            }
        }
        last if ++$cursor > @code.elems;
    }
}

my sub check-matching-loop($code) {
    my $level = 0;
    for $code.comb {
        $level++ if $_ eq '[';
        $level-- if $_ eq ']';
        fail qq{Closing "]" found without matching "["\n} if $level < 0;
        LAST { fail 'Unmatched [ ]' if $level > 0 }
    }
}

=begin pod

=head1 NAME

Inline::Brainfuck - Use Brainfuck language in your Raku programs

=head1 SYNOPSIS

=begin code :lang<raku>

use Inline::Brainfuck;

brainfuck '++++++++++ ++++++++++ ++++++++++ +++.'; # prints "!"

=end code

=head1 DESCRIPTION

This module provides a subroutine that takes a string with
L<Brainfuck code|https://en.wikipedia.org/wiki/Brainfuck> and executes it.

=head1 EXPORTED SUBROUTINES

=head2 brainfuck

=begin code :lang<raku>

brainfuck '++++++++++ ++++++++++ ++++++++++ +++.'; # prints "!"

=end code

Takes a C<Str>  with Brainfuck code to execute. Input will be read
from STDIN. The terminal will be switched to non-buffered mode, so any input
will be processed immediatelly, per-character. Output will be sent to STDOUT.

=head1 AUTHOR

Zoffix Znet

=head1 COPYRIGHT AND LICENSE

Copyright 2016 - 2017 Zoffix Znet

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
