# Changelog: docker-atlassian-jira

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
