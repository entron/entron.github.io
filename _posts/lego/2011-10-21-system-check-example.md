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

I wrote a Matlab function `checksystem.m` to check whether all motors and sensors are working on [NXTCamel](https://evolvingnxt.blogspot.com/2011/09/nxtcamel.html) as I expected (I didn't test the sound and touch sensor in the first version of the function). The program can be downloaded [here](https://code.google.com/p/evolvingnxt/source/browse/nxtcamel/checksystem.m). Before you run this program, you should make sure:

1. The RWTH Mindstorms NXT Toolbox for Matlab is installed correctly and you can connect to NXT within Matlab using Bluetooth without any errors.
2. All sensors and motors are connected to the same ports as in the [building instruction](https://code.google.com/p/evolvingnxt/downloads/detail?name=nxtcamel_building_instruction.tar.gz&can=2&q=).
3. The ultrasonic sensor is facing to the right. I define this as the default starting position.
4. You have enough space (at least 2 by 2 meters) for NXTCamel to run.

If everything works fine, the output in Matlab should look like the following:

> **checksystem**  
> Make sure the ultrasonic sensor faces to the right side before you start.  
> **========Now test driving system========**  
> Drive forward for 3 seconds. Press any key to start...  
> Drive backward for 3 seconds. Press any key to start...  
> Turn left. Press any key to start...  
> Turn right. Press any key to start...  
> Back and turn. Press any key to start...  
> Back and turn to the other direction. Press any key to start...  
> **========Driving system test finished========**  
> **========Now test the sonar system========**  
> Sweep sonar and measure the distance. Press any key to start...  
> **========Sonar test finished========**  
> Light intensity is 42.3%  
> **========All test finished========**

It will also plot the distance measured by the ultrasonic sensor in a polar plot like this:

![Distance Plot](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhY1AeGQMSblynSnIe1rsoy2yaqIO2A3NQWL-RlNIrwLboBguG0wQXRI97GPwZ60TIMT-zB9GSe_GojS5kzuL4915gny6viPZhreXD4KXWgoz2sNJoVk7Kt-XmzB3EAbLxEjQWWLjJIYQ/s1600/distance.png)

Note that the NXTCamel by definition is always facing the 90 degree (12 o'clock) direction. The numbers 100, 200, 300 in the plot represent the distance in centimeters. I measured 10 points here. One could, in principle, sample more points and get a better representation of the surrounding environment, though it will be slower.

This distance information is naive compared with [those from Google car](https://spectrum.ieee.org/automaton/robotics/artificial-intelligence/how-google-self-driving-car-works). Nevertheless, it is enough to let NXTCamel drive without hitting obstacles.

### Update:
[Here is an example](https://code.google.com/p/evolvingnxt/source/browse/nxtcamel/drivenxtcamel.m) with a simple algorithm. I am sure there is still a lot of space for improvement. Please let me know if you find a better way.
