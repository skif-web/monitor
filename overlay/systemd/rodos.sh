#!/bin/bash

##################################################
#
# description: get temp from RODOS5_6 usb thermometer
# params: not avaible
#
##################################################

RODOS5_6 -r -a|tail -n 1|awk -F= '{print $NF}'|awk -F. '{print $1}'