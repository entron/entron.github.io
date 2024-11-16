---
layout: post
title: Random Light Finder (Matlab version)
date: '2011-04-23T19:24:00.000+02:00'
author: Cheng Guo
categories: [Lego NXT]
tags:
- Euglena
modified_time: '2011-10-20T16:36:49.495+02:00'
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-6144518669151500000
blogger_orig_url: https://evolvingnxt.blogspot.com/2011/04/random-light-finder-matlab-version.html
---

Today I found some time to play with the Lego NXT, and I wrote the MATLAB version of the [random light finder](https://evolvingnxt.blogspot.com/2010/10/random-walker-v3.html). The MATLAB program is shown below. It works quite well. With MATLAB, I can now easily implement more sophisticated algorithms.

The robot can now effectively avoid obstacles, and I don't need to help it get out of tight spots from time to time. The program can also plot the light sensor data while the robot moves around. However, it is very slow to find the light because it's a random walker, just like the Euglena.

The code is [here](https://code.google.com/p/evolvingnxt/source/browse/euglena/random.m).

Most of the code is straightforward, but there is one line that needs some explanation:

`abs(lightdata(step)-lightdata(step-1)) < 5`

This means the light intensity has almost not changed compared to the last step. This could happen because the robot is stuck somewhere and can't move forward. It could also happen because it has moved into a dark area where the light is consistently very low and hardly changes. The robot should avoid both situations, so I let the robot go backward a little bit in these two cases.
