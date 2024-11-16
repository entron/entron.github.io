---
layout: post
title: celegans project introduction
date: '2011-10-21T15:28:00.000+02:00'
author: Cheng Guo
categories: [Lego NXT]
tags:
- celegans
modified_time: '2011-10-21T15:40:59.678+02:00'
thumbnail: https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEigc5LVELWaEORvCfI6-pyB_T5gL0MB6_lkOHlif-_MX_CoKEWBWSJR_JhZWrrhKeZm-COs8ltahDAi8GFOpLbEeBtGCWfP9Ej3OdPLk4XI1Vel7maw9o_uHWE5lcmI7rfjgazBt4-t2A/s72-c/Screen+Shot+2011-10-21+at+3.34.00+PM.png
blogger_id: tag:blogger.com,1999:blog-8508490992555187365.post-8239818614591748366
blogger_orig_url: https://evolvingnxt.blogspot.com/2011/10/celegans-project-introduction.html
---

In the previous euglena project, I programmed some simple searching algorithm for the NXT robot to find light. With the celegans project I will go a biotic approach, more specifically I will design a neuron network to control the robot to achieve the same aim (find light) as euglena instead of programming by myself. Here programming I mean the traditional "if...then..." style programming. To design a neural network to realize certain task, generally speaking, is also programming, but I would rather call this kind programming "neuroprogramming". Neuroprogramming is different with conventional programming.&nbsp;It is fundamentally&nbsp;parallel, thus needs a very different programming paradigm. celegans could be a good model to try. The name is from&nbsp;"c. elegans", which is a tiny worm only 1mm long, and it is the&nbsp;simplest intensively-studied&nbsp;model organism with neural system.<br />
<br />
I will use 1 light sensor to detect light and two motors for the movement. Therefore at least 3 neurons are needed: 1 sensor neuron, 2 motor neurons. Are three neurons enough? I guess probably not for an efficient light finder. To find the light&nbsp;source the robot should know the change of light intensity. It might be necessary to include more interneurons for this function.<br />
<br />
During the past few months I have read quite a few papers in neural science to gain some inspiration from the real neural systems. Some of which are about c. elegans. Even though I expected for c. elegans to survive it should do something similar like finding the light I was still a bit&nbsp;surprised&nbsp;to read that the neural network the real c. elegans used could be directly applied on my NXT robot! The only difference is c.~elegans is more interested chemicals rather than light, so light intensity is replaced by chemical concentration for c. elegans. Other than this everything is almost the same. I found the following facts about c. elegans' chemotaxis:<br />
<ul>
<li>It only uses 1 sensor neuron.</li>
<li>Effectively it uses 2 &nbsp;motor neuros to control the left and right side of the muscles.</li>
</ul>
<div>
Neurocircuits it might be using has been proposed, for example&nbsp;<a href="http://edizquierdo.wordpress.com/2010/08/05/evolution-and-analysis-of-minimal-neural-circuits-for-klinotaxis-in-c-elegans/">Eduardo Izquierdo used a genetical algorithm to find some working minimal neural networks</a>&nbsp;(<span style="font-family: MyriadMM; font-size: 8pt;">The Journal of Neuroscience, September 29, 2010 </span><span style="font-family: MyriadMM; font-size: 7pt;">• </span><span style="font-family: MyriadMM; font-size: 8pt;">30(39):12908 –12917</span>); I especially like <a href="http://www.csi.uoregon.edu/projects/celegans/talks/nips1996poster.html">the work by&nbsp;T. C. Ferree et al</a>. Indeed ten years ago, they have done exactly the same thing I want to do now: use the neural network to control the robot to find light! Here is their paper "<a href="http://chinook.uoregon.edu/papers/ab1998.pdf">Robust spatial navigation in a robot inspired by chemotaxis in c. elegans</a>". Therefore as the first step I will simply repeat their work based on NXTCamel. The photo below is their modeling of the car from the paper. NXTCamel is designed to have a&nbsp;equivalent&nbsp; driving system as their model.<br />
<br />
<br /></div>
<div class="separator" style="clear: both; text-align: center;">
<a href="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEigc5LVELWaEORvCfI6-pyB_T5gL0MB6_lkOHlif-_MX_CoKEWBWSJR_JhZWrrhKeZm-COs8ltahDAi8GFOpLbEeBtGCWfP9Ej3OdPLk4XI1Vel7maw9o_uHWE5lcmI7rfjgazBt4-t2A/s1600/Screen+Shot+2011-10-21+at+3.34.00+PM.png" imageanchor="1" style="margin-left: 1em; margin-right: 1em;"><img border="0" height="320" src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEigc5LVELWaEORvCfI6-pyB_T5gL0MB6_lkOHlif-_MX_CoKEWBWSJR_JhZWrrhKeZm-COs8ltahDAi8GFOpLbEeBtGCWfP9Ej3OdPLk4XI1Vel7maw9o_uHWE5lcmI7rfjgazBt4-t2A/s320/Screen+Shot+2011-10-21+at+3.34.00+PM.png" width="280" /></a></div>