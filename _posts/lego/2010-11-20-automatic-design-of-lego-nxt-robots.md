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

Building Lego NXT according to your imagination is lots of fun, but figuring out some really cool stuff is not easy. I was wondering whether there are some ways to automatically design Lego robots (in this blog entry I am only concerned with hardware) like those Windows screensavers generating random forms of artificial life. After some research, I found no one has done it yet. However, there are already lots of resources which might be enough for a group of very talented people to figure out how to design a Lego robot automatically. I will summarize what I have found below.

### Background

I think the most promising way to automatically design a Lego robot is to follow nature, namely using an evolutionary mechanism. One can use a Genetic Algorithm (GA) to search for a design fit to the need. This field of study is called "Evolving Hardware" or "Evolvable Hardware" (EHW). This field is still in its preliminary stage. There are now two major directions in this field.

The first one is evolvable electronics, which can be either digital or analog circuits. For digital circuits, one can first design on a computer using GA and then test it with FPGA or build the evolutionary mechanism directly on the FPGA, which can then achieve some adaptive advantages. Search "FPGA" with "Evolvable Hardware" on Google if you want to learn more about it. For analog circuits, there is less research, though I think it is also a very promising direction. [Here](https://ti.arc.nasa.gov/projects/esg/research/circuit.htm) is a group in NASA doing this kind of research.

Another direction of EHW research is evolutionary machines (objects). It is generally easier to simulate and test electronics than machines, so much less research can be found in this area. The [Golem project](https://ccsl.mae.cornell.edu/golem) at Cornell is probably one of the earliest systematic attempts. A successful story of designing an antenna using GA can be found [here](https://ti.arc.nasa.gov/projects/esg/research/antenna.htm). Automatically designing a Lego NXT robot lies in this direction.

### Outline

I don't think I can make an automatic design of NXT work by myself. It requires a lot of work and has a high risk of not being accomplished even after years of dedicated effort. However, I will list what I would do if I worked on this project here. If I find more collaborators, I might start it.

#### Step 1: Map the Lego NXT robot's structure to a DNA-like one-dimensional representation

One can probably label different types of basic Lego building blocks with different IDs and parameters. The mapping should be done in a way that the code itself reflects the actual similarities and differences between the bricks. For example, in the Lego NXT kit, there are bars with different geometries, lengths, and hole types. Let's say we have 4 bars:

- No.1: Straight bar with 4 round holes.
- No.2: Straight bar with 3 round holes in a row and the last hole is a "+" hole. (If you have a Lego NXT, you know what I mean.)
- No.3: Straight bar with 5 round holes.
- No.4: L-shaped bar with one arm like No.2 and the second arm with a round hole.

If I name them as "A", "B", "C", "D", both computers and people know nothing about the relationship between them. That would be a bad code. A better way to name them could be:

- `BARoooo`  
- `BARooox`  
- `BARooooo`  
- `BARolooox`  

`BAR` is the type name. I think using 3 capital letters for the brick type is a good option, as it allows for sufficient variation to go beyond Lego NXT bricks.

I can either give each bar a unique code like "A" for a straight bar with 4 holes and "B" for a straight bar with 5 holes, or better yet, call them `BAR4` and `BAR5`.

*(to be continued)*
