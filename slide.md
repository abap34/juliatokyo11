
---














---

<!-- _header: 自動微分の勉強で参考になる文献-->

<style scoped>
  {
    font-size: 0.8em;
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
   2. 僕の知る限り、 (若干のニュアンスがあるかもしれませんが) Reverse AD の別表現として以下があります.
   Backward Mode AD = Reverse Mode AD = Fast Differentiation  = Adjoint Differentiation + その訳語たち, 微妙な表記揺れたち
8. [JuliaDiff](https://juliadiff.org/)
   1. Julia での微分についてまとまっています.
9.  [Chainer のソースコード](https://github.com/chainer)
    1. Chainer は Python製の深層学習フレームワークですが、既存の巨大フレームワークと比較すると、裏も Pythonでとても読みやすいです.
    2. 気になる実装があったら当たるのがおすすめです. 議論もたくさん残っているのでそれを巡回するだけでとても勉強になります.

    