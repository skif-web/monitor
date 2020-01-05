#!/bin/bash
RODOS5_6 -r -a|tail -n 1|awk -F= '{print $NF}'|awk -F. '{print $1}'