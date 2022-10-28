[![Actions Status](https://github.com/thundergnat/Terminal-ReadKey/actions/workflows/test.yml/badge.svg)](https://github.com/thundergnat/Terminal-ReadKey/actions)

NAME
====

Terminal::ReadKey - Read non-blocking key presses from the keyboard buffer.

SYNOPSIS
========

```raku
use Terminal::ReadKey;

react { whenever key-pressed() { .say } }
```

DESCRIPTION
===========

Terminal::ReadKey makes it easy to get non-blocking key presses from the keyboard buffer, even multibyte, combination key presses.

USAGE
=====

Terminal::ReadKey has a few options you can set to modify its behavior.

Defaults to cooked mode, where it returns a string containing the named key press. If you want the byte values instead, pass in the parameter :raw set to a truthy value. Raw mode returns a sequence of bytes decoded to an ASCII string. For printable characters it is effectively the same as cooked mode. For non-printables, (function keys, navigation keys, Alt, or Ctrl keys) it won't look like much.

When in cooked mode, if there is an unrecognized keypress, returns the byte string as a stringified list of ordinals.

By default, does not echo each keypress to STDOUT. If you would prefer it to, pass in the parameter :echo set to a truthy value.

```raku
use Terminal::ReadKey;

# cooked mode
react { whenever key-pressed() { .say } }
```

or

```raku
use Terminal::ReadKey;

# raw mode
react { whenever key-pressed( :raw ) { .ords.say } }
```

Also, selectively exports the cooked() routine if you want to convert raw output to cooked manually.

```raku
use Terminal::ReadKey :cooked;

my $fh = open( :a, 'key-cap.txt' ) or die $_;
react { whenever key-pressed( :raw, :echo ) { $fh.print( .&cooked ); $fh.flush } }
```

BUGS
====

Since Terminal::ReadKey interacts with the keyboard buffer rather than reading the keyboard directly, it has no way to differentiate different keypresses that result in the same "keypress" in the buffer. For instance, if it reads a "Ctrl *", it has no way to tell _which_ Ctrl key may have been pressed, only that there _was_ a Ctrl key pressed. Same with Shift, Enter, or any other key combination that may be entered in multiple ways.

That also means that it can be affected by the OS / window managers typing repeat setting. It doesn't see, and is not responding to the actual key press, rather the presence of "key-presses" in the keyboard buffer.

There are a few key combinations that I haven't yet been able to capture because either X11 or the terminal emulator grabs the keypress on my system. If you are able to capture the keypress byte sequence, send a bug report or pull request to get it into a future release. Notably missing (or at least, unverified):

  * Alt F1

  * Alt F2

  * Alt F3

  * Alt F4

  * Alt Tab

  * Ctrl Insert

This was written and tested on a US English keyboard. Characters on non-US keyboards will likely not have correct "cooked" mode support.

AUTHOR
======

Based on Term::ReadKey by jkramer - github.com/jkramer/p6-Term-ReadKey

Modified to recognize multibyte (non-printable) key presses and support "cooked" mode by Stephen Schulze - aka thundergnat <thundergnat@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Stephen Schulze

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

