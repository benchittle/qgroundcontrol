#pragma once

#include "QGCCorePlugin.h"

class CustomCorePlugin : public QGCCorePlugin {
    Q_OBJECT

  public:
     CustomCorePlugin(QGCApplication *app, QGCToolbox *toolbox);
    ~CustomCorePlugin();
};