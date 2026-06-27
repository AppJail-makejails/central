#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

main()
{
    local project
    project="$1"

    if [ -z "${project}" ]; then
        for project in "${BASEDIR}/../projects"/*; do
            project="${project##*/}"

            main "${project}" || exit $?
        done
        exit $?
    fi

    local wrkdir
    wrkdir="${BASEDIR}/../wrkdir"

    local wrksrc
    wrksrc="${wrkdir}/${project}"

    local projectsdir
    projectsdir="${BASEDIR}/../projects"

    local projectdir
    projectdir="${projectsdir}/${project}"

    local param_name=
    if [ -f "${projectdir}/name" ]; then
        param_name=`head -1 -- "${projectdir}/name"` || exit $?
    else
        param_name="${project}"
    fi

    local param_alias=
    if [ -f "${projectdir}/alias" ]; then
        param_alias=`head -1 -- "${projectdir}/alias"` || exit $?
    else
        param_alias="${project}"
    fi

    local param_descr=
    if [ -f "${projectdir}/descr" ]; then
        param_descr=`cat -- "${projectdir}/descr"` || exit $?
    else
        echo "missing: ${projectdir}/descr"
        exit 1
    fi

    local param_www=
    if [ -f "${projectdir}/www" ]; then
        param_www=`head -1 -- "${projectdir}/www"` || exit $?
    fi

    local param_logo=
    if [ -f "${projectdir}/logo" ]; then
        param_logo=`head -1 -- "${projectdir}/logo"` || exit $?
    fi

    local param_howto=
    if [ -f "${projectdir}/howto" ]; then
        param_howto=`cat -- "${projectdir}/howto"` || exit $?
    else
        echo "missing: ${projectdir}/howto"
        exit 1
    fi

    local param_notes=
    if [ -f "${projectdir}/notes" ]; then
        param_notes=`cat -- "${projectdir}/notes"` || exit $?
    else
        param_notes=`cat -- "${BASEDIR}/../template/notes"` || exit $?
    fi

    local param_daemonless=
    if [ -f "${projectdir}/daemonless.yaml" ]; then
        param_daemonless=`cat -- "${projectdir}/daemonless.yaml"` || exit $?
    else
        param_daemonless=`cat -- "${BASEDIR}/../template/daemonless.yaml"` || exit $?
    fi

    local escape_project
    escape_project=`printf "%s" "${project}" | sed -Ee 's/#/\\\\#/g'` || exit $?

    mkdir -p -- "${wrksrc}/.github/workflows" || exit $?
    cp -a -- "${BASEDIR}/../template/workflow.yaml" "${wrksrc}/.github/workflows/build.yaml" || exit $?

    sed -i '' -Ee "s#%%NAME%%#${escape_project}#g" "${wrksrc}/.github/workflows/build.yaml" || exit $?

    mkdir -p -- "${wrksrc}/.daemonless" || exit $?
    printf "%s" "${param_daemonless}" > "${wrksrc}/.daemonless/config.yaml" || exit $?

    {
        printf "# %s\n" "${param_name}"
        printf "\n"
        printf "%s\n" "${param_descr}"
        printf "\n"

        if [ -n "${param_www}" ]; then
            printf "%s\n" "${param_www}"
            printf "\n"
        fi

        if [ -n "${param_logo}" ]; then
            printf "<img src=\"%s\" width=\"30%%\" height=\"auto\" alt=\"%s logo\">\n" \
                "${param_logo}" "${param_name}"
            printf "\n"
        fi

        printf "## How to use this Makejail\n"
        printf "\n"
        printf "%s\n" "${param_howto}"
        printf "\n"

        local stage_build=false

        local stage
        for stage in "${projectdir}/arguments"/*; do
            if [ "${stage}" = "${projectdir}/arguments/*" ]; then
                break
            fi

            stage="${stage##*/}"

            if [ "${stage}" = "build" ]; then
                stage_build=true
            fi

            if [ "${stage}" != "build" ]; then
                echo "### Arguments (stage: ${stage})"
                echo
            else
                _write_stage_build
            fi

            local stagedir
            stagedir="${projectdir}/arguments/${stage}"

            local arg_name
            for arg_name in "${stagedir}"/*; do
                arg_name="${arg_name##*/}"

                local argdir
                argdir="${stagedir}/${arg_name}"

                local arg_type="optional"
                if [ -f "${argdir}/mandatory" ]; then
                    arg_type="mandatory"
                fi

                local arg_default=
                if [ -f "${argdir}/default" ]; then
                    arg_default=`head -1 -- "${argdir}/default"` || exit $?
                fi

                local arg_descr=
                if [ -f "${argdir}/descr" ]; then
                    arg_descr=`head -1 -- "${argdir}/descr"` || exit $?
                else
                    echo "missing: ${argdir}/descr"
                    exit 1
                fi

                if [ -n "${arg_default}" ]; then
                    echo "* \`${arg_name}\` (default: \`${arg_default}\`): ${arg_descr}"
                else
                    echo "* \`${arg_name}\` (${arg_type}): ${arg_descr}"
                fi
            done

            echo
        done

        if ! ${stage_build}; then
            _write_stage_build
        fi

        local stage
        for stage in "${projectdir}/environment"/*; do
            if [ "${stage}" = "${projectdir}/environment/*" ]; then
                break
            fi

            stage="${stage##*/}"

            echo "### Environment (stage: ${stage})"
            echo

            local stagedir
            stagedir="${projectdir}/environment/${stage}"

            local arg_name
            for arg_name in "${stagedir}"/*; do
                arg_name="${arg_name##*/}"

                local argdir
                argdir="${stagedir}/${arg_name}"

                local arg_type="optional"
                if [ -f "${argdir}/mandatory" ]; then
                    arg_type="mandatory"
                fi

                local arg_default=
                if [ -f "${argdir}/default" ]; then
                    arg_default=`head -1 -- "${argdir}/default"` || exit $?
                fi

                local arg_descr=
                if [ -f "${argdir}/descr" ]; then
                    arg_descr=`head -1 -- "${argdir}/descr"` || exit $?
                else
                    echo "missing: ${argdir}/descr"
                    exit 1
                fi

                if [ -n "${arg_default}" ]; then
                    echo "* \`${arg_name}\` (default: \`${arg_default}\`): ${arg_descr}"
                else
                    echo "* \`${arg_name}\` (${arg_type}): ${arg_descr}"
                fi
            done

            echo
        done

        local display_volume_header=true
        local volume
        for volume in "${projectdir}/volumes"/*; do
            if [ "${volume}" = "${projectdir}/volumes/*" ]; then
                break
            fi

            if ${display_volume_header}; then
                echo
                echo "### Volumes"
                echo
                echo "| Name | Owner | Group | Perm | Type | Mountpoint |"
                echo "| --- | --- | --- | --- | --- | --- |"

                display_volume_header=false
            fi

            volume="${volume##*/}"

            local volumedir
            volumedir="${projectdir}/volumes/${volume}"

            local volume_owner="\`\${puid}\`"
            if [ -f "${volumedir}/owner" ]; then
                volume_owner=`head -1 -- "${volumedir}/owner"` || exit $?
            fi

            local volume_group="\`\${pgid}\`"
            if [ -f "${volumedir}/group" ]; then
                volume_group=`head -1 -- "${volumedir}/group"` || exit $?
            fi

            local volume_perm="-"
            if [ -f "${volumedir}/perm" ]; then
                volume_perm=`head -1 -- "${volumedir}/perm"` || exit $?
            fi

            local volume_type="-"
            if [ -f "${volumedir}/type" ]; then
                volume_type=`head -1 -- "${volumedir}/type"` || exit $?
            fi

            local volume_mountpoint="-"
            if [ -f "${volumedir}/mountpoint" ]; then
                volume_mountpoint=`head -1 -- "${volumedir}/mountpoint"` || exit $?
            fi

            echo "| ${volume} | ${volume_owner} | ${volume_group} | ${volume_perm} | ${volume_type} | ${volume_mountpoint} |"
        done

        echo
        echo "## OCI Configuration"
        echo
        echo "\`\`\`yaml"
        printf "%s\n" "${param_daemonless}"
        echo "\`\`\`"

        if [ -n "${param_notes}" ]; then
            echo
            echo "## Notes"
            echo

            printf "%s\n" "${param_notes}"
        fi
    } > "${wrksrc}/README.md" || exit $?

    local sub
    for sub in "${projectdir}/sub"/* "${BASEDIR}/../template/sub"/*; do
        if [ "${sub}" = "${projectdir}/sub/*" ]; then
            continue
        fi

        if [ "${sub}" = "${BASEDIR}/../templates/*" ]; then
            continue
        fi

        value=`head -1 -- "${sub}"` || exit $?
        sub="${sub##*/}"

        local file
        for file in README.md .daemonless/config.yaml .github/workflows/build.yaml; do
            sub=`printf "%s" "${sub}" | sed -Ee 's/#/\\\\#/g'` || exit $?
            value=`printf "%s" "${value}" | sed -Ee 's/#/\\\\#/g'` || exit $?

            sed -i '' -Ee "s#%%${sub}%%#${value}#g" "${wrksrc}/${file}" || exit $?
        done
    done

    return $?
}

_write_stage_build()
{
    echo "### Arguments (stage: build)"
    echo
    echo "* \`${param_alias}_from\` (default: \`ghcr.io/appjail-makejails/${project}\`): Location of OCI image. See also [OCI Configuration](#oci-configuration)."
    echo "* \`${param_alias}_tag\` (default: \`latest\`): OCI image tag. See also [OCI Configuration](#oci-configuration)."
}

main "$@"
