#!/bin/sh

# Update wrkdir/linux-brave/linux-brave/create after changing this.
#PINNED_VERSION="152.0.7977.75-1"
# Simulation.
PINNED_VERSION="0.0.0"

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    CURRENT_VERSION=`make -C "${PORTSDIR:-/usr/ports}/www/linux-widevine-cdm" -V CHROME_VERSION` || exit $?

    if [ -z "${CURRENT_VERSION}" ]; then
        echo "www/linux-widevine-cdm: Could not retrieve the current version of Chrome."
        exit 1
    fi

    if [ "${PINNED_VERSION}" != "${CURRENT_VERSION}" ]; then
        echo "www/linux-widevine-cdm: Chrome version differs: ${PINNED_VERSION} != ${CURRENT_VERSION}"
    fi

    exit 0
}

main "$@"
