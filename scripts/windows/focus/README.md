# Focus

I’ve tried every productivity hack under the sun—from Pomodoro timers to Todoist—and learned one hard truth: the harder you chase optimization, the more overwhelmed you get. That realization led me to strip things back to basics and build a tiny script that quietly pins my current focus next to the clock, so I never lose sight of the task at hand.

## How to use

- Create a folder for your scripts, e.g. `C:\Scripts`.
- Move `focus.bat`  there.
- Add that folder to your **User**  PATH (Win Key → type “Edit environment variables” → Environment Variables → edit your user PATH → add `C:\Scripts`).
- Now you can hit **Win + R**, type `focus "Editing LinkedIn draft"`
- You can see the text besides right bottom side of taskbar, just after the clock like below.
![Focus in action](https://github.com/vishsant/Scripts-and-Configs/blob/main/scripts/windows/focus/assets/images/Focus.png)

## Limitation

There is a delay of max 30 second for the text to get updated after invoking the script.

Why this delay?

Because Windows (including Explorer’s taskbar clock) doesn’t re-draw the clock the instant you write a new format to the registry.

- Explorer caches your locale/time settings in memory, then only re-reads them when it processes a `WM_SETTINGCHANGE` notification and on its regular timer.
-  By default, the **taskbar clock**  is driven by a **Windows Timer**  rather than a continuous, real-time watch. On Windows Embedded it’s even set to tick every **30 seconds**, and if the locale-change flag isn’t set it won’t apply your new format until the **next 60 second**  interval
- Our `SendMessageTimeout`  call broadcasts `WM_SETTINGCHANGE` asynchronously (using the `SMTO_ABORTIFHUNG`  flag), so it **queues**  the notification and returns immediately—Explorer may only handle it when it next wakes up to process messages.

**Net effect:**  you can see up to a **one-second (or more)**  lag between running the script and the tray clock actually redrawing with your “Focus: …” text.
