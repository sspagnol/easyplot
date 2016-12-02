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

project = 'easyplot'
version    = 'master'
url        = ' http://gitlab.aims.gov.au/ogtech/%s.git' % project
exportDir  = 'export'
compilerLog = '.\%s\log.txt' % exportDir
# clone from AIMS gitlab and update submodules
print('\n--exporting tree from %s to %s' % (url, exportDir))
os.system('git clone --recursive %s %s' % (url, exportDir))
print('\n--checking out tree %s' % version)
os.system('cd %s && git checkout %s' % (exportDir, version))
print('\n--git status')
os.system('git status')
print('\n--updating submodules')
os.system('git submodule update --init --recursive')

#
projectITB = 'imos-toolbox'
versionITB    = 'AIMS-2.5'
urlITB        = 'http://gitlab.aims.gov.au/sspagnol/%s.git' % projectITB
exportDirITB  = 'imostoolbox'

# export from AIMS gitlab
print('\n--exporting tree from %s to %s' % (urlITB, exportDirITB))
os.system('cd export && git clone %s %s' % (urlITB, exportDirITB))
os.system('cd export && cd %s && git checkout %s' % (exportDirITB, versionITB))

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
matlabOpts = '-nodisplay -wait -logfile "%s"' % compilerLog
matlabCmd = "addpath('utilities'); try, easyplotCompile(); exit(); catch e, disp(e.message); end;"
os.system('cd %s && matlab %s -r "%s"' % (exportDir, matlabOpts, matlabCmd))

print('\n--removing local git trees')
shutil.rmtree('%s' % exportDir)
shutil.rmtree('%s' % exportDirITB)
