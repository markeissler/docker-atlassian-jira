FROM openjdk:8
MAINTAINER Mark Eissler

# Configuration variables.
ENV JIRA_HOME     /var/atlassian/jira
ENV JIRA_RUNTIME  /var/atlassian/jira_runtime
ENV JIRA_INSTALL  /opt/atlassian/jira
ENV JIRA_VERSION  7.5.0

ENV JAVA_CACERTS  $JAVA_HOME/jre/lib/security/cacerts
ENV CERTIFICATE   $JIRA_HOME/certificate

# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends xmlstarlet \
    && apt-get install --quiet --yes --no-install-recommends -t jessie-backports libtcnative-1 \
    && apt-get clean \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R daemon:daemon  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz" | tar -xz --directory "${JIRA_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar" \
    && rm -f                   "${JIRA_INSTALL}/lib/postgresql-9.1-903.jdbc4-atlassian-hosted.jar" \
    && curl -Ls                "https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar" -o "${JIRA_INSTALL}/lib/postgresql-9.4.1212.jar" \
    && chmod -R 700            "${JIRA_INSTALL}/conf" \
    && chmod -R 700            "${JIRA_INSTALL}/logs" \
    && chmod -R 700            "${JIRA_INSTALL}/temp" \
    && chmod -R 700            "${JIRA_INSTALL}/work" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/conf" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/logs" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/temp" \
    && chown -R daemon:daemon  "${JIRA_INSTALL}/work" \
    && sed --in-place          "s/java version/openjdk version/g" "${JIRA_INSTALL}/bin/check-java.sh" \
    && xmlstarlet              ed --inplace --pf --ps \
        --update               "Server/Service/Connector/@port" --value "8080" \
        --update               "Server/Service/Connector/@redirectPort" --value "8443" \
                               "${JIRA_INSTALL}/conf/server.xml" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml" \
    && chown daemon:daemon     "${JAVA_CACERTS}"

# Support Swarm and NFS by moving caches to local (ephemeral) storage.
#
#   JIRA_HOME/caches/indexes
#       - lucene indexes, we move all caches to JIRA_RUNTIME
#
#   JIRA_HOME/plugins/.osgi-plugins/felix/felix-cache
#       - felix plugin cache, we want to move just felix-cache but JIRA will overwrite
#       a symlink on felix-cache so we move all felix to JIRA_RUNTIME
#
RUN set -x \
    && rm -rf                  "${JIRA_HOME}/caches" \
    && mkdir -p                "${JIRA_HOME}/plugins/.osgi-plugins" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R daemon:daemon  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_RUNTIME}/caches/indexes" \
    && mkdir -p                "${JIRA_RUNTIME}/plugins/.osgi-plugins/felix" \
    && chmod -R 700            "${JIRA_RUNTIME}" \
    && chown -R daemon:daemon  "${JIRA_RUNTIME}" \
    && ln -s                   "${JIRA_RUNTIME}/caches" "${JIRA_HOME}/caches" \
    && ln -s                   "${JIRA_RUNTIME}/plugins/.osgi-plugins/felix" "${JIRA_HOME}/plugins/.osgi-plugins/felix"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8080
EXPOSE 8443

# Persist the following directories
#
#   /var/atlassian/jira - jira.home (settings)
#   /opt/atlassian/jira/logs - server logs
#
VOLUME ["/var/atlassian/jira", "/opt/atlassian/jira/logs"]

# Set the default working directory as the installation directory.
WORKDIR /var/atlassian/jira

COPY "docker-entrypoint.sh" "/"
ENTRYPOINT ["/docker-entrypoint.sh"]

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/jira/bin/catalina.sh", "run"]
