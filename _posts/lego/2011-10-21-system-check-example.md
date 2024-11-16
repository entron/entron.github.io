---
layout: post
title: NXTCamel example
date: '2011-10-21T01:50:00.001+02:00'
author: Cheng Guo
categories: [Lego NXT]
tags:
- NXTCamel
modified_time: '2011-10-22T19:11:34.131+02:00'
thumbnail: https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhY1AeGQMSblynSnIe1rsoy2yaqIO2A3NQWL-RlNIrwLboBguG0wQXRI97GPwZ60TIMT-zB9GSe_GojS5kzuL4915gny6viPZhreXD4KXWgoz2sNJoVk7Kt-XmzB3EAbLxEjQWWLjJIYQ/s72-c/distance.png
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-409192952501488923
blogger_orig_url: https://evolvingnxt.blogspot.com/2011/10/system-check-example.html
---

I wrote a matlab function checksystem.m to check whether all motors and sensors are working on <a href="http://evolvingnxt.blogspot.com/2011/09/nxtcamel.html">NXTCamel</a> as I expected (I didn't test the sound and touch sensor in the first version of the function). The program can be downloaded <a href="http://code.google.com/p/evolvingnxt/source/browse/nxtcamel/checksystem.m">here</a>. Before you running this program you should make sure:<br />
<ol>
<li>The RWTH Mindstorms NXT Toolbox for matlab is installed correctly and you could connect to NXT within matlab using bluetooth without any error.</li>
<li>All sensors and motors are connected to the same ports as in the <a href="http://code.google.com/p/evolvingnxt/downloads/detail?name=nxtcamel_building_instruction.tar.gz&amp;can=2&amp;q=">building instruction</a>. </li>
<li>The ultrasonic sensor is facing to the right. I define this as the default starting position.</li>
<li>You have enough space (at least 2 by 2 meter) for NXTCamel to run.</li>
</ol>
If everything works fine, the output in Matlab should look like the following:<br />
<br />
<div style="background-color: #f9cb9c;">
<span style="font-size: x-small;"><span style="font-family: Arial,Helvetica,sans-serif;">&gt;&gt; checksystem</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Make sure the ultrasonic sensor faces to the right side before you start.</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">========Now test driving system========</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Drive forward for 3 second. Press any key to start...</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Drive backward for 3 second. Press any key to start...</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Turn left. Press any key to start...</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Turn right. Press any key to start...</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Back and turn. Press any key to start...</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Back and turn to the other direction. Press any key to start...</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">========Driving system test finished========</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">========Now test the sonar system========</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Sweep sonar and measure the distance. Press any key to start...</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">========Sonar test finished========</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">Light intensity is 42.3%</span><br style="font-family: Arial,Helvetica,sans-serif;" /><span style="font-family: Arial,Helvetica,sans-serif;">========All test finished========</span></span></div>
<br />
<div style="font-family: inherit;">
<span style="font-size: small;">It will also plot the distance measured by the ultrasonic sensor in a polar plot like this:</span></div>
<div style="font-family: inherit;">
<span style="font-size: small;"><br /></span> </div>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhY1AeGQMSblynSnIe1rsoy2yaqIO2A3NQWL-RlNIrwLboBguG0wQXRI97GPwZ60TIMT-zB9GSe_GojS5kzuL4915gny6viPZhreXD4KXWgoz2sNJoVk7Kt-XmzB3EAbLxEjQWWLjJIYQ/s1600/distance.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhY1AeGQMSblynSnIe1rsoy2yaqIO2A3NQWL-RlNIrwLboBguG0wQXRI97GPwZ60TIMT-zB9GSe_GojS5kzuL4915gny6viPZhreXD4KXWgoz2sNJoVk7Kt-XmzB3EAbLxEjQWWLjJIYQ/s1600/distance.png" /></a> </div>
<div style="font-family: inherit;">
<br />
<span style="font-size: small;">Note that the NXTCamel by definition is always facing the 90 degree (12 o'clock) direction. The number 100, 200, 300 in the plot is the distance in centimeter. I measured 10 points here. One could in principle sample more points and get a better representation of the surrounding environment though it will be slower.&nbsp;&nbsp;</span></div>
<div style="font-family: inherit;">
<span style="font-size: small;"><br /></span> </div>
<div style="font-family: inherit;">
<span style="font-size: small;">This distance information is naive compared with <a href="http://spectrum.ieee.org/automaton/robotics/artificial-intelligence/how-google-self-driving-car-works">those from Google car</a></span>.<span style="font-size: small;"> Nevertheless it is enough to let NXTCamel drive without hitting obstacles.&nbsp;</span><br />
<br />
<span style="font-size: small;">Update:&nbsp;</span><br />
<span style="font-size: small;"><a href="http://code.google.com/p/evolvingnxt/source/browse/nxtcamel/drivenxtcamel.m">Here is an example</a> with a simple algorithm, and I am sure there is still lot of space for improvement. Please let me know if you get a better way.</span> </div>