---
marp: true
paginate: true
math: mathjax
theme: honwaka
---

<!-- _class: lead -->

# [2] 自動で微分
<br>

## 2.1 自動微分の枠組み
## 2.2 数式微分 ─式の表現と微分と連鎖律
## 2.3 自動微分 ─式からアルゴリズムへ 
## 2.4 自動微分とトレース
## 2.5 自動微分とソースコード変換

---


# **2.1 自動微分の枠組み**

<br>



---

<!-- _header: 自動微分の枠組み -->

<div class="section"> 2.1 自動微分の枠組み </div>

**✅ 計算機上で微分するためには、計算機上で関数を表現しないといけない.**


---

<!-- _header: 「自動微分」 -->

<br>
<br>


<div class="section"> 2.1 自動微分の枠組み </div>

<div class="def">

**[定義. 自動微分]**

(数学的な関数を表すように定義された) <span class="dot-text">計算機上のアルゴリズム</span> を入力として、

その関数の任意の点の微分係数を無限精度の計算モデル上で正確に計算できる 

<span class="dot-text">計算機上のアルゴリズム</span> を出力するアルゴリズムを 

「**自動微分(Auto Differentiation, Algorithmic Differentiation)**」

と呼ぶ。

</div>


---

<!-- _header: 自動微分の枠組み -->


![bg right h:500](../img/autodiff_intro.png)

計算機は、
- 計算機上の表現をもらって
- 計算機上の表現を返す.


---

<!-- _header: 自動微分 -->



![bg h:460](../img/autodiff_framework_simple.png)

---

<!-- _header: 自動微分 -->

<div class="section"> 2.1 自動微分の枠組み </div>

<div class="thm">

<!-- **[例: 線形回帰]**

気温とアイスの売り上げ本数のデータ ($\mathcal{D} = \{ (25, 1000), \cdots, (35, 2000) \}$)　
があるので、線形回帰で売り上げを予測したい。
つまり $f(x; a, b) = ax + b$ として、

$$
L(a, b) = \sum_{(x, y) \in \mathcal{D}} (y - f(x; a, b))^2
$$

を小さくする $a, b$ を求める。 これを勾配降下法でやりたいので、
$L$ の各点の勾配を計算するアルゴリズムを自動微分で得たい. -->


**[例: 二次関数の微分]**

:dog: < $f(x) = x^2$ の微分がわからないので、自動微分で計算したい

</div>

---

<!-- _header: 例: 二次関数の微分 -->

![bg right h:350](../img/autodiff_framework_simple.png)

1. 関数 $\rightarrow$ アルゴリズム 
by プログラマー
    
```julia
function f(x::InfinityPrecisionFloat)
    return x^2
end
```



---

<!-- _header: 例: 二次関数の微分 -->

![bg right h:350](../img/autodiff_framework_simple.png)

2. アルゴリズム $\rightarrow$ アルゴリズム
by 自動微分ライブラリ

```julia
using AutoDiffLib # ※ 存在しないです！

function f(x::InfinityPrecisionFloat)
    return x^2
end

df = AutoDiffLib.differentiate(f)

df(2.0) # 4.0
df(3.0) # 6.0
```

---

<!-- _header: 例: 二次関数の微分 -->


<div class="thm">

**[例: 二次関数の微分]**

:dog: < $f(x) = x^2$ の微分がわからないので、自動微分で計算したい

</div>

✅ プログラムに直したプログラマがミスっていなければ
✅ 自動微分ライブラリがバグっていなければ

正しい微分係数を計算できるアルゴリズムを入手できた

---

<!-- _header: 自動微分の枠組み -->

## で、実際に
## どうやって微分する？


⇩



## **自動微分の実装**へ


![bg right h:350](../img/autodiff_framework_simple.png)


---