################################################################################
#
# rodos 5 6
#
################################################################################

RODOS_SOURCE = RODOS5_6.tar.gz
RODOS_SITE = https://silines.ru/software/RODOS/RODOS-5_6
RODOS_DEPENDENCIES += libusb host-libusb
HOST_RODOS_DEPENDENCIES += libusb
RODOS_INSTALL_STAGING = YES


define RODOS_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/RODOS5_6 $(TARGET_DIR)/usr/bin/RODOS5_6
endef

define RODOS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS)  CFLAGS="$(TARGET_CFLAGS)" -C $(@D) 
endef

$(eval $(generic-package))