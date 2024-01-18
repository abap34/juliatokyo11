---
marp: true
paginate: true
math: mathjax
theme: honwaka
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