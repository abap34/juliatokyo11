---
marp: true
paginate: true
math: mathjax
theme: honwaka
---

<!-- _class: lead -->

# **2.3 式の微分から**
# **アルゴリズムの微分へ**


---


<!-- _header: アルゴリズムの表現 -->

<div class="section"> 2.3 式の微分からアルゴリズムの微分へ </div>


おさらい

- 木構造で関数を表現しようとすると、簡単なものでも木が複雑になる.
- 原因は、木で表現された数式は束縛がないこと
- 束縛ができる (中間変数が導入された) 場合にどうなるか考えてみる


---

<!-- _header: DAG による表現 -->





... あるものに名前をつけて
いくらでも参照できるようになった

$$
\begin{split}
t_1 &= x * x \\
t_2 &= t_1 * t_1 \\
\end{split}
$$

![bg right h:450](../img/intro_dag.png)


---


<!-- _header: DAG による表現 -->


**有効非巡回グラフ(DAG)**　
でのアルゴリズムの表現

# **計算グラフ**


![bg right h:550](../img/cgraph0.png)

---

<!-- _header: 計算グラフによる表現 -->


<div class="def">

**[計算グラフ]** 

計算過程をDAGで表現

$$
\Large
\begin{split}
t &= x + y \\
z &= t \times t \\
\end{split}
\ \ \leftrightarrow
$$

</div>



![bg right h:550](../img/cgraph0.png)



<div class="cite">

単に計算過程を表しただけのものを Kantrovich グラフなどと呼び、
これに偏導関数などの情報を加えたものを計算グラフと呼ぶような定義もあります.
(伊里, 久保田 (1998) に詳しく形式的な定義があります)
ただ、単に計算グラフというだけで計算過程を表現するグラフを指すという用法はかなり普及していて一般的と思われます。そのためここでもそれに従って計算過程を表現するグラフを計算グラフと呼びます.

</div>

---



