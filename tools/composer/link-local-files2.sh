#!/bin/bash

#
# Call like so, for non-standard locations like in capistrano:
# CODEBASE_DIRECTORY="/path/to/installation/" php composer.phar install
#


rsync --ignore-existing -raz --progress ../src/* ../http/
