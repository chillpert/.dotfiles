#!/bin/bash

term=$(printf '' | dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -p 'Translate (EN/DE):') "$@" || exit

term=${term//[ ]/+}

firefox https://www.dict.cc/?s=$term
