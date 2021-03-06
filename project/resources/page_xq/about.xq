xquery version "1.0" encoding "UTF-8";
declare namespace h="http://www.w3.org/1999/xhtml";

import module namespace layout="http://kb.dk/this/app/layout" at "../../modules/layout.xqm";
declare option exist:serialize "method=xml media-type=text/html;charset=UTF-8";
declare variable $mode   := request:get-parameter("mode","about") cast as xs:string;

declare variable $coll     := request:get-parameter("c","") cast as xs:string;
let $html := doc("../html/about.html")

let $contents :=
<html xmlns="http://www.w3.org/1999/xhtml">
  {layout:head(concat("About: ",$html//h:title/text()),
  (<link rel="stylesheet" type="text/css" href="/project/resources/css/mei_to_html_public.css"/>),
  false())}
  <body class="text">
    <div id="all">
      {layout:page-head-doc($html)}
      {layout:page-menu($mode)}
      {
         for $main in $html//h:div[@id="main"]
         return $main
      }
    {layout:page-footer($mode)}
    </div>
  </body>
</html>

return $contents

