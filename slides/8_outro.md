---
marp: true
paginate: true
math: mathjax
theme: honwaka
---

# おまけ


# **数値微分**

<br>

```julia
function numerical_derivative(f::Function, x::Number)::Number
    g = numerical_operation(f, x)
    return g
end
```

---



<!-- _header: 数値微分のアイデア -->

<div class="section"> 数値微分 </div>


### 微分の定義  

<br>

$$
\lim_{h \to 0} \frac{f(x+h) - f(x)}{h}
$$ 

### をそのまま近似する

---


<!-- _header: 数値微分の実装 -->


<div class="section"> 数値微分 </div>


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

<!-- _header: 数値微分のデメリット -->

<div class="section"> 数値微分 </div>




### 1. 打ち切り誤差が生じる
### 2. 桁落ちも起こる
### 3. 計算コストが高い

---

<!-- _header: 数値微分の誤差 ~ 打ち切り誤差 -->

<div class="section"> 数値微分 </div>

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


<div class="section"> 数値微分 </div>


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

<div class="section"> 数値微分 </div>

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

![bg right h:400](../img/numd.png)



---

<!-- _header: 丸め誤差と打ち切り誤差のトレードオフ -->



<div class="section"> 数値微分 </div>



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


<div class="section"> 数値微分 </div>

### 誤差への対応

1. 打ち切り誤差　⇨ 計算式の変更
2. 桁落ち ⇨ $h$ の調整？

---

<!-- _header: 数値微分の改良 ~ 打ち切り誤差の改善   -->


<div class="section"> 数値微分 </div>

### 1. 打ち切り誤差への対応

微分の (一般的な) 定義をそのまま計算する方法:

$$
f'(x) \approx  \frac{f(x+h) - f(x)}{h}
$$

は **前進差分** と呼ばれる

---


<!-- _header: 数値微分の改良 ~ 打ち切り誤差の改善   -->

<div class="section"> 数値微分 </div>



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

<div class="section"> 数値微分 </div>

実はこれの方が精度がよい！

<div class="thm">

**[定理3. 中心差分の誤差]**

$$
f'(x) - \frac{f(x+h) - f(x-h)}{2h} = O(h^2)
$$

</div>

同じようにテイラー展開をするとわかる
また、簡単な計算で一般の $n$ について $n$ 点評価で $O(h^n)$ の近似式を得られる

<div class="cite">

中心差分と同様に $x$ から左右に $\frac{n}{2}$ 個ずつ点とってこれらの評価の重みつき和を考えてみます。
すると、テイラー展開の各項を足し合わせて $f'(x)$ 以外の係数を $0$ にすることを考えることで公比が各列 $-\frac{n}{2}, -\frac{n-1}{2}, \cdots, \frac{n}{2}$ で初項 $1$ のヴァンデルモンド行列を $A$ として 
$Ax = e_2$ を満たす $x$ を 各成分 $h$ で割ったのが求めたい重みとわかります. あとはこれの重み付き和をとればいいです. 同様にして $k$ 階微分の近似式も得られます.

</div>

 
---


<!-- _header: 数値微分の改良 ~ 桁落ちへの対応  -->

<div class="section"> 数値微分 </div>

### 2. 桁落ちへの対応

Q. 打ち切り誤差と丸め誤差のトレードオフで $h$ を小さくすればいいというものじゃないことはわかった。じゃあ、最適な $h$ は見積もれる？

A. 最適な $h$ は $f$ の $n$ 階微分の大きさに依存するから簡単ではない. 

例) 中心差分 $\dfrac{f(x+h) - f(x-h)}{h}$ は $h_{best} \approx \ \sqrt[3]{\dfrac{\mathstrut 3 \sqrt{2} 
\ \varepsilon}{|f'''(x)|}}$  くらい ? 


#### ⇨ $f'(x)$ がわからないのに $f'''(x)$ を使った式を使うのは現実的でない. 
しょうがないので $h = \left( \frac{(n+1)!}{\sqrt{n} f(x)} \varepsilon \right)^{\frac{1}{n+1}}$  に線を引いてみると...



---

[導出?]

$n$ 点評価で $O(h^n)$ の近似をしたときの誤差の期待値を最小化する.
前のページで導出した $\boldsymbol{x}$ を使うと $f_{estimate}(x) = \frac{1}{h}  \sum_i^n x_i \hat {f}(x_i)$ 
($\hat{f}$ は計算誤差を含む $f$ の計算結果.) 
ここで各 $\hat{f}(x_i)$ の計算結果が $\varepsilon$ の誤差を生むとすると
分子の誤差の期待値はランダムウォークの期待値を考えて $\sqrt{n} \varepsilon$. 
すると $f'(x)$ との誤差の期待値 $E(h)$ は
$E(h) \approx \sqrt{n} \varepsilon + \dfrac{n f^{(n+1)}(x)}{(n+1)!} h^{n-1}$ ( $\because$ テイラーの定理)


これの最小値を計算すると $h = \left(\dfrac{(n+1)!\varepsilon}{\sqrt{n}f^{(n+1)}(x)}\right)^{\frac{1}{n+1}}$. 


<div class="cite">



</div>


---


<div class="section"> 数値微分 </div>


![h:500](../img/numd2.png)

何回微分しても大きさが変わらないウルトラお行儀が良い関数.

---

<div class="section"> 数値微分 </div>

<br>
<br>

![h:530](../img/numd3.png)

🤨　(微分するたび $5$ が外に出る)



---

<div class="section"> 数値微分 </div>

### デメリット3. 計算コストが高い

---

<!-- _header: 多変数関数への拡張 -->

<div class="section"> 数値微分 </div>

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


#### ⇨ $f$ を $n$ 回評価する必要がある.

---


<!-- _header: 多変数関数への拡張  -->

<div class="section"> 数値微分 </div>

<br>

<br>

##### ✅ 応用では $f$ が重く, $n$ が大きくなりがち ⇨ $n$ 回評価は高コスト



![h:400 center](../img/param-scatter.png)


<div class="cite">
https://www.researchgate.net/figure/Number-of-parameters-ie-weights-in-recent-landmark-neural-networks1-2-31-43_fig1_349044689 より引用
</div>

---

<!-- _header: 結論  -->

<div class="section"> 数値微分 </div>

結論: **数値微分を機械学習などで使うのは難しそう.**

一方、 

- $f$ に特別な準備なくなんでも計算できる 
- 実装が容易でバグが混入しにくい

ため、他の微分アルゴリズムのテストに使われることが多い.





---

<!-- _header: 自動微分の勉強で参考になる文献-->

<style scoped>
  {
    font-size: 0.7em;
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
8. [JuliaDiff](https://juliadiff.org/)
   1. Julia での微分についてまとまっています.
9.  [Chainer のソースコード](https://github.com/chainer)
    1. Chainer は Python製の深層学習フレームワークですが、既存の巨大フレームワークと比較すると、裏も Pythonでとても読みやすいです.
    2. 気になる実装があったら当たるのがおすすめです. 議論もたくさん残っているのでそれを巡回するだけでとても勉強になります.
