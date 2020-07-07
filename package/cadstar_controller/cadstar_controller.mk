################################################################################
#
# controller
#
################################################################################

CADSTAR_CONTROLLER_VERSION = rpi-cm3
CADSTAR_CONTROLLER_SITE = git@gitlab.com:m.naghizadeh91/Projector_app_cm3.git
CADSTAR_CONTROLLER_SITE_METHOD = git
CADSTAR_CONTROLLER_DEPENDENCIES = qt5base cadstar_protocol
CADSTAR_CONTROLLER_CONF_OPTS = QT_CONFIG+=network
CADSTAR_CONTROLLER_INSTALL_STAGING = YES

$(eval $(qmake-package))
