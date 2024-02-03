---
marp: true
paginate: true
math: mathjax
theme: honwaka
---

<!-- _class: lead -->

# **2.3 自動微分**
# **式からアルゴリズムへ**




---


<!-- _header: アルゴリズムの表現 -->

<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>


おさらい

- 木構造で関数を表現しようとすると、簡単なものでも木が複雑になる.
- 原因は、木で表現された数式は束縛がないこと
- 束縛ができる (中間変数が導入された) 場合にどうなるか考えてみる


---

<!-- _header: DAG による表現 -->





... あるものに名前をつけて
いくらでも参照できるようになった

$$
\begin{split}
t_1 &= x * x \\
t_2 &= t_1 * t_1 \\
\end{split}
$$

![bg right h:450](../img/intro_dag.png)


---


<!-- _header: DAG による表現 -->


**有効非巡回グラフ(DAG)**　
でのアルゴリズムの表現

# **計算グラフ**
##### **(Kantrovich グラフ)**


![bg right h:550](../img/cgraph0.png)


---

<!-- _header: 計算グラフによる表現 -->


<div class="def">

**[計算グラフ]** 

計算過程をDAGで表現

$$
\Large
\begin{split}
t &= x + y \\
z &= x \cdot t \\
\end{split}
$$

</div>



![bg right h:550](../img/cgraph0.png)



<div class="cite">

単に計算過程を表しただけのものを Kantrovich グラフなどと呼び、
これに偏導関数などの情報を加えたものを計算グラフと呼ぶような定義もあります.
(伊里, 久保田 (1998) に詳しく形式的な定義があります)
ただ、単に計算グラフというだけで計算過程を表現するグラフを指すという用法はかなり普及していて一般的と思われます。そのためここでもそれに従って計算過程を表現するグラフを計算グラフと呼びます.

</div>

---

<!-- _header: 計算グラフによる表現 -->

<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

(一旦計算グラフを得たものとして、)　
この構造から導関数を得ることを考えてみる.

---

<!-- _header: 連鎖律 -->

<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

<div class="thm">

**[連鎖律]**

$u, v$ の関数 $x, y$ による合成関数 $z \left(x(u, v), y(u, v)\right)$ に対して、

$$
\frac{\partial z}{\partial u} = \frac{\partial z}{\partial x} \cdot \frac{\partial x}{\partial u} + \frac{\partial z}{\partial y} \cdot \frac{\partial y}{\partial u}
$$

$$
\frac{\partial z}{\partial v} = \frac{\partial z}{\partial x} \cdot \frac{\partial x}{\partial v} + \frac{\partial z}{\partial y} \cdot \frac{\partial y}{\partial v}
$$


</div>


---


<!-- _header: 連鎖律と計算グラフの対応 -->

<div class="proof">


**目標**

$
\displaystyle
\begin{split}
x &= u + v \\
y &= u - v \\
z &= x \cdot y
\end{split}
$

のとき、 $\dfrac{\partial z}{\partial u}$ を求める


</div>





![bg right h:550](../img/cgraph1.png)   


---

<!-- _header: 連鎖律と計算グラフの対応 -->

$$
\frac{\partial z}{\partial u} = \frac{\partial z}{\partial x} \cdot \frac{\partial x}{\partial u} + \frac{\partial z}{\partial y} \cdot \frac{\partial y}{\partial u}
$$



との対応は、

![bg right h:550](../img/cgraph1.png) 

---


<!-- _header: 連鎖律と計算グラフの対応 -->

$$
\frac{\partial z}{\partial u} = \color{red} \frac{\partial z}{\partial x} \cdot \frac{\partial x}{\partial u} 
\color{black} + \color{blue} \frac{\partial z}{\partial y} \cdot \frac{\partial y}{\partial u}
$$

![bg right h:550](../img/cgraph1_ano.svg)


---


<!-- _header: 連鎖律と計算グラフの対応 -->

<div class="thm">

✅ 変数 $z$ に対する $u$ による偏微分の
計算グラフ上の表現


$\leftrightarrow$ **$u$ から $z$ への全ての経路の偏微分の総積の総和**



$$
\large
\frac{\partial z}{\partial u} = \sum_{p \in \hat{P}(u, z)} \  \left( \prod_{(s, t) \in p} \dfrac{\partial t}{\partial s} \right)
$$


<div style="font-size: 15px"> 

$\hat{P}(u, z)$ は $u$ から $z$ への全ての経路の集合. $(s, t)$ は変数 $s$ から変数 $t$ への辺を表す.

</div>

</div>

![bg right:25% h:550](../img/cgraph1_ano.svg)

---

<!-- _header: キャッシュ -->

一番簡単なやりかた

$\dfrac{\partial z}{\partial u}$ を求める:

```julia
graph = ComputationalGraph(f)

∂z_∂u = 0
for path in all_paths(graph, u, z)
    ∂z_∂u += prod(grad(s, t) for (s, t) in path)
end
```


![bg right:30% h:650](../img/autodiff-cache1.svg)


---

<!-- _header: キャッシュ -->

続いて $\dfrac{\partial z}{\partial v}$ を求める:

```julia
∂z_∂v = 0

for path in all_paths(graph, v, z)
    ∂z_∂v += prod(grad(s, t) for (s, t) in path)
end
```


![bg right:30% h:650](../img/autodiff-cache1.svg)

---



<!-- _header: 自動微分とキャッシュ -->

共通部がある！ $\leftrightarrow$ 独立して計算するのは非効率. 

⇨ うまく複数のノードからの経路を計算する.



![bg right:30% h:650](../img/autodiff-cashe2.svg)


---


<!-- _header: Backward-Mode AD -->



![bg w:1200](../img/autodiff-v.svg)


---

<!-- _header: Backward-Mode AD -->



![bg w:1200](../img/autodiff-v1.svg)


---

<!-- _header: Backward-Mode AD -->



![bg w:1200](../img/autodiff-v2.svg)

---

<!-- _header: Backward-Mode AD -->


![bg w:1200](../img/autodiff-v3.svg)


---

<!-- _header: Backward-Mode AD -->

![bg w:1200](../img/autodiff-v4.svg)

---

<!-- _header: Backward-Mode AD -->


<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>
<div class="thm">


✅　計算グラフを辿っていくことで、共通部の計算を共有しながら、
**「複数の偏微分係数をグラフ一回の走査で」**
**「中間変数の偏微分係数を共有しながら」**  計算できた！

この微分のアルゴリズムを

**後退型自動微分 (Backward-Mode AD)**、 **高速微分(fast differentiation)**、
**逆向き自動微分(Reverse-Mode AD)**、 **高速自動微分(fast AD)** などと呼ぶ.

</div>

---


<!-- _header: Forward-Mode AD -->

<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

:question: 一般の $f: \mathbb{R}^n \to \mathbb{R}^m$ について、常に逆向きに微分を辿るのがよい？


<div style="text-align: center;">

⇩


$m > n$ の場合を考えてみる


</div>


---

<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

<!-- _header: Forward-Mode AD -->

![](../img/autodiff-foward-v.svg)

... $x$ から辿っていくことで、**共通部を共有しつつ**, **複数の出力に対する偏微分係数**を一度に計算できる

⇨ **前進型自動微分 (Forward-Mode AD)**

---

<!-- _header: Backward / Forward-Mode AD -->
<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

- **逆向き自動微分 (Backward-Mode AD)**

  - $f: \mathbb{R}^n \to \mathbb{R}^m$ に対して、 $m < n$ の場合に効率的
  - 勾配を一回グラフを走査するだけで計算可能

- **前進型自動微分 (Forward-Mode AD)**
  - $f: \mathbb{R}^n \to \mathbb{R}^m$ に対して、 $m > n$ の場合に効率的
  - ヤコビ行列の一列を一回グラフを走査するだけで計算可能
  - 実装では定数倍が軽くなりがちなため、
   $n, m$ が小さい場合には効率的な可能性が高い

<div class="cite">

時間がないため割愛しましたが、 Forward-Mode AD の話でよく出てくる **二重数** というものがあります. $\varepsilon^2 = 0$ かつ $\varepsilon \neq 0$ なる $\varepsilon \notin \mathbb{R}$ を考え、
これと実数からなる集合上の演算を素直に定義すると一見、不思議なことに微分が計算される... というような面白い数です。　
興味があるかたは [「2乗してはじめて0になる数」とかあったら面白くないですか？ですよね - アジマティクス ](https://www.ajimatics.com/entry/2021/03/22/174633) や [ForwardDiff.jlのドキュメント](https://juliadiff.org/ForwardDiff.jl/stable/dev/how_it_works/)　などおすすmです。


</div>


---


<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>


<!-- _header: 計算グラフ以外の表現 -->


<div class="columns">

<div>


<br>


<div class="thm">



✅ **計算グラフは DAG**
**$\leftrightarrow$ トポロジカルソート可能**



演算の適用順序を適切に持てば、
単に演算の列を持って同様に
グラフを辿るのと同じことが可能.


この列を、
**Wengert List**, **Gradient Tape**
と呼ぶ.

</div>




</div>


<div>

<br>


$$
\begin{split}
y_{1} &= x^{2} \\
y_{2} &= 2 \cdot y_{1} \\
y_{3} &= \left(1 + x\right) \\
y_{4} &= 2 \cdot x \\
y_{5} &= 2 \cdot y_{4} \\
y_{6} &= y_{3} \cdot y_{5} \\
y_{7} &= \left(y_{2} - y_{6}\right) \\
y_{8} &= \left(y_{2}\right)^{2} \\
y_{9} &= \dfrac{y_{7}}{y_{8}} \\
\end{split}
$$




</div>

</div>


---

<!-- _header: 計算グラフ vs Wengert List -->


<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>


- PyTorch / Chainer は Wengert List ではなく計算グラフを使っている. [1]
> **No tape**. Traditional reverse-mode differentiation records a tape (also known as a Wengert list) describing the order in which operations were originally executed; <中略>
An added benefit of structuring graphs this way is that when a portion of the graph becomes dead, it is automatically freed; an important consideration when we want to free large
memory chunks as quickly as possible.

- Zygote.jl, Tensorflow などは Wengert List を使っている. 


<div class="cite">

[1] Paszke, A., Gross, S., Chintala, S., Chanan, G., Yang, E., DeVito, Z., Lin, Z., Desmaison, A., Antiga, L. & Lerer, A. (2017). Automatic Differentiation in PyTorch. NIPS 2017 Workshop on Autodiff, .
[2] 計算グラフとメモリの解放周辺で、Chainer の Aggressive Memory Release という仕組みがとても面白いです: [Aggressive buffer release #2368](https://github.com/chainer/chainer/issues/2368)

</div>

---

<!-- _header: 計算グラフをどう得るか？ -->


<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

:dog: < 計算グラフさえあれば計算ができることがわかった。
        では計算グラフをどう得るか？


---

<!-- _header: 計算グラフをどう得るか？ -->

<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

<div class="columns">


<div>


<br><br>


✅ 一般的なプログラムを <span class="dot-text">直接解析</span> して
(微分が計算できる) 計算グラフを得る
プログラムを実装するのはとても難易度が高い.



</div>

<div>

```julia
x = [1, 2, 3]
y = [2, 4, 6]

function linear_regression_error(coef)
    pred = x * coef
    error = 0.
    for i in eachindex(y)
        error += (y[i] - pred[i])^2
    end
    return error
end
```


</div>



</div>

---

<!-- _header: トレースによる計算グラフの獲得 -->    

<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>


✅ **トレース** $\cdots$ **実際にプログラムを実行し、その過程を記録することで計算グラフを得る**


----

<!-- _header: トレースの OO による典型的な実装 -->    



<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>



<div class="def">




**[典型的なトレースの実装]**

1. `Varialble` 型を用意
2. 基本的な演算を表す関数について、`Varialble` 型用のメソッドを実装し、このメソッドの中で計算グラフも構築する




</div>




---

<!-- _header: トレースの OO による典型的な実装 -->    


<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>

```julia
import Base

mutable struct Scalar
    values
    creator
    grad
    generation
    name
end

Base.:+(x1::Scalar, x2::Scalar) = calc_and_build_graph(+, x1, x2)
Base.:*(x1::Scalar, x2::Scalar) = calc_and_build_graph(*, x1, x2)
...
```


---


<!-- _header: トレースの利点 -->


<br>




**「実際そのときあった演算」** のみが記録され問題になる
⇨  制御構文がいくらあってもOK

```julia
function crazy_function(x, y)
    rand() < 0.5 ? x + y : x - y
end

x = Scalar(2.0, name="x")
y = Scalar(3.0, name="y")

z = crazy_function(x, y)

JITrench.plot_graph(z, var_label=:name)
```


![bg right h:500](../img/cgraph3.png)

---

<!-- _header: トレースの欠点 -->


<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>


- 計算時にグラフを作ることによるオーバーヘッド
- コンパイラの最適化の情報が消えてしまい恩恵をうけにくい


---

<!-- _header: トレースからソースコード変換へ -->



<div class="section"> 2.3 自動微分 ─式からアルゴリズムへ  </div>


- コンパイラと深く関わったレベルで自動微分をやっていこう！

<div style="text-align: center;">

⇩

Zygote.jl, Enzyme, TensorFlow in Swift etc...


</div>


---



