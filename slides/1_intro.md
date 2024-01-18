---
marp: true
paginate: true
math: mathjax
theme: honwaka
---


<!-- _class: lead -->

# [1] 微分と連続最適化

<br>
<br>

## 1.1 微分のおさらい
## 1.2 勾配降下法
## 1.3 勾配降下法と機械学習


---


<!-- _header: 微分の定義を振り返る ~ 高校  -->

<div class="section"> 1.1 微分のおさらい </div>


微分の定義 from 高校数学

<div class="def">

**[定義1. 微分係数]**

関数 $f$ の $x$ における微分係数は

$$
\lim_{h \to 0} \frac{f(x+h) - f(x)}{h}
$$
 
</div>


---

<!-- _header: 微分の定義を振り返る ~大学 -->

<div class="section"> 1.1 微分のおさらい </div>


<span class="dot-text">**偏**</span>微分の定義 from 大学数学


$x_i$ について偏微分  $\leftrightarrow$ $x_i$  以外の変数を固定して微分


<div class="def">

**[定義2. 偏微分係数]**

$n$ 変数関数 $f$ の $(x_1, \dots, x_n)$ の $x_i$ に関する偏微分係数

$$
\frac{\partial f}{\partial x_i} (x_1, \cdots, x_n) := \lim_{h \to 0} \frac{f(x_1, \dots, x_{i-1}, x_i + h, x_{i+1}, \dots, x_n) - f(x_1, \dots, x_n)}{h}
$$


</div>

<!-- スペース足りなかったので記号の定義も一緒にやった -->


---

<!-- _header: 微分の定義を振り返る ~大学 -->

<div class="section"> 1.1 微分のおさらい </div>


<div class="def">

各 $x_i$ について偏微分係数を計算して並べたベクトルを **勾配ベクトル** と呼ぶ

$$
\nabla f(x_1, \dots, x_n) := \left( \frac{\partial f}{\partial x_1} (x_1, \dots, x_n), \dots, \frac{\partial f}{\partial x_n} (x_1, \dots, x_n) \right)
$$

</div>

例) $f(x, y) = x^2 + xy$ の $(1, 2)$ における勾配ベクトルは

$$
\begin{cases}
\dfrac{\partial f}{\partial x} = 2x + y \\
\dfrac{\partial f}{\partial y} = x
\end{cases} \ \ \ \ \ \ \ \ \Rightarrow \ \ \ \ \ \ \
\underline{\nabla f(1, 2) = (4, 1)}
$$

---

<!-- _header: 勾配のうれしいポイント -->

<div class="section"> 1.1 微分のおさらい </div>    

### ✅　勾配ベクトルの重要ポイント
##  勾配ベクトルは関数の値が最も大きくなる方向を指し示す

---


<!-- _header: 勾配のうれしいポイント -->

<div class="section"> 1.1 微分のおさらい </div>


<div class="thm">

**[定理1. 勾配ベクトルの性質]**

$-\nabla f(\boldsymbol{x})$ は

$$
g(\boldsymbol{v}) = \lim_{h \to 0} \frac{f(\boldsymbol{x}) - f(\boldsymbol{x} + h\boldsymbol{v})}{h}
$$

の最大値を与える。

</div>



---


<!-- _header: 実例で見てみる -->

<div class="section"> 1.1 微分のおさらい </div>

![h:600](img/f0.png)

( $f(x, y)= x^2y + \frac{1}{x^2 + y^2 + 1}$ のプロット)


---


<!-- _header: 実例で見てみる -->

<div class="section"> 1.1 微分のおさらい </div>

$f(x, y) = x^2y + \frac{1}{x^2 + y^2 + 1}$

計算すると、

$$
\begin{cases}
\dfrac{\partial f}{\partial x} = 2xy - \dfrac{2x}{(x^2 + y^2 + 1)^2} \\
\dfrac{\partial f}{\partial y} = x^2 - \dfrac{2y}{(x^2 + y^2 + 1)^2}
\end{cases}
$$

なので 
$$
\nabla f(0.5, -0.5) = \left(\frac{-17}{18}, \frac{25}{36} \right) = (-0.94, 0.694)
$$

---


<!-- _header: 実例で見てみる -->


<div class="section"> 1.1 微分のおさらい </div>


![h:500](img/f1.png)


---


<!-- _header: 勾配降下法 -->



<br>

✅ **勾配ベクトルは関数の値が大きくなる方向を指し示す**

![bg right h:500](img/gd3d.gif)

⇨ $-\nabla f(x, y)$ の方向にちょっとづつ点を動かしていけば関数のそこそこ小さい値を取る点を探しに行ける

---

<!-- _header: 勾配降下法 -->

<div class="section"> 1.2 勾配降下法 </div>

<div class="def">



### [最急降下法]

1. $\boldsymbol{x}^{(0)}$, $\alpha$ を適当に決める
2. $\boldsymbol{x}^{(k+1)} = \boldsymbol{x}^{(k)} - \alpha \nabla f(\boldsymbol{x}^{(k)})$ として $\boldsymbol{x}^{(k+1)}$ を更新する
3. 収束したと思ったら $\boldsymbol{x}^{(k)}$ を出力して終了. そうでなければ 2. に戻る

</div>

✅ 一般の $f$ について大域的な解を求められる保証はないが、
そこそこ小さい値を取る点を探しに行ける


---

<!-- _header: 勾配降下法を機械学習に応用する -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

機械学習の典型的な問題設定

<div class="def">

学習データ $\mathcal{D} = \{(\boldsymbol{x}_i, y_i)\}_{i=1}^n$ が与えられたとき、 

損失関数
$$
L(\boldsymbol{w}; \mathcal{D})
$$

をなるべく小さくする $\boldsymbol{w}$ を求めよ

</div>

---

<!-- _header: 勾配降下法と深層学習 -->

<!-- <div class="section"> 1.3 勾配降下法と機械学習 </div> -->

勾配降下法を使った深層学習モデルのパラメータの最適化は、
実際やってみると非常に上手くいく

**⇨ 今この瞬間も世界中の計算機が**
**せっせと勾配ベクトルを計算中**


![bg right h:500](image-3.png)


---


<!-- _header: 勾配降下法と深層学習 (※ ギャグです)-->

<div class="section"> 1.3 勾配降下法と機械学習 </div>


<br>



- 2050年にはAI業務サーバの消費電力は 3000 Twh にのぼると予測されている [1] 

- 日産リーフは 7.0 km/kWh で走るらしい

![h:300](image-19.png)


<div class="cite">
[1] JST 低炭素社会戦略センター: 情報化社会の進展がエネルギー消費に与える影響 (Vol.2)
−データセンター消費エネルギーの現状と将来予測および技術的課題 https://www.jst.go.jp/lcs/pdf/fy2020-pp-03.pdf 

</div>


---


<!-- _header: 勾配降下法と深層学習  (※ ギャグです) -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

太陽 ~ 地球の距離は $1.5 \times 10^8$ km　くらい.

$(2.1 \times 10^{16}) / (1.5 \times 10^8) = 1.4 \times 10^5$ 


**⇨ $人類は、一年間で日産リーフを太陽に 140000 \ 台送りこめる電力を$**
**$勾配の計算に費やしている。$**




---


<!-- _header: 勾配の計算法を考える -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

<div class="def">

学習データ $\mathcal{D} = \{(\boldsymbol{x}_i, y_i)\}_{i=1}^n$ が与えられたとき、 

損失関数
$$
L(\boldsymbol{w}; \mathcal{D})
$$

をなるべく小さくする $\boldsymbol{w}$ を求めよ

</div>

勾配降下法で解くには...
$\nabla L$ を使って 
$\boldsymbol{w}$ を更新していけば良い

---

<!-- _header: 勾配の計算法を考える -->

<br>

<div class="section"> 1.3 勾配降下法と機械学習 </div>

<div class="def">

学習データ $\mathcal{D} = \{(\boldsymbol{x}_i, y_i)\}_{i=1}^n$ が与えられたとき、 

損失関数
$$
L(\boldsymbol{w}; \mathcal{D})
$$

をなるべく小さくする $\boldsymbol{w}$ を求めよ

</div>

勾配降下法で解くには...
<div class="red"> 

$\nabla L$ を使って

</div> 

$\boldsymbol{w}$ を更新していけば良い


---

<!-- _header: 勾配の計算法を考える -->

さっきは $f(x, y) = x^2y + \frac{1}{x^2 + y^2 + 1}$ 
⇨ 頑張って手で $\nabla f$ を求められた

### 深層学習の複雑なモデル...

$$ 
L(\boldsymbol{w}; \boldsymbol{x}, y) \\
= \text{\Large{V}\small{e}\large{r}\LARGE{y}\LARGE{c}\Large{o}\small{m}\large{p}\LARGE{l}\small{i}\large{c}\LARGE{a}\small{t}\large{e}\large{d}\LARGE{f}} \left(\boldsymbol{w}; \boldsymbol{x}, y \right)
$$


:innocent: :innocent: :innocent:



![bg right](image-4.png)

<!-- 右下にciteを表示 -->
<div class="cite">
画像: He, K., Zhang, X., Ren, S., & Sun, J. (2015). Deep Residual Learning for Image Recognition. ArXiv. /abs/1512.03385
</div>




---

<div class="section"> 1.3 勾配降下法と機械学習 </div>

:computer: < やりますよ


---

<div class="section"> 1.3 勾配降下法と機械学習 </div>

## ✅ 計算機に自動で微分させよう！

---