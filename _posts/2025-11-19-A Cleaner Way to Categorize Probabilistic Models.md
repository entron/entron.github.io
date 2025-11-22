---
title: "A Cleaner Way to Categorize Probabilistic Models"
categories: [AI]
tags: [Probabilistic Modeling]     # TAG names should always be lowercase
math: true
mermaid: false
---


The classic split between *generative* and *discriminative* models was introduced for supervised learning: compare Naïve Bayes (model $p(x, y)$) with Logistic Regression (model $p(y\mid x)$).

In contemporary ML, the term “generative” is used loosely to refer to any model that is not discriminative, regardless of whether it actually specifies a probability distribution, a latent generative story, or even a sampling mechanism. The result is a terminology that is historically overloaded, pedagogically misleading, and conceptually inaccurate.
The field needs a cleaner taxonomy—one that matches what probabilistic models actually do, rather than relying on outdated terminology.
Here we propose such a framework.




## 1. Primary axis: **Distribution modeling vs. Conditional modeling**

The first, clean question is:

> **What probability does the model aim to capture?**

We propose to replace “generative vs. discriminative” with Distribution modeling and Conditional modeling.

### Distribution Modeling

The model’s primary target is the **data distribution** $p(x)$.
Examples include:

* latent-variable generative models (GMM, HMM, ICA, VAE, RBM, diffusion-as-generative-chain)
* normalizing flows
* autoregressive models
* EBMs
* score models
* efficient-coding / equal-mass partition models
* Bayesian networks modeling only $p(x)$
* Markov chains defining a stationary distribution

### Conditional Modeling

The model’s target is a **conditional distribution** $p(y\mid x)$.
Examples:

* logistic regression
* CRFs / HCRFs
* Bayesian logistic regression

This axis is minimal, clean, and matches probability theory:

* “Distribution” = model $p(x)$
* “Conditional” = model $p(y\mid x)$

No extra philosophical baggage.



## 2. Second axis: **Latent vs. non-latent**

Next, we ask:

> **Does the model explicitly introduce latent variables $z$ as part of its probabilistic story?**

* **Latent = Yes**
  The model introduces hidden variables (sources, codes, states, classes, etc.) with a distribution $p(z)$ and some relationship to $x$.

* **Latent = No**
  The model operates directly on $x$: it may factorize $p(x)$, define a flow, an energy, a score, a Markov chain over $x$, or an equal-mass partition—without any explicit latent $z$.

For **distribution models**:

* Latent + distribution ⇒ **latent-variable generative models** in the classical statistical sense:
  they specify a joint $p(x,z) = p(z)p(x\mid z)$ and a sampling story.

* Non-latent + distribution ⇒ **non-latent distributional models**:
  they define or approximate aspects of $p(x)$ without introducing explicit latents.

For **conditional models**:

* Latent or non-latent just tells you whether you use hidden variables in $p(y\mid x, z)$ etc.



## 3. Third axis: **Density form**

For distribution models, how is $p(x)$ represented?

* **Exact density**
  $\log p_\theta(x)$ is tractable.
  e.g., flows, autoregressive models, many GMMs, some Bayesian networks.

* **Approximate density**
  Optimized via a bound (e.g. ELBO).
  e.g., VAEs, DDPM-style diffusion models.

* **Unnormalized density**
  Only energy $E(x)$; $p(x) \propto e^{-E(x)}$ with unknown partition function.
  e.g., EBMs, RBMs.

* **Implicit density**
  Defined only via a sampler or transformation; no closed-form $p(x)$.
  e.g., GANs, some Markov chains, pure score models (where you know only $\nabla\log p)$.



## 4. Fourth axis: **Sampling route**

For distribution models, how do we sample from the learned distribution?

* **Direct / ancestral**
  One pass through a generative story or invertible map.
  e.g., GMM, naive Bayes, ICA, sparse coding, Bayesian networks, flows.

* **Iterative / Markovian**
  Sampling requires a chain: MCMC, Gibbs, Langevin, reverse diffusion, autoregressive token-by-token.
  e.g., RBM, EBMs, score-based SDEs, DDPM, Markov chains, autoregressive models.

* **No sampling defined**
  The model’s goal is to capture structure in $p(x)$ without providing a generative sampler.



## 5. A unified table of probabilistic models

* Axis 1: **Target** (Distribution vs. Conditional)
* Axis 2: **Latent?** (Yes / No)
* Axis 3: **Density type**
* Axis 4: **Sampling**
* Axis 5: **Inference / training** 
* Axis 6: **Primary Use / Function**

The last two columns corresponde to Shu and Yong in [another post]({% post_url 2025-11-11-A Ti–Yong–Shu Map of Probabilistic Modeling %}). 

### **Table: Categorizing Probabilistic Models**

| Model                               | Target (Dist./Cond.) | Latent?                           | Density type                        | Sampling                      | Inference / Training                | Primary Use / Function                                    |
| ----------------------------------- | -------------------- | --------------------------------- | ----------------------------------- | ----------------------------- | ----------------------------------- | --------------------------------------------------------- |
| **GMM**                             | Dist.                | Yes                               | Exact                               | Direct (ancestral)            | EM / MLE                            | Clustering, density modeling, mixture discovery           |
| **Naive Bayes**                     | Cond. (or Dist.)     | Yes (class as latent or observed) | Exact                               | Direct                        | MLE                                 | Fast classification, interpretable generative classifier  |
| **Bayesian network**                | Dist. or Cond.       | Yes (if hidden nodes)             | Exact (if structured)               | Direct                        | MLE / EM / VI                       | Structured reasoning, causal inference, joint modeling    |
| **Markov chain (stationary dist.)** | Dist.                | No                                | Implicit                            | Iterative (chain)             | Transition estimation / MLE         | Modeling long-run distributions, stochastic processes     |
| **HMM / SSM**                       | Dist.                | Yes                               | Exact (marginalizable)              | Direct (ancestral)            | EM / VI                             | Sequence modeling, state discovery, temporal inference    |
| **RBM**                             | Dist.                | Yes                               | Unnormalized joint                  | Iterative (Gibbs / CD)        | Contrastive divergence / ML         | Feature learning, generative structure discovery          |
| **VAE**                             | Dist.                | Yes                               | Approx. (ELBO)                      | Direct (ancestral from prior) | Variational inference               | Representation learning, generative modeling              |
| **Diffusion models (DDPM-style)**   | Dist.                | Yes (multi-step noise latents)    | Approx. (ELBO-like)                 | Iterative (reverse diffusion) | Variational / score-style           | High-quality sample generation, image/audio synthesis     |
| **Score-based SDE models**          | Dist.                | No                                | Implicit (score only)               | Iterative (reverse SDE/ODE)   | Score matching                      | Generative modeling via learned score function            |
| **Normalizing flows**               | Dist.                | No                                | Exact                               | Direct (invertible map)       | MLE                                 | Exact likelihood modeling, invertible generative mapping  |
| **Autoregressive models**           | Dist.                | No                                | Exact                               | Iterative (sequential)        | MLE                                 | High-quality sequence generation, density modeling        |
| **EBM (visible only)**              | Dist.                | No (or latents if extended)       | Unnormalized                        | Iterative (MCMC) or none      | Contrastive / ML                    | Energy-based representation learning, structure discovery |
| **GAN**                             | Dist.                | Yes (noise input)                 | Implicit                            | Direct (generator forward)    | Adversarial (min–max)               | Fast generation, realistic sample synthesis               |
| **ICA**                             | Dist.                | Yes                               | Exact (often)                       | Direct (sample sources, mix)  | MLE / InfoMax                       | Source separation, latent-factor discovery                |
| **Sparse coding**                   | Dist.                | Yes                               | Approx. (often MAP-based)           | Direct (sample sparse codes)  | Recon + sparsity, sometimes VI      | Sparse representation learning, dictionary learning       |
| **PPCA / Factor analysis**          | Dist.                | Yes                               | Exact                               | Direct                        | EM                                  | Dimensionality reduction, latent-factor discovery         |
| **Even code IPU model**             | Dist.                | No                                | Implicit (equal-mass partition)     | None                          | Information-theoretic               | Representation learning                                   |
| **Logistic regression**             | Cond.                | No                                | Exact                               | N/A                           | CE / MLE                            | Predictive classification, discriminative modeling        |
| **Bayesian logistic regression**    | Cond.                | Yes (global parameter posterior)  | Posterior over parameters           | N/A                           | VI / MCMC                           | Parameter inference, uncertainty quantification           |
| **CRF / HCRF**                      | Cond.                | Yes (structured latents)          | Exact / structured cond. likelihood | N/A                           | Conditional likelihood / max-margin | Structured prediction (e.g., sequences, segmentation)     |
