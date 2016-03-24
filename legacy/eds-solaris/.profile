#!/bin/sh
###############################################################################
#
#  File:       .profile
#  Language:   Shell script
#  Time-stamp: <2008-09-08 05:56:01 tzbblg>
#  Platform:   Unix workstation
#  OS:         Unix / Linux / Cygwin / Mac OS X / Solaris
#  Authors:    Michael Lockhart [MJL]
#
#  Rights:     Use this however you like, just don't sue me
#
#  PURPOSE:    Replace user's default login shell with bash
#
#     There are 3 different types of shells in bash: the login shell,
#     normal shell and interactive shell. There are also different
#     kinds of shell besides bash, such as sh (the original Borne
#     shell), ksh (korn shell) csh (C shell) and others.
#
#     This with my .bash_profile installed, this .profile will only be
#     executed by non-bash shells. It start's bash as the alternate
#     login shell (use in situations where you can't select your
#     default login shell).
#
#  HISTORY
#
#  MJL20080905 - Created.
#  MJL20080908 - exec bash --login   (duh!)
#  MJL20081216 - fix bug in type redirection
#

echo "Replacing login shell with bash..."
type bash > /dev/null 2>&1 \
    && exec bash --login \
    || echo "bash not found on this system!"


# No bash (!) So continue with whatever environment was set up for you
# by the sysadmin...

if [ -f "$HOME"/.localrc ] ; then
    echo "Continuing with original local settings..."
    . "$HOME"/.localrc
else
    echo "Warning: could not find local settings RC:"
    echo "$HOME/.localrc"
fi

