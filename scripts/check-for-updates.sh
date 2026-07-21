#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    echo "S = Skipped, N = Non-existent, n = New"
    echo "--------------------------------------"
    echo

    local pathname
    local ports=

    for pathname in template/sub/*VER* projects/*/sub/*VER*; do
        local filename="${pathname##*/}"

        if ! printf "%s" "${filename}" | grep -qEe '^[A-Z]+VER[0-9]+$'; then
            continue
        fi

        local name
        name=`printf "%s" "${filename}" | sed -Ee 's/^([A-Z]+)VER[0-9]+$/\1/'` || exit $?
        name=`printf "%s" "${name}" | tr '[[:upper:]]' '[[:lower:]]'` || exit $?

        local suffix=

        # Mapping
        case "${name}" in
            py) name="python" ;;
            postgres) name="postgresql"; suffix="-server" ;;
            mariadb) suffix="-server" ;;
        esac

        local content
        content=`head -1 -- "${pathname}"` || exit $?

        local should_continue=true
        local portdir port

        for portdir in "${PORTSDIR:-/usr/ports}"/*/"${name}${content}${suffix}"; do
            if [ "${portdir}" = "${PORTSDIR:-/usr/ports}/*/${name}${content}${suffix}" ]; then
                should_continue=false
            fi

            port=`printf "%s" "${portdir}" | sed -Ee 's#.+/([^/]+)/([^/]+)$#\1/\2#'` || exit $?

            break
        done

        if ! ${should_continue}; then
            echo "S:${port}"
            continue
        fi

        if [ ! -d "${portdir}" ]; then
            echo "N:${port}"
            continue
        fi

        if [ -z "${ports}" ]; then
            ports="${port}"
        else
            ports="${ports} ${port}"
        fi
    done

    local ports_regex
    ports_regex=`printf "%s" "${ports}" | sed -Ee 's/[0-9]+/[0-9]+/g' | tr ' ' $'\n' | sort | uniq`

    local regex

    for regex in ${ports_regex}; do
        find -E "${PORTSDIR:-/usr/ports}" -maxdepth 2 -regex ".*/${regex}" | while IFS= read -r new_portdir; do
            new_port=`printf "%s" "${new_portdir}" | sed -Ee 's#.+/([^/]+)/([^/]+)$#\1/\2#'` || exit $?
            new=true

            for old_port in ${ports}; do
                if [ "${old_port}" = "${new_port}" ]; then
                    new=false
                    break
                fi
            done

            if ! ${new}; then
                continue
            fi

            echo "n:${new_port}"
        done
    done

    echo
    echo "--------------------------------------"
    echo "S = Skipped, N = Non-existent, n = New"
}

main "$@"
