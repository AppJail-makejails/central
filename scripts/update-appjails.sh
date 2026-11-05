#!/bin/sh

set -o pipefail

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    cd -- "${BASEDIR}/.."

    for project in `ls projects/*/is_appjail | sed -Ee 's#^projects/([^/]+)/is_appjail#\1#'`; do
        "./scripts/update.sh" "${project}" || exit $?
    done
}

main "$@"
