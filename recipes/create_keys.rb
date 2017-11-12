#
# Cookbook:: devops
# Recipe:: create_keys 
#
# Copyright:: 2017, The Authors, All Rights Reserved.

devops_n = node['devops']
String vault_addr = devops_n['vault_addr'].to_s 
String vault_token = devops_n['vault_token'].to_s

# Install jq to use with the JSON returned from the API
apt_package 'jq' do
  action :install
end
    
%w{ubuntu homer marge bart lisa}.each do |username|
#%w{ubuntu}.each do |username|    
  String student_script_file_path = "/home/#{username}/create_student_keys.sh"
  String delete_script_file_path = "/home/#{username}/delete_student_role.sh"
  String groupname = username
    
  # Unsigned ssh key pair 
  execute 'create_unsigned_key_pair' do
    user username 
    group groupname
    command "ssh-keygen -t rsa -N '' -f /home/#{username}/.ssh/unsigned.rsa"
    action :run
  end

  # Set permissions
  execute 'set_permissions' do
    user username 
    group groupname
    command "chmod 700 /home/#{username}/.ssh && chmod 400 /home/#{username}/.ssh/*"
    action :run
  end
    
  # Set owner
  execute 'set_permissions' do
    user username 
    group groupname
    command "chown #{username}:#{groupname} /home/#{username}/.ssh/*"
    action :run
  end
     
  # Create the student bash script
  template 'sign_pub_key_script' do
    user username 
    group groupname
    path student_script_file_path 
    source 'create_student_keys.sh.erb'
    mode '0755'
    variables(
      username: username,
      vault_addr: vault_addr,
      vault_token: vault_token 
    )
    action :create
  end

  # Run the student script that signs and creates a new pub to use with unsigned private key
  execute 'run_signed_pub_key_script' do
    user username 
    group groupname
    command "bash #{student_script_file_path}"
    action :run
  end
  
  # Create the delete student bash script
  template 'delete_script' do
    user username 
    group groupname
    path delete_script_file_path 
    source 'delete_student_role.sh.erb'
    mode '0755'
    variables(
      username: username,
      vault_addr: vault_addr,
      vault_token: vault_token 
    )
    action :create
  end
end
