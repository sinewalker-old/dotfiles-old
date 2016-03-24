#!/bin/env python
###############################################################################
#
#  File:       hacksmf.py
#  Language:   Python 2.4
#  Time-stamp: <2009-12-31 08:38:28 tzbblg>
#  Platform:   AGOSP server with Sun Solaris Service Manamegent Framework
#  OS:         Sun Solaris 10
#  Authors:    [MJL]  Michael Lockhart (EDS)  michael.lockhart@hp.com
#
#  Rights:     COPYRIGHT (c) 2009 HP DEVELOPMENT CORPORATION.
#              ALL RIGHTS RESERVED.
#
#  PURPOSE:    AGOSP SMF properties hack
#
#  This is a wrapper for SMF utilities to export/import SMF manifest
#  files. It may be used for bulk editing of SMF properties by
#  exporting to XML, editing with an editor or sed script, and then
#  importing.
#
#  HISTORY
#
# MJL20091229 - Created
# MJL20091230 - modularised, fixed exit codes, just export/import
#

import os, sys, optparse, re


def shell_out(command):
    """
    Executes the specified system command, or prints it out if
debugging.

Params:  command:  the operating system command to execute
Globals: g_opts.debugging: if True, will print instead of execute
    """

    if g_opts.debugging:
        print command
    else:
        os.system (command)



def parse_svccfg_output(ln):
    """
    Parses the output from svccfg list

Parameters:
    ln:  a single line from svccfg list, containing an FMRI for a service

Returns:
   a tuple of two strings (a,b):
    a:  == ln with the carriage return character removed
    b:  a string of the FMRI with / chars replaced, and with ".xml" appended
    """
    line = ln[:-1]
    return (line, line.replace('/','__') + '.xml')



def export_command(pattern):
    """
    Uses svccfg utility to export service manifests whos FMRIs match a pattern

Params:
    pattern:  a pattern to match (svccfg does the match)
    """
    if g_opts.debugging:
        print 'entered export_command. pattern = ' + pattern
    for line in os.popen('svccfg list ' + pattern).readlines():
        (fmri,export_file) = parse_svccfg_output(line)
        shell_out('svccfg export ' + fmri + ' > ' + export_file)



def import_command(pattern):
    """
    Uses svcadm and svccfg utilities to import a service from a
manifest file.  Service is assumed to exist already and is running, so
it is first disabled(stopped) and deleted.  After import, the service
is enabled (started).

    No error checking is performed on the calls to svcadm or svccfg
utilities

Params:
    pattern: a pattern to match (svccfg does the match)
    """
    if g_opts.debugging:
        print 'entered import_command. pattern = ' + pattern
    for line in os.popen('svccfg list ' + pattern).readlines():
        (fmri,import_file) = parse_svccfg_output(line)
        shell_out('svcadm disable ' + fmri)
        shell_out('svccfg delete ' + fmri)
        shell_out('svccfg import ' + import_file)
        shell_out('svcadm enable ' + fmri)



def parse_args():
    """
    Sets up an OptionParser with options for this script, then uses it
to parse the command-line arguments and options.

Returns: a tuple of the options, positional args, and the parser used:
         (dictionary, list, OptionParser)
    """
    parser = optparse.OptionParser (version = '%prog 0.0'
                                    , usage = 'Usage: %prog <command> [options]'
                                    , description = 'AGOSP hack for bulk edits of SMF manifests.'
                                    + ' COPYRIGHT (C) 2009, HP DEVELOPMENT CORP.  ALL RIGHTS RESERVED.')
    parser.add_option('-d', '--debug'
                      , default = False, action = 'store_true'
                      , dest = 'debugging'
                      , help = 'show what would be executed, but do not execute')

    parser.add_option('-p', '--pattern'
                      , default = ''
                      , dest = 'fmri_pattern'
                      , help = 'FMRI pattern to operate on')
#    parser.add_option('-v','--value', default = 'solaris.smf.value.agosp', dest = 'smf_value_property'
#                      , help = 'Auth string for VALUE delegation')
#    parser.add_option('-a','--alter', default = 'solaris.smf.manage.agosp', dest = 'smf_alter_property' 
#                      , help = 'Auth string for ALTER delegation')

    (opts,args) = parser.parse_args()
    return (opts, args, parser)



def list_commands():
    """
    Prints a list of commands supported by the script
    """
    g_parser.print_help()
    print 'commands:'
    print '  e|export \t\texport SMF manifests to XML files'
    print '  i|import \t\timport SMF manifests from XML files'
    print
    print 'Notes:'
    print '\t* You must specify an FMRI_PATTERN with -p or --pattern option'
    print '\t* use "export" command to export FMRIs matching FRMI_PATTERN to files'
    print '\t* use "import" command to import files. The import command will'
    print '\t  disable, delete and then import and enable an FMRI service'
    print '\t* you need ROOT privileges for the import command to succeed'



def main():
    """
Params:  none
Globals: g_opts:   optparse.Options object containing command-line options
         g_args:   list of command-line positional arguments
         g_parser: OptionParser object, for printing help messages
Returns: an integer to use as the script's exit code
    """
    if '' == g_opts.fmri_pattern or 0 == len(g_args):
        list_commands()
        return 1

    command = g_args[0]
    pattern = '\*' + g_opts.fmri_pattern + '\*'

    if command in ('export','e'):
        export_command(pattern)

    if command in ('import','i'):
        import_command(pattern)

    return 0


####
if __name__ == '__main__':
    (g_opts, g_args, g_parser) = parse_args()
    sys.exit(main())
