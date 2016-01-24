grammar Inline::Brainfuck::Grammar {
    token TOP {
        [
            | <next>
            | <prev>
            | <inc>
            | <dec>
            | <out>
            | <in>
            | <loop-open>
            | <loop-close>
        ]
    }
    token next       { '>' }
    token prev       { '<' }
    token inc        { '+' }
    token dec        { '-' }
    token out        { '.' }
    token in         { ',' }
    token loop-open  { '[' }
    token loop-close { ']' }
}

class Inline::Brainfuck::Actions {
    use Term::termios;

    has Buf  $!stack   = Buf.new: 0;
    has Int  $!pointer = 0;
    has Bool $.debug   = False;
    has $!saved-term-settings;

    submethod BUILD {
        $!saved-term-settings = Term::termios.new(fd => 1).getattr;
        given Term::termios.new(fd => 1).getattr {
            .makeraw;
            .setattr(:DRAIN);
        }
    }
    method TOP ($) { $!saved-term-settings.setattr(:DRAIN); }

    method next ($) {
        $!pointer++;
        $!stack.append: 0 if $!stack.elems < $!pointer;
    }
    method prev ($) {
        $!pointer--;
        die "Cannot have a negative cell pointer\n" if $pointer < 0;
    }
    method inc  ($) { $!stack[$!pointer]++ }
    method dec  ($) { $!stack[$!pointer]-- }
    method out  ($) { print $!stack[$!pointer] }
    method in   ($) { $!stack[$!pointer] = $*IN.getc }

    >	increment the data pointer (to point to the next cell to the right).
    <	decrement the data pointer (to point to the next cell to the left).
    +	increment (increase by one) the byte at the data pointer.
    -	decrement (decrease by one) the byte at the data pointer.
    .	output the byte at the data pointer.
    ,	accept one byte of input, storing its value in the byte at the data pointer.
    [	if the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command.
    ]	if the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command.

}


use Term::termios;

# Save the previous attrs
my $saved_termios := Term::termios.new(fd => 1).getattr;

# Get the existing attrs in order to modify them
my $termios := Term::termios.new(fd => 1).getattr;

# Set the tty to raw mode
$termios.makeraw;

# You could also do the same in the old-fashioned way
# $termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
# $termios.set_oflags(<ONLCR>);
# $termios.set_cflags(<CS8>);
# $termios.unset_lflags(<ECHO ICANON IEXTEN ISIG>);

# Set the modified atributes, delayed until the buffer is emptied
$termios.setattr(:DRAIN);

# Loop on characters from STDIN
loop {
    my $c = $*IN.getc;
    print "got: " ~ $c.ord ~ "\r\n";
    last if $c eq 'q';
}

# Restore the saved, previous attributes before exit
$saved_termios.setattr(:DRAIN);
