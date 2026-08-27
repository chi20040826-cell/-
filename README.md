# PomoLoop Debug/Fix #6

Changes focused on blank/black Live Activity UI:
- Widget extension simplified to a single @main Live Activity Widget (no WidgetBundle wrapper).
- Host app and extension deployment target explicitly aligned to iOS 18.0.
- NSSupportsLiveActivities added to widget extension Info.plist too.
- APPLICATION_EXTENSION_API_ONLY enabled.
- Dynamic Island UI reduced to simple Text/timer views for renderer isolation.
