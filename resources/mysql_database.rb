id = 's3backup'

resource_name :s3backup_mysql_database

property :entry_name, String, name_property: true

property :db_host, String, required: true
property :db_port, Integer, required: true
property :db_name, String, required: true
property :db_username, String, required: true
property :db_password, String, required: true
property :options, Hash, required: true

property :aws_iam_access_key_id, String, required: true
property :aws_iam_secret_access_key, String, required: true
property :aws_s3_bucket_region, String, required: true
property :aws_s3_bucket_name, String, required: true

property :schedule, Hash, required: true
property :archive, [TrueClass, FalseClass], default: true

default_action :create

action :create do
  basedir = "/etc/chef-#{id}"
  instance = ::ChefCookbook::Instance::Helper.new(node)

  include_recipe "#{id}::default"

  script_filepath = ::File.join(basedir, "backup_#{new_resource.entry_name}")

  template script_filepath do
    cookbook id
    source 'backup.mysql.sh.erb'
    owner instance.root
    group node['root_group']
    variables(
      virtualenv_path: ::File.join(basedir, '.venv'),
      entry_name: new_resource.entry_name,
      mysql_host: new_resource.db_host,
      mysql_port: new_resource.db_port,
      mysql_dbname: new_resource.db_name,
      mysql_username: new_resource.db_username,
      mysql_password: new_resource.db_password,
      mysqldump_options: new_resource.options,
      aws_iam_access_key_id: new_resource.aws_iam_access_key_id,
      aws_iam_secret_access_key: new_resource.aws_iam_secret_access_key,
      aws_s3_bucket_region: new_resource.aws_s3_bucket_region,
      aws_s3_bucket_name: new_resource.aws_s3_bucket_name,
      archive: new_resource.archive
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
