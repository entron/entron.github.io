---
layout: post
title: Random Light Finder v3
date: '2010-10-24T13:22:00.000+02:00'
author: Cheng Guo
categories: [Lego NXT]
tags:
- Euglena
modified_time: '2011-09-30T22:11:32.285+02:00'
thumbnail: https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjdliZJivjPpFVvBsNPm54hrNFVpGKB5mfh-BugbwKGZKjR5RdgWP41Y0RUCDVKfz6y0fm7D1WVVi4ABp3WrlyqDNycTz3knSV8uyK8juPaJY0XKv7yycdfVJyhOITgnbQ231XsQ4n3aA/s72-c/p1030367.jpg
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-8960600201362967593
blogger_orig_url: https://evolvingnxt.blogspot.com/2010/10/random-walker-v3.html
---
In this version, I added the function to use the ultrasonic sensor to detect approaching objects and let the NXT avoid them. It works, though there are still some "bugs," partly because of the limitations of the sensor (it can't detect objects that don't reflect ultrasonic waves well and can't detect objects that are too close).

Following are the photos to show how to build the Random Light Finder v3 and the setup:

![Random Light Finder v3 - Photo 1](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjdliZJivjPpFVvBsNPm54hrNFVpGKB5mfh-BugbwKGZKjR5RdgWP41Y0RUCDVKfz6y0fm7D1WVVi4ABp3WrlyqDNycTz3knSV8uyK8juPaJY0XKv7yycdfVJyhOITgnbQ231XsQ4n3aA/s400/p1030367.jpg)

Notably, the facing direction (looking up/down) of the ultrasonic sensor can be controlled by Motor B. I didn't alter the direction in this version, but I will probably explore the possibility in future versions.

![Random Light Finder v3 - Photo 2](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhKpkq81UuUl9km-cvAnijqii0Swd-xXVLlowsue-M6Go1FS_8F5GSOXZoJGsj76mWpH8gGFOA9_Gz38_1ToizDIzWZy3GfgZshGFhLiRWiY0gOtC0J0ABJO2yM2v9VHW1QAR-PJacz1Q/s400/p1030369.jpg)

The program [can be downloaded here](https://code.google.com/p/evolvingnxt/downloads/detail?name=Random%20Light%20Finder%20v3.rbt&amp;can=2&amp;q=).

![Random Light Finder v3 - Program Diagram](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEh4DLvl1T00J3UUmABMckelOiY5QnJa6SGcx-KqPfUJoeAGmO-L4yYMOaJ_Ja0Yknx6RXhqWv-uiQo9-9JCPnI5ctfEtN4Ll79Y7MK0wqGSgin66HEUe7zG6uF6gfKhUHJwKzHUqdFHXw/s640/random-light-finder-v3d.png)
