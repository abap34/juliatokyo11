---
marp: true
paginate: true
math: mathjax
theme: honwaka
---

<!-- _class: lead -->

# [3] Juila に微分させる

<br>

---

## 3.1 FiniteDiff.jl/FiniteDifferences.jl

---

<!-- _header: FiniteDiff.jl/FiniteDifferences.jl -->

<div class="section"> FiniteDiff.jl/FiniteDifferences.jl  </div>

- どちらも数値微分のパッケージ
- 概ね機能は同じだが、スパースなヤコビ行列を求めたいときやメモリのアロケーションを気にしたいときは FIniteDiff.jl を使うといいかもしれない
- 詳しい比較は [https://github.com/JuliaDiff/FiniteDifferences.jl](https://github.com/JuliaDiff/FiniteDiff.jl?tab=readme-ov-file#finitediffjl-vs-finitedifferencesjl)

```julia
julia> using FiniteDifferences

julia> central_fdm(5, 1)(sin, π / 3)
0.4999999999999536
```

<div class="cite">

数値微分時代については　「付録: 数値微分」　を参照してください

</div>

---


## ForwardDiff.jl


---

<!-- _header: ForwardDiff.jl -->

- Forward-Mode の自動微分を実装したパッケージ
- 小規模な関数の微分を行う場合は高速なことが多い

```julia
julia> using ForwardDiff

julia> f(x) = x^2 + 4x 
f (generic function with 1 method)

julia> df(x) = ForwardDiff.derivative(f, x) # 2x + 4
df (generic function with 1 method)

julia> df(2)
8
```

---



## Zygote.jl 

---


<!-- _header: Zygote.jl -->


<div class="section"> Zygote.jl  </div>


- コンパイラと深く関わったレベルで自動微分をやっていこう！

<div style="text-align: center;">

⇩

Zygote.jl, Enzyme, Swift for Tensorflow etc...


![h:50](../img/zygote.png) ![h:50](../img/enzyme.png) ![h:50](../img/swift.png) ![h:50](image-1.png)


</div>




---

<!-- _header: Zygote.jl -->



<div class="columns">

<div>

<br>
<br>
<br>


**✅ ソースコード変換**ベースのAD 
**✅ JuliaのコードをSSA形式のIRに変換** して導関数を計算するコード
(Adjoint Code) を生成

</div>


<div>

```julia
julia> f(x) = 3x^2
f (generic function with 1 method)

julia> Zygote.@code_ir f(0.)
1: (%1, %2)
  %3 = Main.:^
  %4 = Core.apply_type(Base.Val, 2)
  %5 = (%4)()
  %6 = Base.literal_pow(%3, %2, %5)
  %7 = 3 * %6
  return %7
```


</div>


</div>

---

<!-- _header: Zygote.jl --> 

- Julia のコンパイラと連携・最適なコードを生成
- SSA形式からの最適化 ... という方向性はJuliaに限らない 
 ⇨ Enzyme, Diffractor.jl...

---

<!-- _header: その他のパッケージ -->

- Enzyme ![h:100](../img/enzyme.png)
  - LLVMのレイヤーで自動微分を行う.
  - Julia をはじめ、LLVMを中間表現に使っている色々な言語で動作させられる
  
- Diffractor.jl ![h:100](image.png)
  - より進んで Juliaの型推論を活用し効率的なコードを生成を目指す
  - まだ experimental だが Keno さんが開発中で期待大！

---

