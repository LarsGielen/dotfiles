#!/bin/bash

killall -9 swaync
killall -9 waybar

uwsm app -s b -- swaync
uwsm app -s b -- waybar
