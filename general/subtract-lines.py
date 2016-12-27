#!/usr/bin/python

from optparse import OptionParser
import sys

usage = "%prog -m MINUEND -s SUBTRAHEND[,SUBTRAHEND...] [ -o OUTPUT ]"
parser = OptionParser(usage=usage)
parser.add_option("-m", "--minuend", action="store", metavar="MINUEND",
                  help = "(required) The file to be subtracted from.")
parser.add_option("-s", "--subtrahend", action="store",
                  metavar="SUBTRAHEND[,...]",
                  help = "(required) The file(s) to subtract")
parser.add_option("-o", "--output", action="store", metavar="OUTPUT",
                  help = "(optional) Output to file, if not specified, stdout")
(options, args) = parser.parse_args()

if not options.minuend:
    print "MINUEND file is not specified"
    parser.print_usage()
    sys.exit(1)

if not options.subtrahend:
    print "SUBTRAHEND file is not specified"
    parser.print_usage()
    sys.exit(1)

f = open(options.minuend)
minuend = f.readlines()
f.close()

subtrahend_file_names = options.subtrahend.split(',')
subtrahends = []
for file in subtrahend_file_names:
    f = open(file)
    subtrahends.append(f.readlines())
    f.close()

if options.output:
    f = open(options.output, "w")
else:
    f = sys.stdout

for line in minuend:
    found = False
    for subtrahend in subtrahends:
        if line in subtrahend:
            found = True
            break
    if not found:
        f.write(line)
