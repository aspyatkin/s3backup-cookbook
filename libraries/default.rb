module ChefCookbook
  module S3BackupHelper
    def self.which_cmd(executable)
      `which #{executable}`.strip
    end
  end
end
