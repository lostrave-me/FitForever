# FitForever

Gentle break reminders with illustrated exercises, eye breaks, hydration and meal reminders for WoW Forever.

Long levelling sessions make it easy to lose track of time. FitForever gives you a small, movable reminder and a clear exercise card when you are ready for a break.

## What it does

- **Illustrated stretches:** shoulder, hand and head-turn animations, plus ankle exercises with a manual repetition counter. Character-aware artwork includes male and female variants, with a generic fallback.
- **Eye breaks:** a 20-second timer and a completion sound, so you can look away from the screen.
- **Movement breaks:** reminders to change position, get up and spend some time away from the screen.
- **Water and food:** optional reminders you can adjust; meals follow your chosen schedule.
- **Progress and controls:** start, pause, skip or snooze. Closing a card does not mark an exercise complete.
- **Quiet gameplay:** combat, battleground and arena suppression. AFK, loading screens and cinematics are also considered.
- **English and Russian:** automatic language selection from your client, with a manual override in settings.

## Useful moments for a break

FitForever can suggest a due short exercise by a recognized campfire or during a flight. When Travelcraft provides a visible remaining-flight countdown, it can choose an activity that fits the time available. Longer flights may offer a walk to refill your water or an optional snack. Without a known flight duration, suggestions stay short.

Raid leaders and assistants can announce a timed break in raid chat, for example `break 5 min`. Russian announcements are also recognized. `break over` cancels the break. Hidden DBM/BigWigs break-timer protocols are not supported yet.

## Getting started

Type `/fitf` or `/fitforever` to open settings. You can also use the leaf button below the minimap.

Try **Exercises / tests** to preview individual exercises. **Breaks** contains flight and raid-break tests; **Session / timers** explains the intervals and includes the battleground suppression test. Test confirmations do not reset your real reminder timers.

Every genuine character login starts a new session with full selected intervals. `/reload` and zone changes preserve your countdowns. Old pending reminders and snoozes do not carry into a new login; missed mealtimes are not replayed on arrival.

## Defaults

- Eyes: every 20 minutes, look into the distance for 20 seconds.
- Movement/stretch reminder: every 30 minutes. Seated exercises complement standing and moving; they do not replace them.
- Longer break: every hour, with a 5-minute timer and a suggested 5–10 minutes away from the screen.
- Water: a configurable 60-minute reminder.
- Meals and snacks: disabled until you enable them. The optional snack interval starts at 180 minutes.

Water and snack intervals are convenience settings, not medical quotas. Choose food and drink according to your needs. Guidance and exercise sources are listed in the included English README.

## Compatibility and beta notes

Built for **WoW Forever 1.60.1, Interface 16001**. Other WoW versions are not currently claimed as supported. No external addon is required; Travelcraft is optional for remaining-flight-time estimates.

This is a public beta. Artwork is still being refined and some frame transitions are rough. Forever's beta APIs may change, so reports about reminder timing, visibility and client errors are especially useful.

## Feedback

Comments, bug reports and suggestions are welcome in **English or Russian**. Use the project's **Issues** link for reproducible bugs or feature requests, or leave a quick comment here.

For a bug report, please include:

- FitForever version and WoW client version;
- what happened and what you expected;
- where it happened: open world, dungeon, raid, battleground or flight;
- steps to reproduce, and an error message or screenshot if available.

For general feedback, tell us whether reminders appeared at convenient moments, which ones felt intrusive, and whether the exercise instructions were clear.

Artwork was created with AI assistance. Gallery screenshots should show the actual in-game interface. FitForever is a reminder tool; it does not measure your health or verify physical exercise completion.


Author: lostrave. Code/documentation: MIT; artwork excluded.

[Report an issue](https://github.com/lostrave-me/FitForever/issues/new/choose).

Textures are supplied in the packaged release ZIP. To use this source checkout, copy its Media folder beside FitForever.toc.
