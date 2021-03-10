xquery version "1.0" encoding "UTF-8";

module  namespace  layout="http://kb.dk/this/app/layout";
declare namespace  h="http://www.w3.org/1999/xhtml";
declare namespace  m="http://www.music-encoding.org/ns/mei";

declare variable $layout:coll     := request:get-parameter("c","") cast as xs:string;

declare function layout:head($title as xs:string,
                             $additions as node()*,
                             $verovio as xs:boolean
			) as node() 
{
  let $head :=
  <head>
    <title>{$title}</title>
      
    <meta http-equiv="Content-Type" content="application/xhtml+xml;charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    
    <link rel="icon" type="image/vnd.microsoft.icon" href="favicon.ico" />
      
    <link type="text/css" 
          href="/project/resources/css/dcm.css" 
	  rel="stylesheet" />

    <link type="text/css" 
          href="/project/resources/css/collection.css" 
	  rel="stylesheet" />

   {$additions}

    <link href="/project/resources/js/jquery/css/base/jquery-ui.css" 
       rel="stylesheet" 
       type="text/css"/>

    <link href="/project/resources/js/jquery/css/style.css" 
       rel="stylesheet"  
       type="text/css"/>
      
    <link type="text/css" 
          href="/project/resources/css/delius_public.css" 
	  rel="stylesheet" />

    <script type="text/javascript" src="/project/resources/js/confirm.js">
      //
    </script>
      <!-- What's this for?
    <script type="text/javascript" src="resources/js/swap_num_type.js">
      //
    </script>-->

    <script type="text/javascript" src="/project/resources/js/checkbox.js">
      //
    </script>
      
    <script type="text/javascript" src="/project/resources/js/publishing.js">
      //
    </script>

    <script type="text/javascript" src="/project/resources/js/jquery/js/jquery-1.9.1.js">
      //
    </script>

    <script type="text/javascript" src="/project/resources/js/jquery/js/jquery-ui-1.10.3.custom.js">
      //
    </script>
    <script type="text/javascript" src="/project/resources/js/jquery/slider.js">
    //
    </script>

    <!--<script type="text/javascript" src="js/google_analytics.js"> 
    //
    </script>-->
    
    { if($verovio) then   
			<script src="http://www.verovio.org/javascript/latest/verovio-toolkit-light.js" type="text/javascript">
			//
			</script>
    else () }
    
    { if($verovio) then   
			<script type="text/javascript">
				/* Create the Verovio toolkit instance */
				var vrvToolkit = new verovio.toolkit();
			</script>
    else () }
    
    
  </head>

  return $head

};

declare function layout:page-head-doc($html as node()) as node()
{
   let $div :=
     for $t in $html//h:title
       let $tit := 
	 if($t/@id) then
	   $t/@id
	 else
	   ""
       let $sub :=
	 if($t/text()) then
	   $t/text()
	 else
	   ""
       return 
         layout:page-head($tit,$sub)
   return $div
};

declare function layout:page-head(
                        $title as xs:string,
			$subtitle as xs:string) as node()
{
  let $header :=
  <div id="header" role="banner">
    <div id="skiptocontent"><a href="#main">skip to main content</a></div>
    <div class="kb_logo">
      <a href="http://www.ox.ac.uk" class="logo" title="University of Oxford"><img
     alt="University of Oxford Logo" src="/project/resources/images/ox_brand1_pos.gif"
	 id="ox-logo-banner"
	 title="University of Oxford" /></a>
    </div>
    <h1>
    <a style="text-decoration:none;" 
       href="http://delius.music.ox.ac.uk/catalogue" 
       title="{$title} – {$subtitle}" tabindex="0">{$title}</a></h1>
    <h2><a style="text-decoration:none;" href="http://delius.music.ox.ac.uk/catalogue/" title="{$title} – {$subtitle}" tabindex="0">{$subtitle}</a></h2>
  </div>

  return $header

};

declare function layout:page-menu($mode as xs:string) as node()
{

  let $menudoc  :=
  <div id="menu" role="navigation" class="noprint"> {
  for $anchor in doc("/db/apps/mermeid/project/resources/html/menu.html")/div/a
    return 
      if(contains($anchor/@href,$mode)) then
	<a href="{$anchor/@href}" class="selected" tabindex="0">{$anchor/text()}</a>
      else
	<a href="{$anchor/@href}" class="" tabindex="0">{$anchor/text()}</a>
  } </div>
  return $menudoc

};


declare function layout:page-footer($mode as xs:string) as node()
{
  let $footer :=
  <div id="footer" role="contentinfo" style="text-align: center; height: auto; padding: 10px 20px;">
    <a href="http://www.ox.ac.uk" class="logo" title="University of Oxford" tabindex="0"><img
     alt="University of Oxford Logo" src="/project/resources/images/ox_brand1_pos.gif"
	 id="ox-logo-footer"
	 title="University of Oxford" /></a>
    2016 University of Oxford <br/> 
  <span class="creativecommons" style="font-size: .65em;">
  This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/3.0/" tabindex="0">Creative
  Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License</a>
  </span>
  </div>

  return $footer

};

