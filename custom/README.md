### Configuring the Project:

- Clone the QGroundControl repository found here: `git clone --recursive -j8 https://github.com/mavlink/qgroundcontrol.git`
- Rename custom-example to custom
- Navigate to custom/ and run `python3 updateqrc.py`
- Open Qt Creator
- Select “File” and then “Open File or Project...”
- Navigate to the repository
- Select the file “qgroundcontrol.pro”
- Select “Configure Project”
- The project will now be able to build without any modifications



### Configuring the Code:

- Use [this](https://github.com/WBawa/QGC_ComponentHiding/tree/simplified_version/custom) for the below section

- Add CustomCorePlugin.h and CustomCorePlugin.cc to custom/src/
- Add AccessType.h and AccessType.cc to custom/src/
- Add AccessTypeConfig.h and AccessTypeConfig.cc to custom/src/
- Create PasscodeMenu directory and add to it PasscodeManager.h/cc

- Configure the custom.pri file:

- Under SOURCES:
```
$$PWD/src/AccessType.cpp \
$$PWD/src/AccessTypeConfig.cpp \
$$PWD/src/CustomCorePlugin.cc \
$$PWD/src/PasscodeMenu/PasscodeManager.cc
```
 
- Under HEADERS:
```
$$PWD/src/AccessType.h \
$$PWD/src/AccessTypeConfig.h \
$$PWD/src/CustomCorePlugin.h \
$$PWD/src/PasscodeMenu/PasscodeManager.h
```

### Configuring the UI:
    
- Add the CustomFlightModeMenuIndicator.qml and PasswordSettings.qml to custom/res/Custom/

- Under the `"/qml"` prefix in custom.qrc, add the following lines:
```
<file alias="QGroundControl/Controls/FlightModeMenuIndicator.qml">res/Custom/CustomFlightModeMenuIndicator.qml</file>
<file alias="PasswordSettings.qml">res/Custom/PasswordSettings.qml</file>
```

- In qgroundcontrol.exclusion, add the following line:
```
<file alias="QGroundControl/Controls/FlightModeMenuIndicator.qml">src/ui/toolbar/FlightModeMenuIndicator.qml</file>
```

After doing this, run `python3 updateqrc.py`
