#
# Cookbook:: devops
# Recipe:: server 
#
# Copyright:: 2017, The Authors, All Rights Reserved.

devops_n = node['devops']
String vault_addr = devops_n['vault_addr'].to_s

# Install OpenSSH Server
apt_package 'openssh-server' do
  action :install
end

# Vault provides a public keyi via API to add onto each of the hosts
execute 'add_public_key' do
  command "sudo curl -o /etc/ssh/trusted-user-ca-keys.pem #{vault_addr}/v1/ssh-client-signer/public_key"
  action :run
  notifies :run, 'execute[add_path_to_trusted_users]', :immediately
end

# Add this public key to trusted users 
execute 'add_path_to_trusted_users' do
  command "sudo printf \"\\nTrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem\" >> /etc/ssh/sshd_config"
  action :nothing
  notifies :run, 'execute[restart_sshd_service]', :delayed
end

# Restart the SSHD service so that the changes take hold
execute 'restart_sshd_service' do
  command "sudo service sshd restart"
  action :nothing
end
