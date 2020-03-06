# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2020-03-05

### Added
- `python` property is added to `s3backup_item` resource.

### Changed
- install `awscli` in a virtualenv.
- no longer dependent on `instance` cookbook

## [3.0.0] - 2020-03-04

### Changed
- `poise-python` is no longer a dependency.

## [2.2.0] - 2019-03-26

Check whether to run backup or not.

### Added
- `check_command` property is added to `s3backup_item` resource.

## [2.1.0] - 2019-03-25

Make use of `ssmtp-lwrp` cookbook.

## [2.0.0] - 2018-11-20

Rewrite the cookbook.

### Added
- `s3backup_item` is added.

### Removed
- the default recipe is removed.
- `s3backup_gogs`, `s3backup_mysql_database`, `s3backup_postgres_database` resources are removed.

## [1.0.5] - 2018-07-13

Create the cookbook.
