#!/bin/bash

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat --format "%Y" "${JIRA_INSTALL}/conf/server.xml")" -eq "0" ]; then
  if [ -n "${X_PROXY_NAME}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_PORT}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_SCHEME}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PROXY_SECURE}" ]; then
    xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "secure" --value "${X_PROXY_SECURE}" "${JIRA_INSTALL}/conf/server.xml"
  fi
  if [ -n "${X_PATH}" ]; then
    xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${JIRA_INSTALL}/conf/server.xml"
  fi
fi

if [ -f "${CERTIFICATE}" ] || [ -f "${CERTIFICATE}.p12" ]; then
  # convert PKCS12 certificate format to JKS certificate format
  #
  # To generate a pkcs12 file from an openssl self-signed cert and key file:
  #   > openssl pkcs12 -export -in server_cert.pem -inkey server_key.pem -out certificate.p12
  #       -passout pass:changeit -name "jira"
  #
  # To test the insertion:
  #   > docker exec -it <CONTAINER_ID> /bin/bash
  #   > keytool -list -keystore $JAVA_HOME/jre/lib/security/cacerts -v | grep Alias | grep jira
  #
  if [[ "${CERTIFICATE}" =~ .p12$ || -f "${CERTIFICATE}.p12" ]]; then
    keytool -noprompt -storepass changeit -importkeystore \
      -srckeystore ${CERTIFICATE%.p12}.p12 -srcstoretype PKCS12 -srcstorepass changeit -alias jira \
      -destkeystore ${JAVA_CACERTS} -deststoretype JKS -deststorepass changeit -destalias jira
  else
    keytool -noprompt -storepass changeit \
      -keystore ${JAVA_CACERTS} -import -file ${CERTIFICATE} -alias jira
  fi

  # Update the server.xml file
  # <!--
  # <Connector port="8443" protocol="org.apache.coyote.http11.Http11Protocol"
  #             maxHttpHeaderSize="8192" SSLEnabled="true"
  #             maxThreads="150" minSpareThreads="25"
  #             enableLookups="false" disableUploadTimeout="true"
  #             acceptCount="100" scheme="https" secure="true"
  #             clientAuth="false" sslProtocol="TLS" useBodyEncodingForURI="true"
  #             keyAlias="jira" keystoreFile="<JIRA_HOME>/jira.jks" keystorePass="changeit" keystoreType="JKS"/>
  # -->
  xmlstarlet ed --inplace --pf --ps \
    --subnode "Server/Service" --type elem --name "ConnectorTMP" --value "" \
    --insert  "//ConnectorTMP" --type attr --name "port" --value "8443" \
    --insert  "//ConnectorTMP" --type attr --name "protocol" --value "org.apache.coyote.http11.Http11NioProtocol" \
    --insert  "//ConnectorTMP" --type attr --name "maxHttpHeaderSize" --value "8192" \
    --insert  "//ConnectorTMP" --type attr --name "SSLEnabled" --value "true"  \
    --insert  "//ConnectorTMP" --type attr --name "maxThreads" --value "150" \
    --insert  "//ConnectorTMP" --type attr --name "minSpareThreads" --value "25" \
    --insert  "//ConnectorTMP" --type attr --name "enableLookups" --value "false" \
    --insert  "//ConnectorTMP" --type attr --name "disableUploadTimeout" --value "true" \
    --insert  "//ConnectorTMP" --type attr --name "acceptCount" --value "100" \
    --insert  "//ConnectorTMP" --type attr --name "scheme" --value "https" \
    --insert  "//ConnectorTMP" --type attr --name "secure" --value "true" \
    --insert  "//ConnectorTMP" --type attr --name "clientAuth" --value "false" \
    --insert  "//ConnectorTMP" --type attr --name "sslProtocol" --value "TLSv1.2" \
    --insert  "//ConnectorTMP" --type attr --name "sslEnabledProtocols" --value "TLSv1.2" \
    --insert  "//ConnectorTMP" --type attr --name "useBodyEncodingForURI" --value "true" \
    --insert  "//ConnectorTMP" --type attr --name "keyAlias" --value "jira" \
    --insert  "//ConnectorTMP" --type attr --name "keystoreFile" --value "${JAVA_CACERTS}" \
    --insert  "//ConnectorTMP" --type attr --name "keystorePass" --value "changeit" \
    --insert  "//ConnectorTMP" --type attr --name "keystoreType" --value "JKS" \
    --rename  "//ConnectorTMP" --value "Connector" \
    "${JIRA_INSTALL}/conf/server.xml"

  # @TODO: Update Base URL to HTTPS
  #
  # https://confluence.atlassian.com/jirakb/how-do-i-manually-change-the-base-url-733940375.html

  # @TODO: Use xmlstarlet to update the web.xml file
  #
  # This will redirect all traffic to use HTTPS urls.
  #
  # Location: ${JIRA_INSTALL}/atlassian-jira/WEB-INF/web.xml
  # <!--
  # <security-constraint>
  #   <web-resource-collection>
  #     <web-resource-name>all-except-attachments</web-resource-name>
  #     <url-pattern>*.jsp</url-pattern>
  #     <url-pattern>*.jspa</url-pattern>
  #     <url-pattern>/browse/*</url-pattern>
  #     <url-pattern>/issues/*</url-pattern>
  #   </web-resource-collection>
  #   <user-data-constraint>
  #     <transport-guarantee>CONFIDENTIAL</transport-guarantee>
  #   </user-data-constraint>
  # </security-constraint>
  # -->
fi

exec "$@"
