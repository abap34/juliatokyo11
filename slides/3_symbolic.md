---
marp: true
paginate: true
math: mathjax
theme: honwaka
---


# **2.1 誤差なしの微分 ─数式微分**

<br>

```julia
function symbolic_derivative(f::Function)::Function
    g = symbolic_operation(f)
    return g
end
```


---

<!-- _header: 数式微分のモチベーション -->

### 数値微分で発生していた打ち切り誤差を発生させずに微分の操作を行いたい. 



---

<!-- _header: 数式微分のアイデア -->

<!-- <div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>  -->

✅ 式は木構造として
計算機上で表現できる.

<br>


$\Large{2x^2 + 3x + 1}  \Rightarrow$

![bg right:60% h:500](../img/exprf.svg)


---


<!-- _header: 数式微分のアイデア -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

<br>

この木をもとに導関数を表現する木を得たい！


![center](../img/symbolic_algo_simple.png)


---



<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

<!-- _header: 数式微分のアイデア -->

![](../img/symbolic_algo.png)


---





<!-- _header: `Expr` 型 -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


<br>
<br>

✅ Julia なら 簡単に式の木構造による表現を得られる. 

```
julia> f = :(4x + 3)   # or Meta.parse("4x + 3")
:(4x + 3)

julia> dump(f)
Expr
  head: Symbol call
  args: Array{Any}((3,))
    1: Symbol +
    2: Expr
      head: Symbol call
      args: Array{Any}((3,))
        1: Symbol *
        2: Int64 4
        3: Symbol x
    3: Int64 3
```



---

<!-- _header: `Expr` 型 -->

`Expr` 型の可視化
─ 構造が保持されてる

![bg right:60% h:750](../img/plotdemo.png)

---

<!-- _header: 数式微分の実装 -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

微分の公式を実装していけばよい.

例) 足し算と掛け算のルール

1. $\dfrac{d}{dx} (f(x) + g(x)) = f'(x) + g'(x)$
   
   
2. $\dfrac{d}{dx} (f(x) \cdot g(x)) = f'(x) \cdot g(x) + f(x) \cdot g'(x)$
   
---

<!-- _header: 数式微分の実装 -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


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

※ Juliaは `2 * x * x` のような式を、 `(2 * x) * x` でなく `*(2, x, x)` として表現するのでこのような式については上は正しい結果を返しません. (スペースが足りませんでした)
このあたりもちゃんとやるやつは付録のソースコードを見てください. 基本的には二項演算の合成とみて順にやっていくだけで良いです。 

---


<!-- _header: 数式微分の実装 -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

例) $f(x) = x^2 + 3$ の導関数 $f'(x) = 2x$ を求めて $x = 2, 10$ での微分係数を計算

```julia
julia> f = :(x * x + 3)
:(x * x + 3)

julia> df = derivative(f)
:((x * 1 + 1x) + 0)

julia> x = 2; eval(df)
4

julia> x = 10; eval(df)
20
```

---


<!-- _header: ⚠️ 数式微分の改良 ~ 複雑な表現  -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


`df = ((x * 1 + 1x) + 0)` ... `2x` にはなっているが冗長？


<!-- <div class="cite">

[1] よく数式微分の固有・不可避っぽい問題だ、みたいな文脈で語られるのですが、数値微分自体の問題ではないという指摘もあります。僕もそう思います。
参考: Laue, S. (2019). On the Equivalence of Automatic and Symbolic Differentiation. ArXiv. /abs/1904.02990


</div> -->


---

<style scoped>
  code {
    font-size: 0.8em;  
  }

  .container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    font-size: 0.9em;
  }

    .container > .left {
      width: 40%;
    }

    .container > .right {
      width: 60%;
    }


</style>

<!-- _header: 簡約化  -->
<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

<br>


<div class="container">
<div class="left">
    
    
### 自明な式の簡約を行ってみる

- 足し算の引数から `0` を除く.
- 掛け算の引数から `1` を除く.

</div>

<div class="right">

```julia
function add(args)
    args = filter(x->x != 0, args)
    if length(args) == 0
        return 0
    elseif length(args) == 1
        return args[1]
    else
        return Expr(:call, :+, args...)
    end
end
```

</div>



---


<!-- _header: 簡約化  -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


<div class="columns">


<div>

<br>
<br>
<br>

- 掛け算の引数から `1` を取り除く.


</div>


<div>

```julia
function mul(args)
    args = filter(x->x != 1, args)
    if length(args) == 0
        return 1
    elseif length(args) == 1
        return args[1]
    else
        return Expr(:call, :*, args...)
    end
end
```


</div>


</div>


---

<!-- _header: 簡約化  -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


<br>


<br>



数式微分 + 自明な簡約

```julia
derivative(ex::Symbol) = 1
derivative(ex::Int64) = 0

function derivative(ex::Expr)
    op = ex.args[1]
    if op == :+
        return add([derivative(ex.args[2]), derivative(ex.args[3])])
    elseif op == :*
        return add([
            mul([ex.args[2], derivative(ex.args[3])]),
            mul([derivative(ex.args[2]), ex.args[3]])
        ])
    end
end
```

---


<!-- _header: 簡約化  -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

✅　簡単な式を得られた

```julia
julia> derivative(:(x * x + 3))
:(x + x)
```

⇨ ではこれでうまくいく？

```julia
julia> derivative(:((1 + x)  / (2 * x^2)))
:((2 * x ^ 2 - (1 + x) * (2 * (2x))) / (2 * x ^ 2) ^ 2)
```

<br>

$= \dfrac{\left(2 \cdot x^{2} - \left(1 + x\right) \cdot 2 \cdot 2 \cdot x\right)}{\left(2 \cdot x^{2}\right)^{2}} \color{gray}{\ = -\dfrac{x + 2}{2x^3}}$ 🧐🧐🧐




---

<!-- _header: 式の表現法を考える -->


```julia
julia> t1 = :(x * x)
julia> t2 = :($t1 * $t1)
julia> f = :($t2 * $t2)
:(((x * x) * (x * x)) * ((x * x) * (x * x)))
```


という $f$ は、木で表現すると...


![bg right h:300](../img/naive-tree-expr.svg)

---

<!-- _header: 式の表現法を考える -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

:question: 単純な関数が、なぜこんなに複雑になってしまったのか？

⇨ (木構造で表す) 式には、**束縛がない** ので、共通のものを参照できない.


---

<!-- _header: 式からアルゴリズムへ、木からDAGへ-->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


<div style="text-align: center;">

✅ 式は束縛がないとても制限されたプログラム.


⇩

これを許したらどうなる？

</div>


---


<!-- _header: 式からアルゴリズムへ、木からDAGへ-->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


$$
f(x) = x \cdot x \cdot x \cdot x \cdot x \cdot x \cdot x \cdot x
$$

<div style="text-align: center;">

⇩

</div>

$$
\begin{aligned}
t_1 &= x \cdot x \\
t_2 &= t_1 \cdot t_1 \\
y &= t_2 \cdot t_2 \\
\end{aligned}
$$


これの表現は？ ⇨ 自動微分へ

<div class="cite">

ヒューリスティックにやってそれなりに簡単な式を得られれば実用的には大丈夫なので与太話になりますが、簡約化を頑張れば最もシンプルな式を得られるか考えてみます。
簡単さの定義にもよるかもしれませんが、$\forall x$ で $f(x) = 0$ な $f$ は $f(x) = 0$ と簡約化されるべきでしょう。
ところが、$f$ が四則演算と $exp, sin, abs$ と有理数, $\pi, \ln{2}$ で作れる式のとき、$\forall x, f(x) = 0$ か判定する問題は決定不能であることが知られています。([Richardson's theorem](https://en.wikipedia.org/wiki/Richardson%27s_theorem))
**したがって、一般の式を入力として、最も簡単な式を出力するようなアルゴリズムは存在しないとわかります。** 

</div>

---
