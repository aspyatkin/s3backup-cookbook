require 'etc'
require 'mixlib/versioning'

resource_name :s3backup_base

property :base_dir, String, name_property: true
property :python, String, default: '2'

default_action :create

action :create do
  directory new_resource.base_dir do
    owner 'root'
    group node['root_group']
    mode 0o700
    recursive true
    action :create
  end

  virtualenv_path = ::File.join(new_resource.base_dir, '.venv')
  passwd_entry = ::Etc.getpwnam('root')
  python_version = ::Mixlib::Versioning.parse(new_resource.python)

  virtualenv_cmd = nil
  if python_version.major == 2
    virtualenv_cmd = "python2 -m virtualenv #{virtualenv_path}"
  elsif python_version.major == 3
    virtualenv_cmd = "python3 -m venv #{virtualenv_path}"
  end

  bash "create virtualenv at #{virtualenv_path}" do
    code virtualenv_cmd
    user 'root'
    group node['root_group']
    environment 'HOME' => passwd_entry.dir
    action :run
    not_if { ::File.exist?(virtualenv_path) }
  end

  bash "install pip requirements at #{virtualenv_path}" do
    code <<-EOH
      source #{virtualenv_path}/bin/activate
      pip install awscli
      deactivate
    EOH
    user 'root'
    group node['root_group']
    environment 'HOME' => passwd_entry.dir
    action :run
  end
end
