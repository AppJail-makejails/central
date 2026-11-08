#!/bin/sh

set -o pipefail

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    cd -- "${BASEDIR}/.."

    for project in `./scripts/ls-appjails.sh`; do
        "./scripts/update.sh" "${project}" || exit $?
    done
}

main "$@"
