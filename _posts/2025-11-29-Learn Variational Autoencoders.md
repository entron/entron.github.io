---
title: "Learn Variational Autoencoders"
categories: [AI]
tags: [Probabilistic Modeling]     # TAG names should always be lowercase
math: true
mermaid: false
---


I have never encountered a problem that required a variational autoencoder (VAE) to solve.
I hope I never will.

However, everyone talks about VAEs, so I assume everyone must know it.
Therefore, I decided to spend some time learning just enough about it so I can pretend I know it too.
Below is my note based on discussion with ChatGPT.

---


## 1. Background: Why Do We Need VAEs?

### 1.1. Classical Autoencoders

The classical autoencoders in deep learning are very simple and straightforward. They learn a mapping:

* **Encoder**: $x \rightarrow z$ (compress input to latent code)
* **Decoder**: $z \rightarrow \hat{x}$ (reconstruct input)

They’re great for:

* Dimensionality reduction
* Denoising
* Feature learning

But they have two big limitations:

1. **Latent space is not continuous or structured**

   * Interpolating between two latent vectors often produces garbage.
   * There’s no guarantee that random points in latent space decode to *valid* samples.

2. **Not true generative models**

   Sampling random points from the latent space does not reliably produce meaningful outputs because the model never learned the distribution of valid latent vectors.

### 1.2. Variational Autoencoders

VAEs fix this by making the whole thing **probabilistic**:

* They assume data $x$ is generated from a latent variable $z$.
* They learn a probabilistic encoder $q_\phi(z \mid x)$ and decoder $p_\theta(x \mid z)$.
* They shape the latent space to follow a simple prior (usually $\mathcal{N}(0, I)$) so that sampling is well-behaved.

Result: a model that can:

* Learn structured latent representations
* Sample new data by drawing $z \sim p(z)$ and decoding
* Interpolate in latent space smoothly and meaningfully



## 2. The Two Fundamental Goals of VAEs

VAE has two fundamental goals:

1. A good generative model of data → large $p_\theta(x)$
2. The posterior over latents → $p_\theta(z \mid x)$

However, the real problem is that the posterior is intractable.
The true posterior is:

$$
p_\theta(z \mid x) = \frac{p_\theta(x,z)}{p_\theta(x)} = \frac{p_\theta(x \mid z)p(z)}{\int p_\theta(x \mid z)p(z)dz}
$$

The denominator $\int p_\theta(x \mid z)p(z) dz$ is hard (high-dimensional integral), so:

* We **can’t** compute $p_\theta(z \mid x)$
* We **also can’t** compute $\log p_\theta(x)$ exactly

Neither of the two goals are easily achievable. 
This is the fundamental pain.


## 3. The V in VAE - Variational Inference

Variational inference is a method used in Bayesian statistics to approximate a complex posterior distribution 
with a simpler, more tractable distribution. 
It works by turning the problem of approximating a probability distribution into an optimization problem, 
where the goal is to find the parameters of the simpler distribution that minimize the difference, 
or Kullback-Leibler (KL) divergence, between it and the true posterior. 

That is, variational inference says:

> Instead of using the true posterior $p_\theta(z \mid x)$, approximate it with a family $q_\phi(z \mid x)$ that is easy to work with (e.g. diagonal Gaussian).

We want:

$$
q_\phi(z \mid x) \approx p_\theta(z \mid x)
$$

So now we have **two sets of parameters**:

* $\theta$: generative model (decoder)
* $\phi$: variational / inference model (encoder)


### 3.1. Some Math Tricks

Start by writing the KL:

$$
D_{\mathrm{KL}}(q(z|x) \| p_\theta(z|x))
=
\mathbb{E}_{q(z|x)}\left[\log \frac{q(z|x)}{p_\theta(z|x)}\right].
$$

Expand $p_\theta(z \mid x)$ via Bayes’ rule:

$$
p_\theta(z \mid x) = \frac{p_\theta(x,z)}{p_\theta(x)}.
$$

Substitute:

$$
D_{\mathrm{KL}}
=
\mathbb{E}_{q(z|x)}\left[
\log q(z|x)
- \log p_\theta(x,z)
+ \log p_\theta(x)
\right].
$$

Distribute the expectation:

$$
D_{\mathrm{KL}} =
\mathbb{E}_{q(z|x)}[\log q(z|x)]
- \mathbb{E}_{q(z|x)}[\log p_\theta(x,z)]
+ \log p_\theta(x).
$$

Now rearrange to isolate $\log p_\theta(x)$:

$$
\log p_\theta(x)
=
\underbrace{
\mathbb{E}_{q(z|x)}[\log p_\theta(x,z)]
-
\mathbb{E}_{q(z|x)}[\log q(z|x)]
}_{\text{ELBO}(x)}
+
D_{\mathrm{KL}}(q(z|x) \| p_\theta(z|x)).
$$

For convienice we give the first two iterms on the right side a nick name ELBO and we have

$$
\log p_\theta(x)
=
\text{ELBO}(x)
+
D_{\mathrm{KL}}(q(z|x) \| p_\theta(z|x))
$$

KL divergence is always ≥ 0. Therefore:

$$
\text{ELBO}(x) \le \log p_\theta(x)
$$

Thus, the ELBO is a lower bound on the log evidence — hence the nick name Evidence Lower BOund (ELBO).

**Training a VAE means maximizing ELBO**, which simultaneously optimize the two goals of VAE:

  * maximizes a lower bound on log-likelihood
  * minimizes KL between approximate posterior and true posterior

This is variational inference, the heart of VAEs.
Everything else — Gaussian encoder, KL term, reparameterization — exists only to make this variational inference workable inside deep learning.

It may be more accurate to say the flow goes the other way:
VAEs gave Bayesian inference a killer implementation toolkit — deep neural networks, backpropagation, and GPUs.
With this combination, variational inference suddenly became scalable to millions of datapoints and high-dimensional continuous observations.
No wonder an enormous amount of modern generative modeling work builds on the VAE framework.


### 3.2. The Loss Function

Initially, I thought we directly maximize ELBO on these two fundamental goals:

$$
\text{ELBO}(x)
= 
\log p_\theta(x)
-
D_{\mathrm{KL}}(q(z|x) \| p_\theta(z|x))
$$

Quickly I realized both terms are not calculatable. Actually, in VAE we use the terms on the other side of the equation:

$$
\begin{aligned}
\text{ELBO}(x)
&=\mathbb{E}_{q_\phi(z|x)}\left[\log p_\theta(x,z) - \log q_\phi(z|x)\right] \\
&=\mathbb{E}_{q_\phi(z|x)}\left[\log p_\theta(x\mid z) + \log p(z) - \log q_\phi(z|x)\right] \\
&=\mathbb{E}_{q_\phi(z|x)}[\log p_\theta(x\mid z)]
+
\mathbb{E}_{q_\phi(z|x)}[\log p(z) - \log q_\phi(z|x)] \\
&=\mathbb{E}_{q_\phi(z|x)}[\log p_\theta(x\mid z)]
-
D_{\mathrm{KL}}\big(q_\phi(z|x)\| p(z)\big)
\end{aligned}
$$

The VAE loss for a single datapoint $x$ is just negative ELBO:

$$
\mathcal{L}(x) =
\underbrace{\mathbb{E}_{q_\phi(z \mid x)}[-\log p_\theta(x \mid z)]}_{\text{Reconstruction loss}}
+
\underbrace{D_{\mathrm{KL}}(q_\phi(z \mid x) \| p(z))}_{\text{KL regularizer}}
$$


#### 3.2.1. Reconstruction Term

* Encourages the decoder to reconstruct $x$ well from latent $z$.
* If $p_\theta(x \mid z)$ is Gaussian with fixed variance, this term reduces to something proportional to mean squared error between $x$ and $\hat{x}$.
* If $p_\theta(x \mid z)$ is Bernoulli, it becomes binary cross-entropy.


#### 3.2.2. KL Term

* Measures how far the encoder’s distribution over $z$ deviates from the prior.
* Encourages latent codes to stay close to the prior $p(z)$, e.g., $ \mathcal{N}(0, I)$.

Intuitions:

* Regularizer: prevents overfitting, keeps $\mu,\sigma$ bounded.
* Latent space shaping: ensures smooth, filled-in latent space.
* Information bottleneck: acts like a “rate” term; higher KL means more bits used to encode $x$.

For Gaussian $q$ and Gaussian prior $p$, the KL has a closed-form expression (a.k.a analytical solution for physicists), which makes training efficient.

Lets dive a bit further on this point. For two multivariate Gaussians:

$$
q(z) = \mathcal{N}(\mu_q, \Sigma_q), \quad
p(z) = \mathcal{N}(\mu_p, \Sigma_p)
$$

the KL divergence has a known closed form:

$$
D_{\mathrm{KL}}(q | p)
=

\frac{1}{2}
\Big(
\mathrm{tr}(\Sigma_p^{-1} \Sigma_q)
+
(\mu_p - \mu_q)^\top \Sigma_p^{-1} (\mu_p - \mu_q)
* k
- \log \frac{\det \Sigma_p}{\det \Sigma_q}
  \Big)
$$

where $k$ is the dimension of $z$.

Now plug in the VAE choices:

* $p(z) = \mathcal{N}(0, I)$ → $\mu_p = 0$, $\Sigma_p = I$
* $q(z \mid x) = \mathcal{N}(\mu_\phi(x), \mathrm{diag}(\sigma_\phi^2(x)))$

Then the formula simplifies dramatically to:

$$
D_{\mathrm{KL}}(q_\phi(z \mid x) \| p(z))
=
\frac{1}{2} \sum_{j=1}^k
\big(
\sigma_j^2 + \mu_j^2 - 1 - \log \sigma_j^2
\big)
$$

where $\mu_j$ and $\sigma_j$ are the components of $\mu_\phi(x)$ and $\sigma_\phi(x)$.

That’s it. No integrals, no sampling, no Monte Carlo.


#### 3.3. Comparison to my IPU model

In my [IPU model](https://arxiv.org/html/2210.13004v3/), there are also two goals.
The first goal — modeling $p(x)$ — is shared with VAEs.

The second goal of my model is the maximization of mutual information between input and output.
In a VAE, the reconstruction term is related to this idea, but only as a proxy: it encourages z to carry information about x, without directly maximizing mutual information.
The KL term in a VAE, however, actually pushes in the opposite direction. When averaged over the data, it includes a mutual information term and penalizes it, effectively acting as an information bottleneck that tends to *reduce* the information z carries about x.

So while VAEs feel conceptually related to my bio-inspired, ab initio IPU model, their optimization objective is fundamentally different: VAEs trade off likelihood and compression, whereas the IPU model explicitly maximizes mutual information between input and output. 

The IPU model also compresses data, often quite drastically in practice. 
However, there is a subtle but important difference: in the IPU model, compression is not an explicit optimization goal but rather a model/hardware constraint, which more closely resembles the situation in biology. 
In that sense, VAEs seem to be aiming for something similar to what the IPU model achieves, but they get there via a very different—and in some ways less direct—objective.



## 4. How a VAE Works (High-Level)

At a high level, a VAE has three main components.

### 4.1. Encoder (Inference Network)

Given input $x$, the encoder outputs the parameters of a distribution $\mu$ and $\sigma$ over latent variables:

$$
q_\phi(z \mid x) = \mathcal{N}(\mu_\phi(x), \text{diag}(\sigma_\phi^2(x)))
$$

So instead of a single latent point, the model produces a Gaussian distribution in latent space.

As we just discussed, the KL term in the loss function can be directly calculated from the output of the encoder.


### 4.2. Reparameterized Sampling

To calculate the reconstruction term of the loss function we need to sample $z$ from $q_\phi(z \mid x)$, but we also need gradients.
Direct sampling $z \sim \mathcal{N}(\mu, \sigma^2)$ blocks backprop.

So we use the reparameterization trick:

$$
\epsilon \sim \mathcal{N}(0, I), \quad z = \mu_\phi(x) + \sigma_\phi(x) \odot \epsilon
$$

Now:

* The randomness is in $\epsilon$,
* The path from $x$ → $\mu,\sigma$ → $z$ is differentiable.

### 4.3. Decoder (Generative Network)

The decoder defines a conditional distribution over $x$ given $z$:

$$
p_\theta(x \mid z)
$$

In practice:

* For continuous data: Gaussian likelihood (decoder outputs mean, maybe variance).
* For binary data: Bernoulli likelihood (decoder outputs probabilities).

The decoder tries to reconstruct $x$ from sampled $z$.


## 5. What Are the Assumptions of VAE?

VAEs make quite a few assumptions (which make me suspicious about its usefulness when applying to practical problems). 
Roughly, they fall into a few categories.

### 5.1 Generative Model Assumptions

1. **Latent variable model**

   $$
   p_\theta(x, z) = p(z) p_\theta(x \mid z)
   $$

   Data is generated by first sampling $z$, then sampling $x$ given $z$.
   This is a fundamental assumption [many probablistic models use]({% post_url 2025-11-19-A Cleaner Way to Categorize Probabilistic Models %}).
   For image or video data x one might hope that the latent variable z corresponds to objects in the scene. 
   Unfortunately, in a standard VAE this is not the case. 
   As a result, this assumption feels poorly grounded for complex visual data.

2. **i.i.d. data**
 
   The dataset ${x^{(i)}}$ is assumed independent and identically distributed:

   $$
   p(\mathcal{D}) = \prod_i p_\theta(x^{(i)})
   $$

   This lets us write the total loss as a sum over datapoints and use minibatches.

3. **Simple prior over $z$**
   
   Usually:
   
   $$
   p(z) = \mathcal{N}(0, I)
   $$

   That is independent latent dimensions, zero-mean, unit variance, unimodal.

### 5.2. Likelihood (Decoder) Assumptions

4. **Choice of likelihood family** $p_\theta(x \mid z)$

   Examples:

   * Gaussian (continuous data)
   * Bernoulli (binary pixels)
   * Categorical (discrete tokens)

5. **Conditional independence / factorization**
   
   Often:
   
   $$
   p_\theta(x \mid z) = \prod_i p_\theta(x_i \mid z)
   $$

   meaning given $z$, individual components of $x$ are independent.


### 5.3. Inference (Encoder) Assumptions

7. **Variational approximation**
   
    We approximate the true posterior $p_\theta(z \mid x)$
    with a simpler family $q_\phi(z \mid x)$.

1. **Gaussian approximate posterior**
    
   $$
   q_\phi(z \mid x) = \mathcal{N}(\mu_\phi(x), \text{diag}(\sigma_\phi^2(x)))
   $$

2.  **Mean-field assumption**
    
    Components of $z$ are independent given $x$.

3.  **Amortized inference**
    
    One shared encoder network $q_\phi(z \mid x)$ works for all datapoints, rather than optimizing a separate variational distribution per sample.

4.  **Reparameterizable distributions**
    
    $q_\phi(z \mid x)$ must allow the reparameterization trick (e.g., Gaussians, some others).

### 5.4. Optimization Assumptions

12. **ELBO as surrogate objective**
    We can’t maximize $\log p_\theta(x)$ directly, so we maximize the Evidence Lower BOund (ELBO), which is a lower bound on it.

13. **Monte Carlo estimation**
    Expectations over $q(z \mid x)$ (e.g., the reconstruction term) are approximated using a small number of samples (often just 1 per datapoint per step).



## 6. Conclusion

Variational Autoencoders really are a bit of a Frankenstein:

* They combine autoencoders, Bayesian latent variable models, variational inference, information theory, and deep learning engineering tricks.
* They rely on a stack of assumptions: i.i.d. data, simple prior, Gaussian posteriors, specific likelihoods, mean-field factorization, and ELBO optimization.
* They introduce extra machinery like the KL divergence term and the reparameterization trick just to make the whole system trainable end-to-end.

But despite the scars and bolts, they were one of the first serious steps toward modern generative AI.

* VAEs were one of the first scalable deep generative models.
* They made latent variable modeling practical for high-dimensional data (images, etc.).
* They inspired a whole ecosystem: β-VAE, VQ-VAE, hierarchical VAEs, flow-based VAEs, diffusion models, and more.

Even though I think VAEs are not the final answer, they are nevertheless an important milestone, and I fully enjoyed learning about them.
