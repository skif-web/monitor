#!/bin/bash
data_file=/tmp/rodos_current_temp
RODOS5_6 -r -a|tail -n 1|awk -F= '{print $NF}' > $data_file || echo "error" > $data_file