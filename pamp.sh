#!/bin/sh

dir=$(realpath "$0")
dir=$(dirname "$dir")

"$dir/pamp" --FONTALIAS=stf_default,Oxanium,13 "$@"
