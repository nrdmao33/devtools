#!/usr/bin/env python
# Copyright (c) 2015 Arista Networks, Inc.  All rights reserved.
# Arista Networks, Inc. Confidential and Proprietary.


import os, glob, re, sys, ArosTest

listOfDuts = ArosTest.workspaceDutspecs()
numOfDuts = len( listOfDuts )
testFiles = []

for testFile in glob.glob( "/usr/share/ptest/%s/*.py" % sys.argv[ 1] ):
   testFiles.append( testFile )
perDut = int( len( testFiles ) / ( 1.0 * numOfDuts ) )

print 'Scheduling %s tests on %s duts or %s per dut.'  %\
         ( len( testFiles ),
               numOfDuts, perDut )


# Create Temp testFiles and start the AutoTest processes 
myAutoTestProcesses = []
for i in range( numOfDuts ):
   with open( "test-file-%s" % i, "w" ) as f:
      for testFile in testFiles[ i * perDut : (i+1) * perDut ]:
         f.write( testFile.replace( "/usr/share/ptest/", "" ) + "\n" )
   cmdStr = "AutoTest --notify=jmurphy --skipTestbedCheck -a --logDir=/tmp/  --testListFile=test-file-%s --algorithm=fixed -d %s -n 423 -t 43200000" % ( i, listOfDuts[ i ] )
   print cmdStr
