---
title: "Two Clarifications About the One-Pixel Model in Even Coding"
date: 2026-07-18 12:00:00 +0200
layout: post
categories: [AI]
tags: [Efficient Coding, Probabilistic Modeling, Information Theory]
math: true
mermaid: false
---

In my paper, [*Efficient Representation of Natural Image Patches*](https://arxiv.org/abs/2210.13004), I argue that two objectives are generally different:

1. maximizing information transmission, and
2. accurately modeling the input probability distribution.

Two parts of the argument are easy to misunderstand—in fact, GPT-5.6 Sol misunderstood them—so I want to explain them briefly.

## 1. Why is $p(x\mid y_i) = 1/n_i$?

The model uses a deterministic many-to-one transformation:

$$
y = f(x).
$$

Suppose the output is $y_i$. We then know that the input $x$ belongs to the corresponding group $G_i$, which contains $n_i$ possible input levels.

However, the transformation has discarded the information that distinguishes those input levels. From the output $y_i$ alone, we know only that

$$
x \in G_i.
$$

We therefore assign equal probability to all $n_i$ possibilities:

$$
p(x \mid y_i) =
\begin{cases}
1/n_i, & x \in G_i, \\
0, & x \notin G_i.
\end{cases}
$$

This does **not** mean that the original input distribution $p(x)$ was uniform inside $G_i$. The original distribution is unknown. It means that, given only $y_i$ and the transformation $f$, we have no information that favors one input level over another.

Using the output probability $Q(y_i)$, the reconstructed distribution is therefore

$$
q(x) = \frac{Q(y_i)}{n_i}, \qquad x \in G_i.
$$

The reconstruction preserves the total probability mass inside every group:

$$
\sum_{x \in G_i} q(x) = Q(y_i) = \sum_{x \in G_i} p(x).
$$

What is lost is the variation of $p(x)$ within each group.

## 2. Why is the longer proof needed?

The entropy of the reconstructed distribution can be written as

$$
H_q = H_Q + \sum_i Q(y_i) \log n_i.
$$

This equation clearly shows that $H_q$ and $H_Q$ are different quantities.

But this alone does not prove that maximizing $H_Q$ fails to minimize $H_q$. Two different objective functions can still have the same optimum.

There is another complication: when a boundary between two groups moves, both their probabilities and their sizes change. In other words,

$$
Q(y_i) \quad \text{and} \quad n_i
$$

change together. The equation above does not directly tell us whether $H_q$ increases or decreases while $H_Q$ is being increased.

This is why the paper analyzes a small movement of a boundary. The result shows that the change in $H_q$ depends on the local probabilities. Increasing $H_Q$ does not always move $H_q$ in the direction needed for better probability modeling.

The appendix then gives a concrete example. For the same input distribution and the same two-output model:

$$
\text{maximizing } H_Q
\quad \Rightarrow \quad
a \approx 0.293M,
$$

while

$$
\text{minimizing } H_q
\quad \Rightarrow \quad
a \approx 0.602M.
$$

The two objectives therefore produce different optimal partitions.
