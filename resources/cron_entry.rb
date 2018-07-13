resource_name :s3backup_cron_entry

property :entry_name, String, name_property: true
property :command, String, required: true
property :schedule, Hash, required: true

default_action :create

action :create do
  full_command = nil
  helper = ::ChefCookbook::BetterSSMTP::Helper.new(node)
  schedule = new_resource.schedule

  ruby_block "construct #{new_resource.entry_name} command" do
    block do
      full_command = "#{node.run_state['cronic_installed'] ? "#{node.run_state['cronic_command']} " : ''}#{new_resource.command}"

      unless schedule.fetch(:mailto, nil).nil? && schedule.fetch(:mailfrom, nil).nil?
        full_command += " 2>&1 | #{helper.mail_send_command('Cron ' + new_resource.entry_name, schedule[:mailfrom], schedule[:mailto], node.run_state['cronic_installed'])}"
      end
    end
    action :run
  end

  cron new_resource.entry_name do
    command lazy { full_command }
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
  helper = ::ChefCookbook::BetterSSMTP::Helper.new(node)
  schedule = new_resource.schedule

  ruby_block "construct #{new_resource.entry_name} command" do
    block do
      full_command = "#{node.run_state['cronic_installed'] ? "#{node.run_state['cronic_command']} " : ''}#{new_resource.command}"

      unless schedule.fetch(:mailto, nil).nil? && schedule.fetch(:mailfrom, nil).nil?
        full_command += " 2>&1 | #{helper.mail_send_command('Cron ' + new_resource.entry_name, schedule[:mailfrom], schedule[:mailto], node.run_state['cronic_installed'])}"
      end
    end
    action :run
  end

  cron new_resource.entry_name do
    command lazy { full_command }
    minute schedule.fetch(:minute, '0')
    hour schedule.fetch(:hour, '2')
    day schedule.fetch(:day, '*')
    month schedule.fetch(:month, '*')
    weekday schedule.fetch(:weekday, '*')
    action :delete
  end
end
