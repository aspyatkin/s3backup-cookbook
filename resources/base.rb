resource_name :s3backup_base

property :base_dir, String, name_property: true

default_action :create

action :create do
  instance = ::ChefCookbook::Instance::Helper.new(node)

  directory new_resource.base_dir do
    owner instance.root
    group node['root_group']
    mode 0o700
    recursive true
    action :create
  end
end
