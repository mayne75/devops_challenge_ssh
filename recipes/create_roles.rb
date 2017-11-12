#
# Cookbook:: devops
# Recipe:: create_roles 
#
# Copyright:: 2017, The Authors, All Rights Reserved.

devops_n = node['devops']
String vault_addr = devops_n['vault_addr'].to_s 
String vault_token = devops_n['vault_token'].to_s

# Create the JSON file that defines the role
%w{ubuntu homer marge bart lisa}.each do |username|
#%w{ubuntu}.each do |username|

  String groupname = username
  String role_json_file_path = "/home/#{username}/role.json"
  String create_script_file_path = "/home/#{username}/create_student_role.sh"
     
  template 'create_role_json' do
    user username
    group groupname
    mode '0755'
    path role_json_file_path 
    source 'role.json.erb'
    #variables(
    #  username: username 
    #)
    action :create
  end

  # Write the role via the API in Vault
  #execute 'write_role' do
    #String curl_command = "curl -s -k -X POST -H \"x-Vault-Token: #{vault_token}\" -d @/home/#{username}/role.json #{vault_addr}/v1/ssh-client-signer/roles/#{username}"
    #command curl_command
    #action :run
  #end
    
  # Create the student bash script
  template 'create_student_role_script' do
    user username 
    group groupname
    path create_script_file_path 
    source 'create_student_role.sh.erb'
    mode '0755'
    variables(
      username: username,
      vault_addr: vault_addr,
      vault_token: vault_token 
    )
    action :create
  end

  # Run the student script that signs and creates a new pub to use with unsigned private key
  execute 'run_create_student_role_script' do
    user username 
    group groupname
    command "bash #{create_script_file_path}"
    action :run
  end
end

