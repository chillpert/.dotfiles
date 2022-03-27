#!/bin/bash

term=$(printf '' | dmenu -i -fn 'VL PGothic-11.5' -p 'Translate (EN/DE):') "$@" || exit

term=${term//[ ]/+}

firefox https://www.dict.cc/?s=$term
