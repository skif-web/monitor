################################################################################
#
#zabbix
#
################################################################################

ZABBIX_VERSION = 4.2.4
ZABBIX_SITE = https://sourceforge.net/projects/zabbix/files

ZABBIX_DEPENDENCIES = host-libcurl libevent libxml2 netsnmp libcurl pcre zlib host-libxml2
ZABBIX_CONF_OPTS = --with-libpcre=$(STAGING_DIR)/usr/bin/ --with-libcurl=$(STAGING_DIR)/usr/bin/curl-config \
	--with-libevent --with-libxml2=$(STAGING_DIR)/usr/bin/xml2-config --with-net-snmp=$(STAGING_DIR)/usr/bin/net-snmp-config

define ZABBIX_SERVER_COPY_FRONTEND
	mkdir -p $(TARGET_DIR)/usr/zabbix/php-frontend/
	cp -r $(@D)/frontends/php/* $(TARGET_DIR)/usr/zabbix/php-frontend/
endef

define ZABBIX_SERVER_PREPARE_POSTGRESQL
	mkdir -p $(TARGET_DIR)/usr/zabbix/postgresql_schema
	cp -r $(@D)/database/postgresql/*\.sql $(TARGET_DIR)/usr/zabbix/postgresql_schema/
endef

define ZABBIX_SERVER_PREPARE_MYSQL
	mkdir -p $(TARGET_DIR)/usr/zabbix/mysql_schema/
	cp -r $(@D)/database/mysql/*\.sql $(TARGET_DIR)/usr/zabbix/mysql_schema/
endef

define ZABBIX_INSTALL_INIT_SYSTEMD
	$(foreach unit,$(ZABBIX_SYSTEMD_UNITS),\
		$(INSTALL) -D -m 644 $(ZABBIX_PKGDIR)$(unit) $(TARGET_DIR)/usr/lib/systemd/system/$(unit) && \
		mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants && \
		ln -fs -r $(TARGET_DIR)/usr/lib/systemd/system/$(unit) $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/$(unit) ;)
endef

define ZABBIX_USERS
	zabbix -1 zabbix -1 !- /var/lib/zabbix - zabbix zabbix user
endef

define ZABBIX_CLIENT_CHANGE_PIDFILE_LOCATION
	sed -i 's/\#\ PidFile=\/tmp\/zabbix_agentd.pid/PidFile=\/run\/zabbix\/zabbix_agentd.pid/g' $(TARGET_DIR)/etc/zabbix_agentd.conf
endef

define ZABBIX_SERVER_CHANGE_PIDFILE_LOCATION
	sed -i 's/\#\ PidFile=\/tmp\/zabbix_server.pid/PidFile=\/run\/zabbix\/zabbix_server.pid/g' $(TARGET_DIR)/etc/zabbix_server.conf
endef

ifeq ($(BR2_PACKAGE_ZABBIX_CLIENT),y)
ZABBIX_CONF_OPTS += --enable-agent
ZABBIX_SYSTEMD_UNITS += zabbix-agent.service
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_CLIENT_CHANGE_PIDFILE_LOCATION
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER),y)
ZABBIX_SYSTEMD_UNITS += zabbix-server.service
ZABBIX_CONF_OPTS += --enable-server
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_COPY_FRONTEND
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_CHANGE_PIDFILE_LOCATION

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_MYSQL),y)
ZABBIX_DEPENDENCIES += mysql
ZABBIX_CONF_OPTS += --with-mysql=$(STAGING_DIR)/usr/bin/mysql_config
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_PREPARE_MYSQL
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_POSTGRESQL),y)
ZABBIX_DEPENDENCIES += postgresql
ZABBIX_CONF_OPTS += --with-postgresql=$(STAGING_DIR)/usr/bin/pg_config
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_PREPARE_POSTGRESQL
endif

endif

$(eval $(autotools-package))
