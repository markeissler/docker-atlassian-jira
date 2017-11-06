# Changelog: docker-atlassian-jira

## 1.8.0 / 2017-11-05

Update JIRA to 7.5.2.

## 1.7.0 / 2017-11-05

Update JIRA to 7.5.1.

## 1.6.0 / 2017-09-13

Update JIRA to 7.5.0.

### Minor version increment!

Since this is a Minor version increment be sure to review the release notes and upgrade notes:

  * [JIRA Software 7.5.x release notes](https://confluence.atlassian.com/jirasoftware/jira-software-7-5-x-release-notes-934719297.html)
  * [JIRA Software 7.5.x upgrade notes](https://confluence.atlassian.com/jirasoftware/jira-software-7-5-x-upgrade-notes-934719299.html)

## 1.5.0 / 2017-09-13

Update JIRA to 7.4.4.

## 1.4.0 / 2017-09-13

Update JIRA to 7.4.3.

## 1.3.0 / 2017-09-13

Update JIRA to 7.4.2.

## 1.2.0 / 2017-07/27

Update JIRA to 7.4.1.

### Short list of commit messages

  * Update JIRA to 7.4.1.

## 1.1.0 / 2017-07-10

Update JIRA to 7.4.0.

### Minor version increment!

Since this is a Minor version increment be sure to review the release notes and upgrade notes:

  * [JIRA Software 7.4.x release notes](https://confluence.atlassian.com/jirasoftware/jira-software-7-4-x-release-notes-902079634.html)
  * [JIRA Software 7.4.x upgrade notes](https://confluence.atlassian.com/jirasoftware/jira-software-7-4-x-upgrade-notes-907283484.html)

### Short list of commit messages

  * Update JIRA to 7.4.0.

## 1.0.0 / 2017-06-25

Update JIRA to 7.3.8.

### Short list of commit messages

  * Update README to include link to upstream release notes.
  * Update README for redeployment indexing issues.
  * Update JIRA to 7.3.8.

## 0.11.0 / 2017-06-19

Docker Swarm support! This version adds support for deployment to a cluster with a failover configuration. That is, only
one instance can be active at a time but the failover instance should startup without encountering errors stemming from
a corrupted _felix_ plugin cache.

Lucene indexes have been moved out of the Docker host's persistence directory so that configurations that enable data
persistence with NFS can be better supported (Lucene doesn't get along with NFS).

### Short list of commit messages

  * Update README for ephemeral storage and Swarm support.
  * Use ephemeral storage for caches

## 0.10.0 / 2017-06-18

Secure connection support! This version adds support for SSL certificates.

### Short list of commit messages

  * Update docker-entrypoint to import PKCS12 certificate found in JIRA_HOME directory at startup.
  * Add sysadmin login troubleshooting info when migrating from Cloud to Server.

## 0.9.0 / 2017-06-11

Initial release! A _dockerized_ [Atlassian Jira](https://www.atlassian.com/software/jira) install.

### Short list of commit messages

  * Update README for v0.9.0.
