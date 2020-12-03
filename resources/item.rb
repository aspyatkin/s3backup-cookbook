resource_name :s3backup_item

property :name, String, name_property: true
property :action_name_template, String, default: 'backup_%{name}'

property :python, String, default: '2'

property :backup_command, String, required: true
property :check_command, [String, NilClass], default: nil

property :aws_iam_access_key_id, String, required: true
property :aws_iam_secret_access_key, String, required: true
property :aws_s3_bucket_region, String, required: true
property :aws_s3_bucket_name, String, required: true

property :schedule, Hash, required: true

default_action :create

action :create do
  basedir = '/etc/chef-s3backup'

  s3backup_base basedir do
    python new_resource.python
    action :create
  end

  action_name = new_resource.action_name_template % { name: new_resource.name }
  script_filepath = ::File.join(basedir, action_name)
  virtualenv_path = ::File.join(basedir, '.venv')

  template script_filepath do
    cookbook 's3backup'
    source 'backup.item.sh.erb'
    owner 'root'
    group node['root_group']
    variables(lazy {
      {
        name: new_resource.name,
        backup_command: new_resource.backup_command,
        check_command: new_resource.check_command,
        virtualenv_path: virtualenv_path,
        aws_iam_access_key_id: new_resource.aws_iam_access_key_id,
        aws_iam_secret_access_key: new_resource.aws_iam_secret_access_key,
        aws_s3_bucket_region: new_resource.aws_s3_bucket_region,
        aws_s3_bucket_name: new_resource.aws_s3_bucket_name
      }
    })
    mode 0o700
    sensitive true
    action :create
  end

  s3backup_cron_entry action_name do
    command script_filepath
    schedule new_resource.schedule
    action :create
  end
end

action :delete do
  action_name = new_resource.action_name_template % { name: new_resource.name }
  script_filepath = ::File.join(basedir, action_name)

  file script_filepath do
    action :delete
  end

  s3backup_cron_entry action_name do
    command script_filepath
    schedule new_resource.schedule
    action :delete
  end
end
