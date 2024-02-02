---
marp: true
paginate: true
math: mathjax
theme: honwaka
---

<!-- _header: 自己紹介-->

<br>
<br>

<div class="columns">

<div>


東京工業大学
情報理工学院 情報工学系 B2 


**趣味**
- :robot: 機械学習
- :gear: 個人開発
- :baseball: 野球をする/みる
- 🍗 大岡山の焼き鳥屋に行く

</div>


<div>



![h:320](../img/abap34.png)



![h:30](../img/github.png) [@abap34](https://github.com/abap34) ![h:30](../img/x.png)  [@abap34](https://twitter.com/abap34) 
![h:30](../img/web.png)  https://abap34.com



</div>


</div>

---

<!-- _header: 自己紹介 -->

<div class="section"> Introduction </div>


<br>

## ✅ Juliaのこんなところが気に入ってます！

1. 綺麗な可視化・ベンチマークライブラリ
2. パッケージ管理ツール
3. すぐ書ける すぐ動く
4. **速い！！**

<!-- 

1.  Plotまわり, `@code_...` マクロ, `BenchmarkTools.jl`  たち
2.  言語同梱で便利だし野良パッケージを簡単に作れるのもいい
3.  Jupyter のサポート, 強力な REPL
4.  裏が速いライブラリの「芸人」にならなくても、素直に書いてそのまま速い

-->


---

<!-- _header: Julia を使って解かれた・書かれたレポートたち -->

<div class="section"> Introduction </div>

![h:200](../img/anim.gif)  ![h:200](../img/report1.png)  ![h:200](../img/train_drop.gif)  ![h:200](../img/report2.png) ![h:200](../img/basic-norsurface.gif)  ![h:250](../img/fitting_history.gif) ![h:200](../img/sort.png)

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

![bg right:63% h:450](../img/tangent.gif)




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

## 実は...

- 自動微分は奥が深くて面白い！
- 状況に応じて適切なアルゴリズムを選ぶことで、幸せになれる
- Julia を使うことで簡単に、そして拡張性の高い自動微分エコシステムに
乗っかることができる！


---

<!-- _header: おしながき -->

<div class="section"> Introduction </div>

<br>

<br>


<div class="columns">

<div>

### [1] 微分と連続最適化
1.1 微分のおさらい
1.2 勾配降下法
1.3 勾配降下法と機械学習

### [2] 自動で微分
2.2 数式微分 ─式の表現と微分
2.3 自動微分 ─式からアルゴリズムへ 
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
### [6] 付録


</div>

</div>


---

<!-- _header: 全体の流れ -->

<div class="section"> Introduction </div>

<br>


1. 微分を求めることでなにが嬉しくなるのか, なぜ今自動微分が必要なのか理解する

   <div style="text-align: center;">
   ⇩
   
   </div>


2. いろいろな微分をする手法のメリット・デメリットを理解する
    
      <div style="text-align: center;">
      
      ⇩
      
      </div>

3. Julia でそれぞれを利用 / 拡張する方法を理解する


---




<!-- _header: 全体の流れ -->

<div class="section"> Introduction </div>

<br>


**1. 微分を求めることでなにが嬉しくなるのか, なぜ今微分が必要なのか理解する**

<div class="gray">

<div style="text-align: center;">

⇩

</div>

3. いろいろな微分をする手法のメリット・デメリットを理解する

<div style="text-align: center;">

⇩

</div>

4. Julia でそれぞれを利用 / 拡張する方法を理解する
   
</div>


---