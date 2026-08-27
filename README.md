# PomoLoop

Private iPhone Pomodoro app designed around one continuous START → STOP session.

## Core behavior
- Focus → short break → focus repeats automatically.
- Every N completed focus sessions, use a long break.
- The completed 🍅 count is session-based, not calendar-day-based.
- Crossing midnight does not reset anything.
- If the app is killed/reopened, state is reconstructed from the original START time.
- Dynamic Island / Lock Screen Live Activity shows the current phase, countdown, and completed 🍅 count.

## Important iOS limitation
The app itself can calculate the infinite cycle perfectly from elapsed time. But iOS does not guarantee waking a local app exactly at every phase boundary in the background. Therefore a serverless Live Activity can count down the currently published phase; when iOS suspends the app, the Dynamic Island cannot be guaranteed to switch its phase label/timer at every boundary until the app gets execution again. Apple push updates can solve this, but add APNs/backend/signing requirements.

## Build without owning a Mac
1. Create a GitHub repository and upload this folder.
2. Open Actions → `Build unsigned IPA` → Run workflow.
3. Download the `PomoLoop-unsigned-ipa` artifact.
4. Sideload/sign it to your own iPhone with your chosen sideloading method.

The GitHub runner uses macOS/Xcode, so your own computer can be Windows.

## Defaults
- Focus: 25 min
- Short break: 5 min
- Long break: 15 min
- Long break every: 4 🍅

All are editable before starting.

## Debug build #4
The app now shows Live Activity authorization/request status in the main screen and includes a retry button while a session is running.


## Debug #5
Dynamic Island foreground is explicitly white in compact, expanded and minimal presentations.
