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

<div class="thm">

### ✅　勾配ベクトルの重要ポイント
##  $- \nabla f(\boldsymbol{x})$ は $\boldsymbol{x}$ における $f$ の値がもっとも小さくなる方向を指す

</div>

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



... せっかく Julia を使っているので視覚的に確かめてみる


---


<!-- _header: 実例で見てみる -->

<div class="section"> 1.1 微分のおさらい </div>

![h:600](../img/f0.png)

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

![h:450](../img/f1.png)


$\nabla f(0.5, -0.5) = \left(\frac{-17}{18}, \frac{25}{36} \right) = (-0.94, 0.694)$ のプロット



---


<!-- _header: 実例で見てみる -->

<div class="section"> 1.1 微分のおさらい </div>


![h:550 center](../img/gd2d.png)



---



<!-- _header: 勾配降下法 -->



<br>

✅ **$-\nabla f(\boldsymbol{x})$ は小さくなる方を指す**

![bg right h:500](../img/gd3d.gif)

<div style="text-align: center;">

⇩

</div>



$-\nabla f(x, y)$ の方向にちょっとづつ点を動かしていけば関数のそこそこ小さい値を取る点を探しに行ける

---

<!-- _header: 勾配降下法 -->

<div class="section"> 1.2 勾配降下法 </div>

<div class="def">



### [最急降下法]

1. $\boldsymbol{x}^{(0)}$, $\alpha$ を適当に決める
2. $\boldsymbol{x}^{(k+1)} = \boldsymbol{x}^{(k)} - \alpha \nabla f(\boldsymbol{x}^{(k)})$ として $\boldsymbol{x}^{(k+1)}$ を更新する
3. 収束したと思ったら $\boldsymbol{x}^{(k+1)}$ を出力して終了. そうでなければ 2. に戻る

</div>

**✅ $\large{\nabla f(\boldsymbol{x})}$ が計算可能でさえあればいつもある程度小さい値を探しに行ける！**

---

<!-- _header: 勾配降下法 -->


$f(x, y) = x^2 + y^2$




![bg right h:600](../img/gd-3d-sphere.gif)



---

<!-- _header: 勾配降下法 -->

<style scoped>
  p {
    font-size: 0.8em;
  }
</style>

<br>


$$
\begin{split}
f(x, y) = & \left( 1 - \frac{1}{1 + 0.05 \cdot x^{2} + \left( y - 10 \right)^{2}} \right. \\
& - \frac{1}{1 + 0.05 \cdot \left( x - 10 \right)^{2} + y^{2}} \\
& - \frac{1.5}{1 + 0.03 \cdot \left( x + 10 \right)^{2} + y^{2}} \\
& - \frac{2}{1 + 0.05 \cdot \left( x - 5 \right)^{2} + \left( y + 10 \right)^{2}} \\
& - \left. \frac{1}{1 + 0.1 \cdot \left( x + 5 \right)^{2} + \left( y + 10 \right)^{2}} \right) \\
& \cdot \left( 1 + 0.0001 \cdot \left( x^{2} + y^{2} \right)^{1.2} \right)
\end{split}
$$



<div class="cite">

元ネタ: Ilya Pavlyukevich, "Levy flights, non-local search and simulated annealing", Journal of Computational Physics 226 (2007) 1830-1844. 

</div>

<!-- Five-Well Potential 関数 -->



![bg right](../img/gd-3d-pf.gif)


---

<!-- _header: 勾配降下法を機械学習に応用する -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

### 機械学習で解きたくなる問題

<div class="def">

データ $\mathcal{D} = \{(\boldsymbol{x}_i, y_i)\}_{i=1}^n$ があるので、

パラメータ $\boldsymbol{\theta}$ を変化させて 損失 $L(\mathcal{D}; \boldsymbol{\theta})$ をなるべく小さくせよ

</div>

<div style="text-align: center;">

⇩



関数の小さい値を探しに行く問題 
$\leftrightarrow$ **勾配降下法チャンス！**


</div>


---

<!-- _header: 勾配降下法と深層学習 -->

<!-- <div class="section"> 1.3 勾配降下法と機械学習 </div> -->

勾配降下法を使った深層学習モデルのパラメータの最適化は、
<span class="dot-text">実際やってみると </span>  非常に上手くいく



![bg right h:500](../img/loss-history.png)



---


<!-- _header: 勾配降下法と深層学習 -->

<!-- <div class="section"> 1.3 勾配降下法と機械学習 </div> -->




基本的に、深層学習モデルは
勾配降下法を使って訓練


**⇨ 今この瞬間も世界中の計算機が
せっせと勾配ベクトルを計算中**



![bg right h:500](../img/gd-illust.png)




<div class="cite">

2050年にはAI業務サーバの消費電力は 3000 Twh にのぼると予測されているらしいです。(https://www.jst.go.jp/lcs/pdf/fy2020-pp-03.pdf)
 このうちどれだけの電力が学習(+そのうちの勾配の計算) に使われているかはわかりませんが、上の電力では日産リーフ五億六千万台を地球一周させることができます。そう考えると勾配の計算の効率化を考えることに多少は時間を使っても良さそうな気になってきます。

</div>


---


<!-- _header: 勾配の計算法を考える -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

<div class="def">

データ $\mathcal{D} = \{(\boldsymbol{x}_i, y_i)\}_{i=1}^n$ があるので、

パラメータ $\boldsymbol{\theta}$ を変化させて 損失 $L(\mathcal{D}; \boldsymbol{\theta})$ をなるべく小さくせよ

</div>

<div style="text-align: center;">

⇩

</div>
勾配降下法で解くには...

<div class="proof">

**$\nabla L$ を使って $\boldsymbol{\theta}$ を更新して小さい値を探索していく**


</div>


---


<!-- _header: 勾配の計算法を考える -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>



<br>
<br>


<div class="def">


データ $\mathcal{D} = \{(\boldsymbol{x}_i, y_i)\}_{i=1}^n$ があるので、

パラメータ $\boldsymbol{\theta}$ を変化させて 損失 $L(\mathcal{D}; \boldsymbol{\theta})$ をなるべく小さくせよ

</div>

<div style="text-align: center;">

⇩

</div>
勾配降下法で解くには...

<div class="proof">

**$\color{red}{\nabla L}(\boldsymbol{\theta})$ の値を使って $\boldsymbol{\theta}$ を更新して小さい値を探索していく** 


</div>


## ... $\nabla L(\boldsymbol{\theta})$ をどうやって計算する？


---

<!-- _header: 勾配の計算法を考える -->

さっきは $f(x, y) = x^2y + \frac{1}{x^2 + y^2 + 1}$ 
⇨ 頑張って手で $\nabla f$ を求められた

### 深層学習の複雑なモデル...

$$ 
L(\boldsymbol{\theta}; \boldsymbol{x}, y) \\
= \text{\Large{V}\small{e}\large{r}\LARGE{y}\LARGE{c}\Large{o}\small{m}\large{p}\LARGE{l}\small{i}\large{c}\LARGE{a}\small{t}\large{e}\large{d}\LARGE{f}} \left(\boldsymbol{\theta}; \boldsymbol{x}, y \right)
$$


<div style="text-align: center;">　

⇩

## とてもつらい.


</div>




![bg right](../img/resnet.png)

<!-- 右下にciteを表示 -->
<div class="cite">
画像: He, K., Zhang, X., Ren, S., & Sun, J. (2015). Deep Residual Learning for Image Recognition. ArXiv. /abs/1512.03385
</div>

---


<!-- _header: 勾配の計算法を考える ~近似編 -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

<div class="columns">

<div>


アイデア1. 近似によって求める？

$\displaystyle f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$


⇨ 実際に小さい $h$ をとって計算する. 


</div>

<div>

```julia
function diff(f, x; h=1e-8)
    return (f(x + h) - f(x)) / h
end
```



</div>  


</div>

---


<!-- _header: 勾配の計算法を考える ~近似編 -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

これでもそれなりに近い値を得られる.

例) $f(x) = x^2$ の $x=2$ における微分係数 $4$ を求める.

```julia
julia> function diff(f, x; h=1e-8)
           return (f(x + h) - f(x)) / h
       end
diff (generic function with 1 method)

julia> diff(x -> x^2, 2)   # おしい！
3.999999975690116 
```

---

<!-- _header: 数値微分 -->


#### 実際に小さい $h$ をとって計算
## **「数値微分」**


お手軽だが...

- 誤差が出る
- 勾配ベクトルの計算が非効率

![bg right h:450](../img/numerical_example.png)


---

<!-- _header: 数値微分 -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>


<div class="columns">



<div>

#### 問題点①. 誤差が出る 
1. 本来極限をとるのに、小さい $h$ を
とって計算しているので誤差が出る

2. 分子が極めて近い値同士の引き算に
なっていて、$\left( \frac{\color{red}{f(x+h) - f(x)}}{h} \right)$
桁落ちによって精度が大幅に悪化.


</div>

<div>

#### 問題点②. 勾配ベクトルの計算が非効率

1. $n$ 変数関数の勾配ベクトル $\nabla f(\boldsymbol{x}) \in \mathbb{R}^n$ を計算するには、
各 $x_i$ について「少し動かす→計算」を繰り返すので $n$回 $f$ を評価する. 
   
2. 応用では $n$ がとても大きくなり、 
$f$ の評価が重くなりがちで **致命的**


</div>

</div>

<div class="cite">
これらの問題の対処法はある？年収は？誤差のオーダーは?より精度のいい近似式の導出方法はある？　
調べてみました！　⇨ 付録: 「数値微分」へ

</div>

---

<!-- _header: 改良を考える -->

<div class="section"> 1.3 勾配降下法と機械学習 </div>

- 微分をすることによる誤差なく
- 高次元の勾配ベクトルを効率よく計算できないか？


---

<div class="section"> 1.3 勾配降下法と機械学習 </div>

:computer: < できますよ
:book: 

---

<div class="section"> 1.3 勾配降下法と機械学習 </div>

## ✅ 自動微分の世界へ

---

<!-- _header: 全体の流れ -->

<div class="section"> Introduction </div>

<br>


**1. 微分を求めることでなにが嬉しくなるのか, なぜ今微分が必要なのか理解する**

<div class="gray">

<div style="text-align: center;">

⇩

</div>


3. いろいろな微分をする手法のメリット・デメリットを理解する

<div style="text-align: center;">

⇩

</div>

4. Julia でそれぞれを利用 / 拡張する方法を理解する
   
</div>


---


<!-- _header: 全体の流れ -->

<div class="section"> Introduction </div>

<br>


<div class="gray">

1. 微分を求めることでなにが嬉しくなるのか, なぜ今微分が必要なのか理解する

</div>

<div style="text-align: center;">

⇩

</div>

**2. いろいろな微分をする手法のメリット・デメリットを理解する**

<div style="text-align: center;">

⇩

</div>

<div class="gray">

3. Julia でそれぞれを利用 / 拡張する方法を理解する
   
</div>

</div>

---