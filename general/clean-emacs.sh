#!/usr/bin/bash

# Clean up all emacs ~ files.
find . -name '*~' -print | xargs rm
