---
marp: true
paginate: true
math: mathjax
theme: honwaka
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

![bg right h:400](../img/abap34.png)


---

<!-- _header: 自己紹介 -->


<!-- ![bg right h:600](img/lang.png) -->

## ✅ Juliaをこんなことに使ってます！

1. データ分析
2. 機械学習や数学の勉強・調べ物
3. 競プロ


![bg right h:300](../img/jl_demo.gif)



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

![h:200](../img/anim.gif)  ![h:200](../img/image-13.png)  ![h:200](../img/train_drop.gif)  ![h:200](../img/image-14.png) ![h:200](../img/basic-norsurface.gif)  ![h:250](../img/fitting_history.gif) ![h:200](../img/gd1.gif)

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

![](../img/jitrench.png)

<div class="center">



https://github.com/abap34/JITrench.jl

</div>


</div>


</div>


---


<!-- _header: 今日のお話 -->




one of 深層学習の基盤

# **自動微分** 

![bg right:63% h:450](../img/plt1.png)




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