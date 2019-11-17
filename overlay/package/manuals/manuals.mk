################################################################################
#
# manuals
#
################################################################################

MANUALS_VERSION:= 1.0.0
MANUALS_SITE:= ${BR2_EXTERNAL_alexeyOverlay_PATH}/manuals
MANUALS_SITE_METHOD:=local


# define RODOS_INSTALL_TARGET_CMDS
# 	pandoc -s -o doc.pdf ~/dev/monitor/monitor/README.md
# endef

define MANUALS_BUILD_CMDS
	pandoc -s -o ${TARGET_DIR}/var/www/manual_en.pdf ${BR2_EXTERNAL_alexeyOverlay_PATH}/../README.md
	pandoc -f markdown -t html -o ${TARGET_DIR}/var/www/manual_en.html ${BR2_EXTERNAL_alexeyOverlay_PATH}/../README.md
endef

$(eval $(generic-package))