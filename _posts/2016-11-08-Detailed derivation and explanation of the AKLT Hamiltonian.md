---
title: Detailed derivation and explanation of the AKLT Hamiltonian
categories: [physics]
tags: []     # TAG names should always be lowercase
math: true
---
This was originally published on [StackExchange](https://physics.stackexchange.com/questions/286601/detailed-derivation-and-explanation-of-the-aklt-hamiltonian). Some background:

While reading about the 2016 Nobel Prize in Physics, I came across the famous AKLT paper.
I should have read it long ago while still studying physics, as it is a very classical model.
After leaving physics for four years, I suddenly wanted to challenge myself to see how much I could still understand from a physics paper, so I started reading it.
I immediately encountered my first obstacle, which led me to ask a question on StackExchange.
The question I asked likely made some moderators think I was a newbie, and they deleted it.
Fortunately, some other moderators stepped in, deemed it a valid question, and restored it.
Below are the original question and my answer.

----------------

I am trying to read the original paper for the [AKLT model](https://en.wikipedia.org/wiki/AKLT_model),

>Rigorous results on valence-bond ground states in antiferromagnets. I Affleck, T Kennedy, RH Lieb and H Tasaki. [*Phys. Rev. Lett.* **59**, 799 (1987)](https://doi.org/10.1103/PhysRevLett.59.799).

However I am stuck at Eq. $(1)$:

>we choose our
Hamiltonian to be a sum of projection operators onto
spin 2 for each neighboring pair:
>$$
\begin{align}
H &= \sum_i P_2 (\mathbf{S_i} + \mathbf{S_{i+1}}) \\
  &= \sum_i \left[\frac{1}{2}\mathbf{S_i}\cdot\mathbf{S_{i+1}} + \frac{1}{6}(\mathbf{S_i}\cdot\mathbf{S_{i+1}})^2 + \frac{1}{3}\right]
\end{align}\tag{1}
$$

In the equation, $H$ is the proposed Hamiltonian for which the authors intend to show that the ground state is the VBS ground state: the (unique) state with a single valence bond connecting each nearest-neighbor pair of spins, i.e. a type of spin-$1$ valence-bond-solid. Moreover, $\mathbf{S_i}$ and $\mathbf{S_{i+1}}$ are spin-$1$ operators, and $P_2$ is the projection operator onto spin-2 for the pair $(i,i+1)$.

I have several questions here.

 - First, how did the authors come up with the first line by observing the spin-1 valence-bond-solid state as below (Fig. 2 of the above paper)? 

![](/assets/2016/W0S85.png)

 - Why do they use a Hamiltonian which is "a sum of projection operators onto spin 2 for each neighboring pair"? 
 - What does it mean exactly to project spin-$1$ pairs to spin $2$, and why do they want to project to spin $2$? 

I feel there are quite a few steps skipped between here and standard QM textbooks. It would be great if somebody could recommend me some materials bridging them.

 - Secondly, I want to know how to go from the first line to the second line of equation $(1)$. However, I couldn't find the explicit form of $P_2$ either in the paper or by googling. Could somebody give me a hint?

Edit: I found a chapter of the unfinished book "Modern Statistical Mechanics" by Paul Fendley almost directly answers all my questions.

----------------

Below is the answer to my above question.

Let me try to answer my own questions to thank those who gave voice and support for undeleting this question. My main reference is the chapter 3 *Basic quantum statistical mechanics
of spin systems* of the unfinished book "Modern Statistical Mechanics" by Paul Fendley. 

The spin-1 valence-bond-solid state (VBS) in Fig. 2 can be imagined as the following: 

* Each spin-1 site is made of two spin-1/2 in triplet states (which has s=1)
* Each of the imagined spin-1/2 forms a singlet state (valence-bond) with another spin-1/2 of the neighboring site. 

In this sense, if we focus on two neighboring spin-1 sites, we can think them as 4 spin-1/2.

Given 4 spin-1/2, the only way to form a spin-2 is two pairs spin-1/2 form two spin-1 respectively, and then these two spin-1 forms a spin-2. If any pair of spins in this 4 spin-1/2 forms a spin-0 valence bond, then this 4 spin-1/2 no longer can form a spin-2 entity, which is the case for the spin-1 VBS state. Therefore, if we apply a projector to spin-2 on two neighboring sites in the spin-1 VBS we get 0 (annihilates the state). Consequently, the sum of such projectors on each pair of the neighboring sites, which is the proposed Hamiltonian, also annihilate the spin-1 VBS state. In other word, the spin-1 VBS state is an eigenstate of the hamiltonian with eigenvalue 0.

Considering the fact that a projector has two eigenvalues 0 and 1 and the sum of projectors has eigenvalues equal or bigger than 0. A 0 eigenvalue means spin-1 VBS is the ground state of the proposed Hamiltonian.

Note that in my question I thought $P_2$ is the projection operator onto spin-2 for the spin pair, but this is a mistake. Actually the whole notation $P_2(\mathbf{S_i} + \mathbf{S_{i+1}})$ is the projector operator. I don't like this confusing notation personally and would prefer something like $P_{2}^{\mathbf{S_i}, \mathbf{S_{i+1}}}$ or $P_{2}^{i, i+1}$, but I will use $P_2$ for short in the following.

Now I have answered the first 3 of my questions. My feeling is that it is more of a trick to get the Hamiltonian. The author could be inspired by previous work with Heisenberg model and Majumdar-Ghosh model as both Hamiltonian can also be expressed as the sum of projectors.

Now comes the last question which is to find out what $P_2$ is. $P_2$ acts on 2 spin-1 sites. 
he eigenstates of $X \equiv (\mathbf{S_i} + \mathbf{S_{i+1}})^2$, namely $|0\rangle$, $|1\rangle$, $|2\rangle$, are also the eigenstate of $P_2$. 
To be complete I listed the eigenvalues of $X$ and the three spin projectors in the following table:


| s   | $X$ | $P_0$ | $P_1$ | $P_2$ |
| --- | --- | ----- | ----- | ----- |
| 0   | 0   | 1     | 0     | 0     |
| 1   | 2   | 0     | 1     | 0     |
| 2   | 6   | 0     | 0     | 1     |


We can express the projector as the function of $X$ so that it satisfy the above table:

$$
\begin{align}
P_0 &= \frac{1}{12} (X-2)(X-6)\\
P_1 &= -\frac{1}{8} X(X-6)\\
P_2 &= \frac{1}{24} X(X-2)
\end{align}
$$

If we replace $X$ in the above equation with

$$
\begin{align}
X &= (\mathbf{S_i} + \mathbf{S_{i+1}})(\mathbf{S_i} + \mathbf{S_{i+1}})\\
 &= \mathbf{S_i^2} + \mathbf{S_{i+1}^2} + 2\mathbf{S_i} \cdot \mathbf{S_{i+1}} \\
 &= 4 + 2\mathbf{S_i} \cdot\mathbf{S_{i+1}}
\end{align}
$$

then we get

$$
P_2 = \frac{1}{6} (\mathbf{S_i} \cdot\mathbf{S_{i+1}})^2 + \frac{1}{2} \mathbf{S_i} \cdot\mathbf{S_{i+1}} + \frac{1}{3}
$$
  