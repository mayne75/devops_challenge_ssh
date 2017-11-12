#
# Cookbook:: devops
# Recipe:: vault_install 
#
# Copyright:: 2017, The Authors, All Rights Reserved.

devops_n = node['devops']
String vault_addr = 'http://0.0.0.0:8200' # Container 
String vault_token = devops_n['vault_token'].to_s

# Install Docker
docker_installation 'default' do
  action :create
end

# Pull Vault image
docker_image 'vault' do
  action :pull_if_missing
end

# Run the vault-dev conatiner, important this for a DEMO so its unsealed and data does not persist
docker_container 'vault-dev' do
    repo 'vault'
    cap_add 'IPC_LOCK'
    env ["VAULT_DEV_ROOT_TOKEN_ID=#{vault_token}", 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200']
    port '80:8200'
    action :run_if_missing
end

# Token create
#docker_exec 'vault_create_a_token' do
#  container 'vault-dev'
#  command ['vault', 'token-create', "#{vault_token}"]
#  action :run
#end

# Export ENV
docker_exec 'set_env' do
   container 'vault-dev'
   command ['export', "VAULT_ADDR=#{vault_addr}"]
   action :run
end

# Check the status of the vault
docker_exec 'vault_status' do
  container 'vault-dev'
  command ['vault', 'status', "-address=#{vault_addr}"]
  action :run
end

# Authenticate using the VAULT_TOKEN
docker_exec 'vault_auth' do
  container 'vault-dev'
  command ['vault', 'auth', "-address=#{vault_addr}", "#{vault_token}"]
  action :run
end

# Mount the SSH Backend
docker_exec 'vault_mount' do
  container 'vault-dev'
  command ['vault', 'mount', "-address=#{vault_addr}", '-path=ssh-client-signer', 'ssh']
  action :run
end

# Let Vault generate the Host key pair, the public key will be added to the Servers 
docker_exec 'vault_write' do
  container 'vault-dev'
  command ['vault', 'write', "-address=#{vault_addr}", 'ssh-client-signer/config/ca', 'generate_signing_key=true']
  action :run
end

