unit class Terminal::ReadKey;

use Term::termios;
use NativeCall;

sub getchar returns int32 is native { * }

sub with-termios(Callable:D $fn, Bool:D :$echo = True --> Str) {
    my $original-flags := Term::termios.new(:fd($*IN.native-descriptor)).getattr;
    my $flags := Term::termios.new(:fd($*IN.native-descriptor)).getattr;

    $flags.unset_lflags('ICANON');
    $flags.unset_lflags('ECHO') unless $echo;
    $flags.setattr(:NOW);

    my $result = $fn();

    $original-flags.setattr(:NOW);

    $result;
}

sub read-character returns Str { $*IN.read(7).decode } # read up to seven bytes from the buffer

sub key-pressed(Bool:D :$echo = True, Bool:D :$raw = False --> Supply) is export {
    my Supplier $supplier .= new;

    my %keys := {
        # single byte
        Buf.new(0).decode => ｢Ctrl `｣,
        Buf.new(1).decode => ｢Ctrl A｣,
        Buf.new(2).decode => ｢Ctrl B｣,
        Buf.new(3).decode => ｢Ctrl C｣,
        Buf.new(4).decode => ｢Ctrl D｣,
        Buf.new(5).decode => ｢Ctrl E｣,
        Buf.new(6).decode => ｢Ctrl F｣,
        Buf.new(7).decode => ｢Ctrl G｣,
        Buf.new(8).decode => ｢Ctrl H｣,
        Buf.new(9).decode => ｢Tab｣,
        Buf.new(10).decode => ｢Enter｣,
        Buf.new(11).decode => ｢Ctrl K｣,
        Buf.new(12).decode => ｢Ctrl L｣,
        Buf.new(14).decode => ｢Ctrl N｣,
        Buf.new(15).decode => ｢Ctrl O｣,
        Buf.new(16).decode => ｢Ctrl P｣,
        Buf.new(17).decode => ｢Ctrl Q｣,
        Buf.new(18).decode => ｢Ctrl R｣,
        Buf.new(19).decode => ｢Ctrl S｣,
        Buf.new(20).decode => ｢Ctrl T｣,
        Buf.new(21).decode => ｢Ctrl U｣,
        Buf.new(22).decode => ｢Ctrl V｣,
        Buf.new(23).decode => ｢Ctrl W｣,
        Buf.new(24).decode => ｢Ctrl X｣,
        Buf.new(25).decode => ｢Ctrl Y｣,
        Buf.new(26).decode => ｢Ctrl Z｣,
        Buf.new(27).decode => ｢Esc｣,

        Buf.new(29).decode => ｢Ctrl ]｣,
        Buf.new(30).decode => ｢Ctrl ~｣,
        Buf.new(31).decode => ｢Ctrl /｣,
        Buf.new(32).decode => ｢Space｣,
        Buf.new(33).decode => ｢!｣,
        Buf.new(34).decode => ｢"｣,
        Buf.new(35).decode => ｢#｣,
        Buf.new(36).decode => ｢$｣,
        Buf.new(37).decode => ｢%｣,
        Buf.new(38).decode => ｢&｣,
        Buf.new(39).decode => ｢'｣,
        Buf.new(40).decode => ｢(｣,
        Buf.new(41).decode => ｢)｣,
        Buf.new(42).decode => ｢*｣,
        Buf.new(43).decode => ｢+｣,
        Buf.new(44).decode => ｢,｣,
        Buf.new(45).decode => ｢-｣,
        Buf.new(46).decode => ｢.｣,
        Buf.new(47).decode => ｢/｣,
        Buf.new(48).decode => ｢0｣,
        Buf.new(49).decode => ｢1｣,
        Buf.new(50).decode => ｢2｣,
        Buf.new(51).decode => ｢3｣,
        Buf.new(52).decode => ｢4｣,
        Buf.new(53).decode => ｢5｣,
        Buf.new(54).decode => ｢6｣,
        Buf.new(55).decode => ｢7｣,
        Buf.new(56).decode => ｢8｣,
        Buf.new(57).decode => ｢9｣,
        Buf.new(58).decode => ｢:｣,
        Buf.new(59).decode => ｢;｣,
        Buf.new(60).decode => ｢<｣,
        Buf.new(61).decode => ｢=｣,
        Buf.new(62).decode => ｢>｣,
        Buf.new(63).decode => ｢?｣,
        Buf.new(64).decode => ｢@｣,
        Buf.new(65).decode => ｢A｣,
        Buf.new(66).decode => ｢B｣,
        Buf.new(67).decode => ｢C｣,
        Buf.new(68).decode => ｢D｣,
        Buf.new(69).decode => ｢E｣,
        Buf.new(70).decode => ｢F｣,
        Buf.new(71).decode => ｢G｣,
        Buf.new(72).decode => ｢H｣,
        Buf.new(73).decode => ｢I｣,
        Buf.new(74).decode => ｢J｣,
        Buf.new(75).decode => ｢K｣,
        Buf.new(76).decode => ｢L｣,
        Buf.new(77).decode => ｢M｣,
        Buf.new(78).decode => ｢N｣,
        Buf.new(79).decode => ｢O｣,
        Buf.new(80).decode => ｢P｣,
        Buf.new(81).decode => ｢Q｣,
        Buf.new(82).decode => ｢R｣,
        Buf.new(83).decode => ｢S｣,
        Buf.new(84).decode => ｢T｣,
        Buf.new(85).decode => ｢U｣,
        Buf.new(86).decode => ｢V｣,
        Buf.new(87).decode => ｢W｣,
        Buf.new(88).decode => ｢X｣,
        Buf.new(89).decode => ｢Y｣,
        Buf.new(90).decode => ｢Z｣,
        Buf.new(91).decode => ｢[｣,
        Buf.new(92).decode => ｢\｣,
        Buf.new(93).decode => ｢]｣,
        Buf.new(94).decode => ｢^｣,
        Buf.new(95).decode => ｢_｣,
        Buf.new(96).decode => ｢`｣,
        Buf.new(97).decode => ｢a｣,
        Buf.new(98).decode => ｢b｣,
        Buf.new(99).decode => ｢c｣,
        Buf.new(100).decode => ｢d｣,
        Buf.new(101).decode => ｢e｣,
        Buf.new(102).decode => ｢f｣,
        Buf.new(103).decode => ｢g｣,
        Buf.new(104).decode => ｢h｣,
        Buf.new(105).decode => ｢i｣,
        Buf.new(106).decode => ｢j｣,
        Buf.new(107).decode => ｢k｣,
        Buf.new(108).decode => ｢l｣,
        Buf.new(109).decode => ｢m｣,
        Buf.new(110).decode => ｢n｣,
        Buf.new(111).decode => ｢o｣,
        Buf.new(112).decode => ｢p｣,
        Buf.new(113).decode => ｢q｣,
        Buf.new(114).decode => ｢r｣,
        Buf.new(115).decode => ｢s｣,
        Buf.new(116).decode => ｢t｣,
        Buf.new(117).decode => ｢u｣,
        Buf.new(118).decode => ｢v｣,
        Buf.new(119).decode => ｢w｣,
        Buf.new(120).decode => ｢x｣,
        Buf.new(121).decode => ｢y｣,
        Buf.new(122).decode => ｢z｣,
        Buf.new(123).decode => ｢{｣,
        Buf.new(124).decode => ｢|｣,
        Buf.new(125).decode => ｢}｣,
        Buf.new(126).decode => ｢~｣,
        Buf.new(127).decode => ｢Backspace｣,

        # two bytes
        Buf.new(27, 10).decode => ｢Alt Enter｣,
        Buf.new(27, 27).decode => ｢Alt Esc｣,
        Buf.new(27, 33).decode => ｢Alt !｣,
        Buf.new(27, 34).decode => ｢Alt "｣,
        Buf.new(27, 35).decode => ｢Alt #｣,
        Buf.new(27, 36).decode => ｢Alt $｣,
        Buf.new(27, 37).decode => ｢Alt %｣,
        Buf.new(27, 38).decode => ｢Alt &｣,
        Buf.new(27, 39).decode => ｢Alt '｣,
        Buf.new(27, 42).decode => ｢Alt *｣,
        Buf.new(27, 40).decode => ｢Alt (｣,
        Buf.new(27, 41).decode => ｢Alt )｣,
        Buf.new(27, 43).decode => ｢Alt +｣,
        Buf.new(27, 44).decode => ｢Alt ,｣,
        Buf.new(27, 45).decode => ｢Alt -｣,
        Buf.new(27, 46).decode => ｢Alt .｣,
        Buf.new(27, 47).decode => ｢Alt /｣,
        Buf.new(27, 48).decode => ｢Alt 0｣,
        Buf.new(27, 49).decode => ｢Alt 1｣,
        Buf.new(27, 50).decode => ｢Alt 2｣,
        Buf.new(27, 51).decode => ｢Alt 3｣,
        Buf.new(27, 52).decode => ｢Alt 4｣,
        Buf.new(27, 53).decode => ｢Alt 5｣,
        Buf.new(27, 54).decode => ｢Alt 6｣,
        Buf.new(27, 55).decode => ｢Alt 7｣,
        Buf.new(27, 56).decode => ｢Alt 8｣,
        Buf.new(27, 57).decode => ｢Alt 9｣,
        Buf.new(27, 58).decode => ｢Alt :｣,
        Buf.new(27, 59).decode => ｢Alt ;｣,
        Buf.new(27, 60).decode => ｢Alt <｣,
        Buf.new(27, 61).decode => ｢Alt =｣,
        Buf.new(27, 62).decode => ｢Alt >｣,
        Buf.new(27, 63).decode => ｢Alt ?｣,
        Buf.new(27, 64).decode => ｢Alt @｣,
        Buf.new(27, 65).decode => ｢Alt A｣,
        Buf.new(27, 66).decode => ｢Alt B｣,
        Buf.new(27, 67).decode => ｢Alt C｣,
        Buf.new(27, 68).decode => ｢Alt D｣,
        Buf.new(27, 69).decode => ｢Alt E｣,
        Buf.new(27, 70).decode => ｢Alt F｣,
        Buf.new(27, 71).decode => ｢Alt G｣,
        Buf.new(27, 72).decode => ｢Alt H｣,
        Buf.new(27, 73).decode => ｢Alt I｣,
        Buf.new(27, 74).decode => ｢Alt J｣,
        Buf.new(27, 75).decode => ｢Alt K｣,
        Buf.new(27, 76).decode => ｢Alt L｣,
        Buf.new(27, 77).decode => ｢Alt M｣,
        Buf.new(27, 78).decode => ｢Alt N｣,
        Buf.new(27, 79).decode => ｢Alt O｣,
        Buf.new(27, 80).decode => ｢Alt P｣,
        Buf.new(27, 81).decode => ｢Alt Q｣,
        Buf.new(27, 82).decode => ｢Alt R｣,
        Buf.new(27, 83).decode => ｢Alt S｣,
        Buf.new(27, 84).decode => ｢Alt T｣,
        Buf.new(27, 85).decode => ｢Alt U｣,
        Buf.new(27, 86).decode => ｢Alt V｣,
        Buf.new(27, 87).decode => ｢Alt W｣,
        Buf.new(27, 88).decode => ｢Alt X｣,
        Buf.new(27, 89).decode => ｢Alt Y｣,
        Buf.new(27, 90).decode => ｢Alt Z｣,
        Buf.new(27, 91).decode => ｢Alt [｣,
        Buf.new(27, 92).decode => ｢Alt \｣,
        Buf.new(27, 93).decode => ｢Alt ]｣,
        Buf.new(27, 94).decode => ｢Alt ^｣,
        Buf.new(27, 95).decode => ｢Alt _｣,
        Buf.new(27, 96).decode => ｢Alt `｣,
        Buf.new(27, 97).decode => ｢Alt a｣,
        Buf.new(27, 98).decode => ｢Alt b｣,
        Buf.new(27, 99).decode => ｢Alt c｣,
        Buf.new(27, 100).decode => ｢Alt d｣,
        Buf.new(27, 101).decode => ｢Alt e｣,
        Buf.new(27, 102).decode => ｢Alt f｣,
        Buf.new(27, 103).decode => ｢Alt g｣,
        Buf.new(27, 104).decode => ｢Alt h｣,
        Buf.new(27, 105).decode => ｢Alt i｣,
        Buf.new(27, 106).decode => ｢Alt j｣,
        Buf.new(27, 107).decode => ｢Alt k｣,
        Buf.new(27, 108).decode => ｢Alt l｣,
        Buf.new(27, 109).decode => ｢Alt m｣,
        Buf.new(27, 110).decode => ｢Alt n｣,
        Buf.new(27, 111).decode => ｢Alt o｣,
        Buf.new(27, 112).decode => ｢Alt p｣,
        Buf.new(27, 113).decode => ｢Alt q｣,
        Buf.new(27, 114).decode => ｢Alt r｣,
        Buf.new(27, 115).decode => ｢Alt s｣,
        Buf.new(27, 116).decode => ｢Alt t｣,
        Buf.new(27, 117).decode => ｢Alt u｣,
        Buf.new(27, 118).decode => ｢Alt v｣,
        Buf.new(27, 119).decode => ｢Alt w｣,
        Buf.new(27, 120).decode => ｢Alt x｣,
        Buf.new(27, 121).decode => ｢Alt y｣,
        Buf.new(27, 122).decode => ｢Alt z｣,
        Buf.new(27, 123).decode => ｢Alt {｣,
        Buf.new(27, 124).decode => ｢Alt |｣,
        Buf.new(27, 125).decode => ｢Alt }｣,
        Buf.new(27, 126).decode => ｢Alt ~｣,
        Buf.new(27, 127).decode => ｢Alt Backspace｣,

        # three bytes
        Buf.new(27, 79, 80).decode => ｢F1｣,
        Buf.new(27, 79, 81).decode => ｢F2｣,
        Buf.new(27, 79, 82).decode => ｢F3｣,
        Buf.new(27, 79, 83).decode => ｢F4｣,
        Buf.new(27, 91, 65).decode => ｢Up｣,
        Buf.new(27, 91, 66).decode => ｢Down｣,
        Buf.new(27, 91, 67).decode => ｢Right｣,
        Buf.new(27, 91, 68).decode => ｢Left｣,
        Buf.new(27, 91, 69).decode => ｢Center｣,
        Buf.new(27, 91, 70).decode => ｢End｣,
        Buf.new(27, 91, 72).decode => ｢Home｣,

        # four bytes
        Buf.new(27, 91, 50, 126).decode => ｢Insert｣,
        Buf.new(27, 91, 51, 126).decode => ｢Del｣,
        Buf.new(27, 91, 53, 126).decode => ｢PgUp｣,
        Buf.new(27, 91, 54, 126).decode => ｢PgDn｣,

        # five bytes
        Buf.new(27, 91, 49, 53, 126).decode => ｢F5｣,
        Buf.new(27, 91, 49, 55, 126).decode => ｢F6｣,
        Buf.new(27, 91, 49, 56, 126).decode => ｢F7｣,
        Buf.new(27, 91, 49, 57, 126).decode => ｢F8｣,
        Buf.new(27, 91, 50, 48, 126).decode => ｢F9｣,
        Buf.new(27, 91, 50, 49, 126).decode => ｢F10｣,
        Buf.new(27, 91, 50, 51, 126).decode => ｢F11｣,
        Buf.new(27, 91, 50, 52, 126).decode => ｢F12｣,

        #six bytes
        Buf.new(27, 79, 49, 59, 51, 80).decode => ｢*Alt F1｣, # Needs testing
        Buf.new(27, 79, 49, 59, 51, 81).decode => ｢*Alt F2｣, # Needs testing
        Buf.new(27, 79, 49, 59, 51, 82).decode => ｢*Alt F3｣, # Needs testing
        Buf.new(27, 79, 49, 59, 51, 83).decode => ｢*Alt F4｣, # Needs testing

        Buf.new(27, 91, 49, 59, 51, 65).decode => ｢Alt Up｣,
        Buf.new(27, 91, 49, 59, 51, 66).decode => ｢Alt Down｣,
        Buf.new(27, 91, 49, 59, 51, 67).decode => ｢Alt Right｣,
        Buf.new(27, 91, 49, 59, 51, 68).decode => ｢Alt Left｣,
        Buf.new(27, 91, 49, 59, 51, 69).decode => ｢Alt Center｣,
        Buf.new(27, 91, 49, 59, 51, 70).decode => ｢Alt End｣,
        Buf.new(27, 91, 49, 59, 51, 72).decode => ｢Alt Home｣,
        Buf.new(27, 91, 49, 59, 53, 65).decode => ｢Ctrl Up｣,
        Buf.new(27, 91, 49, 59, 53, 66).decode => ｢Ctrl Down｣,
        Buf.new(27, 91, 49, 59, 53, 67).decode => ｢Ctrl Right｣,
        Buf.new(27, 91, 49, 59, 53, 68).decode => ｢Ctrl Left｣,
        Buf.new(27, 91, 49, 59, 53, 69).decode => ｢Ctrl Center｣,
        Buf.new(27, 91, 49, 59, 53, 70).decode => ｢Ctrl End｣,
        Buf.new(27, 91, 49, 59, 53, 72).decode => ｢Ctrl Home｣,
        Buf.new(27, 91, 49, 59, 53, 80).decode => ｢Ctrl F1｣,
        Buf.new(27, 91, 49, 59, 53, 81).decode => ｢Ctrl F2｣,
        Buf.new(27, 91, 49, 59, 53, 82).decode => ｢Ctrl F3｣,
        Buf.new(27, 91, 49, 59, 53, 83).decode => ｢Ctrl F4｣,
        Buf.new(27, 91, 50, 59, 51, 126).decode => ｢Alt Insert｣,
        Buf.new(27, 91, 51, 59, 51, 126).decode => ｢Alt Del｣,
        Buf.new(27, 91, 51, 59, 53, 126).decode => ｢Ctrl Del｣,
        Buf.new(27, 91, 53, 59, 51, 126).decode => ｢Alt PgUp｣,
        Buf.new(27, 91, 53, 59, 53, 126).decode => ｢Ctrl PgUp｣,
        Buf.new(27, 91, 54, 59, 51, 126).decode => ｢Alt PgDn｣,
        Buf.new(27, 91, 54, 59, 53, 126).decode => ｢Ctrl PgDn｣,

        # seven bytes
        Buf.new(27, 91, 49, 53, 59, 51, 126).decode => ｢Alt F5｣,
        Buf.new(27, 91, 49, 55, 59, 51, 126).decode => ｢Alt F6｣,
        Buf.new(27, 91, 49, 56, 59, 51, 126).decode => ｢Alt F7｣,
        Buf.new(27, 91, 49, 57, 59, 51, 126).decode => ｢Alt F8｣,
        Buf.new(27, 91, 50, 48, 59, 51, 126).decode => ｢Alt F9｣,
        Buf.new(27, 91, 50, 49, 59, 51, 126).decode => ｢Alt F10｣,
        Buf.new(27, 91, 50, 51, 59, 51, 126).decode => ｢Alt F11｣,
        Buf.new(27, 91, 50, 52, 59, 51, 126).decode => ｢Alt F12｣,
        Buf.new(27, 91, 49, 53, 59, 53, 126).decode => ｢Ctrl F5｣,
        Buf.new(27, 91, 49, 55, 59, 53, 126).decode => ｢Ctrl F6｣,
        Buf.new(27, 91, 49, 56, 59, 53, 126).decode => ｢Ctrl F7｣,
        Buf.new(27, 91, 49, 57, 59, 53, 126).decode => ｢Ctrl F8｣,
        Buf.new(27, 91, 50, 48, 59, 53, 126).decode => ｢Ctrl F9｣,
        Buf.new(27, 91, 50, 49, 59, 53, 126).decode => ｢Ctrl F10｣,
        Buf.new(27, 91, 50, 51, 59, 53, 126).decode => ｢Ctrl F11｣,
        Buf.new(27, 91, 50, 52, 59, 53, 126).decode => ｢Ctrl F12｣,
};

    my $done = False;
    my $supply = $supplier.Supply.on-close: { $done = True };

    start {
        with-termios(
            sub {
                until $done {
                    my $ch = read-character;
                    last if $ch ~~ Nil;
                    $supplier.emit($raw ?? $ch !! (%keys{$ch} ?? %keys{$ch} !! $ch.ords ) );
                }
            },
            :$echo
        )
    }
    $supply
}

=begin pod

=head1 NAME

Terminal::ReadKey - Read unbuffered, non-blocking key presses from STDIN.

=head1 SYNOPSIS

=begin code :lang<raku>

use Terminal::ReadKey;

react { whenever key-pressed( :!echo ) { .say } }

=end code

=head1 DESCRIPTION

Terminal::ReadKey makes it easy to get un-buffered, non-blocking key presses
from the keyboard buffer, even multibyte, combination key presses.

=head1 USAGE

Terminal::ReadKey has a few options you can set to modify its behavior.

By default, will echo each keypress to STDOUT. If you would like to suppress
that, pass in the parameter :echo set to a falsey value.

Defaults to returning a string containg the named key press (cooked mode). If
you want the byte values instead, pass in the parameter :raw set to a truthy
value.

When in cooked mode, if there is an unrecognized keypress, returns the byte
string as a list of ordinals instead.


=begin code :lang<raku>

use Terminal::ReadKey;

# cooked mode
react { whenever key-pressed( :!echo ) { .say } }

=end code

or

=begin code :lang<raku>

# raw mode
react { whenever key-pressed( :!echo, :raw ) { .ords.say } }

=end code

=head1 BUGS

There are a few key combinations that I haven't yet been able to capture because
either X11 or the terminal emulator grabs the keypress on my system. If you are
able to capture the keypress byte sequence, send a bug report or pull request to
get it into a future release. Notably missing:

=item Alt F1
=item Alt F2
=item Alt F3
=item Alt F4
=item Ctrl Insert


This was written and tested on a US English keyboard. Characters on non-US
keyboards will likely not have "cooked" mode support. Again, bug reports / pull
requests with the character and keypress byte sequence will likely get added.

At a minimum, give the byte list and character, one per line. EG:

=item (269) => č 



=head1 AUTHOR

Based on Term::ReadKey by jkramer - github.com/jkramer/p6-Term-ReadKey

Modified to recognize multibyte key presses and support "cooked" mode
by Stephen Schulze - aka thundergnat <thundergnat@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Stephen Schulze

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
