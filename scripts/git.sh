#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    local project
    project="$1"

    if [ $# -gt 0 ]; then
        shift
    fi

    if [ -z "${project}" ]; then
        local errlevel=0

        for project in "${BASEDIR}/../projects"/*; do
            project="${project##*/}"

            main "${project}" "$@"

            if [ ${errlevel} -eq 0 ]; then
                errlevel=$?
            fi
        done
        exit ${errlevel}
    fi

    local wrkdir
    wrkdir="${BASEDIR}/../wrkdir"

    local wrksrc
    wrksrc="${wrkdir}/${project}"

    echo >&2
    echo "[${project}]:" >&2
    echo >&2

    git -C "${wrksrc}" "$@"

    return $?
}

main "$@"
