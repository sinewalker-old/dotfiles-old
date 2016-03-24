#/bin/bash
################################################################################
#
#   File:       .bashrc
#   Created:    2013-10-24
#   Language:   Shell-script
#   Time-stamp: <2016-01-08 12:19:23 mjl>
#   Platform:   openSUSE
#   OS:         Linux
#   Author:     [MJL] Michael J. Lockhart (mlockhart@squiz.net)
#
#   Rights:     Copyright © 2014, 2015, 2016 Michael James Lockhart, B.App.Comp(HONS)
#
#   PURPOSE:    Personal shell configuration (squiz)
#
#       Originally I meant this to be a quick-and-dirty setup until I
#       could migrate my more elaborate setup from my home machine
#       (once that was taken out of Storage).  I've since learnt a lot
#       on the job here and my original setup could probably stand to
#       be based upon this instead.
#
#   HISTORY
#
#   MJL20131024 - Created
#   MJL20140909 - comments added
#   MJL20150316 - GOPATH
#   MJL20150417 - analyse web server with goaccess
#   MJL20160108 - add '.' to the end of $PATH
#

function source_if() {
# source a file only if it's readable
  for f in ${@}; do
    test -r ${f} && source ${f}
  done
}

source_if /etc/skel/.bashrc

export HISTCONTROL=histappend:ignoreboth #prepend command with space
                                         #to ignore it in history

export CDPATH=.:~:~/Squiz:~/Squiz/svn:~/Squiz/git:~/Documents:~/Projects:~/hax
export PATH=${PATH}:/sbin:/usr/sbin:${HOME}/bin:${HOME}/.local/bin
export PATH=${PATH}:${HOME}/.rvm/bin:${HOME}/Squiz/bin # Add RVM and Squiz to PATH for scripting

export GOPATH=${HOME}/go
export PATH=${PATH}:${GOPATH}/bin

#this should be last of all
export PATH=${PATH}:.

export EDITOR="emacsclient -a emacs"
export VISUAL="emacsclient -a emacs"
export PLAYER=clementine
export VIEWER=display
export BROWSER=firefox


#Python virtual environments
export WORKON_HOME=${HOME}/lib/venv
source_if /usr/bin/virtualenvwrapper.sh

#nice commands
alias que=${PLAYER}
alias view=${VIEWER}
alias web=${BROWSER}
alias whence="type -a"

#editing
alias ec="emacsclient -c -n -a emacs"
alias et="emacsclient -t -a emacs"
[[ -z $DISPLAY ]] && alias ed=et || alias ed=ec
alias eb='ed -e "(switch-to-buffer \"*Bookmark List*\")"'
alias vi=ed

alias ifrit="emacs --daemon&&ed"
alias bannish="emacsclient -e '(mjl/client-save-kill-emacs)'"

#play sounds
alias dsp="aplay -c 2 -f S16_LE -r 44100"  # plays stdin assuming
                                # stereo signed 16-bit LE at 44.1kHz

alias gdpush='drive push -ignore-conflict'
alias gdpull='drive pull -ignore-conflict'

#the keyboard/mouse hooked into the USB hub on this Dell keep needing to be reset...
alias console="~/bin/orbit;  ~/bin/dellkb; ~/bin/dellmon"
alias term="~/bin/orbit; ~/bin/dellkb"
alias crt="~/bin/dellmon"
alias kb="~/bin/dellkb"

#doo eet
alias fuck='sudo $(history -p \!\!)'
alias sammich='sudo $(history -p \!\!)'
alias whoops='history -d $(($HISTCMD-1))'
alias please=sudo

alias traceroute=tracepath
alias tracert=tracepath

#terminals
alias kons="konsole --profile $1 2> /dev/null"
alias kons-show="konsole --list-profiles"
alias root="konsole --profile 'Root Shell'"

#squizisms

alias squizup='pushd ~/Squiz/svn; ./update; popd'
alias squizwords='gpg -d ~/Squiz/svn/sysadmin/support-passwords.txt.gpg|less'
alias edpass='pushd ~/Squiz/svn/sysadmin; svn up; ed support-passwords.txt.gpg; popd'

#bounce to the UK
alias bounce="ssh bounce.squiz.co.uk -lmlockhart -o ForwardAagent=yes"

#better rdesktop experience for Squiz (uploads from \\tsclient\upload)
# (see https://opswiki.squiz.net/Clients/CSU ):
alias rdp="rdesktop -g 1200x800 -a 15 -z -x b -P -r disk:upload=${HOME}/Uploads -rclipboard:PRIMARYCLIPBOARD"

# reset control masters for SSH (when I forget to add -A...)
alias ssh-reset='rm -f ~/.ssh/master*'

function ssh-find() {
    for PATTERN in $*; do
         grep -i ${PATTERN} ~/.ssh/config || echo "${PATTERN}: not in config"
    done
}

function zyp() {
# if you're not root, run zypper without refresh so it sort-of works
  [[ ${UID} -ne 0 ]] && zypper --no-refresh $* || zypper $*
}

function sam() {
#Smoke and Mirrors - move a file, link to where it was
    mv ${1} ${2} && ln -s ${2}/$(basename ${1}) ${1}
}


#khelpcenter shortcuts for graphical manual/info/help viewer
function kman() {
  khelpcenter man:/${@} 2> /dev/null
}

function kinfo() {
  khelpcenter info:/${@} 2> /dev/null
}

function khelp() {
  khelpcenter help:/${@} 2> /dev/null
}

# Open specified DIR in emacs' dired (or CWD)
function edir() {
  DIR=${1}
  [[ -z ${DIR} ]] && DIR=$(pwd)
  [[ -d ${DIR} ]] && emacsclient -n -e '(dired "'${DIR}'")' > /dev/null
}

# Convert a BST time into local (not working)
function pingdate() {
    date -d "$(date -d "$1 BST" -u)"
}

function analyse-web() {
    #runs a real-time analysis on a web server's access logs
    #requires goaccess -  http://goaccess.io/
    #
    #Params:  $1:  server name (you must be able to read the web logs on this server)
    #         $2:  path to the access log on the server (default /var/log/openresty/access.log)
    #         $3:  (optional) if set, remove the local log copy after quitting
    [[ -z ${1} ]] && exit
    SERVER=${1}
    LOG=${2}
    [[ -z ${LOG} ]] && LOG=/var/log/openresty/access.log
    LOCAL=$(mktemp -t "analysis-XXX")
    echo "Tailing to ${LOCAL}..."
    ssh ${SERVER} "tail -f ${LOG}" > ${LOCAL} &
    LOGGER=$!
    sleep 3
    [[ -s ${LOCAL} ]] && goaccess -f ${LOCAL} -a
    kill $LOGGER
    [[ -z ${3} ]] || (rm ${LOCAL}; echo "${LOCAL} removed")
}


#session recording
SESSION_DIRECTORY=~/hax/sessions

function _set_sdir() {
    # function helper (DRY).  It checks for $SESSION_DIRECTORY
    # and uses that if set, or ~/hax/sessions if not.

    SDIR=; [[ -z ${SESSION_DIRECTORY} ]] &&
        SDIR=${HOME}/hax/sessions || SDIR=${SESSION_DIRECTORY}
}

function _list_avail_sessions() {
    # function helper (DRY). lists all the session files
    # in $SDIR. TODO: include the date/time in output

    echo "specify a session name:"
    for x in ${SDIR}/*.trans; do
        basename ${x} |sed 's/.trans//'
    done
}


function session() {
    #runs script, saving transcript and timing files to the specified
    #file pair.  e.g. session zen12345 will create a zen12345.trans
    #and zen12345.time in the ${SESSION_DIRECTORY} directory.
    #
    # can be played back with
    # scriptreplay -t zen12345.time zen12345.trans
    [[ -z ${1} ]] && echo "specify a session name" && return
    _set_sdir
    
    SESSION=${1}; shift
    [[ -e ${SDIR} ]] || mkdir -p ${SDIR}
    echo ${COLUMNS} ${LINES} > ${SDIR}/${SESSION}.dims
    script -a --timing=${SDIR}/${SESSION}.time ${SDIR}/${SESSION}.trans ${@}
}

function replay() {
    #Replays a session recorded with the session function
    #Just a nice convinience. You can use scriptreplay directly
    #
    # Optional 2nd+ params are more arguments to scriptreplay,
    # such as the playback divisor
    #
    _set_sdir
    [[ -z ${1} ]] && _list_avail_sessions && return

    SESSION=${1}; shift
    DIMSTR=; [[ -e ${SDIR}/${SESSION}.dims ]] &&
        read SCOLS SLINES < ${SDIR}/${SESSION}.dims &&
        DIMSTR="(dimensions: ${SCOLS} cols X ${SLINES} lines) "
    echo "***** REPLAYING SESSION ${SESSION} $DIMSTR*****"
    echo
    scriptreplay --timing=${SDIR}/${SESSION}.time ${SDIR}/${SESSION}.trans ${@}
    echo
    echo "***** FINISHED SESSION REPLAY *****"
}

function pack() {
    #Prepairs a session for attaching to a ticket. Requires a player
    #script, assumes it's there and called "player"
    _set_sdir
    [[ -z ${1} ]] && _list_avail_sessions && return

    SESSION=${1}
    pushd ${SDIR} > /dev/null
    tar czf ${SDIR}/${SESSION}.tar.gz player ${SESSION}.!(tar.gz)* &&
        echo "packed session '${SESSION}' to ${SDIR}/${SESSION}.tar.gz"
    popd > /dev/null
}

function cleanup() {
    #remove session transcript/timing/dimensions files

    _set_sdir
    [[ -z ${1} ]] && _list_avail_sessions && return
    
    rm -f ${SDIR}/${1}.!(tar.gz)
}

### for CI

ssh_host()
{
        VZ_GUEST=$1

        if [ $# -lt 1 ]; then
                echo "Syntax: ssh_host <vz_guest>"
                return 0
        fi

        ssh -t `host -t txt $VZ_GUEST.syd.ipowered.com.au | cut -d \" -f 2`
}
ssh_guest()
{
        VZ_GUEST=$1
        SITE=$2

        if [ $# -lt 1 ]; then
                echo "Syntax: ssh_guest <vz_guest> [site_name]"
                return 0
        fi

        ssh -t `host -t txt $VZ_GUEST.syd.ipowered.com.au | cut -d \" -f 2` "/bin/bash --login -c 'enter_host $VZ_GUEST $SITE'"
}
ssh_site()
{
        SITE=$1

        if [ $# -lt 1 ]; then
                echo "Syntax: ssh_site <site_name>"
                retu
rn 0
        fi

        VZ_GUEST=$(host -t a $SITE.insightfulcrm.com | tail -n 1 | awk '{print $1}' | cut -d '.' -f 1)

        if [ "$VZ_GUEST" != "$SITE" ]; then
                ssh -t `host -t txt $VZ_GUEST.syd.ipowered.com.au | cut -d \" -f 2` "/bin/bash --login -c 'enter_host $VZ_GUEST $SITE'"
        else
                echo "Site $SITE does not exist!"
                return 1
        fi
}
