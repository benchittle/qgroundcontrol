//#pragma once
#include "CustomCorePlugin.h"
#include "QmlComponentInfo.h"
#include "AccessTypeConfig.h"
#include "MAVLinkLogManager.h"
#include "PasscodeMenu/PasscodeManager.h"
#include <iostream>
#include <string>
using namespace std;

QGC_LOGGING_CATEGORY(CustomCorePluginLog, "CustomCorePluginLog")

CustomCorePlugin::CustomCorePlugin(QGCApplication *app, QGCToolbox *toolbox)
    : QGCCorePlugin(app, toolbox) { }

CustomCorePlugin::~CustomCorePlugin() {}

void CustomCorePlugin::paletteOverride(QString colorName, QGCPalette::PaletteColorInfo_t& colorInfo) {
    if (colorName == QStringLiteral("warningText")) {
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled] = QColor("#F58F29");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled] = QColor("#F58F29");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled] = QColor("#CC3F0C");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#CC3F0C");
    } else if (colorName == QStringLiteral("statusPassedText")) {
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled] = QColor("#0DBF6F");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled] = QColor("#0DBF6F");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled] = QColor("#679436");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#679436");
    } else if (colorName == QStringLiteral("statusFailedText")) {
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupEnabled] = QColor("#FB4B4E");
        colorInfo[QGCPalette::Dark][QGCPalette::ColorGroupDisabled] = QColor("#FB4B4E");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupEnabled] = QColor("#CC3F0C");
        colorInfo[QGCPalette::Light][QGCPalette::ColorGroupDisabled] = QColor("#CC3F0C");
    }
}

void CustomCorePlugin::_addSettingsEntry(const QString &title, const char *qmlFile,
                                     const char *iconFile) {
    Q_CHECK_PTR(qmlFile);
    _customSettingsList.append(QVariant::fromValue(new QmlComponentInfo(
        title, QUrl::fromUserInput(qmlFile),
        iconFile == nullptr ? QUrl() : QUrl::fromUserInput(iconFile), this)));
}

QVariantList &CustomCorePlugin::settingsPages() {
    if(_customSettingsList.isEmpty()) {
        _addSettingsEntry(tr("General"), "qrc:/qml/GeneralSettings.qml", "qrc:/res/gear-white.svg");
        _addSettingsEntry(tr("Enter Passcode"), "qrc:/qml/PasswordSettings.qml", "qrc:/res/gear-white.svg");
        _addSettingsEntry(tr("Comm Links"), "qrc:/qml/LinkSettings.qml", "qrc:/res/waves.svg");
        _addSettingsEntry(tr("Offline Maps"), "qrc:/qml/OfflineMap.qml", "qrc:/res/waves.svg");
        _addSettingsEntry(tr("MAVLink"), "qrc:/qml/MavlinkSettings.qml", "qrc:/res/waves.svg");
        _addSettingsEntry(tr("Console"), "qrc:/qml/QGroundControl/Controls/AppMessages.qml");
        _addSettingsEntry(tr("Mock Link"), "qrc:/qml/MockLink.qml");
    }
    return _customSettingsList;
}

void CustomCorePlugin::setAccessType(QString qAccessType) {
    std::cout << "SET ACCESS TYPE IS BEING CALLED" << std::endl;
    string newAccessType = qAccessType.toStdString();
    std::cout << "TRYING TO SET: " << newAccessType << std::endl;
    if (newAccessType == accessTypeString(AccessType::Basic)) {
        this->_accessType = AccessType::Basic;
        std::cout << "Setting to Basic" << std::endl;
    } else if (newAccessType == accessTypeString(AccessType::Expert)) {
        this->_accessType = AccessType::Expert;
        std::cout << "Setting to Expert" << std::endl;
    } else if (newAccessType == accessTypeString(AccessType::Factory)) {
        this->_accessType = AccessType::Factory;
        std::cout << "Setting to Factory" << std::endl;
    } /*else {
        this->_accessType = AccessType::Basic;
        std::cout << "Setting to Basic in Else" << std::endl;
    }*/

    setUserAccessType(this->_accessType);
}

void CustomCorePlugin::updateFlightModes() {
   std::cout << "updating flight modes" << std::endl;
//   px4FirmwarePlugin->updateFlightModes();
}

QQmlApplicationEngine *
CustomCorePlugin::createQmlApplicationEngine(QObject *parent) {

    QQmlApplicationEngine *engine =
        QGCCorePlugin::createQmlApplicationEngine(parent);

    AccessType currentAccessType = getInitialUserAccessType();
    this->setAccessType(
        QString::fromStdString(accessTypeString(currentAccessType)));
    
    PasscodeManager *passcodeManager = new PasscodeManager();

    engine->rootContext()->setContextProperty("CustomCorePlugin", this);
    engine->rootContext()->setContextProperty("PasscodeManager", passcodeManager);
    std::cout << "THIS IS RUNNING" << std::endl;

    return engine;
}
