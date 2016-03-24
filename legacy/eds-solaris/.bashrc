#!/bin/bash
###############################################################################
#
#  File:       .bashrc
#  Language:   Bash script
#  Time-stamp: <2009-12-01 13:52:45 tzbblg>
#  Platform:   Unix workstation
#  OS:         Unix / Linux / Cygwin / Mac OS X / Solaris
#  Authors:    Michael Lockhart [MJL]
#
#  Rights:     Use this however you like, just don't sue me
#
#  PURPOSE:    Michael's personal Bash RC.
#
#     There are 3 different types of shells in bash: the login shell,
#     normal shell and interactive shell.
#
#     o Login shells will first read /etc/profile and then
#       ~/.bash_profile or ~/.bash_login or ~/.profile (first of these
#       three found wins).
#
#     o Interactive non-login shells read ~/.bashrc but not the
#       others.
#
#     o "normal" shells read whatever the BASH_ENV environment
#       variable tells them to, or nothing if the variable does not
#       exist.
#
#     In our setup, /etc/profile sources ~/.bashrc - thus all settings
#     made here will also take effect in a login shell.
#
#       NOTE: We recommend you make language settings in
#             ~/.bash_profile rather than here, since multilingual X
#             sessions would not work properly if LANG is over-ridden
#             in every subshell.
#
#  HISTORY:
#
# MJL1999 - Created

# MJL20070430 - Re-organised based upon sample .bashrc for SuSE Linux
#             - Generified for different OS platforms, then put
#               specifics into a case statement based on TERM type -
#               Placed into source control finally.
# MJL20070509 - Moved utility scripts into this file, under Functions.
#             - Moved functions into their own dotfile, similar to .alias
# MJL20071214 - Playing with prompts
# MJL20080123 - Explicitely pick the default Java version for cygwin (Tiger)
# MJL20080407 - Minor spacing fix to shell prompts for linux and xterm consoles
# MJL20080415 - Remove cruft, override default editor based on term type
# MJL20080507 - removed backtik inline commands, using $() instead
#               (use of backtiks in bash is deprecated)
# MJL20080626 - Changed prompts for Linux, Cygwin and xterm to include
#               traditional hostname before the prompt end
# MJL20080903 - Remove generic EDITOR setting, make it OS-dependant
#             - Replace my old test -s "x$BLAH" = "x" idiom...
#             - Add a step to load system local settings from separate file
# MJL20080904 - Added default 'edit' alias (system dependant...)
#             - Load LSCOLORS from ~/.dircolors, if present
# MJL20080905 - Fix $HOME expansion
# MJL20080908 - Use bash [[ compound expression for tests
# MJL20080915 - Still more shell style / syntax clean-ups!
# MJL20080930 - Solaris customisations and fixes, swap order of OS and Term
# MJL20081205 - Changed prompt for xterm and konsole, to put the hostname
#               *first*  in the title-bar. Makes visual ID easier for 
#               multiple hosts on a single X terminal
# MJL20090313 - added  Sun FreeWare and C Compiler Suite to PATH in Solaris
# MJL20091201 - TRAMP-safe shell prompts
#

### Bash shell options
#on (by default)
shopt -s cmdhist expand_aliases extquote force_fignore hostcomplete \
    interactive_comments progcomp promptvars sourcepath
#on 
shopt -s cdspell extglob histappend histreedit histverify xpg_echo
#off

### Variables:

# make sure "less" is "more", and draw the control-chars, 
# rather than ^ESC...
export PAGER="less -r"

# ignore backup and working files in TAB-key filename completion:
export FIGNORE='~:#'

# History
set -o history

export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S%z "
unset HISTFILESIZE

# Temporary files (in own directory under /tmp if one exists)
if [[ -z $TMP ]] ; then
    if [[ -d /tmp/$USER ]] ; then
	export TMP=/tmp/"$USER"
    else
	export TMP=/tmp
    fi
fi

# Some programs look for $TEMP instead of $TMP...
export TEMP="$TMP"


# Source Aliases from a separate file
if [[ -s $HOME/.alias ]]; then
    source "$HOME"/.alias
fi

# Source Functions from a separate file
if [[ -s $HOME/.function ]]; then
    source "$HOME"/.function
fi

# Source local system settings
# (e.g. Oracle setups or other application settings)
if [[ -s $HOME/.localrc ]]; then
    source "$HOME"/.localrc
fi

# Set LSCOLORS if custom settings exist and haven't already been set
if [[ -s $HOME/.dircolors && -z $LS_COLORS ]] ; then
    eval $(dircolors --sh "$HOME"/.dircolors)
    export LS_COLORS
fi



### OS specific customisations
case $(uname) in
    CYGWIN*)
        # Save path without JAVA (if we haven't already done so)
        test -z "$X_PATH_NO_JAVA" && export X_PATH_NO_JAVA="$PATH"
        # Set up Java switching function and run it (if it exists in file)
        if [[ -s $HOME/.JVersion ]] ; then
	    source "$HOME"/.JVersion && JVersion Mustang > /dev/null
	fi
        export CDPATH=:"$HOME":/cygdrive:/drv
	alias ls='ls --color=auto --show-control-chars'
        umask 002
        ;;
    Linux)
        export CDPATH=:"$HOME":/media:/mnt
        alias ls='ls --color=auto --show-control-chars'
        ;;
    SunOS)
        alias ping='/usr/sbin/ping -vI 1'  # Solaris' ping is strange...
        export CDPATH=:"$HOME":/opt:/export
	export PATH="$PATH":/usr/sfw:/usr/ccs/bin
	export EDITOR=vi
	alias edit=vi
        stty erase 
        ;;
    *)
        export CDPATH=:"$HOME"
	export EDITOR=vi   # I guess...?
	alias edit=vi
        ;;
esac


### Set shell environment according to terminal capabilities
case $TERM in
    dumb)
        PS1='\h$> '
	unalias ls; alias ls='ls -Fh'
	unset LS_COLORS
	alias d='d --colorize=false'
	export EDITOR="vi"
	alias edit='vi'
        ;;
    cygwin)
        PS1='\[\e]0;\w\a\]'
	PS1=${PS1}'\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\h\$ '
	export EDITOR=/usr/bin/mcedit
	alias edit='/usr/bin/mcedit'
        stty erase 
	shopt -s checkwinsize
        ;;
    linux)
	PS1='\D{%Y%m%d}-\A\h[\W]\$ '
	export EDITOR=/usr/bin/mcedit
	alias edit='/usr/bin/mcedit'
        ;;
    xterm | konsole)
        PS1='\[\e]0;[\u@\h] \w (\D{%Y%m%d}-\A)\a\]'
	PS1=${PS1}'\[\e[1;36m\][\W]\[\e[1;34m\]\h\[\e[0m\]\$ '
        stty erase 
	export EDITOR="emacsclient --alternate-editor emacs +%d %s"
	alias edit='emacsclient -n -a emacs'
	shopt -s checkwinsize
        ;;
    eterm-color)
	PS1='\[\e[1;37m\][\W]\[\e[1;33m\]\h\[\e[0m\]\$ '
	export EDITOR="emacsclient"
	alias edit='emacsclient -n '
	shopt -s checkwinsize
        ;;
    *)
	# Don't know what it is, be conservative
        PS1='\w\n\h\$ '
	unalias ls; alias ls='ls -Fh'
	unset LS_COLORS
	alias d='d --colorize=false'
	export EDITOR=vi
	alias edit=vi
        stty erase 
       ;;
esac
