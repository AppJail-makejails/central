#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    local project
    project="$1"

    if [ -z "${project}" ]; then
        echo "usage: create-new-release.sh <project>" >&2
        exit 1
    fi

    local wrkdir
    wrkdir="${BASEDIR}/../wrkdir"

    local wrksrc
    wrksrc="${wrkdir}/${project}"

    local new_version
    new_version=`date -u +"r%Y%m%d%H%M%S"` || return $?

    git -C "${wrksrc}" commit --allow-empty -m "Bump version to ${new_version}" || return $?
    git -C "${wrksrc}" tag "${new_version}" || return $?

    return 0
}

main "$@"
