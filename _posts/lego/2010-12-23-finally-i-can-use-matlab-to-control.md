---
layout: post
title: Finally I can use matlab to control Lego NXT on my macbook
date: '2010-12-23T00:48:00.000+01:00'
author: Cheng Guo
categories: [Lego NXT]
modified_time: '2011-09-30T21:15:16.346+02:00'
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-5373637552909015831
blogger_orig_url: https://evolvingnxt.blogspot.com/2010/12/finally-i-can-use-matlab-to-control.html
---

I got a license for MATLAB on my MacBook Pro, and I tested controlling NXT with [RWTH Aachen MINDSTORMS NXT Toolbox](https://www.mindstorms.rwth-aachen.de/trac/wiki/Download). With Bluetooth, it works very well, though I haven't succeeded in using USB. Anyway, Bluetooth is all I need, so that's alright for me.

One thing to note is that in the installation instructions ([link here](https://www.mindstorms.rwth-aachen.de/trac/wiki/Download4.04)), there is a small mistake: only after you execute

```matlab
COM_OpenNXT('bluetooth.ini')
```
You get the sign on NXT change from **B<** to **B< >**.

I will experiment with the power of Matlab from now on!
