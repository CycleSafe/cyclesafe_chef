
node.default[:cyclesafe_chef][:user] = 'cyclesafe'
node.default[:cyclesafe_chef][:group] = 'cyclesafe'
node.default[:cyclesafe_chef][:directory] = '/srv/cyclesafe'
node.default[:cyclesafe_chef][:requirements_file] = 'prod_requirements.txt'
node.default[:cyclesafe_chef][:db_name] = 'default'
node.default[:cyclesafe_chef][:hostname] = 'cyclesafe.us'
node.default[:cyclesafe_chef][:debug_mode] = false

# as a string, converted into symbol later
node.default[:cyclesafe_chef][:deploy_action] = 'deploy'
