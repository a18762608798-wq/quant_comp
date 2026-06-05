# classical error

## fundation

<span style="color:blue">classical error is std, proof as follow:</span>

$$
error = \sqrt{E[(\widetilde \theta - \theta)^2]}
$$

Where $\hat \theta$ is estimate value, $E$ is to calculate the expectation.

**If $\hat \theta$ is unbiased**, Viz., $E(\widetilde \theta) = \theta$ <!--just the definition of std-->

$$
error = std(\widetilde \theta)
$$

In this paper, > ([[2023_Elben-Zoller_Randomized-measurement_Nat.Rev.Phys.pdf#page=3&annotation=2140R|2023_Elben-Zoller_Randomized-measurement_Nat.Rev.Phys, p.3]])

## case

In the paper [[2023_Elben-Zoller_Randomized-measurement_Nat.Rev.Phys.pdf]]

$$
std(\overline X) = \frac{std(X)}{\sqrt{n}}
$$
For the $\pm 1$ variable, $Var(X) \le 1$ ($Var(X) = E(X^2) - [E(X)]^2$，方差必然大于0，证明小于1即可), Viz.,

$$
error \sim \frac{1}{\sqrt n}
$$
Intent to let $error \sim \epsilon$, Viz.,

$$
n \sim \frac{1}{\epsilon^2}
$$