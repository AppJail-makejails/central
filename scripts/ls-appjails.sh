#!/bin/sh

set -o pipefail

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    ls -1 projects/*/is_appjail | sed -Ee 's#^projects/([^/]+)/is_appjail#\1#'
}

main "$@"
