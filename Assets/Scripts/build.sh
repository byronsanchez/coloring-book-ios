#!/bin/bash

###############
# CONFIGURATION
###############

# NOTE: No custom configuration is needed for this repository. You may
# safely ignore the warnings produced by this script.

######################
# SYSTEM CONFIGURATION
######################

# Don't modify this unless you are moving this file.
PROJECT_DIR="."
# Extension sed uses for backups during substitution.
BACKUP_EXT=".bu"

###########
# FUNCTIONS
###########

function validate_user {
    printf "
    DO NOT PROCEED IF YOU HAVE NOT SET UP THIS SCRIPT'S CONFIG VARIABLES!

    This script is meant to be executed only once, right after a git clone
    (of the master AND submodule repositories). Run this script from the
    root of the project directory.

    It will customize the repository so that the application can compile
    properly, using your own IDs for various components. If you do not set
    up these components (either by running this script or through manual
    configuration of the necessary files), the application will NOT
    run properly. It may not even compile.

    To setup the necessary config variables, open build.sh in a text editor
    and only modify the CONFIGURATION section. Do not modify \$PROJECT_DIR,
    unless you are moving the build.sh file.
    "

  input=""
  printf "Are you ready to run the build (y/n)? "
  read input
  printf "\n"
  if [ "$input" != "y" ]; then
    message="Build aborted!"
    printf "\e[31m$message\e[0m\n"
    exit 1
  fi
}

# NOTE: Currently not used. Use if there are any required config
# variable definitions.
function check_sanity {
  isInvalid=false

  # Put config validation here if needed.

  if $isInvalid; then
    message="Build aborted due to errors!"
    printf "\e[31m$message\e[0m\n"
    exit 2
  fi
}

function build_database {
  target_db="$PROJECT_DIR/Assets/coloring_book.db"
  target_ddl="$PROJECT_DIR/Assets/coloring-book.sql"
  sqlite3 $target_db < $target_ddl
}

# NOTE: Currently not used. Use this function if you need to make
# substitutions.
function sed_file {
  file=$1
  sub_string=$2

  sed -i$BACKUP_EXT "$sub_string" $file
  exit_code=$?

  if [ $exit_code != 0 ]; then
    message="Failed to run the build on file \"$file\"."
    printf "\e[31m$message\e[0m\n"
  else
    rm $file$BACKUP_EXT
  fi
}

######
# MAIN
######

case "$1" in
all)
  validate_user
  check_sanity
  build_database
  message="Build complete!"
  printf "\e[32m$message\e[0m\n"
  ;;
*)
  printf "Usage: `basename $0` [option]\n"
  printf "Available options:\n"
  for option in all
  do 
      printf "  - $option\n"
  done
  ;;
esac
