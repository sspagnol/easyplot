#!/usr/bin/python

import os
import sys
import time
import shutil

# buildBinaries.py
# Exports easyplot from AIMS gitlab and
#
#   - Runs Util/imosCompile.m to create an easyplot executable
# 
# Both of these files are copied to the relevant directory and commited to SVN.
#
# python, git, javac, ant and matlab must be on PATH
# JAVA_HOME must be set
#

lt = time.localtime()
# http://gitlab.aims.gov.au/ogtech/easyplot.git
project = 'easyplot'

# version    = 'master'
version    = 'main_function_cleanup'

url        = ' http://gitlab.aims.gov.au/ogtech/%s.git' % project
exportDir  = 'export'

compilerLog = '.\%s\log.txt' % exportDir

#
# clone from git
#
print('\n--exporting tree from %s to %s' % (url, exportDir))
os.system('git clone %s %s' % (url, exportDir))
os.system('cd %s && git checkout %s' % (exportDir, version))
os.system('git status')


# remove snapshot directory
#
print('\n--removing snapshot')
shutil.rmtree('%s/snapshot' % exportDir)


# build DDB interface
#
#print('\n--building DDB interface')
#compiled = os.system('cd %s/Java && ant install' % exportDir)

# if compiled is not 0:
#  print('\n--DDB interface compilation failed - cleaning')
#  os.system('cd %s/Java && ant clean' % exportDir)


# create snapshot
#
print('\n--building Matlab binaries')
matlabOpts = '-nodisplay -nojvm -wait -logfile "%s"' % compilerLog
matlabCmd = "addpath('utilities'); try, easyplotCompile(); exit(); catch e, disp(e.message); end;"
os.system('cd %s && matlab %s -r "%s"' % (exportDir, matlabOpts, matlabCmd))

print('\n--removing local git tree')
shutil.rmtree('%s' % exportDir)
