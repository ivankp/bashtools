#!/bin/bash

# bashtools: tools for me (or you I GUESS) to use with Bash.
# Copyright (C) 2017  Sam Marinelli
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Address correspondence about this program to samuelmarinelli@gmail.com.

export PS1="\[$(tput setaf 3)\]\h\$\[$(tput sgr0)\] "

export GIT_EDITOR=nano

export MSU=marinellis@hx10.pa.msu.edu:/work/raida/marinellis
export UMD=samm@pa-pub.umd.edu:/data/scratch/userspace/samm

for command in grep fgrep ls
do alias "$command=$command --color=auto"
done

function quiet {
    "$@" &> /dev/null &
}

for command in eZuceSRN firefox
do alias "$command=quiet $command"
done

for command in df du
do alias "$command=$command -h"
done

alias "rm=rm -i"

alias "time=/usr/bin/time -v"

alias "make=make -j$(fgrep processor /proc/cpuinfo | wc -l)"

alias "root=root -l"

alias "i3lock=i3lock -c 000000"

alias "deepin-screenshot=deepin-screenshot -d 2 -f -s"

alias "untar=tar -xvf"

function err {
    echo "$@" 1>&2
}

function backup {

    src_dir="$1"
    target_dir="$2"

    if [ ! -d "$target_dir" ]
    then
        echo "Cannot find directory '$target_dir'.  Perhaps the drive is" \
            "not mounted."
        return 1
    fi

    rsync --delete --progress -r -L "$src_dir"/* "$target_dir"

}

function cs {

    dir="${1-$H2}"
    if ! [ "$dir" ]
    then dir=~
    fi

    cd "$dir"
    ls

}

function up {

    for ((i = 0; i < ${1-1}; ++i))
    do cd ..
    done
    ls

}

function op {

    exe=(evince mirage ffplay libreoffice gedit)
    extension=("pdf" "jpg|png" "mkv|wav" "docx|xlsx" ".*")

    files=("$@")

    for ((i = 0; i < ${#exe[@]}; ++i))
    do
    
        matched=()
        unmatched=()
        
        for file in "${files[@]}"
        do
            if [[ "${file##*.}" =~ ${extension[i]} ]]
            then matched+=("$file")
            else unmatched+=("$file")
            fi
        done
        
        if [ ${#matched[@]} -gt 0 ]
        then quiet ${exe[i]} "${matched[@]}"
        fi
        
        files=("${unmatched[@]}")
    
    done

}

function li {

    name="$1"

    for tuple in "marinellis hx10    .pa.msu.edu"         \
                 "samm       pa-pub  .umd.edu"            \
                 "samm       sequoia .private.pa.umd.edu"
    do
        arr=($tuple)
        if [ "$name" == ${arr[1]} ]
        then
            ssh -Y ${arr[0]}@${arr[1]}${arr[2]}
            return 0
        fi
    done
    
    err "Unrecognized host '$name'."
    return 1

}

function pdf {

    for file in "$@"
    do
        for i in {1..2}
        do
            if ! pdflatex -shell-escape -halt-on-error $file
            then return 1
            fi
        done
    done

}

function prepend {

    var="$1"
    paths="$2"
    
    export "$var=$paths:${!var}"

}
