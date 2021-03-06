$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require File.dirname(__FILE__)+'/../lib/ndoc'

filename = ARGV[0] || File.dirname(__FILE__) + '/document.ndoc'

html = Ndoc::NdocParser.new(File.read(filename)).to_html
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
div.ndoc-inside{
  padding: 6px; border-radius: 5px; margin-left:4px; margin-right: 4px; border: solid 1px #999;
  background-color: #F5F5F5;
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
