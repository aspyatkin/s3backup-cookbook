# s3backup-cookbook
Chef cookbook to setup a scheduled backup on Amazon S3.

## Concept

This cookbook is useful to setup an application or a database backup on a regular basis. It is expected that this resource (application, database etc.) provides a backup script which can be called with one parameter (a temporary directory), like below:

```sh
$ myapp-backup.sh /tmp/myapp-backup-storage
```

The backup script is supposed to create a backup archive (e.g. a database dump) and save it to the directory specified by the first parameter.

The backup process is triggered by cron. During the process:
- a temporary directory is created;
- a resource backup script is called;
- all files placed in the temporary directory are uploaded to Amazon S3;
- the temporary directory is removed.

It may be useful to run a script beforehand so as to decide whether to proceed with a backup or not. From `2.2.0` a new property `check_command` is added to `s3backup_item` resource. When a script in `check_command` returns `0`, a backup process will proceed.

## Prerequisites

- python
- pip
- awscli pip package

One can use the following Chef snippets (Ubuntu) so as to install them:

```ruby
# the snippet was tested on Ubuntu. Package names may be different in other Linux distributions.

# Python 2
package 'python2.7'
package 'python-pip'

execute 'pip install awscli' do
  action :run
end

# Python 3
# package 'python3'
# package 'python3-pip'

# execute 'pip3 install awscli' do
#   action :run
# end
```

## Usage

For instance, this is how an application backup could be setup. The schedule is set with the cron-like syntax.

```ruby
s3backup_item 'myapp' do
  backup_command '/usr/local/bin/myapp-backup'
  aws_iam_access_key_id 'AKIA...'
  aws_iam_secret_access_key 'tLSy...'
  aws_s3_bucket_region 'us-east-1'
  aws_s3_bucket_name 'myapp.example'
  schedule(
    mailto: 'admin@myapp.example',
    mailfrom: "Myapp <cron@myapp.example>",
    minute: '0',
    hour: '3',
    day: '*',
    month: '*',
    weekday: '*'
  )
  action :create
end
```

### check_command use case

A script in `check_command` can, for instance, log into a special email account and search for a message from a whitelisted address (e.g. ops team). If there is such a message, the script will exit with code `0`, thus confirming the request for a backup.

## License
MIT © [Alexander Pyatkin](https://github.com/aspyatkin)
