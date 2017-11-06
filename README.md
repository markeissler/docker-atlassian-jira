# Atlassian Jira for Docker

__docker-atlassian-jira__ provides [Atlassian Jira](https://www.atlassian.com/software/jira) in a [docker](https://www.docker.com/)
container to support issue and project tracking for software teams.

## Overview

This revision of __docker-atlassian-jira__ will install:

[JIRA 7.5.1](https://confluence.atlassian.com/jirasoftware/issues-resolved-in-7-5-1-939495773.html)

## Installation

This application is ready to launch on a Docker host:

```sh
prompt> docker run -d -p 8080:8080 -p 8443:8443 markeissler/atlassian-jira:latest
```

## Usage

<a name="data-persistence"></a>

### Data Persistence

As configured, data on the following volumes will be created to persist data between container starts:

| Volume | Purpose                                                    |
|:-------|:-----------------------------------------------------------|
| /var/atlassian/jira                     | application configuration |
| /opt/atlassian/jira/logs                | runtime logs              |

<a name="data-persistence-nfs"></a>

### Data Persistence over NFS

It may be desirable to configure data persistence over NFS, in which case NFS volumes are mounted at the locations
described in the [Data Persistence](#data-persistence) section above. NFS support requires that the underlying Docker
host supports NFS; if deploying to a [Docker swarm](https://docs.docker.com/engine/swarm/) a potential __boot2docker.iso__
candidate that supports NFS is the [boot2docker-nfs.iso](https://github.com/markeissler/boot2docker-nfs).

Certain JIRA directories are moved out of the application configuration directory and into an ephemeral runtime storage
area to prevent data corruption startup failures. Specfically, cache directories are moved so that clean re-starts
are possible; often, when an instance dies Tomcat will not be shutdown cleanly and data corruption is likely to occur
with regard to the _felix_ plugin cache).

| Directory | Purpose                                                    |
|:----------|:-----------------------------------------------------------|
| /var/atlassian/jira_runtime   | runtime storage for caches and indexes |

### SSL Support

You can enable SSL by simply copying a PKCS12 format certificate (`certificate.p12`) into the `JIRA_HOME` directory
(`/var/atlassian/jira`) and then restarting the container. The PKCS12 file format has been selected to make it easier to
generate certificates using `openssl`.

An example `openssl` command that will create a PKCS12 file from a private key (`server_key.pem`) and public certficate
(`server_cert.pem`) follows:

```sh
prompt> openssl pkcs12 -export -in server_cert.pem \
    -inkey server_key.pem -out certificate.p12 \
    -passout pass:changeit -name "jira"
```

On container startup, the PCKS12 format certificate.p12 file will be converted and stored in the system JKS keystore.

## Docker Swarm Support

While __docker-atlassian-jira__ does not support multi-node clustering it does support deployment to a cluster with a
failover configuration (where only a single JIRA instance is active at any time).

This configuration requires that [Data Persistence over NFS](#data-persistence-nfs) has been configured to share JIRA
configuration information among replicated instances.

## Redeployment Index Regeneration

Indexes are stored in ephemeral storage; consequently, when redeploying the application on top of existing persistent
storage (i.e. [Data Persistence over NFS](#data-persistence-nfs)) it will be necessary to manually trigger a rebuild of
all indexes. Log in as a user with administrative permissions, then navigate to:

`Cog > System > Advanced > Indexing`

Click on the <kbd>Re-Index</kbd> button.

## Troubleshooting

For general troubleshooting information check the [Troubleshoot](troubleshoot.md) document.

## Upstream Release Notes

Release notes for all versions of JIRA can be viewed online:

[JIRA Release Notes](https://confluence.atlassian.com/jirasoftware/jira-software-release-notes-776821069.html)

## Authors

__docker-atlassian-jira__ is the work of __Mark Eissler__.

## Attributions

__docker-atlassian-jira__ was inspired by the work of [Martin Aksel Jensen](https://github.com/cptactionhank),
specifically his ongoing efforts to provide up-to-date _dockerized_ versions of other popular [Atlassian](https://www.atlassian.com/)
applications.

## License

__docker-atlassian-jira__ is licensed under the MIT open source license.

---
Without open source, there would be no Internet as we know it today.
