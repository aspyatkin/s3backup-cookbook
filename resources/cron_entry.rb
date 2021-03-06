resource_name :s3backup_cron_entry

property :name, String, name_property: true
property :command, String, required: true
property :schedule, Hash, required: true

default_action :create

action :create do
  full_command = nil
  helper = nil
  if !node.run_state['ssmtp'].nil? && node.run_state['ssmtp']['installed']
    helper = ::ChefCookbook::SSMTP::Helper.new(node)
  end
  schedule = new_resource.schedule

  ruby_block "construct #{new_resource.name} command" do
    block do
      cronic_installed = !node.run_state['cronic'].nil? && node.run_state['cronic']['installed']
      full_command = "#{cronic_installed ? "#{node.run_state['cronic']['command']} " : ''}#{new_resource.command}"

      unless helper.nil? || schedule.fetch(:mailto, nil).nil? || schedule.fetch(:mailfrom, nil).nil?
        full_command += " 2>&1 | #{helper.mail_send_command('Cron ' + new_resource.name, schedule[:mailfrom], schedule[:mailto], cronic_installed)}"
      end
    end
    action :run
  end

  cron new_resource.name do
    command(lazy { full_command })
    minute schedule.fetch(:minute, '0')
    hour schedule.fetch(:hour, '2')
    day schedule.fetch(:day, '*')
    month schedule.fetch(:month, '*')
    weekday schedule.fetch(:weekday, '*')
    action :create
  end
end

action :delete do
  full_command = nil
  helper = nil
  if !node.run_state['ssmtp'].nil? && node.run_state['ssmtp']['installed']
    helper = ::ChefCookbook::SSMTP::Helper.new(node)
  end
  schedule = new_resource.schedule

  ruby_block "construct #{new_resource.name} command" do
    block do
      cronic_installed = !node.run_state['cronic'].nil? && node.run_state['cronic']['installed']
      full_command = "#{cronic_installed ? "#{node.run_state['cronic']['command']} " : ''}#{new_resource.command}"

      unless helper.nil? || schedule.fetch(:mailto, nil).nil? || schedule.fetch(:mailfrom, nil).nil?
        full_command += " 2>&1 | #{helper.mail_send_command('Cron ' + new_resource.name, schedule[:mailfrom], schedule[:mailto], cronic_installed)}"
      end
    end
    action :run
  end

  cron new_resource.name do
    command(lazy { full_command })
    minute schedule.fetch(:minute, '0')
    hour schedule.fetch(:hour, '2')
    day schedule.fetch(:day, '*')
    month schedule.fetch(:month, '*')
    weekday schedule.fetch(:weekday, '*')
    action :delete
  end
end
