# Лист формул

## Меры и пространства

- $P\left(\bigcup_{n=1}^{\infty} A_n\right)=\sum_{n=1}^{\infty}P(A_n)$ для попарно непересекающихся $A_n$.
- $\delta_x(A)=\mathbf 1_A(x)$.
- $\mu_F((a,b])=F(b)-F(a)$.
- $\mathcal B(X)=\sigma(\text{open sets})$.

## Распределения и интегралы

- $P_X(B)=P\{X\in B\}$.
- $F_X(x)=P\{X\le x\}$.
- $F_{t_1,\ldots,t_n}(x_1,\ldots,x_n)=P\{X_{t_1}\le x_1,\ldots,X_{t_n}\le x_n\}$.
- $P_X(B)=\int_B p(x)\,dx$ при плотности.
- $\int\sum_k a_k\mathbf 1_{A_k}\,d\mu=\sum_k a_k\mu(A_k)$.
- $\mathbb E g(X)=\int_\Omega g(X)\,dP=\int_E g(x)P_X(dx)$.
- $\operatorname{Var}X=\mathbb E X^2-(\mathbb E X)^2$.
- $\operatorname{Cov}(X,Y)=\mathbb E[(X-\mathbb E X)(Y-\mathbb E Y)]$.

## Характеристические функции

- $\varphi_X(t)=\mathbb E e^{itX}$, $\varphi_X(0)=1$, $|\varphi_X(t)|\le1$.
- $\varphi_{X+Y}=\varphi_X\varphi_Y$ при независимости.
- $\varphi_X^{(k)}(0)=i^k\mathbb E X^k$, если момент существует.
- $\partial_i\varphi(0)=i\mathbb E X_i$, $\partial_{ij}\varphi(0)=-\mathbb E[X_iX_j]$.

## Условное ожидание

- $\nu\ll\mu\Rightarrow \nu(A)=\int_A \frac{d\nu}{d\mu}\,d\mu$.
- $Y=\mathbb E[X\mid\mathcal G]$ означает: $Y$ $\mathcal G$-измерима и $\int_GY\,dP=\int_GX\,dP$.
- $\mathbb E(\mathbb E[X\mid\mathcal G])=\mathbb E X$.
- Если $\mathcal H\subset\mathcal G$, то $\mathbb E(\mathbb E[X\mid\mathcal G]\mid\mathcal H)=\mathbb E[X\mid\mathcal H]$.

## Второй порядок

- $\langle X,Y\rangle=\mathbb E[XY]$ в $L^2$.
- $\rho(X,Y)=\dfrac{\operatorname{Cov}(X,Y)}{\sqrt{\operatorname{Var}X\operatorname{Var}Y}}$.
- $|\rho|\le1$.
- Проекция: $x-P_Hx\perp H$.

## Последовательности и процессы

- $X:\Omega\to E^{\mathbb N}$, $X(\omega)=(X_0,X_1,\ldots)$.
- Узкая стационарность: $(X_{t_1+h},\ldots,X_{t_n+h})\stackrel d=(X_{t_1},\ldots,X_{t_n})$.
- Широкая стационарность: $\mathbb E X_n=m$, $\operatorname{Cov}(X_n,X_{n+k})=R(k)$.
- Гауссовский вектор: $\varphi(u)=\exp\{i\langle u,m\rangle-\tfrac12u^T\Sigma u\}$.
- Блуждание: $S_n=\sum_{k=1}^n\xi_k$.
- ЦПТ: $\dfrac{\sum_{k=1}^nX_k-nm}{\sigma\sqrt n}\Rightarrow N(0,1)$.

## Марковские цепи и спектры

- $P(X_{n+1}=j\mid X_0=i_0,\ldots,X_n=i)=p_{ij}$.
- $p_{ij}\ge0$, $\sum_jp_{ij}=1$.
- $P^{m+n}=P^mP^n$.
- $\pi_{n+1}=\pi_nP$, стационарность $\pi=\pi P$.
- $R(k)=\operatorname{Cov}(X_0,X_k)$.
- $\operatorname{Var}(\bar X_N)=N^{-2}\sum_{i,j}R(i-j)$.
- $R(k)=\int_{-\pi}^{\pi}e^{ik\lambda}F(d\lambda)$.
