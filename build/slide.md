---
marp: true
paginate: true
math: mathjax
theme: honwaka
transition: fade
---

$$
\newcommand{\argmin}{\mathop{\rm arg~min}\limits}
$$


<!-- _class: lead -->

# Juliaと歩く
# 自動微分の世界
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

<div class="section"> Introduction </div>


<br>

## ✅ Juliaのこんなところが気に入ってます！

1. 綺麗な可視化・ベンチマークライブラリ
   - Plotまわり, `@code_...` マクロ, `BenchmarkTools.jl`  たち
2. パッケージ管理ツール
   - 言語同梱で超便利 (友人間で共有するのに一苦労の言語も)
3. すぐ書ける すぐ動く
   - Jupyter のサポート, 強力な REPL
4. **速い！！**
   - 速度は正義
   - 裏が速いライブラリの「芸人」にならなくても、素直に書いてそのまま速い

---

<!-- _header: Julia を使って解かれた・書かれたレポートたち -->

<div class="section"> Introduction </div>

![h:200](anim.gif)  ![h:200](image-13.png)  ![h:200](train_drop.gif)  ![h:200](image-14.png) ![h:200](basic-norsurface.gif)  ![h:250](fitting_history.gif) ![h:200](gd1.gif)

---


<!-- _header: 今日のお話 -->



<div class="columns">


<div>

<br>

<br>
<br>
<br>



one of 興味があるもの

## **機械学習(特に深層学習)**
## **の基盤**




</div>


<div>

![](image-17.png)

<div class="center">



[:自作DLフレームワーク](https://github.com/abap34/JITrench.jl)


</div>


</div>






</div>


---


<!-- _header: 今日のお話 -->


<div class="section"> Introduction </div>

one of 深層学習の基盤

# **自動微分**

<br>

について話します.


---

<!-- _header: 今日話すこと -->

<div class="section"> Introduction </div>

## こんなことがありませんか？

1. 深層学習フレームワークを使っているけど、あまり中身がわかっていない.
2. 微分を求めたいことがあって既存のライブラリを使っているけど、
どの場面でどれを使うのが適切かわからない
3. 自分の計算ルーチンに微分の計算を組み込みたいけどやり方がわからない
4. え、自動微分ってただ計算するだけじゃないの？何がおもしろいの？

---

<!-- _header: 今日話すこと -->

<div class="section"> Introduction </div>

<br>

<br>


<div class="proof">

**[メインテーマ]**

- 自動で微分を求めることのモチベーション
- 自動で微分を求めるアルゴリズムたちの紹介と実装
- 一般的な自動微分の実装
- 自動微分の先進的な研究 (Julia まわりを中心に)
- 微分ライブラリの紹介



</div>


<div style="font-size: 0.8em;">

こんなワードが出てきます :  
勾配降下法, 数値微分, 数式微分, 自動微分, 誤差評価, 深層学習フレームワーク, Define and/by Run
計算グラフ, Wengert List, Source Code Transformation(SCT), SSA形式

</div>  




---

<!-- _header: おしながき -->

<div class="section"> Introduction </div>

<br>

<div class="columns">

<div>

### [1] 微分と連続最適化
1.1 微分のおさらい
1.2 勾配降下法
1.3 勾配降下法と機械学習

### [2] 自動で微分
2.1 微分の近似─数値微分 
2.2 誤差なしの微分 ─数式微分
2.3 式の微分からアルゴリズムの微分へ 
2.4 自動微分とトレース
2.5 自動微分とソースコード変換

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
### [6] 参考になる文献



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

## 2.1 微分の近似─数値微分
## 2.2 誤差なしの微分 ─数式微分
## 2.3 式の微分からアルゴリズムの微分へ
## 2.4 自動微分とトレース
## 2.5 自動微分とソースコード変換




---

<div class="section"> 2.2 数値微分 </div>

# **2.1 微分の近似─数値微分**

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


### 微分の定義  

<br>

$$
\lim_{h \to 0} \frac{f(x+h) - f(x)}{h}
$$ 

### をそのまま近似する

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




## ✅ 実装が極めて容易
## ✅ $\ \Large{f}$ が <span class="dot-text">なんでも</span> 計算可能.




---

<!-- _header: 数値微分のメリット ~ 実装が容易 -->

<div class="section"> 2.2 数値微分 </div>

### これだけで完了


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

<br>

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




```julia
function numerical_derivative(f, x; h=1e-8)
    g = (f(x+h) - f(x)) / h
    return g
end
```


**$f$ がどんなに訳のわからない演算でも**
**$f(x+h)$ さえ $f(x)$ が計算できればOK**

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

<!-- _header: 自動微分の勉強で参考になる文献-->

<style scoped>
  {
    font-size: 0.8em;
  }
</style>

<br>


1.  久保田光一, 伊里正夫 「アルゴリズムの自動微分と応用」 コロナ社 (1998)
    1. 自動微分そのものついて扱ったおそらく唯一の和書です.　詳しいです.
    2. 形式的な定義から、計算グラフの縮小のアルゴリズムや実装例と基礎から実用まで触れられています.
    3. サンプルコードは、FORTRAN, (昔の) C++ です. 😐
2. 斉藤康毅 「ゼロから作るDeep Learning ③」 O'Reilly Japan (2020)
    1. トレースベースの Reverse AD を Python で実装します. 
    2. Step by step で丁寧に進んでいくので、とてもおすすめです.
    3. 自動微分自体について扱った本ではないため、その辺りの説明は若干手薄かもしれません.
3. Baydin, A. G., Pearlmutter, B. A., Radul, A. A., & Siskind, J. M. (2015). Automatic differentiation in machine learning: A survey. ArXiv. /abs/1502.05767
    1. 機械学習 x AD のサーベイですが、機械学習に限らず AD の歴史やトピックを広く取り上げてます.
    2. 少し内容が古くなっているかもしれません.
4. [Differentiation for Hackers](https://github.com/MikeInnes/diff-zoo) 
   1. Flux.jl  や Zygote.jl の開発をしている Mike J Innes さんが書いた自動微分の解説です。 Juliaで動かしながら勉強できます. おすすめです.
5. Innes, M. (2018). Don't Unroll Adjoint: Differentiating SSA-Form Programs. ArXiv. /abs/1810.07951
   1. Zygote.jl の論文です. かなりわかりやすいです.
6. Gebremedhin, A. H., & Walther, A. (2019). An introduction to algorithmic differentiation. Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery, 10(1), e1334. https://doi.org/10.1002/widm.1334
   1. 実装のパラダイムやCheckpoint, 並列化などかなり広く触れられています
7. [Zygote.jl のドキュメントの用語集](https://fluxml.ai/Zygote.jl/stable/glossary/)
   1. 自動微分は必要になった応用の人がやったり、コンパイラの人がやったり、数学の人がやったりで用語が乱立しまくっているのでこちらを参照して整理すると良いです
   2. 僕の知る限り、 (若干のニュアンスがあるかもしれませんが) Reverse AD の別表現として以下があります.
   Backward Mode AD = Reverse Mode AD = Fast Differentiation  = Adjoint Differentiation + その訳語たち, 微妙な表記揺れたち
8. [JuliaDiff](https://juliadiff.org/)
   1. Julia での微分についてまとまっています.
9.  [Chainer のソースコード](https://github.com/chainer)
    1. Chainer は Python製の深層学習フレームワークですが、既存の巨大フレームワークと比較すると、裏も Pythonでとても読みやすいです.
    2. 気になる実装があったら当たるのがおすすめです. 議論もたくさん残っているのでそれを巡回するだけでとても勉強になります.

    