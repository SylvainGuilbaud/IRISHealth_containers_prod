#!/usr/bin/env bash
#
# ContainerCheck is a tool to simplify gathering data for InterSystems IRIS
# containers running on Docker or Kubernetes.  It should be used by running:
#
# # ./ContainerCheck.sh your-container-or-pod-name
#
# This script checks for the kubectl and docker binaries, with priority given to kubectl,
# when deciding which container client to use. To override this selection, run
#     export CONTAINER_CLIENT={docker|kubectl}
# before executing this script.
#
# Must be run as a user with access to the docker/kubectl daemon, such as root.
# You must have write permissions on the current directory in order to
# write out the report file.

main() {
    checkUtilities;

    setCONTAINER_NAME "$@";
    setTIMESTAMP;
    setREPORT_DIR_HOST;
    setREPORT_LOGFILE_HOST

    setCONTAINER_CLIENT;
    getClientInfo;

    setISC_PACKAGE_INSTANCENAME;
    setISC_PACKAGE_INSTALLDIR;
    setREPORT_DIR_CONTAINER;

    runSystemCheck;

    tarname="$TIMESTAMP.tar"
    tarball "$tarname";
    filename="$REPORT_DIR_HOST/$tarname.gz"

    echo
    echo
    echo "ContainerCheck complete.  FTP the following file to ISC Support:"
    echo "$filename"
}

# Check for the existence of various common shell utilities. These are very
# likely to be present in all Linuxes, even busybox/Alpine distributions.
checkUtilities() {
    date >/dev/null
    if [ $? -ne 0 ]; then
    	pwd >/dev/null;
    	if [ $? -ne 0 ]; then
    		error "Mandatory core utilities (date, pwd) not found.  Cannot continue.";
    		exit 1;
    	fi
    fi
}

setCONTAINER_NAME() {
    test -n "$1";
    if [ $? -gt 0 ]; then
        error "No container or pod name specified.";
        cat <<EOT
Usage: ./ContainerCheck.sh container-or-pod-name

Try running 'docker ps' or 'kubectl get pods' to see the names of available containers or pods.
EOT
        exit 2
    fi
    export CONTAINER_NAME="$1"
}

setTIMESTAMP() {
    # date is in GNU coreutils
    export TIMESTAMP=$(date -u +"%Y-%m-%dT%H%M%SZ")
    if [ $? -gt 0 ]; then
        # if it isn't, use this fallback
        export TIMESTAMP="PID-$$"
        error "Could not generate timestamp with GNU 'date' utility, using '$TIMESTAMP' as an identifier instead"
    fi
}

setISC_PACKAGE_INSTANCENAME() {
    export ISC_PACKAGE_INSTANCENAME=$(containerExec "echo \$ISC_PACKAGE_INSTANCENAME")
    exit_if_error "Could not check container environment.  Cannot continue."
    test -n "$ISC_PACKAGE_INSTANCENAME"; 
    exit_if_error "ISC_PACKAGE_INSTANCENAME not set in container.  Images without this environment variable set are not supported."
}

setISC_PACKAGE_INSTALLDIR() {
    export ISC_PACKAGE_INSTALLDIR=$(containerExec "echo \$ISC_PACKAGE_INSTALLDIR")
    exit_if_error "Could not check container environment.  Cannot continue."
    test -n "$ISC_PACKAGE_INSTALLDIR"; 
    exit_if_error "ISC_PACKAGE_INSTALLDIR not set in container.  Images without this environment variable set are not supported."
}

setCONTAINER_CLIENT() {
    if [ -z "$CONTAINER_CLIENT" ]; then
        if command -v kubectl > /dev/null 2>&1 ; then
            CONTAINER_CLIENT=kubectl
        elif command -v docker > /dev/null 2>&1 ; then
            CONTAINER_CLIENT=docker
        else
            echo Unable to find kubectl or docker binaries on this system 1>&2
        fi
    else
        if [ "$CONTAINER_CLIENT" != "docker" -a "$CONTAINER_CLIENT" != "kubectl" ]; then
            echo "Invalid value for variable CONTAINER_CLIENT=$CONTAINER_CLIENT. CONTAINER_CLIENT must be docker or kubectl."
        fi
    fi
}

getClientInfo() {
    if [ "$CONTAINER_CLIENT" == "docker" ] ; then
        checkDockerDaemonAccess;
        runDockerInfo;
        runDockerInspect;
    elif [ "$CONTAINER_CLIENT" == "kubectl" ] ; then
        runKubectlVersion;
        runKubectlDescribe;
    else
        echo "Invalid value for variable CONTAINER_CLIENT=$CONTAINER_CLIENT. CONTAINER_CLIENT must be docker or kubectl."
    fi
}

containerExec() {
    if [ "$CONTAINER_CLIENT" == "docker" ] ; then
        docker exec "$CONTAINER_NAME" bash -c "$1"
    elif [ "$CONTAINER_CLIENT" == "kubectl" ] ; then
        kubectl exec "$CONTAINER_NAME" -- bash -c "$1"
    else
        echo "Invalid value for variable CONTAINER_CLIENT=$CONTAINER_CLIENT. CONTAINER_CLIENT must be docker or kubectl."
    fi
}

setREPORT_DIR_HOST() {
    # pwd is in GNU coreutils
    export REPORT_DIR_HOST="$(pwd)/$CONTAINER_NAME-$TIMESTAMP"
    exit_if_error "Cannot run 'pwd'"
    mkdir "$REPORT_DIR_HOST"
    exit_if_error "Cannot mkdir '$REPORT_DIR_HOST'."
}

setREPORT_LOGFILE_HOST() {
    export REPORT_LOGFILE_HOST="$REPORT_DIR_HOST/ContainerCheck.$TIMESTAMP.log"
}

setREPORT_DIR_CONTAINER() {
    containerHome=$(containerExec "echo \$HOME")
    exit_if_error "Could not detect \$HOME in container."
    export REPORT_DIR_CONTAINER="$containerHome/ContainerCheck/$TIMESTAMP"
}

checkDockerDaemonAccess() {
    docker info > /dev/null 2>&1
    if [ $? -gt 0 ]; then
        docker info > /dev/null # Present error message here
        error "This tool must be run as root or another user with access to the Docker daemon."
        exit 1
    fi
}

runDockerInfo() {
    # Now that we know we can run docker commands, put stderr in our file.
    # Sometimes docker emits non-fatal warnings to stderr and we want those.
    filename="$REPORT_DIR_HOST/docker-info.txt"
    docker info > "$filename" 2>&1
    exit_if_error "Cannot run 'docker info'.  This tool must be run as root or another user with access to the Docker daemon."
}

runKubectlVersion() {
    filename="$REPORT_DIR_HOST/kubectl-version.txt"
    kubectl version > "$filename" 2>&1
    exit_if_error "Cannot run 'kubectl version'"
}

runDockerInspect() {
    filename="$REPORT_DIR_HOST/docker-inspect-$CONTAINER_NAME.txt"
    docker inspect "$CONTAINER_NAME" > "$filename"
    # We know we can "docker info", so a failure here has one likely cause.
    exit_if_error "Cannot run 'docker inspect $CONTAINER_NAME' - please double-check that your container name is correct."
}

runKubectlDescribe() {
    filename="$REPORT_DIR_HOST/kubectl-describe-$CONTAINER_NAME.txt"
    kubectl describe pod $CONTAINER_NAME > "$filename"
    exit_if_error "Cannot run 'kubectl describe pod $CONTAINER_NAME' - please double-check that your pod name is correct."
}

runSystemCheck() {
    containerExec "mkdir -p $REPORT_DIR_CONTAINER"
    exit_if_error "Could not make report directory '$REPORT_DIR_CONTAINER'"

    local username
    local pwd
    if [[ $(containerExec "iris session \$ISC_PACKAGE_INSTANCENAME") == *"Access Denied" ]]; then
        echo -n "Username for IRIS terminal access: "
        read username
        echo -n "Password for user '${username}': "
        read -s pwd
    fi

    containerExec "export ISC_CONTAINERCHECK_REPORTDIR=$REPORT_DIR_CONTAINER && printf '%s\n' ${username} ${pwd} |iris session \$ISC_PACKAGE_INSTANCENAME -U %SYS ContainerCheck^SystemCheck"
    # ContainerCheck will exit to shell with code 1 on success, and code 0 on
    # failure.  This is the opposite of normal shell convention, but since
    # irissession returns 0 even in the case of <NOLINE> errors, this is our
    # best chance at an unambiguous exit code.
    test $? -eq 1; exit_if_error "Could not run SystemCheck."
}

tarball() {
    tarname="$1"
    # We invoke tar in the container, but create a file on the host by
    # redirecting stdout rather than using "tar cf" and copying it out.
    containerExec "cd $REPORT_DIR_CONTAINER && tar c *" > "$REPORT_DIR_HOST/$tarname"
    exit_if_error "Could not create '$tarname' - tar failed"
    cd "$REPORT_DIR_HOST" &&
    tar rf "$tarname" ./*.txt &&
    gzip "$tarname"
    cd ..
    exit_if_error "Could not add text files to '$REPORT_DIR_HOST/$tarname' - tar failed"
}

exit_if_error() {
    if [ $(($(echo "${PIPESTATUS[@]}" | tr -s ' ' +))) -ne 0 ]; then
        error "$1"
        exit 1
    fi
}

error() {
    printf "%s Error: $1\n" $(date '+%Y%m%d-%H:%M:%S:%N') 1>&2
}

main "$@";
exit $?
