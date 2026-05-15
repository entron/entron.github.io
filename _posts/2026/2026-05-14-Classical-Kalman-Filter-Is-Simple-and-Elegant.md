---
title: "Classical Kalman Filter Is Simple and Elegant"
date: 2026-05-14 12:00:00 +0000
layout: post
categories: [AI]
tags: [Kalman Filter]
math: true
mermaid: false
---

Kalman filtering often looks intimidating at first. Many introductions start with matrix equations, state-space models, Gaussian distributions, and recursive Bayesian estimation. All of that is correct, but it can hide a very simple idea:

A Kalman filter is a principled way to combine uncertain information.

I am writing this to help myself, and hopefully my dear reader, quickly grasp the core idea of the Kalman filter.


---

## 1. One Sensor

Suppose we want to estimate a quantity $x$. For example, $x$ could be the position of a car along a straight road.

A sensor gives us a measurement $z$. $z$ is influenced by both $x$ and measurement noise $v$.
In the simpliest case we have:

$$
\begin{equation}
z = x + v
\label{eq:one-sensor-measurement}
\end{equation}
$$


If the noise is [Gaussian](https://en.wikipedia.org/wiki/Normal_distribution) which has zero mean and variance $R$, we can write:

$$
\begin{equation}
v \sim \mathcal{N}(0, R)
\label{eq:one-sensor-noise}
\end{equation}
$$

This means the sensor is not perfect, but we know how uncertain it is. A small $R$ means the sensor is accurate. A large $R$ means the sensor is noisy.

If this is the only information we have, the best estimate is simply the sensor reading:

$$
\begin{equation}
\hat{x} = z
\label{eq:one-sensor-estimate}
\end{equation}
$$

The uncertainty of this estimate is just the sensor variance:

$$
\begin{equation}
P = R
\label{eq:one-sensor-variance}
\end{equation}
$$

This is the simplest possible estimation problem. One sensor gives one estimate, and the uncertainty of the estimate is the uncertainty of the sensor.

But things become more interesting when we have more than one source of information.

## 2. Two Sensors: The Wisdom of the Crowd

What if we are not satisfied with the sensor's accuracy and we want a better estimate of $x$? One straightforward way is to measure multiple times if $x$ is fixed and then average the measurements.
In practice, this is seldom the case. Instead, $x$ is changing all the time and we want to have an accurate measurement at every time point. What we can do is add more sensors and measure simultaneously, then average them. We use the wisdom of the crowd to get a better estimation.

Now suppose we have two sensors measuring the same quantity $x$:

$$
\begin{equation}
z_1 = x + v_1
\label{eq:two-sensor-measurement-1}
\end{equation}
$$

$$
\begin{equation}
z_2 = x + v_2
\label{eq:two-sensor-measurement-2}
\end{equation}
$$

The two sensors have different noise variances:

$$
\begin{equation}
v_1 \sim \mathcal{N}(0, R_1)
\label{eq:two-sensor-noise-1}
\end{equation}
$$

$$
\begin{equation}
v_2 \sim \mathcal{N}(0, R_2)
\label{eq:two-sensor-noise-2}
\end{equation}
$$

Sensor 1 may be more accurate than sensor 2, or vice versa. 

One can of course keep only the better sensor, but that discards a source of information that should, intuitively, add value if kept. Then the question is: how should we combine them?


A naive approach would be to average them:

$$
\begin{equation}
\hat{x} = \frac{z_1 + z_2}{2}
\label{eq:two-sensor-naive-average}
\end{equation}
$$

But this ignores the fact that one sensor may be more reliable than the other. If sensor 1 is much more accurate, it should receive more weight. If sensor 2 is very noisy, it should receive less weight.

The optimal fused estimate is a weighted average:

$$
\begin{equation}
\hat{x} = \frac{\frac{1}{R_1}z_1 + \frac{1}{R_2}z_2}{\frac{1}{R_1} + \frac{1}{R_2}}
\label{eq:two-sensor-optimal-fusion}
\end{equation}
$$

The weights are proportional to the inverse variances. This is intuitive:
the smaller the variance, the larger the weight.

A precise sensor should be trusted more. A noisy sensor should be trusted less.

The variance of the fused estimate is:

$$
\begin{equation}
P = \frac{1}{\frac{1}{R_1} + \frac{1}{R_2}} = \frac{R_1 R_2}{R_1 + R_2}
\label{eq:two-sensor-fused-variance}
\end{equation}
$$

This variance is smaller than either $R_1$ or $R_2$, assuming the two sensor noises are independent. That is a beautiful result:
two uncertain measurements can be combined into an estimate that is more accurate than either measurement alone. This is already the essence of sensor fusion.


## 3. Two Sensors: The Math

Now I will show how to derive the last two equations in the previous section. You can skip this section if you do not care about the proof.

Assume the fused estimate is a weighted average:

$$
\begin{equation}
\hat{x} = w z_1 + (1-w) z_2,
\label{eq:two-sensor-weighted-average}
\end{equation}
$$

and we want to find the best $w$.

Combine Eq. \eqref{eq:two-sensor-weighted-average} with Eq. \eqref{eq:two-sensor-measurement-1} and \eqref{eq:two-sensor-measurement-2}:

$$
\begin{equation}
\hat{x} - x = w v_1 + (1-w) v_2
\label{eq:two-sensor-estimation-error}
\end{equation}
$$

Assume the two sensor noises are independent. Then the variance is (see the appendix, especially \eqref{eq:variance-linear-combination-independent}):

$$
\begin{equation}
P(w) = \mathrm{Var}(\hat{x} - x) = w^2 R_1 + (1-w)^2 R_2
\label{eq:two-sensor-variance-as-function-of-w}
\end{equation}
$$

Minimize this with respect to $w$:

$$
\begin{equation}
\frac{dP}{dw} = 2wR_1 - 2(1-w)R_2 = 0
\label{eq:two-sensor-optimality-condition}
\end{equation}
$$

So:

$$
\begin{equation}
w = \frac{R_2}{R_1 + R_2}
\label{eq:two-sensor-optimal-weight}
\end{equation}
$$

Substituting into $P(w)$, we get:


$$
\begin{equation}
P = \frac{R_1 R_2}{R_1 + R_2}
\label{eq:two-sensor-product-over-sum}
\end{equation}
$$

Eq. \eqref{eq:two-sensor-optimal-weight} gives the optimal weight for fusing the two sensors, so that the variance of the fused estimate reaches the minimum value in Eq. \eqref{eq:two-sensor-product-over-sum}.



## 4. One Sensor and One Virtual Sensor: The Kalman Filter

Most of the time, the system we are dealing with is not completely random.
The value at time step $k-1$, namely $x_{k-1}$, or even earlier steps, often tells us something about the range of $x_k$.
Therefore, it is a waste to ignore this historical information.
What the Kalman filter effectively does is recycle the previous information and transform it into a virtual sensor without adding a real second sensor. The virtual sensor's "reading" is a dynamic model prediction based on past information.


Imagine we are tracking the position of a car over time. At time $k-1$, we already have an estimate of the car's state. For simplicity, assume the state is just position:

$$
\begin{equation}
\hat{x}_{k-1|k-1}
\label{eq:prior-estimate}
\end{equation}
$$

The notation means: our estimate of $x$ at time $k-1$, after using all measurements up to time $k-1$.

This estimate has uncertainty:

$$
\begin{equation}
P_{k-1|k-1}
 =
\mathrm{Var}(x_{k-1}-\hat{x}_{k-1|k-1})
\label{eq:prior-estimate-uncertainty}
\end{equation}
$$

Now time moves forward. We want to estimate the current state $x_k$. If we have a dynamic model, we can predict the current state from the previous one. In the simplest case, the current state is just a linear transformation of the previous state:

$$
\begin{equation}
x_k = a x_{k-1} + w_k
\label{eq:scalar-dynamics}
\end{equation}
$$

where $w_k$ is the process noise, with

$$
\begin{equation}
\mathrm{Var}(w_k)=Q
\label{eq:process-noise}
\end{equation}
$$

We have the uncertainty of the previous estimate, and we have the uncertainty introduced by the prediction model. How can we combine them to get the variance of the virtual sensor, that is, the variance of the predicted state $P_{k|k-1}$?
Let's find this out next.

At time $k-1$, we do not know the true $x_{k-1}$. We only have an estimate:

$$
\begin{equation}
\hat{x}_{k-1|k-1}
\label{eq:prior-estimate-repeat}
\end{equation}
$$


Now we predict the next state using the model:

$$
\begin{equation}
\hat{x}_{k|k-1} = a \hat{x}_{k-1|k-1}
\label{eq:scalar-prediction}
\end{equation}
$$

The prediction error is:

$$
\begin{equation}
x_k-\hat{x}_{k|k-1}
\label{eq:scalar-prediction-error}
\end{equation}
$$

Substitute the true dynamics and the predicted estimate:

$$
\begin{equation}
x_k-\hat{x}_{k|k-1}
=
(a x_{k-1}+w_k)-a\hat{x}_{k-1|k-1}
\label{eq:scalar-prediction-error-substituted}
\end{equation}
$$

Factor out $a$:

$$
\begin{equation}
x_k-\hat{x}_{k|k-1}
=
a(x_{k-1}-\hat{x}_{k-1|k-1})+w_k
\label{eq:scalar-prediction-error-factored}
\end{equation}
$$

Now take the variance on both sides:

$$
\begin{equation}
P_{k|k-1}
=
\mathrm{Var}\left(a(x_{k-1}-\hat{x}_{k-1|k-1})+w_k\right)
\label{eq:scalar-prediction-variance-before-rule}
\end{equation}
$$

Using the variance rule we derived in the Appendix:

$$
\begin{equation}
\mathrm{Var}(aX+Y)
=
a^2\mathrm{Var}(X)+\mathrm{Var}(Y)+2a\,\mathrm{Cov}(X,Y)
\label{eq:variance-rule-two-variables}
\end{equation}
$$

Here:

$$
\begin{equation}
X=x_{k-1}-\hat{x}_{k-1|k-1}
\label{eq:variance-rule-x}
\end{equation}
$$

and

$$
\begin{equation}
Y=w_k
\label{eq:variance-rule-y}
\end{equation}
$$

So we have:

$$
\begin{equation}
P_{k|k-1} = a^2P_{k-1|k-1} + Q + 2a\,\mathrm{Cov}(x_{k-1}-\hat{x}_{k-1|k-1}, w_k)
\label{eq:scalar-prediction-variance-with-covariance}
\end{equation}
$$

The standard Kalman filter assumes the process noise $w_k$ is independent of the previous estimation error, so the covariance term is zero. Therefore:

$$
\begin{equation}
P_{k|k-1} = a^2 P_{k-1|k-1} + Q
\label{eq:scalar-prediction-variance}
\end{equation}
$$

So the meaning is:

$$
\begin{equation}
\boxed{\text{prediction uncertainty} = \text{propagated previous uncertainty} + \text{new model uncertainty}}
\label{eq:prediction-uncertainty-meaning}
\end{equation}
$$

The $a^2P_{k-1|k-1}$ part comes from uncertainty already present at time $k-1$.
The $Q$ part comes from the new uncertainty introduced by the imperfect dynamic model during the transition from time $k-1$ to time $k$.


We combine the real sensor and the virtual sensor using uncertainty-weighted fusion exactly like the two-sensor problem:

$$
\begin{equation}
\hat{x}_{k|k} = \frac{\frac{1}{P_{k|k-1}}\hat{x}_{k|k-1} + \frac{1}{R}z_k}{\frac{1}{P_{k|k-1}} + \frac{1}{R}}
\label{eq:scalar-kalman-fusion}
\end{equation}
$$

The updated uncertainty is:

$$
\begin{equation}
P_{k|k} = \frac{1}{\frac{1}{P_{k|k-1}} + \frac{1}{R}}
\label{eq:scalar-kalman-updated-variance}
\end{equation}
$$
This finishes one time-step update of the Kalman filter, and we can move on to the next time step and repeat the same procedure iteratively.


So the Kalman filter is doing something extremely natural: It fuses the current real measurement with a prediction generated from historical information and a dynamic model.

The dynamic model allows information from the past to remain useful in the present. Without the model, the previous estimate would simply be an estimate of the past. With the model, it becomes a prediction of the present.


---

## 5. Kalman gain and innovation/residual

We have already learned the essence of the Kalman filter. However, I cannot stop here because there are still a few more important points to cover before we can say we have really understood the Kalman filter. Let us first start with the terminology.

The **Kalman gain** $K_k$ is standard terminology in the Kalman filter. It is simply a convenient reparameterization of the scalar fusion equation in \eqref{eq:scalar-kalman-fusion}.
Starting from the fused estimate, we can rewrite it as:

$$
\begin{equation}
\hat{x}_{k|k} = (1-K_k)\hat{x}_{k|k-1} + K_k z_k
\label{eq:scalar-kalman-update-weighted}
\end{equation}
$$

where the Kalman gain is:

$$
\begin{equation}
K_k = \frac{P_{k|k-1}}{P_{k|k-1} + R}
\label{eq:scalar-kalman-gain}
\end{equation}
$$

So $K_k$ is simply the weight assigned to the measurement, while $1-K_k$ is the weight assigned to the prediction.

Rearranging gives the standard update equation:

$$
\begin{equation}
\hat{x}_{k|k} = \hat{x}_{k|k-1} + K_k(z_k - \hat{x}_{k|k-1})
\label{eq:scalar-kalman-update}
\end{equation}
$$

The term:

$$
\begin{equation}
z_k - \hat{x}_{k|k-1}
\label{eq:innovation}
\end{equation}
$$

is called the **innovation** or **residual**, often denoted as $\nu_k$. It is the difference between what the sensor says and what the model predicted.

---

## 6. From Scalar to Vector Form

Real systems usually have more than one state variable. For example, a car's state may include position and velocity:

$$
\begin{equation}
x_k =
\begin{bmatrix}
\text{position} \\
\text{velocity}
\end{bmatrix}
\label{eq:state-vector-example}
\end{equation}
$$

The dynamic model is still linear and it becomes:

$$
\begin{equation}
x_k = F_k x_{k-1} + w_k
\label{eq:vector-dynamics}
\end{equation}
$$

The prediction step is:

$$
\begin{equation}
\hat{x}_{k|k-1} = F_k \hat{x}_{k-1|k-1}
\label{eq:vector-prediction}
\end{equation}
$$

In this case Eq. \eqref{eq:scalar-prediction-variance} becomes

$$
\begin{equation}
P_{k|k-1} = F_k P_{k-1|k-1} F_k^T + Q_k
\label{eq:vector-prediction-covariance}
\end{equation}
$$

To be more general, the classical Kalman filter assumes that the measurement is also a linear transformation of the state:

$$
\begin{equation}
z_k = H_k x_k + v_k
\label{eq:vector-measurement-model}
\end{equation}
$$

The case we assumed above, where the measurement is the state itself, is just a special case with $H_k = I$.

The update step follows the same pattern as in the scalar case.
Eq. \eqref{eq:scalar-kalman-gain} becomes:

$$
\begin{equation}
K_k = \frac{P_{k|k-1} H_k^T}{H_k P_{k|k-1} H_k^T + R_k}
\label{eq:vector-kalman-gain}
\end{equation}
$$

Eq. \eqref{eq:scalar-kalman-update} becomes:

$$
\begin{equation}
\hat{x}_{k|k} = \hat{x}_{k|k-1} + K_k(z_k - H_k \hat{x}_{k|k-1})
\label{eq:vector-kalman-update}
\end{equation}
$$

Eq. \eqref{eq:scalar-kalman-updated-variance} becomes:

$$
\begin{equation}
P_{k|k} = (I - K_k H_k) P_{k|k-1}
\label{eq:vector-kalman-covariance-update}
\end{equation}
$$

These equations look more complex, but the idea has not changed.
The covariance matrices replace scalar variances, and matrices such as $F_k$ and $H_k$ describe how states evolve and how sensors observe the state.

---

## 7. Conclusion

The classical Kalman filter is simple and elegant because it is built from one basic idea: combine uncertain information according to uncertainty. This is the heart of the Kalman filter:

$$
\begin{equation}
\text{previous estimate} + \text{model} \rightarrow \text{prediction}
\label{eq:history-model-to-prediction}
\end{equation}
$$

$$
\begin{equation}
\text{prediction} + \text{measurement} \rightarrow \text{updated estimate}
\label{eq:prediction-measurement-to-update}
\end{equation}
$$

Of course, the classical Kalman filter has limitations. It assumes linear dynamics, linear measurements, and Gaussian noise. In practice, these assumptions are often only approximately true. When the system is nonlinear, people often use extensions such as the Extended Kalman Filter (EKF) or the Unscented Kalman Filter (UKF). When the noise is strongly non-Gaussian or the posterior is far from Gaussian, particle filters and other Bayesian filtering methods may be more appropriate.

---

## Appendix: Variance of a Linear Combination

In deriving \eqref{eq:two-sensor-variance-as-function-of-w}, we implicitly used a standard relation for the variance of a linear combination of random variables. Here is the proof.

It comes directly from the definition of variance.

For any random variable $Y$:

$$
\begin{equation}
\mathrm{Var}(Y)=\mathbb{E}\left[(Y-\mathbb{E}[Y])^2\right]
\label{eq:variance-definition}
\end{equation}
$$

Let:

$$
\begin{equation}
Y = aX + bZ
\label{eq:linear-combination-y}
\end{equation}
$$

Then:

$$
\begin{equation}
\mathbb{E}[Y]=a\mathbb{E}[X]+b\mathbb{E}[Z]
\label{eq:linear-combination-mean}
\end{equation}
$$

So:

$$
\begin{equation}
Y-\mathbb{E}[Y]
=
a(X-\mathbb{E}[X]) + b(Z-\mathbb{E}[Z])
\label{eq:centered-linear-combination}
\end{equation}
$$

Now square it:

$$
\begin{equation}
\mathrm{Var}(Y)
=
\mathbb{E}\left[
\left(
a(X-\mathbb{E}[X]) + b(Z-\mathbb{E}[Z])
\right)^2
\right]
\label{eq:variance-before-expansion}
\end{equation}
$$

Expand:

$$
\begin{equation}
\begin{aligned}
\mathrm{Var}(Y)
=\;&
a^2\mathbb{E}[(X-\mathbb{E}[X])^2] \\
&+
b^2\mathbb{E}[(Z-\mathbb{E}[Z])^2] \\
&+
2ab\mathbb{E}[(X-\mathbb{E}[X])(Z-\mathbb{E}[Z])]
\end{aligned}
\label{eq:variance-expanded}
\end{equation}
$$

Recognize the terms:

$$
\begin{equation}
\mathbb{E}[(X-\mathbb{E}[X])^2]=\mathrm{Var}(X)
\label{eq:variance-x}
\end{equation}
$$

$$
\begin{equation}
\mathbb{E}[(Z-\mathbb{E}[Z])^2]=\mathrm{Var}(Z)
\label{eq:variance-z}
\end{equation}
$$

$$
\begin{equation}
\mathbb{E}[(X-\mathbb{E}[X])(Z-\mathbb{E}[Z])]=\mathrm{Cov}(X,Z)
\label{eq:covariance-xz}
\end{equation}
$$

Therefore:

$$
\begin{equation}
\mathrm{Var}(aX+bZ)
=
a^2\mathrm{Var}(X)
+
b^2\mathrm{Var}(Z)
+
2ab\mathrm{Cov}(X,Z)
\label{eq:variance-linear-combination-general}
\end{equation}
$$

If $X$ and $Z$ are independent, then:

$$
\begin{equation}
\mathrm{Cov}(X,Z)=0
\label{eq:independent-zero-covariance}
\end{equation}
$$

so:

$$
\begin{equation}
\mathrm{Var}(aX+bZ)
=
a^2\mathrm{Var}(X)
+
b^2\mathrm{Var}(Z)
\label{eq:variance-linear-combination-independent}
\end{equation}
$$

For the sensor case:

$$
\begin{equation}
X=v_1,\qquad Z=v_2,\qquad a=w,\qquad b=1-w
\label{eq:sensor-case-substitution}
\end{equation}
$$

so:

$$
\begin{equation}
\mathrm{Var}(wv_1+(1-w)v_2)
=
w^2R_1+(1-w)^2R_2
\label{eq:sensor-case-variance}
\end{equation}
$$
