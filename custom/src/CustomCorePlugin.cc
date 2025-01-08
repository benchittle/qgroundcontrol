#include "CustomCorePlugin.h"
#include "QmlComponentInfo.h"
// #include "AccessTypeConfig.h"
// #include "MAVLinkLogManager.h"
// #include "PasscodeMenu/PasscodeManager.h"
// #include <iostream>
// #include <string>
using namespace std;

// QGC_LOGGING_CATEGORY(CustomCorePluginLog, "CustomCorePluginLog")

CustomCorePlugin::CustomCorePlugin(QGCApplication *app, QGCToolbox *toolbox)
    : QGCCorePlugin(app, toolbox) { }

CustomCorePlugin::~CustomCorePlugin() {}