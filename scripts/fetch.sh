#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    local project
    project="$1"

    if [ -z "${project}" ]; then
        local errlevel=0

        for project in "${BASEDIR}/../projects"/*; do
            project="${project##*/}"

            main "${project}"

            if [ ${errlevel} -eq 0 ]; then
                errlevel=$?
            fi
        done
        exit ${errlevel}
    fi

    git clone git@github.com:appjail-makejails/${project} "${BASEDIR}/../wrkdir/${project}"

    return $?
}

main "$@"
