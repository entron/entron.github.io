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

Today I found some time to play with the Lego NXT, and I wrote the matlab version of the <a href="http://evolvingnxt.blogspot.com/2010/10/random-walker-v3.html" target="_blank">random light finder</a>. The matlab program is shown below. It works quite well. With matlab I can now easily implement more sophisticated algorithm.<br />
<br />
The robot can now effectively avoid obstacles, and I don't need to help it get out of somewhere from time to time. The program can also plot the light sensor data while the robot moves around. It is very slow to find the light because it's a random walker just like the Euglena.<br />
<br />
The code is <a href="http://code.google.com/p/evolvingnxt/source/browse/euglena/random.m">here</a>.<br />
<br />
Most of the code are straight forward, there is only one line I need to put some more words.<br />
<br />
<em>abs(lightdata(step)-lightdata(step-1))&lt;5 </em>means the light intensity almost unchanged compare to the last step. This could because the Robot get stuck somewhere and can't move forward. It also could because it goes to a dark regime where the light is always very low therefore hardly changes. The robot should avoid both the situations, so I let the robot go backwards a little bit in these two cases.<br />
<br />
<em><br /></em>