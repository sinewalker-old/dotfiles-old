#!/bin/bash
###############################################################################
#
#  File:       .bash_profile
#  Language:   Bash script
#  Time-stamp: <2009-03-13 09:39:49 tzbblg>
#  Platform:   Unix workstation
#  OS:         Unix / Linux / Cygwin / Mac OS X / Solaris
#  Authors:    Michael Lockhart [MJL]
#
#  Rights:     Use this however you like, just don't sue me
#
#  PURPOSE:    executed by bash for login shells
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
#     made there will also take effect in a login shell.
#
#     This profile sources global settings, bash settings and then
#     sets some path variables and tells a fortune.  Setting the paths
#     here avoids creating redundant path lists when running
#     interactive shells or sub-shells.
#
#  HISTORY
#
# MJL20070431 - Made cross-platform, so that I can just copy it wherever 
#               without porting
# MJL20070504 - Fixed the CLASSPATH under Cygwin 
#               (forgot that java is a non-cygwin prog)
# MJL20070911 - Add JAR files to the CLASSPATH, all platforms
#               (JARs will live along side classes in ~/lib/java)
# MJL20070912 - Made the test for presence of fortune not rely on install path
#             - removed backtik inline commands, using $() instead
#               (use of backtiks in bash is deprecated)
# MJL20080903 - Java CLASSPATH: can't use wildcards, removed
# MJL20080905 - Fix HOME expansion
# MJL20080908 - Use bash [[ compound expression for tests
# MJL20090220 - CLASSPATH: add personal JAR library to the path
#             - in Cygwin don't mung the CLASSPATH, it's already okay
#             - added uname -a to sign-on banner
# MJL20090310 - cryptic/yoda error for missing fortune toy
# MJL20090313 - add /usr/local/bin to PATH
#


# Source global settings
if [[ -e /etc/bash.bashrc ]] ; then
  source /etc/bash.bashrc
fi

# If user's customised settings exist, then source them
if [[ -e $HOME/.bashrc ]] ; then
  source "$HOME"/.bashrc
fi

PATH="$PATH":/usr/local/bin
#Set PATH so it includes user's private bin if it exists
if [[ -d $HOME/bin ]] ; then
  PATH="$HOME"/bin:"$PATH":.
fi


#Set MANPATH so it includes users' private man if it exists
if [[ -d $HOME/man ]]; then
  MANPATH="$HOME"/man:"$MANPATH"
fi

#Set INFOPATH so it includes users' private info if it exists
if [[ -d $HOME/info ]]; then
  INFOPATH="$HOME"/info:"$INFOPATH"
fi

#Set CLASSPATH so it includes users' private java libraries if they exist
if [[ -d $HOME/lib/java ]]; then
  # JARs must be included individually
  for JAR in ~/lib/java/*.jar; do
    test -f "$JAR" && JARPATH="$JARPATH:$JAR"
  done

  if [[ 'Cygwin' == $(uname -o) ]]; then
  # In Cygwin, we must use Windows-style path lists for Java
    JARPATH=$(cygpath -wp "$JARPATH")
    CLASSPATH=".;"$(cygpath -w "$HOME/lib/java")";$JARPATH;$CLASSPATH"
  else
    CLASSPATH=".:$HOME/lib/java:$JARPATH:$CLASSPATH"
  fi
  unset JARPATH
fi

# Sign-on banner, Tell a fortune at login time
uname -a; echo 
type fortune &> /dev/null && fortune || echo "Difficult to see, the future is."

#Avoid delays
unset MAILCHECK

