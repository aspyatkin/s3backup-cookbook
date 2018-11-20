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

## License
MIT © [Alexander Pyatkin](https://github.com/aspyatkin)
