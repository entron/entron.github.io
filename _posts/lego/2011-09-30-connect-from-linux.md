---
layout: post
title: Connect from linux
date: '2011-09-30T22:25:00.001+02:00'
author: Cheng Guo
categories: [Lego NXT]
modified_time: '2011-09-30T22:29:59.665+02:00'
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-5262842752984806329
blogger_orig_url: https://evolvingnxt.blogspot.com/2011/09/connect-from-linux.html
---

Bought a very cheap Asus X54L laptop two weeks ago. I installed Ubuntu 11.04 on it. Since there is no Bluetooth adapter on the laptop, I bought [LogiLink Bluetooth USB-Adapter Class2 EDR V2.0](https://www.amazon.de/LogiLink-Bluetooth-USB-Adapter-Class2-V2-0/dp/B0019D1LSW/ref=sr_1_4?ie=UTF8&qid=1317413780&sr=8-4) on Amazon.de. It only costs about 3 Euros and works well with Lego NXT.

I basically followed [RWTH Mindstorms NXT toolbox instructions](https://www.mindstorms.rwth-aachen.de/trac/wiki/Download4.04) to successfully connect to Lego NXT without much difficulty. The only problem is that, for some unknown reason, I need to connect twice with the `btconnect` command provided by the toolbox to let Matlab recognize NXT.