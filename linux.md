God bless you are not on macOS side.

# input remapping
So for input remapping on kernel lever you
can use keyd daemon. Amazing and simple
thing. Example `/etc/keyd/default.conf`
file:

    [ids]
    *

    [main]

    capslock = esc
    esc = capslock

To emulate ANSI keyboard on ISO you can use
this config:

    [ids]
    *

    [main]
    \ = enter
    enter = \
    102nd = leftshift

102nd is the right part of left shift that
has been split. To get key code for your
keys use `keyd monitor` command.

