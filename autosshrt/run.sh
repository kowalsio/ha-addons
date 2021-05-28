#!/usr/bin/with-contenv bashio

KEY_PATH=/data/autosshrt/ssh_keys

#Options
HOSTNAME=$(bashio::config 'hostname')
SSH_PORT=$(bashio::config 'ssh_port')
USERNAME=$(bashio::config 'username')
REMOTE_FORWARDING=$(bashio::config 'remote_forwarding[]')
OTHER_SSH_OPTIONS=$(bashio::config 'other_ssh_options')
REGENERATE_KEY=$(bashio::config 'regenerate_key')
MONITOR_PORT=$(bashio::config 'monitor_port')
MINITOR_PORT_ENABLE=$(bashio::config 'monitor_port_enable')

bashio::log.debug "Starting AutoSSH Remote Tunnel ..."

# SSH Keys
# Delete existing SSH keys
if [ "$REGENERATE_KEY" != "false" ]; then
  bashio::log.info "Deleting existing key pair due to set 'regenerate_key' option"
  bashio::log.info "Do not forget to set 'regenerate_key' option to false, in your add-on configuration"
  rm -rf "$KEY_PATH"
fi
# Generate or restore SSH keys
if [ ! -d "$KEY_PATH" ]; then
  # SSH keys not found, generate new ones
  bashio::log.info "SSH keys not found"
  bashio::log.info "Generating new SSH keys"
  mkdir -p "$KEY_PATH"
  ssh-keygen -b 4096 -t rsa -N "" -f "${KEY_PATH}/autossh_rsa_key"
  bashio::log.info "The public key is:"
  cat "${KEY_PATH}/autossh_rsa_key.pub"
  bashio::log.info "Add public key to '~/.ssh/authorized_keys' on your remote server"
  bashio::log.info "Please restart add-on when done. Exiting..."
  exit 1
else
  bashio::log.info "Restoring SSH keys"
  if [ ! -f "$KEY_PATH/autossh_rsa_key" ]; then
    bashio::log.warning "Unable to restore SSH keys"
    bashio::log.warning "Please use 'regenerate_key' option to generate new SSH keys"
    exit 1
  else
    bashio::log.info "Authentication key pair restored"
    bashio::log.info "The public key is:"
    cat "${KEY_PATH}/autossh_rsa_key.pub"
    bashio::log.info "Add public key to '~/.ssh/authorized_keys' on your remote server"
  fi
fi


# Check required options
# Remote server host or IP address
if [ -z "$HOSTNAME" ]; then
  bashio::log.error "Please set 'hostname' in your config"
  exit 1
fi
# Remote server SSH port (def. 22)
if [ -z "$SSH_PORT" ]; then
  bashio::log.error "Please set 'ssh_port' in your config"
  exit 1
fi
# Remote server username
if [ -z "$USERNAME" ]; then
  bashio::log.error "Please set 'username' in your config"
  exit 1
fi


#Test before autossh connect
TEST_COMMAND="/usr/bin/ssh "\
"-o BatchMode=yes "\
"-o ConnectTimeout=5 "\
"-o PubkeyAuthentication=no "\
"-o PasswordAuthentication=no "\
"-o KbdInteractiveAuthentication=no "\
"-o ChallengeResponseAuthentication=no "\
"-o StrictHostKeyChecking=no "\
"-p ${SSH_PORT} -t -t "\
"test@${HOSTNAME} "\
"2>&1 || true"

if eval "${TEST_COMMAND}" | grep -q "Permission denied"; then
  bashio::log.info "Testing SSH connection... SSH service reachable on remote server"
else
  eval "${TEST_COMMAND}"
  bashio::log.error "SSH service can't be reached on remote server. Exiting..."
  exit 1
fi

if [ "$MINITOR_PORT_ENABLE" != "false" ]; then
  bashio::log.info "Port monitor enabled"
else
  bashio::log.info "Port monitor disabled"
  MONITOR_PORT = 0 
fi

bashio::log.info "Remote server host keys:"
ssh-keyscan -p $SSH_PORT $HOSTNAME || true


COMMAND="/usr/bin/autossh "\
" -M ${MONITOR_PORT} -N "\
"-o ServerAliveInterval=30 "\
"-o ServerAliveCountMax=3 "\
"-o StrictHostKeyChecking=no "\
"-o ExitOnForwardFailure=yes "\
"-p ${SSH_PORT} -t -t "\
"-i ${KEY_PATH}/autossh_rsa_key "\
"${USERNAME}@${HOSTNAME}"

if [ ! -z "${REMOTE_FORWARDING}" ]; then
  while read -r LINE; do
    COMMAND="${COMMAND} -R ${LINE}"
  done <<< "${REMOTE_FORWARDING}"
fi

COMMAND="${COMMAND} ${OTHER_SSH_OPTIONS}"

bashio::log.info "Executing command: ${COMMAND}"

# Execute
exec ${COMMAND}