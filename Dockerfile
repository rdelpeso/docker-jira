FROM nathonfowlie/centos-jre:latest

# Setup useful environment variables
ENV CONF_HOME     /var/local/atlassian/jira
ENV CONF_INSTALL  /usr/local/atlassian/jira
ENV CONF_VERSION  6.3.12

# Install Atlassian Confluence and helper tools and setup initial home
# directory structure.
RUN set -x \
    && yum install -y --quiet epel-release \
    && yum update -y --quiet \
    && yum install -y --quiet tomcat-native xmlstarlet \
    && yum clean all --quiet \
    && mkdir -p -m 700         "${CONF_HOME}" \
    && chown daemon:daemon     "${CONF_HOME}" \
    && mkdir -p                "${CONF_INSTALL}/confi/Catalina" \
    && curl -Ls                "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${CONF_VERSION}.tar.gz" | tar -xz --directory "${CONF_INSTALL}" --strip-components=1 --no-same-owner \
    && chmod -R 700            "${CONF_INSTALL}/conf" \
    && chmod -R 700            "${CONF_INSTALL}/temp" \
    && chmod -R 700            "${CONF_INSTALL}/logs" \
    && chmod -R 700            "${CONF_INSTALL}/work" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/conf" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/temp" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/logs" \
    && chown -R daemon:daemon  "${CONF_INSTALL}/work" \
    && echo -e                 "\njira.home=$CONF_HOME" >> "${CONF_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/local/atlassian/jira"]

# Set the default working directory as the Confluence home directory.
WORKDIR ${CONF_HOME}

# Run Atlassian JIRA as a foreground process by default.
CMD ["/usr/local/atlassian/jira/bin/start-jira.sh", "-fg"]
