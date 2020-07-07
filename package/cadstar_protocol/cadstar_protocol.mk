################################################################################
#
# libprotocol
#
################################################################################

CADSTAR_PROTOCOL_VERSION = rpi-cm3
CADSTAR_PROTOCOL_SITE_METHOD = git
CADSTAR_PROTOCOL_SITE = git@gitlab.com:m.naghizadeh91/ProjectorJSonRPC.git
CADSTAR_PROTOCOL_DEPENDENCIES = qt5base
CADSTAR_PROTOCOL_CONF_OPTS = QT_CONFIG+=network
CADSTAR_PROTOCOL_INSTALL_STAGING = YES

$(eval $(qmake-package))
