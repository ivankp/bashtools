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

if [[ "$-" =~ .*i.* ]]
then export PS1="\[$(tput setaf 3)\]\h\$\[$(tput sgr0)\] "
fi

export GIT_EDITOR=nano

export MSU=marinellis@hx10.pa.msu.edu:/work/raida/marinellis
export UMD=samm@pa-pub.umd.edu:/data/scratch/userspace/samm
export SVN=https://private.hawc-observatory.org/svn/hawc

for command in grep egrep fgrep ls
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

alias "valgrind=valgrind --leak-check=yes"

function err {
    echo "$@" 1>&2
}

function backup {

    local src_dir="$1"
    local target_dir="$2"

    if [ ! -d "$target_dir" ]
    then
        echo "Cannot find directory '$target_dir'.  Perhaps the drive is" \
            "not mounted."
        return 1
    fi

    rsync --delete --progress -r -L "$src_dir"/* "$target_dir"

}

function cs {

    local dir="${1-$H2}"
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

    local exe=(evince mirage ffplay libreoffice gedit)
    local extension=("pdf" "jpg|png" "mkv|wav" "docx|xlsx" ".*")

    local files=("$@")

    for ((i = 0; i < ${#exe[@]}; ++i))
    do
    
        local matched=()
        local unmatched=()
        
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
        
        local files=("${unmatched[@]}")
    
    done

}

function li {

    local name="$1"

    for tuple in "marinellis h"{x,t}{1..30}" .pa.msu.edu"         \
                 "samm       pa-pub          .umd.edu"            \
                 "samm       sequoia         .private.pa.umd.edu" \
                 "samm       mckenzie        .private.pa.umd.edu"
    do
        local arr=($tuple)
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
            if ! pdflatex -shell-escape -halt-on-error "$file"
            then return 1
            fi
        done
    done

}

function prepend {

    local var="$1"
    shift
    
    local prefix=
    for file in "$@"
    do prefix+="$file:"
    done
    
    export "$var=$prefix${!var}"

}

function join_with {

    local IFS="$1"
    shift
    echo "$*"

}
