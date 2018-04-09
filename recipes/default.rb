id = 's3backup'

basedir = "/etc/chef-#{id}"
instance = ::ChefCookbook::Instance::Helper.new(node)

directory basedir do
  owner instance.root
  group node['root_group']
  mode 0700
  recursive true
  action :create
end

virtualenv_path = ::File.join(basedir, '.venv')

python_virtualenv virtualenv_path do
  python '2'
  user instance.root
  group node['root_group']
  action :create
end

python_package 'awscli' do
  user instance.root
  group node['root_group']
  virtualenv virtualenv_path
  action :install
end
