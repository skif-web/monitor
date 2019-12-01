################################################################################
#
#zabbix
#
################################################################################

ZABBIX_VERSION = 4.4.3
ZABBIX_SITE = https://sourceforge.net/projects/zabbix/files
ZABBIX_LICENSE = GPL-2.0
ZABBIX_LICENSE_FILES = README

ZABBIX_DEPENDENCIES = pcre
ZABBIX_CONF_OPTS = \
	--with-libpcre=$(STAGING_DIR)/usr/bin/ \
	--enable-agent

ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_CLIENT_CHANGE_PIDFILE_LOCATION
ZABBIX_SYSTEMD_UNITS += zabbix-agent.service

define ZABBIX_INSTALL_INIT_SYSTEMD
	$(foreach unit,$(ZABBIX_SYSTEMD_UNITS),\
		$(INSTALL) -D -m 0644 $(ZABBIX_PKGDIR)/$(unit) $(TARGET_DIR)/usr/lib/systemd/system/$(unit) && \
		mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants && \
		ln -fs -r $(TARGET_DIR)/usr/lib/systemd/system/$(unit) $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/$(unit)
	)
endef

define ZABBIX_USERS
	zabbix -1 zabbix -1 !- /var/lib/zabbix - zabbix zabbix user
endef

define ZABBIX_CLIENT_CHANGE_PIDFILE_LOCATION
	$(SED) 's%\#\ PidFile=/tmp/zabbix_agentd.pid%PidFile=/run/zabbix/zabbix_agentd.pid%g' $(TARGET_DIR)/etc/zabbix_agentd.conf
endef

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER),y)
ZABBIX_SYSTEMD_UNITS += zabbix-server.service
ZABBIX_DEPENDENCIES += host-libcurl libevent libxml2 netsnmp libcurl zlib host-libxml2 php
ZABBIX_CONF_OPTS += --enable-server \
	--with-libevent \
	--with-libcurl=$(STAGING_DIR)/usr/bin/curl-config \
	--with-libxml2=$(STAGING_DIR)/usr/bin/xml2-config \
	--with-net-snmp=$(STAGING_DIR)/usr/bin/net-snmp-config \

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_COPY_FRONTEND),y)
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_COPY_FRONTEND

define ZABBIX_SERVER_COPY_FRONTEND
	mkdir -p $(TARGET_DIR)/usr/zabbix/php-frontend/
	cp -r $(@D)/frontends/php/* $(TARGET_DIR)/usr/zabbix/php-frontend/
endef

endif

ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_CHANGE_PIDFILE_LOCATION

define ZABBIX_SERVER_CHANGE_PIDFILE_LOCATION
	$(SED) 's%\#\ PidFile=/tmp/zabbix_server.pid%PidFile=/run/zabbix/zabbix_server.pid%g' $(TARGET_DIR)/etc/zabbix_server.conf
endef

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_MYSQL),y)
ZABBIX_DEPENDENCIES += mysql
ZABBIX_CONF_OPTS += --with-mysql=$(TARGET_DIR)/usr/bin/mysql_config

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_COPY_DUMPS),y)
	ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_PREPARE_MYSQL
endif

define ZABBIX_SERVER_PREPARE_MYSQL
	mkdir -p $(TARGET_DIR)/usr/zabbix/mysql_schema/
	cp -r $(@D)/database/mysql/*\.sql $(TARGET_DIR)/usr/zabbix/mysql_schema/
endef

endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_POSTGRESQL),y)
ZABBIX_DEPENDENCIES += postgresql
ZABBIX_CONF_OPTS += --with-postgresql=$(STAGING_DIR)/usr/bin/pg_config

define ZABBIX_SERVER_PREPARE_POSTGRESQL
	mkdir -p $(TARGET_DIR)/usr/zabbix/postgresql_schema
	cp -r $(@D)/database/postgresql/*\.sql $(TARGET_DIR)/usr/zabbix/postgresql_schema/
endef

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_COPY_DUMPS),y)
	ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_PREPARE_POSTGRESQL
endif

endif

endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))
