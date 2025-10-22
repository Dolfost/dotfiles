God bless you are not on macOS side.

# Input
# keyd
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

## Lofree Flow Lite use FN keys over media keys
To use FN keys over media keys on lofree flow lite 100 execute 

    echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/20_lofree_fn_mode_fix.conf

and reboot.
