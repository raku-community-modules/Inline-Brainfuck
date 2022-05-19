[![Actions Status](https://github.com/raku-community-modules/Inline-Brainfuck/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/Inline-Brainfuck/actions)

NAME
====

Inline::Brainfuck - Use Brainfuck language in your Raku programs

SYNOPSIS
========

```raku
use Inline::Brainfuck;

brainfuck '++++++++++ ++++++++++ ++++++++++ +++.'; # prints "!"
```

DESCRIPTION
===========

This module provides a subroutine that takes a string with [Brainfuck code](https://en.wikipedia.org/wiki/Brainfuck) and executes it.

EXPORTED SUBROUTINES
====================

brainfuck
---------

```raku
brainfuck '++++++++++ ++++++++++ ++++++++++ +++.'; # prints "!"
```

Takes a `Str` with Brainfuck code to execute. Input will be read from STDIN. The terminal will be switched to non-buffered mode, so any input will be processed immediatelly, per-character. Output will be sent to STDOUT.

AUTHOR
======

Zoffix Znet

COPYRIGHT AND LICENSE
=====================

Copyright 2016 - 2017 Zoffix Znet

Copyright 2018 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

