/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Vehicle
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.SettingsManager

Control {
    id: control

    property real   value:              0
    property real   from:               0
    property real   to:                 100
    property string unitsString
    property string label

    required property int   decimalPlaces
    required property real  majorTickStepSize

    property real   _indicatorCenterPos:    sliderFlickable.width / 2

    property real   _majorTickSpacing:      ScreenTools.defaultFontPixelWidth * 6

    property real   _majorTickSize:         valueIndicator.pointerSize + valueIndicator.indicatorValueMargins
    property real   _tickValueEdgeMargin:   ScreenTools.defaultFontPixelWidth / 2
    property real   _minorTickSize:        _majorTickSize / 2
    property real   _sliderValuePerPixel:   majorTickStepSize / _majorTickSpacing

    property int    _minorTickValueStep:    majorTickStepSize / 2

    property real   _sliderValue:           _firstPixelValue + ((sliderFlickable.contentX + _indicatorCenterPos) * _sliderValuePerPixel)

    // Calculate the full range of the slider. We have been given a min/max but that is for clamping the selected slider values.
    // We need expand that range to take into account additional values that must be displayed above/below the value indicator
    // when it is at min/max.

    // Add additional major ticks above/below min/max to ensure we can display the full visual range of the slider
    property int    _majorTicksVisibleBeyondIndicator:   Math.floor(_indicatorCenterPos / _majorTickSpacing)
    property int    _majorTickAdjustment:               _majorTicksVisibleBeyondIndicator * majorTickStepSize

    // Calculate the next major tick above/below min/max
    property int    _majorTickMinValue: Math.ceil((from - _majorTickAdjustment) / majorTickStepSize) * majorTickStepSize
    property int    _majorTickMaxValue: Math.floor((to + _majorTickAdjustment) / majorTickStepSize) * majorTickStepSize

    // Now calculate the position we draw the first tick mark such that we are not allowed to flick above the max value
    property real   _firstTickPixelOffset:  _indicatorCenterPos - ((from - _majorTickMinValue) / _sliderValuePerPixel)
    property real   _firstPixelValue:       _majorTickMinValue - (_firstTickPixelOffset * _sliderValuePerPixel)

    // Calculate the slider width such that we can flick through the full range of the slider
    property real   _sliderContentSize: ((to - _firstPixelValue) / _sliderValuePerPixel) + (sliderFlickable.width - _indicatorCenterPos)

    property int     _cMajorTicks: (_majorTickMaxValue - _majorTickMinValue) / majorTickStepSize + 1

    property var qgcPal: QGroundControl.globalPalette

    on_SliderValueChanged: value = _sliderValue

    Component.onCompleted: {
        setCurrentValue(value, false)
    }

    function setCurrentValue(currentValue, animate = true) {
        // Position the slider such that the indicator is pointing to the current value
        var contentX = _indicatorCenterPos - ((currentValue - _firstPixelValue) / _sliderValuePerPixel)
        console.log("setCurrentValue: ", currentValue, contentX, _firstPixelValue, _sliderValuePerPixel, _indicatorCenterPos)   
        if (animate) {
            flickableAnimation.from = sliderFlickable.contentX
            flickableAnimation.to = contentX
            flickableAnimation.start()
        } else {
            sliderFlickable.contentX = contentX
        }
    }

    function _clampedSliderValue(value) {
        return Math.min(Math.max(value, from), to).toFixed(decimalPlaces)
    }

    function getOutputValue() {
        return _clampedSliderValue(_sliderValue)
    }

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  control.enabled
    }

    background: Item {
        implicitHeight: _majorTickSize + tickValueMargin + ScreenTools.defaultFontPixelHeight

        property real tickValueMargin: ScreenTools.defaultFontPixelHeight / 3

        DeadMouseArea {
            anchors.fill: parent
        }

        QGCFlickable {
            id:                 sliderFlickable
            anchors.fill:       parent
            contentWidth:       sliderContainer.width
            contentHeight:      sliderContainer.height
            flickDeceleration:  0.5
            flickableDirection: Flickable.HorizontalFlick

            PropertyAnimation on contentX {
                id:             flickableAnimation
                duration:       500
                from:           fromValue
                to:             toValue
                easing.type:    Easing.OutCubic
                running:        false

                property real fromValue
                property real toValue
            }

            Item {
                id:     sliderContainer
                width:  _sliderContentSize
                height: sliderFlickable.height

                Component.onCompleted: console.log("sliderContainer: ", width, sliderFlickable.width, sliderFlickable.contentWidth)

                // Major tick marks
                Repeater {
                    model: _cMajorTicks

                    Item {
                        width:      1
                        height:     sliderContainer.height
                        x:          _majorTickSpacing * index + _firstTickPixelOffset
                        opacity:    tickValue < from || tickValue > to ? 0.5 : 1

                        property real tickValue: _majorTickMinValue + (majorTickStepSize * index)

                        Rectangle {
                            id:     majorTickMark
                            width:  1
                            height: _majorTickSize
                            color:  qgcPal.text
                        }

                        QGCLabel {
                            anchors.bottomMargin:       _tickValueEdgeMargin
                            anchors.bottom:             parent.bottom
                            anchors.horizontalCenter:   majorTickMark.horizontalCenter
                            text:                       parent.tickValue
                        }
                    }
                }

                // Minor tick marks
                Repeater {
                    model: _cMajorTicks * 2

                    Rectangle {
                        x:          _majorTickSpacing / 2 * index +  + _firstTickPixelOffset
                        width:      1
                        height:     _minorTickSize
                        color:      qgcPal.text
                        opacity:    tickValue < from || tickValue > to ? 0.5 : 1
                        visible:    index % 2 === 1

                        property real tickValue: _majorTickMaxValue - ((majorTickStepSize  / 2) * index)
                    }
                }
            }
        }

        Rectangle {
            width:      labelItem.contentWidth
            height:     labelItem.contentHeight
            color:      qgcPal.window
            opacity:    0.8

            QGCLabel {
                id:                 labelItem
                anchors.left:       parent.left
                anchors.top:        parent.top
                text:               label
            }
        }
    }

    contentItem: Item {
        implicitHeight: valueIndicator.height

        Canvas {
            id:                         valueIndicator
            anchors.horizontalCenter:   parent.horizontalCenter
            width:                      Math.max(valueLabel.contentWidth + (indicatorValueMargins * 2), pointerSize * 2 + 2)
            height:                     valueLabel.contentHeight + (indicatorValueMargins * 2) + pointerSize

            property real indicatorValueMargins:    ScreenTools.defaultFontPixelWidth / 2
            property real indicatorHeight:          valueLabel.contentHeight
            property real pointerSize:              ScreenTools.defaultFontPixelWidth

            onPaint: {
                var ctx = getContext("2d")
                ctx.strokeStyle = qgcPal.text
                ctx.fillStyle = qgcPal.window
                ctx.lineWidth = 1
                ctx.beginPath()
                ctx.moveTo(width / 2, 0)
                ctx.lineTo(width / 2 + pointerSize, pointerSize)
                ctx.lineTo(width - 1, pointerSize)
                ctx.lineTo(width - 1, height - 1)
                ctx.lineTo(1, height - 1)
                ctx.lineTo(1, pointerSize)
                ctx.lineTo(width / 2 - pointerSize, pointerSize)
                ctx.closePath()
                ctx.fill()
                ctx.stroke()
            }

            QGCLabel {
                id:                         valueLabel
                anchors.bottomMargin:       parent.indicatorValueMargins
                anchors.bottom:             parent.bottom
                anchors.horizontalCenter:   parent.horizontalCenter
                horizontalAlignment:        Text.AlignHCenter
                verticalAlignment:          Text.AlignBottom
                text:                       _clampedSliderValue(_sliderValue) + (unitsString !== "" ? " " + unitsString : "")
            }
        }
    }
}
