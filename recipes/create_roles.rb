#
# Cookbook:: devops
# Recipe:: create_roles 
#
# Copyright:: 2017, The Authors, All Rights Reserved.

devops_n = node['devops']
String vault_addr = '127.0.0.1' # localhost 
String vault_token = devops_n['vault_token'].to_s
String role_json_file_path = '/tmp/role.json'
String curl_command = "curl -s -k -X POST -H \"x-Vault-Token: #{vault_token}\" -d @/tmp/role.json #{vault_addr}/v1/ssh-client-signer/roles/student"

# Create the JSON file that defines the role
template 'create_role_json' do
  path role_json_file_path 
  source 'role.json.erb'
  action :create
  notifies :run, 'execute[write_role]', :delayed
end

# Write the role via the API in Vault
execute 'write_role' do
  command curl_command
  action :nothing
end

