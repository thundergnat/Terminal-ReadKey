NAME
====

Terminal::ReadKey - Read unbuffered, non-blocking key presses from STDIN.

SYNOPSIS
========

```raku
use Terminal::ReadKey;

react { whenever key-pressed( :!echo ) { .say } }
```

DESCRIPTION
===========

Terminal::ReadKey makes it easy to get un-buffered, non-blocking key presses from the keyboard buffer, even multibyte, combination key presses.

USAGE
=====

Terminal::ReadKey has a few options you can set to modify its behavior.

By default, will echo each keypress to STDOUT. If you would like to suppress that, pass in the parameter :echo set to a falsey value.

Defaults to returning a string containg the named key press (cooked mode). If you want the byte values instead, pass in the parameter :raw set to a truthy value.

When in cooked mode, if there is an unrecognized keypress, returns the byte string as a list of ordinals instead.

```raku
use Terminal::ReadKey;

# cooked mode
react { whenever key-pressed( :!echo ) { .say } }
```

or

```raku
# raw mode
react { whenever key-pressed( :!echo, :raw ) { .ords.say } }
```

BUGS
====

There are a few key combinations that I haven't yet been able to capture because either X11 or the terminal emulator grabs the keypress on my system. If you are able to capture the keypress byte sequence, send a bug report or pull request to get it into a future release. Notably missing:

  * Alt F1

  * Alt F2

  * Alt F3

  * Alt F4

  * Ctrl Insert

This was written and tested on a US English keyboard. Characters on non-US keyboards will likely not have "cooked" mode support. Again, bug reports / pull requests with the character and keypress byte sequence will likely get added.

At a minimum, give the byte list and character, one per line. EG:

  * (269) => č 

AUTHOR
======

Based on Term::ReadKey by jkramer - github.com/jkramer/p6-Term-ReadKey

Modified to recognize multibyte key presses and support "cooked" mode by Stephen Schulze - aka thundergnat <thundergnat@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Stephen Schulze

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

