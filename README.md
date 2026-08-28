# PomoLoop Fix #11 — Live Activity Push Token Test

Based on Fix #10. The app now starts its Live Activity with `pushType: .token` and listens to `pushTokenUpdates`.

## Test
1. Install with SideStore and keep the Live Activity extension.
2. Open PomoLoop and press START.
3. Check the new "Live Activity Push テスト" box.
4. If a long hexadecimal token appears, the first APNs/ActivityKit push-token test succeeded.
5. If it stays on "Push token取得待ち…" for 30–60 seconds, the current free-signing path may not be receiving a Live Activity push token.

No server is used in this build yet. This build only tests whether iOS gives the Live Activity a push token.
