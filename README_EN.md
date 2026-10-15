# FitForever 0.7.2-beta

A WoW Forever addon for gentle reminders to move, rest your eyes, drink and eat. Interface 16001. No external libraries required.

## Language

Open `/fitf` or `/fitforever`. The language controls are near the bottom of settings:

- **Auto (client)**: Russian for a `ruRU` client; English for other client languages. This is the default on first launch and when upgrading without a saved language preference.
- **Русский**: always use Russian.
- **English**: always use English.

Changes apply immediately, including open windows and exercise cards. Your choice is saved across sessions. Changing language does not reset reminder intervals, snoozes, artwork selection or an exercise in progress. Raid break announcements are recognized in both English and Russian regardless of your interface language. Artwork is shared between languages.

## Controls and reminders

The leaf button below the minimap opens a pending reminder with left click and settings with right click. Each reminder has a **Test** button. **Exercises / tests** opens individual exercise tests; **Breaks** contains flight, raid break and return-alert tests. `/fitf stoptest` exits a test. Tests do not confirm real reminders; regular reminder intervals continue to run.

Default intervals: eyes 20 minutes, stretches 30, walking 60, water 60. Meals and snacks are disabled until you choose to enable them. Meal times use your computer's local time, with up to six comma-separated times such as `09:00, 13:00, 19:00`; press **Save** to apply the schedule. A meal reminder can appear within an hour of its scheduled time, once per day; times already past when you log in are skipped.

A notification tucks away after 20 seconds and remains available through the minimap button. **Later** snoozes a reminder for 5 minutes. Closing a card does not mark it complete. Timers start when you press **Start**; completing the timer plays the completion sound if enabled, but you still confirm completion yourself. Shoulders use three repetitions with 3-second holds; hands use three cycles; head turns alternate sides with 5-second holds, three times each way. Ankles use a static illustration and manual repetition counter.

Combat, loading screens, cinematics and AFK suppress reminder windows. Combat pauses an active exercise; AFK alone does not pause an exercise you already started. Reminder intervals exclude AFK by default. A stretch routine selects two of the least recently completed exercises. Skipping does not record an exercise as completed.

Every genuine character login starts a new session: all five interval reminders restart with their full selected intervals, and pending reminders and snoozes are cleared. Preferences, language and exercise history are preserved. Resetting a session does not mark water as drunk or exercises as completed. /reload and zone changes preserve reminder countdowns and active session duration. Loading screens do not consume reminder time. Open exercise cards, exercise progress, test queues and the temporary global pause are not restored after restarting or reloading the UI.

## Flights, campfires and raid breaks

Flight time is read from the visible Travelcraft countdown after confirming that it decreases. Unknown routes may show elapsed time instead; FitForever rejects that as a remaining-time estimate. Without an available countdown, only short seated exercises are suggested. Flight time is approximate and the integration depends on Travelcraft's current named bar.

Only enabled, due and unsnoozed reminders are selected. Flights longer than five remaining minutes can offer water, a snack, a meal or walking if sufficient time remains, including a one-minute return buffer. These are planning estimates, not guaranteed activity durations. A return sound and notification trigger when a known countdown crosses one minute remaining. Landing hides the flight card without marking completion.

Raid leaders and assistants can announce `break 5 min`, `break for 5 min`, `break 05:00` or `break 30 sec` in raid chat or raid warnings. Durations from 15 seconds to 60 minutes are recognized. `break over` and `break ended` cancel the break. Russian equivalents also work. Combat, leaving the raid or expiry cancels it. Messages without a duration do not start a timer. Hidden DBM/BigWigs timer protocols are not integrated. FitForever does not send chat messages.

Campfire opportunities offer a due short eye or shoulder break when the recognized campfire aura has enough time left.

## Movement, water and food

Move gently, within a comfortable range, without pain. Skip exercises that are unsuitable for you. Use a stable chair without wheels for seated exercises. Do not tilt your head back during head turns. Look away from the screen during the eye break rather than watching its progress bar.

Water and snack intervals are reminders, not required drinking or eating quotas. Drink if thirsty and eat if hungry or at your chosen mealtime. Personal medical restrictions take priority. The addon does not measure dehydration, hunger or actual exercise completion. Short breaks do not replace regular physical activity.

Exercise sources used by this addon:

- Shoulders: https://www.ccohs.ca/oshanswers/ergonomics/office/stretching.html
- Hands: https://www.newcastle-hospitals.nhs.uk/services/newcastle-occupational-health-service/information-for-staff/physiotherapy/self-help-leaflets/1-minute-body-check/
- Head turns and ankles: https://www.nhs.uk/live-well/exercise/sitting-exercises/
- Eye breaks: https://www.aoa.org/healthy-eyes/eye-and-vision-conditions/computer-vision-syndrome
- Breaks: https://www.hse.gov.uk/msd/dse/work-routine.htm
- Water: https://www.nhs.uk/live-well/eat-well/food-guidelines-and-food-labels/water-drinks-nutrition/

Artwork currently includes cosmetic imperfections accepted for the beta. The English and Russian interfaces are covered by automated Lua 5.1 tests with simulated WoW APIs; actual rendering and client events still require in-game verification.


## 0.7.1-beta: session and timer settings

**Session / timers** explains the default intervals and includes **Test new session**, which uses a copy of your state and reports to chat without resetting your actual timers. **Default intervals** sets eyes / stretches / walks to 20 / 30 / 60 minutes and restarts only those three countdowns. Other reminder settings and custom intervals remain available.

The baseline is supported by the following practical guidance, checked on 15 October 2026:

- Eyes: AOA's 20–20–20 advice — every 20 minutes look about 20 feet away for 20 seconds. https://www.aoa.org/healthy-eyes/caring-for-your-eyes/gaming-and-digital-eye-strain
- Movement: the NHS MyHealthLondon service advises breaking up sitting with light activity every 30 minutes. This does not prescribe a fixed schedule for every individual seated exercise; seated stretches do not replace standing and moving. https://www.myhealthlondon.nhs.uk/resources/internal/exercise-and-physical-activity-healthy-living/
- Longer breaks: HSE and CCOHS suggest 5–10 minutes per hour at a workstation. The addon uses a five-minute timer within that range. https://www.hse.gov.uk/msd/dse/work-routine.htm
- Water: NHS recommends drinking regularly through the day, without a universal interval in minutes. The default 60-minute reminder is a configurable convenience, not a medical quota. https://www.nhs.uk/live-well/eat-well/food-guidelines-and-food-labels/water-drinks-nutrition/
- Food: CDC suggests nutritious snacks when hungry between meals, without prescribing a universal interval. Snacks remain disabled by default; the optional 180-minute reminder and your meal schedule are personal choices. https://www.cdc.gov/healthy-weight-growth/healthy-eating/meals-snacks.html

There are 61 passing automated Lua 5.1 scenarios, including genuine login, reload, zone changes, loading time, mealtime boundaries and both UI languages. Actual client events and rendering still require in-game verification.


## 0.7.2-beta: battleground and arena suppression

Reminders previously hid during combat but could appear between fights in a battleground. FitForever now suppresses notification banners, exercise cards, pending indicators and sounds throughout battlegrounds and arenas, including pre-match waiting, death and out-of-combat periods. Instance detection uses `IsInInstance()` types `pvp` and `arena`; unavailable or restricted state also suppresses reminders.

Reminder intervals keep counting game time. Pending activities are preserved without being marked complete; active exercise execution pauses. On leaving the map, pending reminders can appear again. Old transient return alerts are discarded; raid break announcements inside battlegrounds or arenas are ignored. Test cards cannot bypass this protection.

**Session / timers → Battleground test (8 s)** hides a test card for eight seconds, then restores it without resetting actual intervals. A real battleground or arena remains blocked after the test expires.

There are 67 passing automated Lua 5.1 scenarios. Actual battleground behavior still needs in-client verification.
