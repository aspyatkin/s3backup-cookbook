resource_name :s3backup_base

property :basedir, String, name_property: true

default_action :create

action :create do
  instance = ::ChefCookbook::Instance::Helper.new(node)

  directory new_resource.basedir do
    owner instance.root
    group node['root_group']
    mode 0700
    recursive true
    action :create
  end

  virtualenv_path = ::File.join(new_resource.basedir, '.venv')

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
end
