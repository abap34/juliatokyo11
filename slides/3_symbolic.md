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

✅ Julia なら `Expr`型を使えば
何もしなくても式の木構造を得られる. 

```julia
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
   
   
3. $\dfrac{d}{dx} (f(x) \cdot g(x)) = f'(x) \cdot g(x) + f(x) \cdot g'(x)$
   
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
f = :(x * x + 3) 
df = derivative(f) 
```


```julia
x = 2
eval(df)  # 4

x = 10
eval(df) # 20
```

---


<!-- _header: 数式微分の実装 -->

<div class="section"> 2.2 誤差なしの微分 ─数式微分 </div>

