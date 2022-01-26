#
# Find files matching grep pattern
#
find . -type f | xargs grep -n "$1" 2> /dev/null
