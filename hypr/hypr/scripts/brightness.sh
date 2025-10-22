#!/bin/sh 

USAGE=$(cat << EOF
Change screen brightness. Avaliable commands:
  max                set screen brightness to maximum
  min                set screen brightness to minimux
  small-dec          decrease brightness by small step
  samll-inc          increase brightness by small step
  dec                decrease brightness by step
  inc                increase brightness by step
  big-dec            decrease brightness by big step
  big-inc            increase brightness by big step
  large-dec          decrease brightness by big step
  large-inc          increase brightness by big step
	help               print this message
EOF
)

# config
min_brightness=0
max_brightness=100
small_step=1
step=5
big_step=10
large_step=10
bus=8

cmd="ddcutil --noverify --sleep-multiplier .1 --bus $bus"
cmd_get="$cmd getvcp 0x10 -t"
cmd_set="$cmd setvcp 0x10"

case $1 in
	max)
		$cmd_set $max_brightness
		;;
	min)
		$cmd_set $min_brightness
		;;
	small-inc)
		$cmd_set + $small_step
		;;
	small-dec)
		$cmd_set - $small_step
		;;
	inc)
		$cmd_set + $step
		;;
	dec)
		$cmd_set - $step
		;;
	big-inc)
		$cmd_set + $big_step
		;;
	big-dec)
		$cmd_set - $big_step
		;;
	large-inc)
		$cmd_set + $large_step
		;;
	large-dec)
		$cmd_set - $large_step
		;;
	help | -h | --help)
		echo -e $USAGE
		;;
	*)
		echo "No action specified. "
		exit 1
		;;
esac

notify-send -u low -a ddcutil -h int:value:$($cmd_get | awk '{print $4}') -r 7423790 '󰃝  Brightness'
