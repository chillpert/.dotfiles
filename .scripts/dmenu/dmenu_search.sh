#!/bin/bash

term=$(printf '' | dmenu -nf '#FFFFFF' -sb '#af87ff' -sf '#FFFFFF' -nb '#262626' -i -fn 'VL PGothic-11.5' -p 'Search the web:') "$@" || exit

term=${term//[ ]/+}

firefox https://www.startpage.com/sp/search?query=$term https://lite.qwant.com/?q=$term https://searx.be/search?q=$term
