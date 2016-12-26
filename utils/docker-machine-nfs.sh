#!/usr/bin/env bash

# Environment variables and their defaults
LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency

# BEGIN _functions

# @info:    Prints the ascii logo
function asciiLogo ()
{
  echo
  echo
  echo '                       ##         .'
  echo '                 ## ## ##        ==               _   _ _____ ____'
  echo '              ## ## ## ## ##    ===              | \ | |  ___/ ___|'
  echo '          /"""""""""""""""""\___/ ===            |  \| | |_  \___ \'
  echo '     ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~     | |\  |  _|  ___) |'
  echo '          \______ o           __/                |_| \_|_|   |____/'
  echo '            \    \         __/'
  echo '             \____\_______/'
  echo
  echo
}

# @info:    Prints the usage
function usage ()
{

  asciiLogo

  cat <<EOF
Usage: $0 <machine-name> [options]

Options:

  -f, --force               Force reconfiguration of nfs
  -n, --nfs-config          NFS configuration to use in /etc/exports. (default to '-alldirs -mapall=\$(id -u):\$(id -g)')
  -s, --shared-folder,...   Folder to share (default to /Users)
  -m, --mount-opts          NFS mount options (default to 'noacl,async')

Examples:

  $ docker-machine-nfs test

    > Configure the /Users folder with NFS

  $ docker-machine-nfs test --shared-folder=/Users --shared-folder=/var/www

    > Configures the /Users and /var/www folder with NFS

  $ docker-machine-nfs test --shared-folder=/var/www --nfs-config="-alldirs -maproot=0"

    > Configure the /var/www folder with NFS and the options '-alldirs -maproot=0'

  $ docker-machine-nfs test --mount-opts="noacl,async,nolock,vers=3,udp,noatime,actimeo=1"

    > Configure the /User folder with NFS and specific mount options.

EOF
  exit 0
}

# @info:    Prints colored messages
# @args:    colored-message
function _fmt ()      {
    local color_ok="\x1b[32m"
    local color_bad="\x1b[31m"

    local color="${color_bad}"
    if [ "${1}" = "debug" ] || [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then
        color="${color_ok}"
    fi

    local color_reset="\x1b[0m"
    if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then
        # Don't use colors on pipes or non-recognized terminals
        color=""; color_reset=""
    fi
    echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" ${1})${color_reset}";
}

# @info:    Prints emergency messages
# @args:    emergency-message
function emergency () {                             echo "$(_fmt emergency) ${@}" >&2 || true; exit 1; }

# @info:    Prints alert messages
# @args:    alert-message
function alert ()     { [ "${LOG_LEVEL}" -ge 1 ] && echo "$(_fmt alert) ${@}" >&2 || true; }

# @info:    Prints critical messages
# @args:    critical-message
function critical ()  { [ "${LOG_LEVEL}" -ge 2 ] && echo "$(_fmt critical) ${@}" >&2 || true; }

# @info:    Prints error messages
# @args:    error-message
function error ()     { [ "${LOG_LEVEL}" -ge 3 ] && echo "$(_fmt error) ${@}" >&2 || true; }

# @info:    Prints warning messages
# @args:    warning-message
function warning ()   { [ "${LOG_LEVEL}" -ge 4 ] && echo "$(_fmt warning) ${@}" >&2 || true; }

# @info:    Prints notice messages
# @args:    notice-message
function notice ()    { [ "${LOG_LEVEL}" -ge 5 ] && echo "$(_fmt notice) ${@}" >&2 || true; }

# @info:    Prints info messages
# @args:    info-message
function info ()      { [ "${LOG_LEVEL}" -ge 6 ] && echo "$(_fmt info) ${@}" >&2 || true; }

# @info:    Prints debug messages
# @args:    debug-message
function debug ()     { [ "${LOG_LEVEL}" -ge 7 ] && echo "$(_fmt debug) ${@}" >&2 || true; }

# @info:    Checks if a given property is set
# @return:  true, if variable is not set; else false
function isPropertyNotSet()
{
  if [ -z ${1+x} ]; then return 0; else return 1; fi
}

# @info:    Sets the default properties
function setPropDefaults()
{
  prop_machine_name=
  prop_shared_folders=()
  prop_nfs_config="-alldirs -mapall="$(id -u):$(id -g)
  prop_mount_options="noacl,async"
  prop_force_configuration_nfs=false
}

# @info:    Parses and validates the CLI arguments
function parseCli()
{

  [ "$#" -ge 1 ] || usage

  prop_machine_name=$1

  for i in "${@:2}"
  do
    case $i in
      -s=*|--shared-folder=*)
      local shared_folder="${i#*=}"
      shift

      if [ ! -d "$shared_folder" ]; then
        error "Given shared folder '$shared_folder' does not exist!"
        exit 1
      fi

      prop_shared_folders+=($shared_folder)
      ;;

      -n=*|--nfs-config=*)
        prop_nfs_config="${i#*=}"
      ;;

      -m=*|--mount-opts=*)
        prop_mount_options="${i#*=}"
      ;;


      -f|--force)
      prop_force_configuration_nfs=true
      shift
      ;;

      *)
        error "Unknown argument '$i' given"
        usage
      ;;
    esac
  done

  if [ ${#prop_shared_folders[@]} -eq 0 ]; then
    prop_shared_folders+=("/Users")
  fi;

  info "Configuration:"

  info "Machine Name: $prop_machine_name"
  for shared_folder in "${prop_shared_folders[@]}"
  do
    info "Shared Folder: $shared_folder"
  done

  info "Mount Options: $prop_mount_options"
  info "Force: $prop_force_configuration_nfs"
}

# @info:    Checks if the machine is present
# @args:    machine-name
# @return:  (none)
function checkMachinePresence ()
{
  info "Machine presence..."

  if [ "" = "$(docker-machine ls | sed 1d | grep -w "$1")" ]; then
    error "Could not find the machine '$1'!"; exit 1;
  fi

  info "OK"
}

# @info:    Checks if the machine is running
# @args:    machine-name
# @return:  (none)
function checkMachineRunning ()
{
  info "Machine running..."

  machine_state=$(docker-machine ls | sed 1d | grep "^$1\s" | awk '{print $4}')

  if [ "Running" != "${machine_state}" ]; then
    error "The machine '$1' is not running but '${machine_state}'!";
    exit 1;
  fi

  info "OK"
}

# @info:    Returns the driver used to create the machine
# @args:    machine-name
# @return:  The driver used to create the machine
function getMachineDriver ()
{
  docker-machine ls | sed 1d | grep "^$1\s" | awk '{print $3}'
}

# @info:    Loads mandatory properties from the docker machine
function lookupMandatoryProperties ()
{
  info "Lookup mandatory properties..."

  prop_machine_ip=$(docker-machine ip $1)

  prop_machine_driver=$(getMachineDriver $1)

  if [ "$prop_machine_driver" = "vmwarefusion" ]; then
    prop_network_id="Shared"
    prop_nfshost_ip=$(ifconfig -m `route get 8.8.8.8 | awk '{if ($1 ~ /interface:/){print $2}}'` | awk 'sub(/inet /,""){print $1}')
    prop_machine_ip=$prop_nfshost_ip
    if [ "" = "${prop_nfshost_ip}" ]; then
      error "Could not find the vmware fusion net IP!"; exit 1
    fi
    local nfsd_line="nfs.server.mount.require_resv_port = 0"
    info "OK"

    info "Check NFS config settings..."
    if [ "$(grep -Fxq "$nfsd_line" /etc/nfs.conf)" == "0" ]; then
      info "/etc/nfs.conf is setup correctly!"
    else
      warning "Sudo will be necessary for editing /etc/nfs.conf"
      # Backup /etc/nfs.conf file
      sudo cp /etc/nfs.conf /etc/nfs.conf.bak && \
      echo "nfs.server.mount.require_resv_port = 0" | \
        sudo tee /etc/nfs.conf > /dev/null
      warning "Backed up /etc/nfs.conf to /nfs.conf.bak"
      warning "Added 'nfs.server.mount.require_resv_port = 0' to /etc/nfs.conf"
    fi
    info "OK"
    return
  fi

  if [ "$prop_machine_driver" = "xhyve" ]; then
    prop_network_id="Shared"
    prop_nfshost_ip=$(ifconfig -m `route get $prop_machine_ip | awk '{if ($1 ~ /interface:/){print $2}}'` | awk 'sub(/inet /,""){print $1}')
    if [ "" = "${prop_nfshost_ip}" ]; then
      error "Could not find the xhyve net IP!"; exit 1
    fi
    info "OK"
    return
  fi

  if [ "$prop_machine_driver" = "parallels" ]; then
    prop_network_id="Shared"
    prop_nfshost_ip=$(prlsrvctl net info \
      "${prop_network_id}" | grep 'IPv4 address' | sed 's/.*: //')

    if [ "" = "${prop_nfshost_ip}" ]; then
      error "Could not find the parallels net IP!"; exit 1
    fi

    info "OK"
    return
  fi

  if [ "$prop_machine_driver" != "virtualbox" ]; then
    error "Unsupported docker-machine driver: $prop_machine_driver"; exit 1
  fi

  prop_network_id=$(VBoxManage showvminfo $1 --machinereadable |
    grep hostonlyadapter | cut -d'"' -f2)
  if [ "" = "${prop_network_id}" ]; then
    error "Could not find the virtualbox net name!"; exit 1
  fi

  prop_nfshost_ip=$(VBoxManage list hostonlyifs |
    grep "${prop_network_id}" -A 3 | grep IPAddress |
    cut -d ':' -f2 | xargs);
  if [ "" = "${prop_nfshost_ip}" ]; then
    error "Could not find the virtualbox net IP!"; exit 1
  fi

  info "OK"
}

# @info:    Configures the NFS
function configureNFS()
{
  info "Configure NFS..."

  if isPropertyNotSet $prop_machine_ip; then
    error "'prop_machine_ip' not set!"; exit 1;
  fi

  warning "Sudo will be necessary for editing /etc/exports"

  for shared_folder in "${prop_shared_folders[@]}"
  do
    # Update the /etc/exports file and restart nfsd
    (
      echo "$shared_folder $prop_machine_ip $prop_nfs_config" | sudo tee -a /etc/exports
    ) > /dev/null
  done

  sudo nfsd restart ; sleep 2 && sudo nfsd checkexports

  info "OK"
}

# @info:    Configures the VirtualBox Docker Machine to mount nfs
function configureBoot2Docker()
{
  info "Configure Docker Machine..."

  if isPropertyNotSet $prop_machine_name; then
    error "'prop_machine_name' not set!"; exit 1;
  fi
  if isPropertyNotSet $prop_nfshost_ip; then
    error "'prop_nfshost_ip' not set!"; exit 1;
  fi

  # render bootlocal.sh and copy bootlocal.sh over to Docker Machine
  # (this will override an existing /var/lib/boot2docker/bootlocal.sh)

  local bootlocalsh='#!/bin/sh
  sudo umount /Users'

  for shared_folder in "${prop_shared_folders[@]}"
  do
    bootlocalsh="${bootlocalsh}
    sudo mkdir -p "$shared_folder
  done

  bootlocalsh="${bootlocalsh}
  sudo /usr/local/etc/init.d/nfs-client start"

  for shared_folder in "${prop_shared_folders[@]}"
  do
    bootlocalsh="${bootlocalsh}
    sudo mount -t nfs -o "$prop_mount_options" "$prop_nfshost_ip":"$shared_folder" "$shared_folder
  done

  local file="/var/lib/boot2docker/bootlocal.sh"

  docker-machine ssh $prop_machine_name \
    "echo '$bootlocalsh' | sudo tee $file && sudo chmod +x $file && sync" > /dev/null

  sleep 2

  info "OK"
}

# @info:    Restarts Docker Machine
function restartDockerMachine()
{
  info "Restart Docker Machine..."

  if isPropertyNotSet $prop_machine_name; then
    error "'prop_machine_name' not set!"; exit 1;
  fi

  docker-machine restart $prop_machine_name > /dev/null

  info "OK"
}

# @return:  'true', if NFS is mounted; else 'false'
function isNFSMounted()
{
  for shared_folder in "${prop_shared_folders[@]}"
  do
    local nfs_mount=$(docker-machine ssh $prop_machine_name "sudo df" |
      grep "$prop_nfshost_ip:$prop_shared_folders")
    if [ "" = "$nfs_mount" ]; then
      echo "false";
      return;
    fi
  done

  echo "true"
}

# @info:    Verifies that NFS is successfully mounted
function verifyNFSMount()
{
  info "Verify NFS mount..."

  local attempts=10

  while [ ! $attempts -eq 0 ]; do
    sleep 1
    [ "$(isNFSMounted)" = "true" ] && break
    attempts=$(($attempts-1))
  done

  if [ $attempts -eq 0 ]; then
    error "Cannot detect the NFS mount :("; exit 1
  fi

  info "OK"
}

# @info:    Displays the finish message
function showFinish()
{
  echo "\x1b[32m"
  echo "--------------------------------------------"
  echo
  echo " The docker-machine '$prop_machine_name'"
  echo " is now mounted with NFS!"
  echo
  echo " ENJOY high speed mounts :D"
  echo
  echo "--------------------------------------------"
  echo "\x1b[0m"
}

# END _functions

set -o errexit
set -o nounset
set -o pipefail

setPropDefaults

parseCli "$@"

checkMachinePresence $prop_machine_name
checkMachineRunning $prop_machine_name

lookupMandatoryProperties $prop_machine_name

if [ "$(isNFSMounted)" = "true" ] && [ "$prop_force_configuration_nfs" = false ]; then
    info "NFS already mounted." ; showFinish ; exit 0
fi

info "Machine IP: $prop_machine_ip"
info "Network ID: $prop_network_id"
info "NFSHost IP: $prop_nfshost_ip"

configureNFS

configureBoot2Docker
restartDockerMachine

verifyNFSMount

showFinish
