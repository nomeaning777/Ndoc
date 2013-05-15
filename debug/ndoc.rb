$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require File.dirname(__FILE__)+'/../lib/ndoc'


html = Ndoc::NdocParser.new(<<AAA).to_html
= Ndoc =
NdocはMoinMoin Wiki及びPukiWikiの文法を参考にして作られたMarkup形式です。
== 文法 ==
=== 見出し ===
{{{
= 見出し1 =
== 見出し2 ==
=== 見出し3 ====
==== 見出し4 ====
===== 見出し5 =====
}}}
{{{ndoc
= 見出し1 =
== 見出し2 ==
=== 見出し3 ===
==== 見出し4 ====
===== 見出し5 =====
}}}
=== 箇条書き ===
{{{
 *要素1
 *要素2
  *要素2-1
   *要素2-1-1
   *要素2-1-2
  *要素2-2
 *要素3

 +番号付きリスト1
  +番号付きリスト1-1
  +番号付きリスト1-2
 +番号付きリスト2
  +番号付きリスト2-1
 +番号付きリスト3
 +番号付きリスト4
}}}
{{{ndoc
 *要素1
 *要素2
  *要素2-1
   *要素2-1-1
   *要素2-1-2
  *要素2-2
 *要素3

 +番号付きリスト1
  +番号付きリスト1-1
  +番号付きリスト1-2
 +番号付きリスト2
  +番号付きリスト2-1
 +番号付きリスト3
 +番号付きリスト4
}}}
=== 定義リスト ===
{{{
 HTML:: Hyper Text Markup Language
 GNU:: 
 GNU is Not Unix
}}}
{{{ndoc
 HTML:: Hyper Text Markup Language
 GNU:: 
 GNU is Not Unix
}}}
=== ソースコード ===
{{{{
{{{
abc
def
ghi
}}}
}}}}
{{{{ndoc
{{{
abc
def
ghi
}}}
}}}}

{{{{
{{{code
#include <stdio.h>
int main(){
  return 0 * printf("Hello World\\n");
}
}}}
}}}}
{{{{ndoc
{{{code
#include <stdio.h>
int main(){
  return 0 * printf("Hello World\\n");
}
}}}
}}}}

=== インライン要素 ===
 &#39;&#39;hoge&#39;&#39;:: ''hoge'' 太字で表示
 &#39;&#39;&#39;hoge&#39;&#39;&#39;:: '''hoge''' 斜体で表示
 &#96;hoge&#96;:: `hoge` 等幅で表示
 &#45;&#45;hoge&#45;&#45;:: --hoge-- 取り消し線
 &#95;&#95;hoge&#95;&#95;:: __hoge__ 下線
 &#44;&#44;hoge&#44;&#44;:: ,,hoge,, 下付き文字
 &#94;&#94;hoge&#94;&#94;:: ^^hoge^^ 上付き文字

{{{
'''''太字+斜体''斜体'''
'''斜体'''''太字''
}}}
{{{{ndoc
'''''太字+斜体''斜体'''
'''斜体'''''太字''
}}}}

=== 数式 ===
{{{
$$ x + y = z $$
インライン数式 $ x ^ 2 + y ^ 2 = 1 $
}}}
{{{ndoc
$$ x + y = z $$
インライン数式 $ x ^ 2 + y ^ 2 = 1 $
}}}
=== マクロ ===
マクロは&lt;&lt;Macro名 引数（空白区切り)&gt;&gt;という形式で用います。
{{{
改<<br>>行
}}}
{{{ndoc
改<<br>>行
}}}

AAA

puts <<AAA
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
   <link href="css/bootstrap.min.css" rel="stylesheet" media="screen">
   <link href="js/google-code-prettify/prettify.css" rel="stylesheet">
  <title>test page</title>
</head>
<style>
div.ndoc-indent{
  padding-left: 2em; 
}
ul.ndoc-indent{
  padding-left: 2em; 
}
dl.ndoc-indent{
  padding-left: 2em; 
}
ol.ndoc-indent{
  padding-left: 2em; 
}
</style>
<body>
  <div class="ndoc-indent" style="padding-left: 3px !important;">
#{html}
  </div>
<script src="http://code.jquery.com/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
<script src="js/google-code-prettify/prettify.js"></script>
 <script>prettyPrint();</script>
 <script type="text/javascript"
  src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
</body>
</html>
AAA
