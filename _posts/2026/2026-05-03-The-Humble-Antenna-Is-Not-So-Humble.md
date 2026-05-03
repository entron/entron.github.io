---
title: "The Humble Antenna Is Not So Humble"
categories: [robotics]
tags: [robotics, tactile-sensing, bio-inspired, stm32, esp32]
math: false
mermaid: false
---

The following blog post is drafted by ChatGPT based on my discussion on this topic with some of my edits.

---

I have been working on a small hobby robot whose goal is intentionally modest: place it in a room, and it should move toward the brightest area it can find. Actually 16 years ago I built [such a robot with Lego]({% post_url lego/2010-10-24-random-walker-v3 %}). Now I want to build a "pro" version of it with STM32/ESP32. It does not need to recognize furniture. It does not need a map. It does not need to know what a “room” is. Ideally, it should behave more like a simple organism than a modern autonomous vehicle.

The hardware is already fairly simple: an STM32 as the main controller, two rear drive motors, a front steering servo, wheel encoders, and an ESP32 for wireless communication and WebSocket-based remote control. The next obvious step is to add a few light sensors so the robot can compare brightness in different directions and move up the light gradient.

That part is relatively straightforward.
The harder question is: how does such a minimal robot avoid walls, furniture, table legs, and other obstacles?

The obvious engineering answers are cameras, lidar, depth sensors, SLAM, or some kind of map-building system. But those feel wrong for this project, because I want a biologically inspired light-seeking robot that behaves more like a simple life form than a fully perceptive machine.

The more I thought about it, the more one simple biological structure stood out: antennae like those found in insects.

## The Humble Antenna Is Not So Humble

Before thinking about this project, I mostly associated insect antennae with smell, pheromones, and social communication. That is not wrong. Antennae are indeed major chemical sensors in many insects.

But they are much more than smell sensors.

Insect antennae are multimodal sensing organs. They can detect contact, bending, vibration, airflow, position, motion, and chemical signals. A recent study on hawkmoth antennae describes antennae as multifunctional, multimodal sensory probes, noting that beyond olfaction, they support auditory, vestibular, tactile, airflow, and gravity-related mechanosensory functions. The Johnston’s organ, located near the base of the antenna, plays an important role in sensing antennal motion and mechanical input. ([PMC][1])


## Are There Commercial Artificial Antennae?

There are some, but mostly in very simple forms.

Educational robotics already has simple tactile contact probes. SparkFun’s RedBot Mechanical Bumper, for example, is essentially a single-pole single-throw switch: when the flexible contact hits an object, it contacts a nearby nut and closes the circuit. SparkFun describes it as a way for the contact probe to hit something before the robot itself crashes into it. ([SparkFun Electronics][5])

Parallax’s Boe-Bot educational robot kit also includes touch sensors, phototransistors, and infrared emitter/receiver pairs. The product page explicitly frames touch, light, and infrared sensors as the systems that let the robot navigate autonomously. ([Parallax][6])

These are useful and accessible, but they are primitive compared with biological antennae. They mostly answer one question: did I touch something?

A richer artificial antenna would answer several questions: which direction did the contact come from, how much did the antenna bend, how strong was the contact, is the contact sliding, where along the antenna did the contact occur, and what kind of surface is being touched?

That kind of sensor is not yet a common, cheap, plug-and-play module for hobby robotics.

## What Research Is Exploring

Artificial antennae and related tactile probes are active research areas. A review of tactile probe sensors in marine science and engineering notes that these sensors have been studied since at least 1987 and can be categorized by sensing principle: optical, magnetic, resistive, capacitive, piezoelectric, and triboelectric. The same review discusses possible uses in marine structure monitoring, tactile perception for marine robots, environmental sensing, and collision avoidance. ([MDPI][7])

More recent work has moved beyond simple rod-like tactile probes and toward insect-inspired antennae.

A 2025 *Nature Communications* paper presented a robust, omnidirectional electronic antenna inspired by insect antennae. The system used flexible, partially magnetized structures so that deformation of the antenna produced measurable magnetic changes. The authors demonstrated vision-free navigation with 0.2 mm tracking deviation, 97% ground texture recognition accuracy, and robotic brushing on curved surfaces with low force variance. ([Nature][8])

A 2024 *Nature Communications* paper reported a neuromorphic antennal sensory system inspired by ant antennae. It used flexible three-dimensional electronic antennae to detect tactile and magnetic stimuli, then processed the signals with artificial synaptic devices. The system performed vibrotactile perception tasks such as profile and texture classification, and magnetic perception tasks including magnetic navigation and touchless interaction. ([Nature][9])

These studies show that artificial antennae are not just about avoiding collisions. They can support vision-free navigation, texture recognition, surface following, magnetic perception, and contact-rich manipulation.

## The Gap Between Biology and Engineering

Despite this progress, artificial antennae remain far behind biological ones.

Biological antennae are highly integrated. They combine chemical sensing, mechanical sensing, motion sensing, airflow sensing, and active movement in one structure. Most engineered systems replicate only one or two of these functions.

Biological antennae also have distributed sensing. A real insect antenna is not a dead rod attached to one sensor at the base. It contains many sensory structures distributed along its length and at its joints. By contrast, many artificial antenna designs measure only root bending or root force. That makes it difficult to infer where contact happened. The same root bending could be caused by a light touch near the tip or a stronger touch closer to the base.

Another useful idea is morphological computation. In animals, the shape, flexibility, damping, segmentation, and surface hairs of the antenna help preprocess information before the nervous system even interprets it. In other words, the body is doing part of the computation. Engineered sensors often do the opposite: they use a simple mechanical structure and then push the complexity into electronics and software.

Finally, many biological tactile systems are active. Insects move their antennae. Active tactile sensing gives the animal extra information because it knows what motion it commanded. If contact happens at a certain point in the sweep, the animal can infer where the object is. Many hobby robots still use purely passive bumpers.


## Why This Matters

This project started as a simple light-seeking robot. But the obstacle-avoidance problem led me to something much deeper: tactile intelligence.

Robotics has made enormous progress with cameras, lidar, and machine learning. But perhaps some robots do not need more vision. Perhaps they need better contact with the world.

A cheap artificial antenna module could be useful for educational robots, cleaning robots, pipe-inspection robots, underwater robots, agricultural robots, search-and-rescue robots, and small mobile platforms that need to move safely without expensive perception hardware.

More importantly, it points to a different way of thinking about robot intelligence.

## References

Haberkern et al., “Behavioural integration of auditory and antennal stimulation during phonotaxis in the field cricket *Gryllus bimaculatus*,” *Journal of Experimental Biology*, 2016. ([The Company of Biologists][1])

SparkFun RedBot Mechanical Bumper product documentation. ([SparkFun Electronics][5])

Parallax Boe-Bot Robot Kit documentation. ([Parallax][6])

Wang et al. review on tactile probes in marine science and engineering, 2023. ([MDPI][7])

Jiang et al., “Neuromorphic antennal sensory system,” *Nature Communications*, 2024. ([Nature][9])

Ren et al., “A robust and omnidirectional-sensitive electronic antenna for tactile-induced perception,” *Nature Communications*, 2025. ([Nature][8])

[1]: https://journals.biologists.com/jeb/article/219/22/3575/16664/Behavioural-integration-of-auditory-and-antennal "Behavioural integration of auditory and antennal ..."
[5]: https://www.sparkfun.com/sparkfun-redbot-sensor-mechanical-bumper.html "SparkFun RedBot Sensor - Mechanical Bumper - SparkFun Electronics"
[6]: https://www.parallax.com/product/boe-bot-robot-kit-usb/ "Boe-Bot Robot Kit - USB - Parallax"
[7]: https://www.mdpi.com/2077-1312/11/11/2108 "MDPI article on tactile probes in marine science and engineering"
[8]: https://www.nature.com/articles/s41467-025-58403-3 "A robust and omnidirectional-sensitive electronic antenna for tactile-induced perception | Nature Communications"
[9]: https://www.nature.com/articles/s41467-024-46393-7 "Neuromorphic antennal sensory system | Nature Communications"
