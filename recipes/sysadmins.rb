
# include the sysadmins recipe
# don't install public keys and password hashes on vagrant machines
include_recipe 'users::sysadmins'
include_recipe 'openssh'
include_recipe 'sudo'
