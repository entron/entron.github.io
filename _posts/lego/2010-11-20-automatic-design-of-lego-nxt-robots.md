---
layout: post
title: Automatic design of Lego NXT robots
date: '2010-11-20T22:41:00.000+01:00'
author: Cheng Guo
categories: [Lego NXT]
modified_time: '2011-10-05T14:21:57.000+02:00'
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-5237600223772916868
blogger_orig_url: https://evolvingnxt.blogspot.com/2010/11/automatic-design-of-lego-nxt-robots.html
---

Building Lego NXT according to your imagination is lots of fun, but to figure out some really cool stuff is not easy. I was wondering whether there are some ways to automatically design Lego robots (in this blog entry I only concern about hardware) like those windows screen saver generating random forms of artificial life. After some research I found no one has done it yet. However, there are already lots of resources which maybe already enough for a group of very talented people to figure out how to design a Lego robot automatically. I will summarize what I have found in the following.<br />
<br />
<h3>








Background</h3>
I think the most promising way to automatically design a Lego robots is to follow the nature, namely using evolutionary mechanism. One uses Genetic Algorithm (GA) to search for a design fit to the need. This field of study is called "Evolving Hardware" or "Evolvable Hardware" (EHW).&nbsp; This field is still in its preliminary stage. There are now two major directions in this field. The first one is evolvable electronics, which can be either digital or analog circus. &nbsp; For digital circus, one can first design on a computer&nbsp; using GA then test it with FPGA or build the evolutionary mechanism directly on the FPGA which can then achieve some adaptive advantage. Search "FPGA" with "Evolvable Hardware" on Google if you want to know about it. For analog circus there are fewer research though I think its also&nbsp; a very promising direction. <a href="http://ti.arc.nasa.gov/projects/esg/research/circuit.htm" target="_blank">Here</a> is a group in NASA who are doing this kind of research.<br />
<br />
Another direction of EHW research is the evolutionary machines (objects). It is generally easier to simulate and test electronics than machines, therefore much fewer research can be found in this direction. The <a href="http://ccsl.mae.cornell.edu/golem" target="_blank">Golem project</a> at Cornell is probably one of the most earliest systematic try. A successful story to design antenna using GA can be found <a href="http://ti.arc.nasa.gov/projects/esg/research/antenna.htm" target="_blank">here</a>. To automatically design a Lego NXT robots lyes in this direction.<br />
<br />
<h3>








Outline</h3>
I don't think I can make an automatic design of NXT work by myself. It needs lots of work and has a high risk to be not&nbsp;accomplished after years of dedicated work.&nbsp;&nbsp;However, I still list what I will do if I work on this project here. When I find more people I might start it.<br />
<br />
<h4>








Step 1&nbsp;<span style="font-size: 13px; font-weight: normal;">Map the Lego NXT robot's structure to a DNA like one dimensional representation</span></h4>
Probably one can label different types of the basic Lego building blocks with different id and&nbsp;parameters. I should choose a way of mapping so that the code itself could reflect the actual similarity and difference of the bricks.&nbsp;For example in the Lego NXT kit there are bars with different geometry, length and different types of holes. Let's say we have 4 bars. They are:<br />
<br />
No.1 Straight bar with 4 round holes.<br />
<br />
No.2 Straight bar with 3 round hole in a row and the last hole is a "+" hole. (If you have a Lego NXT, you know what I mean.)<br />
<br />
No.3 Straight bar with 5 round holes.<br />
<br />
No.4 L shape bar with one arm like No.2 and the seconde arm is a round hole.<br />
<br />
If I name them as "A", "B", "C", "D", both computer and people know nothing about the relation between them. That's a bad code. &nbsp;A better way to call them is to use these names:<br />
<br />
BARoooo<br />
<br />
BARooox<br />
<br />
BARooooo<br />
<br />
BARolooox<br />
<br />
BAR is the name of the type. I think to use 3 capital letter for the type of bricks is a good option so you have enough variations to go beyond Lego NXT bricks.<br />
<br />
I can either give each bar a unique code like "A" for a straight bar with length 4 holes one it and "B" a&nbsp;straight&nbsp;&nbsp;bar with 5 holes on it or better call them "BAR4" and "BAR5"<br />
<br />
(to be continued)