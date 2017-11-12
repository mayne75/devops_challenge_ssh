#
# Cookbook:: devops
# Recipe:: create_students 
#
# Copyright:: 2017, The Authors, All Rights Reserved.

devops_n = node['devops']
String vault_addr = devops_n['vault_addr'].to_s 
String vault_token = devops_n['vault_token'].to_s
id = 100000

# Create more students
%w{homer marge lisa bart}.each do |username|
  
  String groupname = username
  id = id + 1
    
  # Create a group for the students
  group groupname do
    gid id
    action :create
  end

  user username do
    comment "Student"
    uid id
    gid id
    home "/home/#{username}"
    shell "/bin/bash"
    manage_home true
    action :create
  end

  # Also add student to existing groups
  %w{adm dialout cdrom floppy sudo audio dip video plugdev netdev lxd}.each do |g|
    group g do
      action :modify
      members "#{username}"
      append true
    end
  end
end