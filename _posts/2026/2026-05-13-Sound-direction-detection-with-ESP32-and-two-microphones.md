---
title: "Sound Direction Detection with ESP32 and Two Microphones"
date: 2026-05-13 12:00:00 +0000
layout: post
categories: [robotics]
tags: [esp32, audio, INMP441]
math: false
---

I have just open-sourced my little sound direction detection project here:
[entron/esp32_sound_direction](https://github.com/entron/esp32_sound_direction).

![My sound direction experiment](/assets/2025/sound_direction_exp.jpg)

The idea is simple: use an ESP32 and two microphones to estimate where a sound is coming from.
We do this naturally with our two ears, and I wanted to see whether I could do the same thing with two microphones.

It is not a lab-grade localization system. It is a practical hobby project that is good enough to explore the basic physics, embedded audio handling, and a few useful signal-processing tricks.
If you want to learn these things, I recommend trying it out. It is lots of fun!

At first, I could not make this work and gave up after a few tries. Recently, I asked Codex to examine the reason, and after a few iterations it figured out that I was using two mono channels for the two microphones, which meant the timing was not guaranteed to be synchronized.
After switching to stereo, it worked like magic.
This is a good lesson that when dealing with sensors, timing synchronization is extremely important.

I also asked Codex to build a web monitor, and after a few tweaks I am quite happy with it:

![Web monitor](/assets/2026/web_monitor.png)
