---
layout: post
title: Random Light Finder v1
date: '2010-10-05T00:18:00.000+02:00'
author: Cheng Guo
categories: [Lego NXT]
tags:
- Euglena
modified_time: '2011-09-30T21:12:57.887+02:00'
thumbnail: https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhiXYT5LzWBzboF1lvd4Fc-c5SXfyA3gb8bRTz4UxgOwsFF18pHcvPeWtpGjY7WXXn7XXEXNCTbBY4O-RdPRLZvqJ5VvJ3yWtOTCdqNesG4KBoJgdqpRscqxZpc-xKqMQsa4iWxjdMCow/s72-c/random-light-finderd.png
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-1678816388178533591
blogger_orig_url: https://evolvingnxt.blogspot.com/2010/10/random-walker-v1.html
---

The first scheme I used is to let the robot do a random walk and stop when the light is stronger than a threshold.

I use the software NXT-G, which comes with the Lego NXT 8527 package, to program it. Below is the illustration of the program, and the program is attached.

![Random Light Finder Program](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhiXYT5LzWBzboF1lvd4Fc-c5SXfyA3gb8bRTz4UxgOwsFF18pHcvPeWtpGjY7WXXn7XXEXNCTbBY4O-RdPRLZvqJ5VvJ3yWtOTCdqNesG4KBoJgdqpRscqxZpc-xKqMQsa4iWxjdMCow/s640/random-light-finderd.png)

I put my desktop lamp on the floor as the light source. When NXT is within 30 cm and facing the lamp, I get a light intensity over 70%. Therefore, I set 70% as the threshold in the program to tell NXT to stop.

[Download the program here.](https://code.google.com/p/evolvingnxt/downloads/detail?name=Random%20Light%20Finder.rbt&amp;can=2&amp;q=)
