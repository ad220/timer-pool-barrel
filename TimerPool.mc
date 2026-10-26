import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;


module TimerPool {

class Controller {

    private var timer as Timer.Timer;
    private var period as Number;
    private var isRunning as Boolean;
    private var callbackList as Array<Callback>;

    public function initialize(periodInMs as Number) {
        self.timer = new Timer.Timer();
        self.period = periodInMs;
        self.callbackList = [];
        self.isRunning = false;
    }

    public function triggerCallbacks() as Void {
        for (var i=0; i<callbackList.size(); i++) {
            callbackList[i].trigger();
        }
    }

    public function start(callback as Method() as Void, periodInMs as Number, repeat as Boolean) as Callback {
        var periodInTicks = periodInMs / self.period;
        if (periodInTicks < 1) { periodInTicks = 1; }
        var timerCallback = new Callback(callback, periodInTicks, repeat, self);
        callbackList.add(timerCallback);

        if (!isRunning) { resume(); }
        return timerCallback;
    }

    public function stop(callback as Callback?) as Void {
        if (callback != null) {
            callback.clear();
            callbackList.remove(callback);
        }

        if (callbackList.size() == 0) { pause(); }
    }

    public function stopAll() as Void {
        for (var i=0; i<callbackList.size(); i++) {
            stop(callbackList[i]);
        }
    }

    (:inline)
    public function pause() as Void {
        timer.stop();
        isRunning = false;
    }

    (:inline)
    public function resume() as Void {
        timer.start(method(:triggerCallbacks), period, true);
        isRunning = true;
    }

    public function getPeriod() as Number {
        return period;
    }
}


class Callback {

    private var callback as Method() as Void?;
    private var period as Number;
    private var repeat as Boolean;
    private var controller as Controller;
    private var tickCount as Number;


    public function initialize(callback as Method() as Void, period as Number, repeat as Boolean, controller as Controller) {
        self.callback = callback;
        self.period = period;
        self.repeat = repeat;
        self.controller = controller;
        self.tickCount = 0;
    }

    public function trigger() as Void {
        tickCount = (tickCount + 1) % period;
        if (tickCount == 0) {
            if (callback != null) { callback.invoke(); }

            if (!repeat) {
                stop();
            }
        }
    }

    public function stop() as Void {
        controller.stop(self);
    }

    public function clear() as Void {
        callback = null;
    }
}

} // end of module TimerPool
