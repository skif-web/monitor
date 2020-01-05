################################################################################
#
# zabbix
#
################################################################################

ZABBIX_VERSION = 4.4.3
ZABBIX_SITE = https://sourceforge.net/projects/zabbix/files
ZABBIX_LICENSE = GPL-2.0
ZABBIX_LICENSE_FILES = README

ZABBIX_DEPENDENCIES = pcre
ZABBIX_CONF_OPTS = --with-libpcre=$(STAGING_DIR)/usr/bin/ \
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
ZABBIX_CONF_OPTS += --enable-server \
	--with-libevent \
	--with-libpthread=$(STAGING_DIR)/usr \
	--with-zlib=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += libevent zlib

# Need openipmi in staging dir. Patch submitted at 2019.12.16
# Before this patch enabled, use this crutch
ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_OPENIPMI),y)
ZABBIX_CONF_OPTS += --with-openipmi=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += openipmi
ZABBIX_PRE_CONFIGURE_HOOKS += BR2_PACKAGE_ZABBIX_SERVER_OPENIPMI_FIX_LIBS

define BR2_PACKAGE_ZABBIX_SERVER_OPENIPMI_FIX_LIBS
	if [ ! -f $(STAGING_DIR)/usr/lib/libOpenIPMI.so ]; then \
		cp -rf $(TARGET_DIR)/usr/lib/libOpenIPMI* $(STAGING_DIR)/usr/lib/ ;\
		cp -rf $(TARGET_DIR)/usr/include/OpenIPMI $(STAGING_DIR)/usr/include/ ;\
	fi 
endef
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_LIBCURL),y)
ZABBIX_CONF_OPTS += --with-libcurl=$(STAGING_DIR)/usr/bin/curl-config
ZABBIX_DEPENDENCIES += libcurl
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_LIBXML2),y)
ZABBIX_CONF_OPTS += --with-libxml2=$(STAGING_DIR)/usr/bin/xml2-config
ZABBIX_DEPENDENCIES += libxml2
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_NETSNMP),y)
ZABBIX_CONF_OPTS += --with-net-snmp=$(STAGING_DIR)/usr/bin/net-snmp-config
ZABBIX_DEPENDENCIES += netsnmp
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_LDAP),y)
ZABBIX_CONF_OPTS += --with-ldap=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += openldap
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_LIBSSH2),y)
ZABBIX_CONF_OPTS += --with-ssh2=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += libssh2
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_OPENSSL),y)
ZABBIX_CONF_OPTS += --with-openssl=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += openssl
else ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_GNUTLS),y)
ZABBIX_CONF_OPTS += --with-gnutls=$(STAGING_DIR)/usr
ZABBIX_DEPENDENCIES += gnutls
endif

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_COPY_FRONTEND),y)
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_COPY_FRONTEND

define ZABBIX_SERVER_COPY_FRONTEND
	mkdir -p $(TARGET_DIR)/usr/zabbix/php-frontend/
	cp -r $(@D)/frontends/php/* $(TARGET_DIR)/usr/zabbix/php-frontend/
endef

endif

define ZABBIX_SERVER_CHANGE_PIDFILE_LOCATION
	$(SED) 's%\#\ PidFile=/tmp/zabbix_server.pid%PidFile=/run/zabbix/zabbix_server.pid%g' $(TARGET_DIR)/etc/zabbix_server.conf
endef

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_MYSQL),y)
ZABBIX_DEPENDENCIES += mysql
ZABBIX_CONF_OPTS += --with-mysql=$(STAGING_DIR)/usr/bin/mysql_config
# Need package/mariadb/0003-add-sysroot-path-to-mariadb_config.patch by Ryan Coe
# While this patch not included, use this crutch
ZABBIX_PRE_CONFIGURE_HOOKS += ZABBIX_DISABLE_MARIADB_CONFIG
ZABBIX_POST_CONFIGURE_HOOKS += ZABBIX_ENABLE_MARIADB_CONFIG

define ZABBIX_DISABLE_MARIADB_CONFIG
	if [ -f "$(STAGING_DIR)/usr/bin/mariadb_config" ]; then \
		mv $(STAGING_DIR)/usr/bin/mariadb_config $(STAGING_DIR)/usr/bin/mariadb_config_save; \
	fi
endef

define ZABBIX_ENABLE_MARIADB_CONFIG
	if [ -f "$(STAGING_DIR)/usr/bin/mariadb_confi_save" ]; then \
		mv $(STAGING_DIR)/usr/bin/mariadb_config_save $(STAGING_DIR)/usr/bin/mariadb_config; \
	fi
endef

ifeq ($(BR2_PACKAGE_ZABBIX_SERVER_COPY_DUMPS),y)
ZABBIX_POST_INSTALL_TARGET_HOOKS += ZABBIX_SERVER_PREPARE_MYSQL
endif

define ZABBIX_SERVER_PREPARE_MYSQL
	mkdir -p $(TARGET_DIR)/usr/zabbix/mysql_schema/
	cp -r $(@D) $(@D)/database/mysql/*\.sql $(TARGET_DIR)/usr/zabbix/mysql_schema/
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
