# PomoLoop Fix #9 — Background Live Activity experiment

Adds BGAppRefreshTask scheduling at the next phase boundary. When iOS grants background runtime, PomoLoop recomputes the phase from the absolute session start time, updates the Live Activity, and schedules the next refresh.

Important: iOS does not guarantee BGAppRefreshTask will run at the requested exact time. This build is an experiment to measure how well it works on the actual device before implementing APNs Live Activity push.

Recommended test: focus 1 min / short break 1 min, START, return to Home/lock screen, and do not reopen PomoLoop for several minutes.


## Fix #10 — phase colors
Dynamic Island / Live Activity colors: focus = red, short break = green, long break = blue. No timer or notification logic changed from #9.
