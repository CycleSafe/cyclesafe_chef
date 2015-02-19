
include_recipe 'cyclesafe_chef'

if node['instance_role'] == 'vagrant'
  database_password = data_bag_item('passwords','database')['mysql']
else
  database_password = chef_vault_item('passwords','database')['mysql']
end


db_name = node[:cyclesafe_chef][:db_name]

mysql_service db_name do
  version '5.5'
  port '3306'
  bind_address '127.0.0.1'
  initial_root_password database_password
  action [:create,:start]
  notifies :run, 'execute[apt-get update]', :immediately
end

user 'cyclesafe' do
  home node[:cyclesafe_chef][:directory]
  shell '/bin/bash'
  system true
end

directory node[:cyclesafe_chef][:directory] do
  action :create
  recursive true
  owner node[:cyclesafe_chef][:user]
  group node[:cyclesafe_chef][:group]
  mode 0755
end

template "#{node[:cyclesafe_chef][:directory]}/django_db.sql" do
  source 'django_db.sql.erb'
  variables ({
    :db_name => 'cyclesafe',
    :db_pass => database_password,
    :db_user => 'cyclesafe'
    })
  action :create
  owner node[:cyclesafe_chef][:user]
  group node[:cyclesafe_chef][:group]
  mode 0755
end

bash 'install_cyclesafe_user' do
  code "mysql -u root -p#{database_password} -h 127.0.0.1 < django_db.sql"
  cwd "#{node[:cyclesafe_chef][:directory]}"
  sensitive true
  user 'root'
end

# symbolic link to websocket, place where django expects it 
#     (because django isn't smart about mysql sockets yet)
symlink_dir = "/var/run/mysqld"
symlink_destination = "#{symlink_dir}/mysqld.sock"

# make sure mysqld directory exists
directory symlink_dir do
  action :create
  owner 'mysql'
  group 'mysql'
  mode 0777
  recursive true
  not_if {::File.exists?(symlink_dir)}
end

# then symlink the socket
bash 'symlink_mysql socket create' do
  code "ln -s /var/run/mysql-#{db_name}/mysqld.sock #{symlink_destination}"
  user 'root'
  sensitive true
  not_if {::File.exists?(symlink_destination)}
end
