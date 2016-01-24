unit class Inline::Brainfuck;

has $!state = Inline::Brainfuck::State.new;

method run (Str:D $code) {
    $code.subst-mutate: /<-[-<>+.,[\]]>/, '', :g;
}
