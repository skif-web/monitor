#!/bin/bash
data_file="/tmp/rodos_current_temp"
RODOS5_6 -r -a|tail -n 1|awk -F= '{print $NF}'|awk -F. '{print $1}' > $data_file
