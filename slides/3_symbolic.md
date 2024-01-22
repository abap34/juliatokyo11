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



<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

<!-- _header: 数式微分のアイデア -->

![](../img/symbolic_algo.png)

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
このあたりもちゃんとやるやつは付録のソースコードを見てください. 

---


<!-- _header: 数式微分の実装 -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

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
</style>

<!-- _header: 簡約化  -->



<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

自明な式の簡約を行ってみる.

- 足し算の引数から `0` を取り除く.


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

---


<!-- _header: 簡約化  -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

- 掛け算の引数から `1` を取り除く.

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
julia> derivative3(:(x * x + 3))
:(x + x)
```

---

<!-- _header: 式の膨張 ? -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>



---

<!-- _header: ⚠️ 数式微分の注意点？  -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>





---

<!-- _header: ⚠️ 数式微分の注意点？  -->


<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


数式微分の <span class="dot-text">**不用意な実装**</span> は導関数の式が爆発してまう 


<div class="thm">

$\dfrac{d}{dx} (f(x) \cdot g(x)) = f'(x) \cdot g(x) + f(x) \cdot g'(x)$

</div>

... 項が二つに **「分裂」** するので、再帰的に微分していくと項が爆発的に増える.


---

<!-- _header: ⚠️ 数式微分の注意点？  -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>


<span class="dot-text">**不用意な実装**</span> では確かにうまく行かなさそう.






