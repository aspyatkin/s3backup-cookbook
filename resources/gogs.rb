id = 's3backup'

resource_name :s3backup_gogs

property :entry_name, String, name_property: true

property :gogs_user, String, required: true
property :gogs_user_home, String, required: true
property :gogs_work_dir, String, required: true

property :aws_iam_access_key_id, String, required: true
property :aws_iam_secret_access_key, String, required: true
property :aws_s3_bucket_region, String, required: true
property :aws_s3_bucket_name, String, required: true

property :schedule, Hash, required: true

default_action :create

action :create do
  basedir = "/etc/chef-#{id}"
  instance = ::ChefCookbook::Instance::Helper.new(node)

  include_recipe "#{id}::default"

  script_filepath = ::File.join(basedir, "backup_#{new_resource.entry_name}")

  template script_filepath do
    cookbook id
    source 'backup.gogs.sh.erb'
    owner instance.root
    group node['root_group']
    variables(
      virtualenv_path: ::File.join(basedir, '.venv'),
      entry_name: new_resource.entry_name,
      gogs_user: new_resource.gogs_user,
      gogs_user_home: new_resource.gogs_user_home,
      gogs_work_dir: new_resource.gogs_work_dir,
      aws_iam_access_key_id: new_resource.aws_iam_access_key_id,
      aws_iam_secret_access_key: new_resource.aws_iam_secret_access_key,
      aws_s3_bucket_region: new_resource.aws_s3_bucket_region,
      aws_s3_bucket_name: new_resource.aws_s3_bucket_name
    )
    mode 0700
    sensitive true
    action :create
  end

  s3backup_cron_entry "backup_#{new_resource.entry_name}" do
    command script_filepath
    schedule new_resource.schedule
    action :create
  end
end

action :delete do
  script_filepath = ::File.join('/etc', "chef-#{id}", "backup_#{new_resource.entry_name}")

  file script_filepath do
    action :delete
  end

  s3backup_cron_entry "backup_#{new_resource.entry_name}" do
    command script_filepath
    schedule new_resource.schedule
    action :delete
  end
end
