---
marp: true
paginate: true
math: mathjax
theme: honwaka
---
$$
\newcommand{\argmin}{\mathop{\rm arg~min}\limits}
$$


<!-- _class: lead -->

# Juliaと歩く自動微分の世界
## Julia Tokyo #11

@abap34
2023/02/03


---

<!-- _header: 自己紹介-->

<br>

## @abap34
東工大 情報理工学院 情報工学系 B2 
(もうすぐ消滅)
**趣味**
- :robot: 機械学習
- :gear: 個人開発
- :baseball: 野球をする/みる

GitHub: @abap34
Twitter: @abap34

![bg right h:400](img/abap34.png)


---

<!-- _header: 自己紹介 -->


<!-- ![bg right h:600](img/lang.png) -->

## ✅ Juliaをこんなことに使ってます！

1. データ分析
2. 機械学習や数学の勉強・調べ物
3. 競プロ


![bg right h:300](img/jl_demo.gif)



---

<!-- _header: 自己紹介 -->

<div class="section"> 自己紹介 </div>


<br>

## ✅ Juliaのこんなところが気に入ってます！

1. 綺麗な可視化・ベンチマークライブラリ
   - Plotまわり・ `@code_...` マクロ, `BenchmarkTools.jl`  たち
2. パッケージ管理ツール同梱
   - 言語同梱がありがたい！ (友人間で共有するのに一苦労の言語も)
3. チャッとかける
   - Jupyter のサポート, 強力な REPL
4. **速い！！**
   - 速いは正義
   - 裏が速いライブラリの「芸人」にならなくても素直に書いてそのまま速い

---

<!-- _header: Julia を使って解かれた・書かれたレポートたち -->

<div class="section"> 自己紹介 </div>

![h:200](anim.gif)  ![h:200](image-13.png)  ![h:200](train_drop.gif)  ![h:200](image-14.png) ![h:200](basic-norsurface.gif)  ![h:250](fitting_history.gif) ![h:200](gd1.gif)

---


<!-- _header:  自己紹介 -->


<div class="columns">


<div>

<br>

<br>
<br>
<br>



one of 興味があるもの

## **機械学習(特に深層学習)の**
## **エンジニアリング的な基盤**




</div>


<div>

![](image-17.png)

<div class="center">



自作DLフレームワーク: [JITrench.jl](https://github.com/abap34/JITrench.jl)


</div>


</div>






</div>


---


<!-- _header:  自己紹介 -->


one of 深層学習の基盤

# **自動微分**




---

<!-- _header: 今日話すこと -->

<br>

### メイントピック
- なぜ自動で微分が求まると嬉しい？
- 微分を自動で求めるにはどういう方法がある？
- Juliaを使って計算機に微分をさせるには？

### ターゲット層
- 微分を求めたいことがあって既存のライブラリを使っているけど、どの場面でどれを使うのが適切かわからない
- 深層学習フレームワークを使っているけど、あんまり中身がわかっていない
- 自分のフレームワークに自動微分を組み込みたい

---

<!-- _header: 今日のおしながき -->

<br>

<div class="columns">

<div>

### [1] 微分と連続最適化
1.1 微分のおさらい
1.2 勾配降下法
1.3 勾配降下法と機械学習

### [2] 自動で微分
2.1 「自動で微分を求める」とは
2.2 数値微分 
2.3 数式微分と自動微分は違う?
2.4 数式微分 
2.5 自動微分 

</div>


<div>


### [3] Juliaに微分させる
3.1 FiniteDiff.jl/FiniteDifferences.jl
3.1 ForwardDiff.jl
3.2 Zygote.jl/Diffractor.jl
3.3 AbstractDifferentiation.jl

### [4] Juliaの微分を拡張する
4.1 ChainRules

### [5] まとめ 
### [6] 付録・参考文献



</div>

</div>

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
<!-- _class: lead -->

# [2] 自動微分

<br>

## 2.1 「自動で微分を求める」とは？
## 2.2 数値微分
## 2.3 数式微分と自動微分は違う?

---


<!-- _header: 「微分を求める」は具体的に何？ -->

<div class="section"> 2.1 「自動で微分を求める」とは？ </div>


<div class="columns">

<div>


人に頼んだ場合...

:dog: < $f(x) = x^2 + 1$ を微分して ?
:man: < $f'(x) = 2x$.




### = 人間は `Expr` $\to$ `Expr` の微分ロボ.

1. $f'$ を求めて
2. 代入することで各微分係数を求める

</div>

<div>

```julia
function human(f::Expr)::Expr
    df = 長い人生で獲得した微分能力(f)
    return df
end


f′ = human(:(x^2 + 1)) 
f′ # :(2x)
```

</div>


</div>




--- 

<!-- _header: 「導関数」は本当に必要？ -->

<div class="section"> 2.1 「自動で微分を求める」とは？ </div>


<div class="def">

### [最急降下法]

1. $\boldsymbol{x}^{(0)}$, $\alpha$ を適当に決める
2. $\boldsymbol{x}^{(k+1)} = \boldsymbol{x}^{(k)} - \alpha \nabla f(\boldsymbol{x}^{(k)})$ として $\boldsymbol{x}^{(k+1)}$ を更新する
3. 収束したと思ったら $\boldsymbol{x}^{(k)}$ を出力して終了. そうでなければ 2. に戻る

</div>

⇨ 計算過程で必要なのは $\nabla f(\boldsymbol{x}^{(k)})$ という **値** であって関数でない

---

<!-- _header: 「導関数」は本当に必要？ -->


<div class="section"> 2.1 「自動で微分を求める」とは？ </div>

<div class="columns">

<div>

本当に求められていること...

必要になった $\boldsymbol{x}$ に対して
そのとき $\nabla f(\boldsymbol{x})$ の値さえ求まればOK.


**⇨ $\nabla f$ の形は陽に求まらないけど値は**
**計算できる手法もウェルカム**

</div>

<div>

```julia
function df(f::Function, x::Number)::Number
    g = 謎のアルゴリズム(f, x)
    return g
end
```


</div>


</div>



---

<!-- _header: 微分を求める3つの手法 -->


<div class="section"> 2.1 「自動で微分を求める」とは？ </div>

## 3 つの主要な手法

### 1. 数値微分
### 2. 数式微分
### 3. 自動微分


<!-- --- -->


<!-- _header: 微分を求める3つの手法 -->
<!-- 
<div class="section"> 2.1 「自動で微分を求める」とは？ </div>
<br>

<br> -->

<!-- ![](img/difflalgos.png)  -->




---

<div class="section"> 2.2 数値微分 </div>

# **- 数値微分**

<br>

```julia
function numerical_derivative(f::Function, x::Number)::Number
    g = numerical_operation(f, x)
    return g
end
```

---



<!-- _header: 数値微分のアイデア -->

<div class="section"> 2.2 数値微分 </div>

### `謎のアルゴリズム` の実現方法1. 

### 微分の定義  

<br>

$$
\lim_{h \to 0} \frac{f(x+h) - f(x)}{h}
$$ 

### をそのまま近似する

---

<!-- _header: 数値微分のアイデア -->

<div class="section"> 2.2 数値微分 </div>



<div class="def">

**[数値微分]**

1. $h$ として具体的に小さい値をとる

2. $\displaystyle \frac{f(x+h) - f(x)}{h}$ を計算

</div>


---


<!-- _header: 数値微分の実装 -->


<div class="section"> 2.2 数値微分 </div>


```julia
function numerical_derivative(f, x; h=1e-8)
    g = (f(x+h) - f(x)) / h
    return g
end

f(x) = sin(x)
f′(x) = cos(x)
x = π / 3

numerical_derivative(f, x) # 0.4999999969612645
f′(x)                      # 0.5000000000000001
```

---


<!-- _header: + 数値微分のメリット -->


<div class="section"> 2.2 数値微分 </div>



## 1. 実装が極めて容易
## 2. $\ \Large{f}$ が <span class="dot-text">なんでも</span> 計算可能.




---

<!-- _header: 数値微分のメリット ~ 実装が容易 -->

<div class="section"> 2.2 数値微分 </div>

### ✅ これだけで実装完了

```julia
function numerical_derivative(f, x; h=1e-8)
    g = (f(x+h) - f(x)) / h
    return g
end

f(x) = sin(x)
f′(x) = cos(x)
x = π / 3

numerical_derivative(f, x) # 0.4999999969612645
f′(x)                      # 0.5000000000000001
```

---

<!-- _header: 数値微分のメリット ~ 実装が容易 -->

<div class="section"> 2.2 数値微分 </div>

### 多変数関数への拡張 $\cdots$ $i$ 番目を固定して繰り返し計算



```julia
function numerical_gradient(f, x::Vector; h=1e-8)
    n = length(x)
    g = zeros(n)
    y = f(x...)
    for i in 1:n
        x[i] += h
        g[i] = (f(x...) - y) / h
        x[i] -= h
    end
    return g
end
```

### ✅ 実装完了

---

<!-- _header: 数値微分のメリット ~ なんでも計算可能 -->

<div class="section"> 2.2 数値微分 </div>

### ✅ なんでも計算可能

```julia
function numerical_derivative(f, x; h=1e-8)
    g = (f(x+h) - f(x)) / h
    return g
end
```

→ $f$ がどんなに訳のわからない演算でも、 
$f(x+h)$ と $f(x)$ が計算できればOK

---

<!-- _header: 数値微分のデメリット -->

<div class="section"> 2.2 数値微分 </div>




### 1. 打ち切り誤差が生じる
### 2. 桁落ちも起こる
### 3. 計算コストが高い

---

<!-- _header: 数値微分の誤差 ~ 打ち切り誤差 -->

<div class="section"> 2.2 数値微分 </div>

<div class="columns">

<div>

本来は極限を取るのに小さい値で
誤魔化すので誤差が発生

⇩

実際どれくらいの誤差が発生する？

</div>


<div>



$$
\LARGE \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}
$$

</div>

</div>



---



<!-- _header: 数値微分の誤差 -->

<br>
<br>


<div class="section"> 2.2 数値微分 </div>


<div class="thm">

**[定理2. 数値微分の誤差]**

$$
f'(x) - \frac{f(x+h) - f(x)}{h} = O(h)
$$


</div>


<div class="proof" style="font-size: 0.8em;">

**[証明]**

テイラー展開すると、

$$
\begin{align}
f'(x) - \frac{1}{h} \left( f(x+h) - f(x) \right) &= f'(x) - \frac{1}{h} \left( f(x) + f'(x)h + O(h^2) - f(x) \right) \\
&= O(h)
\end{align}
$$

</div>

---

<!-- _header: 誤差の最小化 -->

<div class="section"> 2.2 数値微分 </div>

### 実験:

$O(h)$ なら、 $h$ をどんどん小さくすればいくらでも精度が良くなるはず？

```julia
H = [0.1^i for i in 4:0.5:10]
E = similar(H)

for i in eachindex(H)
    d = numerical_derivative(f, x, h=H[i])
    E[i] = abs(d - f′(x))
end

plot(H, E)
```


---

<!-- _header: 誤差の最小化 -->


### 実際


$h < 10^{-8}$ くらいになるとむしろ
精度が悪化する

![bg right h:400](img/numd.png)



---

<!-- _header: 丸め誤差と打ち切り誤差のトレードオフ -->



<div class="section"> 2.2 数値微分 </div>



<div class="columns">

<div>


$h$ が小さくなると、分子の引き算が非常に近い値の引き算になる


### ⇨ 桁落ちが発生し全体として悪化

</div>

<div>



$$
\LARGE\frac{\color{red}{f(x+h) - f(x)}}{h} 
$$


</div>


</div>


---

<!-- _header: 数値微分の改良 -->


<div class="section"> 2.2 数値微分 </div>

### 誤差への対応

1. 打ち切り誤差　⇨ 計算式の変更
2. 桁落ち ⇨ $h$ の調整？

---

<!-- _header: 数値微分の改良 ~ 打ち切り誤差の改善   -->


<div class="section"> 2.2 数値微分 </div>

### 1. 打ち切り誤差への対応

微分の (一般的な) 定義をそのまま計算する方法:

$$
f'(x) \approx  \frac{f(x+h) - f(x)}{h}
$$

は **前進差分** と呼ばれる

---


<!-- _header: 数値微分の改良 ~ 打ち切り誤差の改善   -->

<div class="section"> 2.2 数値微分 </div>



ところで、

$$
\lim_{h \to 0} \frac{f(x+h) - f(x)}{h} = \lim_{h \to 0} \frac{f(x+h) - f(x-h)}{2h} 
$$

<div class="center">

### ⇩

### これを近似してみても良さそう？



</div>

---

<!-- _header: 中心差分による２次精度の数値微分  -->

<div class="section"> 2.2 数値微分 </div>

実はこれの方が精度がよい！

<div class="thm">

**[定理3. 中心差分の誤差]**

$$
f'(x) - \frac{f(x+h) - f(x-h)}{2h} = O(h^2)
$$

</div>

同じようにテイラー展開をするとわかる
また、簡単な計算で一般の $n$ について誤差 $O(h^n)$ の近似式を得られる (下参照)

<div class="cite">

中心差分と同様に $x$ から左右に $\frac{n}{2}$ ずつとってこれの評価の重みつき和を考えてみます。
すると、テイラー展開の各項を足し合わせて $f'(x)$ 以外の係数を $0$ にすることを考えることで公比が各列 $-\frac{n}{2}, -\frac{n-1}{2}, \cdots, \frac{n}{2}$ で初項 $1$ のヴァンデルモンド行列を $A$ として 
$Ax = e_2$ を満たす $x$ を $h$ で割ったのが求めたい重みとわかります. あとはこれの重み付き和をとればいいです. 同様に $k$ 階微分の近似式も得られます.

</div>

 
---


<!-- _header: 数値微分の改良 ~ 桁落ちへの対応  -->

<div class="section"> 2.2 数値微分 </div>

### 2. 桁落ちへの対応

Q. 打ち切り誤差と丸め誤差のトレードオフで $h$ を小さくすればいいというものじゃないことはわかった。じゃあ、最適な $h$ は見積もれる？

A. 最適な $h$ は $f$ の $n$ 階微分の大きさに依存するから簡単ではない. 

例) 中心差分 $\dfrac{f(x+h) - f(x-h)}{h}$ は $h_{best} \approx \ \sqrt[3]{\dfrac{\mathstrut 3 \sqrt{2} 
\ \varepsilon}{|f'''(x)|}}$  くらい ? 


#### ⇨ $f'(x)$ がわからないのに $f'''(x)$ を使った式を使うのは現実的でない. 
しょうがないので $h = \left( \frac{(n+1)!}{\sqrt{n} f(x)} \varepsilon \right)^{\frac{1}{n+1}}$  に線を引いてみると...


<!-- 
---

[導出]
$n$ 点評価で $O(h^n)$ の近似をしたときの誤差の期待値を最小化する.
前のページで使った $\boldsymbol{x}$ を使うと $f_{estimate}(x) = \frac{1}{h}  \sum_i^n x_i \hat {f}(x_i)$ 
($\hat{f}$ は浮動小数点誤差を含む $f$ の計算結果.) 
ここで各 $\hat{f}(x_i)$ の計算結果が $\varepsilon$ の誤差を生むとすると
分子の誤差の期待値はランダムウォークの期待値を考えて $\sqrt{n} \varepsilon$. 
すると $f'(x)$ との誤差 $E(h)$ は
$E(h) \approx \sqrt{n} \varepsilon + \dfrac{n f^{(n+1)}(x)}{(n+1)!} h^{n-1}$ ($\because$ テイラーの定理, $h$ 小さいので剰余項 $f^{(n+1)}(c) \approx f^{(n+1)}(x)$ - この近似がやばそうだが他に計算できるものがない)

これの最小値を計算すると $h = \left(\dfrac{(n+1)!\varepsilon}{\sqrt{n}f^{(n+1)}(x)}\right)^{\frac{1}{n+1}}$. 

 $n=2$ で計算すると $h = \sqrt{\dfrac{3 \sqrt{2} \varepsilon}{|f'''(x)|}}$ -->


---


<div class="section"> 2.2 数値微分 </div>


![h:500](img/numd2.png)

結構いい感じ？

---

<div class="section"> 2.2 数値微分 </div>

<br>
<br>

![h:530](img/numd3.png)

🤨



---

<div class="section"> 2.2 数値微分 </div>

### デメリット3. 計算コストが高い

---

<!-- _header: 多変数関数への拡張 -->

<div class="section"> 2.2 数値微分 </div>

<br>

#### $f: \mathbb{R}^n \to \mathbb{R}$ の $\boldsymbol{x}$ における勾配ベクトル $\nabla f(\boldsymbol{x})$ を求める

```julia
function numerical_gradient(f, x::Vector; h=1e-8)
    n = length(x)
    g = zeros(n)
    y = f(x...)
    for i in 1:n
        x[i] += h
        g[i] = (f(x...) - y) / h
        x[i] -= h
    end
    return g
end
```


#### ⇨ 関数を $n$ 回評価する必要がある.

---


<!-- _header: $n$ 回評価は致命的 -->

<div class="section"> 2.2 数値微分 </div>

<br>

<br>

##### ✅ 応用では $f$ が重く, $n$ が大きくなりがち ⇨ $n$ 回評価は高コスト


<br>

<div class="center">


![h:400](image-5.png)


</div>


<div class="cite">
https://www.researchgate.net/figure/Number-of-parameters-ie-weights-in-recent-landmark-neural-networks1-2-31-43_fig1_349044689 より引用
</div>

---

<div class="section"> 2.2 数値微分 </div>



## 結論: 実装の手軽さや $f$ がなんでもいけるのは非常に有用！

一方、機械学習などで応用するのはきびしそう



---



<!-- _header: 数式微分と自動微分は違う? -->


各ツールに対して
数式微分 / 自動微分のどちらかを
きっちり分類するのは不毛ぎみ？

![bg right h:400](img/ad_vs_sd.png)


--- 

<div class="section"> 2.1 「自動で微分を求める」とは？ </div>

## 3 つの主要な手法

<div class="gray">


### 1. 数値微分

</div>


### 2. 数式微分


<div class="gray">



### 3. 自動微分

</div>



---


<div class="section"> 2.4 数式微分 </div>


# **- 数式微分**

<br>

```julia
function symbolic_derivative(f::Expr)::Expr
    df = symbolic_operation(f)
    return df
end
```

---


<!-- _header: 数式微分の方針 -->


<div class="section"> 2.4 数式微分 </div>


式 (`Expr`) を入力として、式 (`Expr`) を出力する


---


<!-- _header: 式・プログラムの表現 -->

<!-- <div class="section"> 2.4 数式微分 </div> -->



式, プログラムは木構造で表現できる

$f(x) = 4x+3$ は ...

```julia
@to_graphviz 4x+3
```

![bg right h:400](img/expr0.svg)



---


<!-- _header: 数式微分の目標 -->

<div class="section"> 2.4 数式微分 </div>



<div class="columns">


<div>

<br>


<br>

#### ✅ 木に操作を頑張って行うことで

#### 導関数を表す式を構築する



</div>

| $\small{f(x) = 2x^2 + 3x + 1}$ | $\small{f'(x) = 2x + 3}$ |
| ------------------------------ | ------------------------ |
| ![h:250](img/exprf.svg)        | ![h:250](img/exprdf.svg) |


</div>

---

<!-- _header: 数式微分の目標 -->


<div class="section"> 2.4 数式微分 </div>

![h:240](img/nd-algo.png)


---

<!-- _header: Juliaでのプログラムの表現 -->


<div class="section"> 2.4 数式微分 </div>

<br>
<br>


**✅ Julia ならプログラムそのものをデータとして扱う機構が整っている！**

- `Expr` 型 ... Julia のプログラムを表現する型

```julia
julia> ex = Meta.parse("3 + 4")
:(3 + 4)

julia> dump(ex)
Expr
  head: Symbol call
  args: Array{Any}((3,))
    1: Symbol +
    2: Int64 3
    3: Int64 4

julia> eval(ex)
7
```

---




<div class="section"> 2.4 数式微分 </div>

#### ✅ Juliaなら、特別な準備なく (数学の意味での) 式をそのまま扱って微分できる



---


<!-- _header: 数式微分の簡単な実装 -->

<div class="section"> 2.4 数式微分 </div>

足し算と掛け算に関するルールを実装してみる

1. $\dfrac{d}{dx} (f(x) + g(x)) = f'(x) + g'(x)$
   
   
3. $\dfrac{d}{dx} (f(x) \cdot g(x)) = f'(x) \cdot g(x) + f(x) \cdot g'(x)$
   


---

<!-- _header: 数式微分の簡単な実装 -->

<div class="section"> 2.4 数式微分 </div>


```julia
derivative(ex::Symbol) = 1     # dx/dx = 1
derivative(ex::Int64) = 0      # 定数の微分は 0

function derivative(ex::Expr)::Expr
    op = ex.args[1]
    if op == :+     
        return Expr(:call, :+, derivative(ex.args[2]), derivative(ex.args[3])) 
    elseif op == :*                
        return Expr(
            :call,
            :+,
            Expr(:call, :*, ex.args[2], derivative(ex.args[3])),
            Expr(:call, :*, derivative(ex.args[2]), ex.args[3])
        )
    end
end
```

<div class="cite">

※ Juliaは `2 * x * x` のような式を、 `(2 * x) * x` でなく `*(2, x, x)` として表現するのでこのような式については上は正しい結果を返しません. (スペース不足)
このあたりもちゃんとやる場合をいちおう掲載しておきます: [gist](あとでリンク入れる)


</div>

---

<!-- _header: 数式微分の簡単な実装 -->

<div class="section"> 2.4 数式微分 </div>

```julia
f = :(x * x + 3) 
df = derivative(f)  # :((x * 1 + 1x) + 0)
```


```julia
x = 2
eval(df)  # 4

x = 10
eval(df) # 20
```

<!--  -->


---

<!-- _header: ⚠️ 数式微分の注意点？  -->


<div class="section"> 2.4 数式微分 </div>

<span class="dot-text">**不用意な実装**</span> だと、導関数の式が爆発してまう [1]

<div class="thm">

$\dfrac{d}{dx} (f(x) \cdot g(x)) = f'(x) \cdot g(x) + f(x) \cdot g'(x)$


</div>

... 項が二つに **「分裂」** するので、再帰的に微分していくと項が爆発的に増える


<div class="cite">

[1] よく数式微分の固有・不可避っぽい問題だ、みたいな文脈で語られるのですが、数値微分自体の問題ではないという指摘もあります。僕もそう思います。
参考: [Soeren Laue, 2019, "On the Equivalence of Automatic and Symbolic Differentiation"](https://arxiv.org/abs/1904.02990)


</div>






---

<div class="section"> 2.4 数式微分 </div>

#### ✅ Juliaなら、特別な準備なく (数学の意味での) 式をそのまま扱って微分できる



---

<div class="section"> 2.4 数式微分 </div>

#### ✅ Juliaなら、特別な準備なく **(数学の意味での)** 式をそのまま扱って微分できる



---


<!-- _header: 式の微分からアルゴリズムの微分へ -->

<div class="section"> 2.4 数式微分 </div>


<br>

#### 需要: 制御構文とかも許して柔軟な記述をしたい.


```julia
x = [1, 2, 3]
y = [2, 4, 6]

function linear_regression_error(coef)
    pred = x * coef
    error = 0
    for i in eachindex(y)
        error += (y[i] - pred[i])^2
    end
    return error
end
```


---

<!-- _header: 式の微分からアルゴリズムの微分へ -->

<div class="section"> 2.4 数式微分 </div>

### ✅ 数値微分なら中身がなんでも結果さえあれば微分できた

```julia
function numerical_derivative(f, x::Number; h=1e-8)
    return (f(x + h) - f(x)) / h
end

coef = 1
numerical_derivative(linear_regression_error, coef) # -27.999999474559445

lr = 0.01
for i in 1:100
    coef -= lr * numerical_derivative(linear_regression_error, coef)
end
```

$\leftrightarrow$ 数式微分は、中身の式の構造を見る必要がある


---

<!-- _header: 式の微分からアルゴリズムの微分へ -->


<div class="section"> 2.4 数式微分 </div>

<style>
    code {
        font-size: 0.1em;
    }
</style>

<br>

<br>

<div class="columns">

<div>

<br>

<br>

AST を見てみると...

```julia
quote
    function linear_regression_error(coef)
        pred = x * coef
        error = 0
        for i in eachindex(y)
            error += (y[i] - pred[i])^2
        end
        return error
    end
end |> dump 
```

<div class="center">

## ⇨

</div>

</div>

```
Expr
  head: Symbol block
  args: Array{Any}((2,))
    1: LineNumberNode
      line: Int64 3
      file: Symbol In[42]
    2: Expr
      head: Symbol function
      args: Array{Any}((2,))
        1: Expr
          head: Symbol call
          args: Array{Any}((2,))
            1: Symbol linear_regression_error
            2: Symbol coef
        2: Expr
          head: Symbol block
          args: Array{Any}((9,))
            1: LineNumberNode
              line: Int64 3
              file: Symbol In[42]
            2: LineNumberNode
              line: Int64 4
              file: Symbol In[42]
            3: Expr
              head: Symbol =
              args: Array{Any}((2,))
                1: Symbol pred
                2: Expr
            4: LineNumberNode
              line: Int64 5
              file: Symbol In[42]
            5: Expr
              head: Symbol =
              args: Array{Any}((2,))
                1: Symbol error
                2: Int64 0
            6: LineNumberNode
              line: Int64 6
              file: Symbol In[42]
            7: Expr
              head: Symbol for
              args: Array{Any}((2,))
                1: Expr
                2: Expr
            8: LineNumberNode
              line: Int64 9
              file: Symbol In[42]
            9: Expr
              head: Symbol return
              args: Array{Any}((1,))
                1: Symbol error
```


</div>


---

<div class="section"> 2.4 数式微分 </div>

**✅ 再代入、ループ、条件分岐 など含んだプログラムに対して、
直接変換を頑張ることで「陽に書かれた形の」導関数のプログラムを得るのは
難しいタスク**

<!-- <div class="cite">

「陽に書く」と言う言葉のニュアンスですが、例えば `grad(x) = numerical_derivative(f, x)` もまぁ陽に書けているような気もします。
ここでいう「陽に書かれた」と言うのは、もはや元の関数の情報を使わずに導関数を常に計算可能なコードとして得ることが不可能、のような意味で使っています。
例えば、 `f(x) = something(x)` に対して `grad(x) = operation(f, x)` のように定義される「導関数」を考えてみると、これは毎回 $f$ の情報にアクセスしています。
つまりこの意味では「陽に」書けていません。
一方、最初の数式微分の例であれば、一回 `derivative` 関数に通して得られた式はそれ自体独立して計算できる導関数の式になっています。 なのでこの意味では「陽に書けています」。 この辺りは若干言葉遊びのようになっていてる感もあるのですが、ニュアンスとしてはこんな感じのことを表現しようとしています。

</div> -->

---

<div class="section"> 2.4 自動微分 </div>

# **- 自動微分**

<br>

```julia
function automatic_derivative(f::Function, x::Number)::Number
    g = automatic_operation(f, x)
    return g
end
```


---

<!-- _header: 自動微分の方針 -->

<div class="section"> 2.4 自動微分 </div>

#### 数値微分と同様,
## (関数, 値) から直接、値を出力する



---

<!-- _header: 自動微分の特徴 -->

<div class="section"> 2.4 自動微分 </div>



### ✅ (入力 ⊻ 出力) が高次元でも高速に計算できる！


---

<!-- _header: 自動微分の特徴 -->

数値微分 $\cdots$ $f: \mathbb{R}^n \to \mathbb{R}$ の微分は $n$ 回の $f$ の評価が必要

⇩

## 自動微分 なら $1$ 回 + $1$ 回で可能！

<div class="cite">

※ 単に2回と書かなかった理由はこの後のスライドを参照してください 

</div>

---

<!-- _header: 自動微分の特徴 -->

### ✅ 応用で非常に有用で広く使われる

![w:200](image-7.png)  ![w:200](image-8.png) ![w:200](image-12.png)  ![w:200](image-9.png) 
![w:200](image-10.png) ![h:150](image-20.png)


---


<!-- _header: 自動微分のアイデア -->


<div class="section"> 2.4 自動微分 </div>


<div class="def">

**[自動微分のアイデア]**

連鎖律(Chaine Rule)...

$$
\frac{df}{dx} = \frac{df}{dg} \cdot \frac{dg}{dx}
$$

を使う



</div>

---


<!-- _header: 自動微分のアイデア -->

<div class="section"> 2.4 自動微分 </div>

$f(x) = 2x^2 + 3x + 1$ を例に考える

これを分解する...


$$
\begin{equation}
\begin{split}
y_1 &= x \\
y_2 &= y_1^2 \\
y_3 &= 2y_2 \\
y_4 &= 3y_1 \\
y_5 &= y_3 + y_4 \\
y_6 &= y_5 + 1 \\
\end{split}
\end{equation}
$$

としたら、 $f(x) = y_6$ とする

---

<!-- _header: 自動微分のアイデア -->

<div class="section"> 2.4 自動微分 </div>

すると...

$$
\LARGE
\dfrac{dy_6}{dx} = \color{red}{\underbracket{\dfrac{dy_6}{dy_5}}} \color{black} \cdot \dfrac{dy_5}{dx}
$$

<div class="center">


**これは行けるはず！**


</div>

---

<!-- _header: 自動微分のアイデア -->

<div class="section"> 2.4 自動微分 </div>

$\large{y_6 = y_5 + 1}$


⇨ これは $f(x) = x + 1$ の微分ができるなら極めて容易に微分できる

同様に、全ての微分を展開していくと...


$$
\large
\dfrac{\partial y_6}{\partial x}=\dfrac{\partial y_6}{\partial y_5}\left(\dfrac{\partial y_5}{\partial y_3} \dfrac{\partial y_3}{\partial y_2} \dfrac{\partial y_2}{\partial y_1}+\dfrac{\partial y_5}{\partial y_4} \dfrac{\partial y_4}{\partial y_1}\right)
$$

---

<!-- _header: 自動微分のアイデア -->

<div class="section"> 2.4 自動微分 </div>


<div class="columns">

</div>

$$
\begin{equation}
\begin{split}
y_1 &= x \\
y_2 &= y_1^2 \\
y_3 &= 2y_2 \\
y_4 &= 3y_1 \\
y_5 &= y_3 + y_4 \\
y_6 &= y_5 + 1 \\
\end{split}
\end{equation}
$$

<div class="center">

... $\large\dfrac{\partial y_i}{\partial y_j}$ ($\small i \geq  j$) **は簡単な計算！**


</div>



---

<!-- _header: 自動微分のアイデア -->

<div class="section"> 2.4 自動微分 </div>

$$
\begin{align}
\dfrac{\partial y_6}{\partial x} &= \dfrac{\partial y_6}{\partial y_5}\left(\dfrac{\partial y_5}{\partial y_3} \dfrac{\partial y_3}{\partial y_2} \dfrac{\partial y_2}{\partial y_1}+\dfrac{\partial y_5}{\partial y_4} \dfrac{\partial y_4}{\partial y_1}\right) \\ \\
&= 1 \cdot \left(1 \cdot 2 \cdot 2x + 1 \cdot 3 \right) \\ \\
&= 4x + 3
\end{align}
$$

<div class="center">

⇩

**全体が計算できた！**


</div>

---

<!-- _header: 自動微分の基本的な構造 -->


<div class="section"> 2.4 自動微分 </div>

![w:1200](img/ad.png)


---

<!-- _header: 計算グラフ -->





---


<!-- _header: 自動微分の用語 -->

Prefix たち

- Forward = Bottom Up = BU = Tangent Linear = 前進型
- Backward = Reverse = Top Down = TD = Adjoint = 後退型 = 高速自動微分


