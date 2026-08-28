# PomoLoop Fix #13 — App Intent Update Test

Based on the working phase-color build (#10).

Adds a Shortcuts/App Intents action named **PomoLoop Update**. It is designed to run without opening the app, reconstruct the current Pomodoro phase from the stored absolute session start time, and call ActivityKit update on the current Live Activity.

Test goal: create a Shortcuts personal automation that runs PomoLoop Update at a chosen time, with Run Immediately, while PomoLoop stays in the background. If Dynamic Island changes from 00:00 to the current next phase without opening PomoLoop, this route works.

## Fix #14
- Fixed AppShortcuts utterances to include the required application name token (`\\(.applicationName)`).


## Fix15 - Shortcut loop
PomoLoop Update now returns the current phase end Date to Shortcuts while updating the Live Activity. Use that output as the until-date for the dedicated Study Focus mode.
