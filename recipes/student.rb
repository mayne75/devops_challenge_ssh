#
# Cookbook:: devops
# Recipe:: student 
#
# Copyright:: 2017, The Authors, All Rights Reserved.

devops_n = node['devops']
String vault_addr = devops_n['vault_addr'].to_s 
String vault_token = devops_n['vault_token'].to_s
String student_script_file_path = '/tmp/student.sh'

# Install jq to use with the JSON returned from the API
apt_package 'jq' do
  action :install
end

# Unsigned ssh key pair 
execute 'create_unsigned_key_pair' do
  user 'ubuntu'
  command "ssh-keygen -t rsa -N '' -f /home/ubuntu/.ssh/unsigned.rsa"
  action :run
  notifies :create, 'template[sign_pub_key_script]', :immediately
end

# Create the student bash script
template 'sign_pub_key_script' do
  path student_script_file_path 
  source 'student.sh.erb'
  mode '0755'
  variables(
    vault_addr: vault_addr,
    vault_token: vault_token 
  )
  action :nothing
  notifies :run, 'execute[run_signed_pub_key_script]', :immediately
end

# Run the student script that signs and creates a new pub to use with unsigned private key
execute 'run_signed_pub_key_script' do
  command "bash #{student_script_file_path}"
  action :nothing
  notifies :delete, "template[#{student_script_file_path}]", :delayed
end

# Clean up script which removes the vault_token from the students machine
template student_script_file_path do
  action :nothing
end

