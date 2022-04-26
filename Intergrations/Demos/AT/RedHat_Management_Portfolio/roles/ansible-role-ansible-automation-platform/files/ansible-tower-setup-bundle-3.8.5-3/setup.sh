#!/usr/bin/env bash
# This script runs setup for Ansible Tower.
# It determines how Tower is to be installed, gives the proper command,
# and then executes the command if asked.

# -------------
# Initial Setup
# -------------

# Cause exit codes to trickle through piping.
set -o pipefail

# When using an interactive shell, force colorized output from Ansible.
if [ -t "0" ]; then
    ANSIBLE_FORCE_COLOR=True
fi

# Set variables.
TIMESTAMP=$(date +"%F-%T")
LOG_DIR="/var/log/tower"
LOG_FILE="${LOG_DIR}/setup-${TIMESTAMP}.log"
TEMP_LOG_FILE='setup.log'

INVENTORY_FILE="inventory"
OPTIONS=""

# What playbook should be run?
# By default, this is setup.log, unless we are doing a backup
# (specified in the options).
PLAYBOOK="install.yml"

# -e bundle_install=false to override and disable bundle installer
OVERRIDE_BUNDLE_INSTALL=false

AW_REPO_URL=${AW_REPO_URL:-https://releases.ansible.com/ansible-tower}
GPGCHECK=1

# -------------
# Helper functions
# -------------

# Be able to get the real path to a file.
realpath() {
    echo $(cd $(dirname $1); pwd)/$(basename $1)
}

find_bundle_rpm() {
    if [ -d bundle ]; then
        find bundle/el$(distribution_major_version) -type f -iname "$1" -not -iname "*.src.rpm"
    fi
}

is_ansible_installed() {
    type -p ansible-playbook > /dev/null
}

is_ansible_new_enough() {
    ver=$(ansible-playbook --version | awk '/^ansible/ { print $2 }')
    req_ver=$(awk '/^minimum_ansible_version/ { print $2 }' roles/preflight/defaults/main.yml)
    DISTRIBUTION_MAJOR_VERSION=$(distribution_major_version)
    case ${DISTRIBUTION_MAJOR_VERSION} in
        8)
            /usr/libexec/platform-python -c "import sys ; from distutils.version import LooseVersion ; sys.exit(0) if (LooseVersion('$ver') > LooseVersion($req_ver)) else sys.exit(1)"
            ;;
        *)
            python -c "import sys ; from distutils.version import LooseVersion ; sys.exit(0) if (LooseVersion('$ver') > LooseVersion($req_ver)) else sys.exit(1)"
            ;;
    esac
}

is_bundle_install() {
    [ -d "bundle" ] && [[ ${OVERRIDE_BUNDLE_INSTALL} == false ]]
}

distribution_id() {
    RETVAL=""
    if [ -z "${RETVAL}" -a -e "/etc/os-release" ]; then
        . /etc/os-release
        RETVAL="${ID}"
    fi

    if [ -z "${RETVAL}" -a -e "/etc/centos-release" ]; then
        RETVAL="centos"
    fi

    if [ -z "${RETVAL}" -a -e "/etc/fedora-release" ]; then
        RETVAL="fedora"
    fi

    if [ -z "${RETVAL}" -a -e "/etc/redhat-release" ]; then
        RELEASE_OUT=$(head -n1 /etc/redhat-release)
        case "${RELEASE_OUT}" in
            Red\ Hat\ Enterprise\ Linux*)
                RETVAL="rhel"
                ;;
            CentOS*)
                RETVAL="centos"
                ;;
            Fedora*)
                RETVAL="fedora"
                ;;
        esac
    fi

    if [ -z "${RETVAL}" ]; then
        RETVAL="unknown"
    fi

    echo ${RETVAL}
}

distribution_major_version() {
    for RELEASE_FILE in /etc/system-release \
                        /etc/centos-release \
                        /etc/fedora-release \
                        /etc/redhat-release
    do
        if [ -e "${RELEASE_FILE}" ]; then
            RELEASE_VERSION=$(head -n1 ${RELEASE_FILE})
            break
        fi
    done
    echo ${RELEASE_VERSION} | sed -e 's|\(.\+\) release \([0-9]\+\)\([0-9.]*\).*|\2|'
}

log_success() {
    if [ $# -eq 0 ]; then
        cat
    else
        echo "$*"
    fi
}

log_warning() {
    echo -n "[warn] "
    if [ $# -eq 0 ]; then
        cat
    else
        echo "$*"
    fi
}

log_error() {
    echo -n "[error] "
    if [ $# -eq 0 ]; then
        cat
    else
        echo "$*"
    fi
}

fatal_ansible_not_installed() {
    log_error <<-EOF
		Ansible is not installed on this machine.
		You must install Ansible before you can install Tower.

		For guidance on installing Ansible, consult
		http://docs.ansible.com/intro_installation.html.
		EOF
    exit 32
}

install_dependency_repo() {
repo=$(mktemp /etc/yum.repos.d/tower-tmpXXXXXX.repo)
cat > $repo << EOF
[ansible-tower-dependencies-temp]
name=Ansible Tower Dependencies Repository - $releasever $basearch
baseurl=$AW_REPO_URL/rpm/dependencies/$(grep tower_package_version group_vars/all | grep -o '[[:digit:]].[[:digit:]]')/epel-$1-x86_64
enabled=0
gpgcheck=$GPGCHECK
gpgkey=https://www.redhat.com/security/data/fd431d51.txt
EOF
echo $repo
}


# --------------
# Usage
# --------------

function usage() {
    cat << EOF
Usage: $0 [Options] [-- Ansible Options]

Options:
  -i INVENTORY_FILE     Path to ansible inventory file (default: ${INVENTORY_FILE})
  -e EXTRA_VARS         Set additional ansible variables as key=value or YAML/JSON
                        i.e. -e bundle_install=false will force an online install

  -b                    Perform a database backup in lieu of installing
  -r                    Perform a database restore in lieu of installing
  -k                    Generate and distribute a new SECRET_KEY

  -h                    Show this help message and exit

Ansible Options:
  Additional options to be passed to ansible-playbook can be added
  following the -- separator
EOF
    exit 64
}


# --------------
# Option Parsing
# --------------

# First, search for -- (end of args)
# Anything after -- is placed into OPTIONS and passed to Ansible
# Anything before -- (or the whole string, if no --) is processed below
ARGS=$*
if [[ "$ARGS" == *"-- "* ]]; then
    SETUP_ARGS=${ARGS%%-- *}
    OPTIONS=${ARGS##*-- }
else
    SETUP_ARGS=$ARGS
    OPTIONS=""
fi

# Process options to setup.sh
while getopts ':a:i:e:brk' OPTION $SETUP_ARGS; do
    case $OPTION in
        a)
            AW_REPO_URL=$OPTARG
            ;;
        i)
            INVENTORY_FILE=$(realpath $OPTARG)
            ;;
        e)
            OPTIONS="$OPTIONS -e $OPTARG"
            IFS='=' read -a kv <<< "$OPTARG"
            if [ "${kv[0]}" == "bundle_install" ]; then
                OVERRIDE_BUNDLE_INSTALL=true
            fi
            if [ "${kv[0]}" == "aw_repo_url" ]; then
                AW_REPO_URL=${kv[1]}
            fi
            if [ "${kv[0]}" == "gpgcheck" ]; then
                GPGCHECK=${kv[1]}
            fi
            ;;
        b)
            PLAYBOOK="backup.yml"
            TEMP_LOG_FILE="backup.log"
            OPTIONS="$OPTIONS --force-handlers"
            ;;
        r)
            PLAYBOOK="restore.yml"
            TEMP_LOG_FILE="restore.log"
            OPTIONS="$OPTIONS --force-handlers"
            ;;
        k)
            PLAYBOOK="rekey.yml"
            TEMP_LOG_FILE="rekey.log"
            OPTIONS="$OPTIONS --force-handlers"
            ;;
        *)
            usage
            ;;
    esac
done

# Sanity check: Test to ensure that Ansible exists.
is_ansible_installed && is_ansible_new_enough
if [ $? -ne 0 ]; then
    SKIP_ANSIBLE_CHECK=0
    case $(distribution_id) in
        rhel|centos|ol)
            DISTRIBUTION_MAJOR_VERSION=$(distribution_major_version)
            is_bundle_install
            if [ $? -eq 0 ]; then
                log_warning "Will install bundled Ansible"
	            SKIP_ANSIBLE_CHECK=1
            else
                tmprepo=
                case ${DISTRIBUTION_MAJOR_VERSION} in
                    7)
                        tmprepo=$(install_dependency_repo 7)
                        ;;
                    8)
                        tmprepo=$(install_dependency_repo 8)
                        ;;
                esac
                yum install -y --enablerepo='ansible-tower-dependencies-temp' ansible
                [ -n "$tmprepo" ] && rm -f "$tmprepo"
            fi
            ;;
        fedora)
            yum install -y ansible
            ;;
    esac

    # Check whether ansible was successfully installed
    if [ ${SKIP_ANSIBLE_CHECK} -ne 1 ]; then
        is_ansible_installed
        if [ $? -ne 0 ]; then
            log_error "Unable to install ansible."
            fatal_ansible_not_installed
        fi
    fi
fi

is_bundle_install
if [ $? -eq 0 ]; then
    DISTRIBUTION_MAJOR_VERSION=$(distribution_major_version)
    is_ansible_installed && is_ansible_new_enough
    [ $? -eq 1 ] && \
    if [ "$(distribution_id)" == "centos" ] || [ "$(distribution_id)" == "rhel" ] || [ "$(distribution_id)" == "ol" ]; then
        # Attempt to find ansible package for the current distro in the bundle bundle
        ANSIBLE_RPM_PATH=$(find_bundle_rpm "ansible-[0-9]*.el${DISTRIBUTION_MAJOR_VERSION}ae.*noarch.rpm")
        # Attempt to find ansible dependencies from the bundle bundle
        SSHPASS_RPM_PATH=$(find_bundle_rpm "sshpass-*.rpm")
        PYTHON_PASSLIB_RPM_PATH=$(find_bundle_rpm "python-passlib*.rpm")
        PYTHON_JMESPATH_RPM_PATH=$(find_bundle_rpm "python2-jmespath*.rpm")
        PYTHON_JINJA_RPM_PATH=""
        if [ -f "${ANSIBLE_RPM_PATH}" ]; then
            yum install -y ${ANSIBLE_RPM_PATH}  ${SSHPASS_RPM_PATH} ${PYTHON_JINJA_RPM_PATH} ${PYTHON_PASSLIB_RPM_PATH} ${PYTHON_JMESPATH_RPM_PATH}
        else
            log_error "Unable to find ansible rpm for el${DISTRIBUTION_MAJOR_VERSION}."
        fi
    else
        log_warning "Ignoring forced Ansible upgrade for bundle on $(distribution_id)"
    fi
fi

# Change to the running directory for tower conf file and inventory file
# defaults.
cd "$( dirname "${BASH_SOURCE[0]}" )"


# Sanity check: Test to ensure that an inventory file exists.
if [ ! -e "${INVENTORY_FILE}" ]; then
    log_error <<-EOF
		No inventory file could be found at ${INVENTORY_FILE}.
		Please create one, or specify one manually with -i.
		EOF
    exit 64
fi

# Presume bundle install mode if directory "bundle" exists
# unless user overrides with "-e bundle_install=*"
if [ $PLAYBOOK == "install.yml" ]; then
    is_bundle_install
    if [ $? -eq 0 ]; then
        OPTIONS="$OPTIONS -e bundle_install=true"
    fi
fi

# Run the playbook.
PYTHONUNBUFFERED=x ANSIBLE_FORCE_COLOR=$ANSIBLE_FORCE_COLOR \
ANSIBLE_ERROR_ON_UNDEFINED_VARS=True \
ansible-playbook -i "${INVENTORY_FILE}" -v \
                 $OPTIONS \
                 $PLAYBOOK 2>&1 | tee $TEMP_LOG_FILE

# Save the exit code and output accordingly.
RC=$?
if [ ${RC} -ne 0 ]; then
    log_error "Oops!  An error occurred while running setup."
else
    log_success "The setup process completed successfully."
fi

# Save log file.
if [ -d "${LOG_DIR}" ]; then
    if [ -w "${LOG_DIR}" ]; then
        cp ${TEMP_LOG_FILE} ${LOG_FILE}
    else
        ${ANSIBLE_BECOME_METHOD:-sudo} cp ${TEMP_LOG_FILE} ${LOG_FILE}
    fi
    if [ $? -eq 0 ]; then
        rm ${TEMP_LOG_FILE}
        log_success "Setup log saved to ${LOG_FILE}."

        # Remove world readable
        if [ -n "$SUDO_USER" ]; then
            ${ANSIBLE_BECOME_METHOD:-sudo} chmod 0440 ${LOG_FILE}
        else
            chmod 0440 ${LOG_FILE}
        fi

    else
        log_warning "Unable to save log to ${LOG_DIR}. Setup log saved to ${TEMP_LOG_FILE}."
    fi
else
    log_warning "${LOG_DIR} does not exist. Setup log saved to ${TEMP_LOG_FILE}."
fi

# Remove world readable and chown for sudo users if temp log still exists
if [ -f "${TEMP_LOG_FILE}" ]; then
    if [ -n "${SUDO_USER}" ]; then
        ${ANSIBLE_BECOME_METHOD:-sudo} chmod 0440 ${TEMP_LOG_FILE}
        ${ANSIBLE_BECOME_METHOD:-sudo} chown ${SUDO_USER} ${TEMP_LOG_FILE}
    else
        chmod 0440 ${TEMP_LOG_FILE}
    fi
fi

exit ${RC}
