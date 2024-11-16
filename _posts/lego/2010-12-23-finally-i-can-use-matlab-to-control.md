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

I got a license for matlab on my Macbook pro and I test to control nxt with <a href="http://www.mindstorms.rwth-aachen.de/trac/wiki/Download" target="_blank">RWTH Aachen MINDSTORMS NXT Toolbox</a>. With bluetooth it works very well though I haven't succeed to use USB. &nbsp;Anyway, bluetooth is all I need, so that's alright for me. One thing I should note is that in the installation instruction( http://www.mindstorms.rwth-aachen.de/trac/wiki/Download4.04 ) there is a small mistake: only after you execute<br />
<blockquote>
<tt>COM_OpenNXT('bluetooth.ini')</tt></blockquote>
<br />
you get the sign on NXT change from&nbsp;<strong>B&lt;</strong> to&nbsp;<strong>B&lt; &gt;</strong><br />
<br />
I will experiment with the power of Matlab from now on!