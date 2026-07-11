The task is: "Apply the SUGGESTED EDIT to the ORIGINAL CODE. Output the complete modified file."
The task is to apply the SUGGESTED EDIT to the ORIGINAL CODE, which is the CooperTestView class in source/CooperTestView.mc, and output the complete modified file. But the SUGGESTED EDIT is a list of files: README.md, manifest.xml, resources/strings.xml, source/CooperTestApp .```
import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Math;

class CooperTestView extends WatchUi.SimpleDataField {
    // Cooper formula: VO2 max = (distance in meters - 504.9) / 44.73
    // This is valid for runs up to 12 minutes
    
    private var _startTime as Number = 0;
    private var _startDistance as Float = 0.0f;
    private var _hasStarted as Boolean = false;
    private var _vo2Max as Float = 0.0f;
    private var _distanceMeters as Float = 0.0f;
    private var _elapsedMinutes as Float = 0.0f;

    function initialize() {
        SimpleDataField.initialize();
        label = "Cooper VO2";
    }

    // Called when the activity starts
    function onTimerStart() as Void {
        _hasStarted = true;
        var info = Activity.getActivityInfo();
        if (info != null) {
            if (info.elapsedTime != null) {
                _startTime = info.elapsedTime;
            }
            if (info.elapsedDistance != null) {
                _startDistance = info.elapsedDistance;
            }
        }
    }

    // Called when the activity is paused
    function onTimerPause() as Void {
        // Keep the data for display
    }

    // Called when the activity is resumed
    function onTimerResume() as Void {
        // Continue tracking
    }

    // Called when the activity stops
    function onTimerStop() as Void {
        // Final calculation
        computeVo2Max();
    }

    // Called when the activity resets
    function onTimerReset() as Void {
        _hasStarted = false;
        _startTime = 0;
        _startDistance = 0.0f;
        _vo2Max = 0.0f;
        _distanceMeters = 0.0f;
        _elapsedMinutes = 0.0f;
    }

    // Compute the current VO2 max estimate
    private function computeVo2Max() as Void {
        var info = Activity.getActivityInfo();
        if (info == null) {
            return;
        }

        var currentTime = info.elapsedTime != null ? info.elapsedTime : 0;
        var currentDistance = info.elapsedDistance != null ? info.elapsedDistance : 0.0f;

        _elapsedMinutes = (currentTime - _startTime).toFloat() / 1000.0f / 60.0f;
        _distanceMeters = currentDistance - _startDistance;

        // Cooper formula: VO2 max = (distance in meters - 504.9) / 44.73
        // Only compute if we have meaningful data (at least 1 minute)
        if (_elapsedMinutes >= 1.0f && _distanceMeters > 0) {
            _vo2Max = (_distanceMeters - 504.9f) / 44.73f;
            // Clamp to reasonable range (typically 20-80 ml/kg/min)
            if (_vo2Max < 0.0f) {
                _vo2Max = 0.0f;
            }
        }
    }

    // Compute function called to update the data field
    function compute(info as Activity.Info) as Numeric or Long or Float or String or Null {
        if (!_hasStarted) {
            return "--";
        }

        // Update the calculation on each compute cycle
        computeVo2Max();

        // If we have a valid VO2 max estimate, display it
        if (_vo2Max > 0.0f) {
            var prefix = _elapsedMinutes >= 12.0f ? "" : "~";
            return prefix + _vo2Max.format("%.1f");
        }

        // Show distance covered so far if we don't have enough time yet
        if (_distanceMeters > 0) {
            return (_distanceMeters / 1000.0f).format("%.2f") + "km";
        }

        return "--";
    }

    // Draw the data field - override to show more detailed info
    function onUpdate(dc as Dc) as Void {
        // Let the parent handle the basic display
        SimpleDataField.onUpdate(dc);
    }
}
