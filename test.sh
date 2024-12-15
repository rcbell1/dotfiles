#!/bin/bash
echo ${BASH_SOURCE[0]}
echo $(realpath "$(dirname "${BASH_SOURCE[0]}")")
echo $(dirname "${BASH_SOURCE[0]}")
[ -f ~/.bash_profile ]
