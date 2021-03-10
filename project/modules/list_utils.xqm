xquery version "1.0" encoding "UTF-8";

module namespace  app="http://kb.dk/this/listapp";
import module namespace config="https://github.com/edirom/mermeid/config" at "/db/apps/mermeid/modules/config.xqm";

declare namespace file="http://exist-db.org/xquery/file";
declare namespace fn="http://www.w3.org/2005/xpath-functions";
declare namespace ft="http://exist-db.org/xquery/lucene";
declare namespace ht="http://exist-db.org/xquery/httpclient";
declare namespace m="http://www.music-encoding.org/ns/mei";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace xl="http://www.w3.org/1999/xlink";
declare namespace xdb="http://exist-db.org/xquery/xmldb";


declare function app:options() as node()*
{ 
let $options:= 
  (
  <option value="">All documents</option>,
  <option value="published">Published</option>,
  <option value="modified">Modified</option>,
  <option value="unpublished">Unpublished</option>)

  return $options
};



    declare function app:get-publication-reference($doc as node() )  as node()* 
    {
      let $doc-name:=util:document-name($doc)
      let $color_style := 
	if(doc-available(concat($config:data-public-root,'/',$doc-name))) then
	  (
	    let $dcmtime := xs:dateTime(xdb:last-modified($config:data-root, $doc-name))
	    let $pubtime := xs:dateTime(xdb:last-modified($config:data-public-root, $doc-name))
	    return
	      if($dcmtime lt $pubtime) then
		"publishedIsGreen"
	      else
		"pendingIsYellow"
           )
         else
	   "unpublishedIsRed"

      let $form:=
      <form id="formsourcediv{$doc-name}" action="" method="post" style="display:inline;">
      
	<div id="sourcediv{$doc-name}"
             style="display:inline;">
		
	  <input id="source{$doc-name}" 
	         type="hidden" 
		 value="publish" 
		 name="dcm/{$doc-name}" 
		 title="file name"/>

	  <label class="{$color_style}" for='checkbox{$doc-name}'>
	    <input id='checkbox{$doc-name}'
	    onclick="add_publish('sourcediv{$doc-name}',
	    'source{$doc-name}',
	    'checkbox{$doc-name}');" 
	    type="checkbox" 
	    name="button" 
	    value="" 
	    title="publish"/>
	  </label>

	</div>
      </form>
      return $form
    };

    declare function app:get-edition-and-number($doc as node() ) as xs:string* {
      let $c := 
	  $doc//m:fileDesc/m:seriesStmt/m:identifier[@type="file_collection"][1]/string()
      let $no := $doc//m:meiHead/m:workList/m:work[1]/m:identifier[@label=$c][1]/string()
      (: shorten very long identifiers (i.e. lists of numbers) :)
	  let $part1 := substring($no, 1, 11)
	  let $part2 := substring($no, 12)
      let $delimiter := substring(concat(translate($part2,'0123456789',''),' '),1,1)
      let $n := 
          if (string-length($no)>11) then 
            concat($part1,substring-before($part2,$delimiter),'...')
          else
            $no
      return ($c, $n)	
    };

    declare function app:view-document-reference($doc as node()) as node() {
      (: it is assumed that we live in the same collection 'modules' :)
      let $ref := 
      <a  target="_blank"
      title="View" 
      href="./document.xq?doc={util:document-name($doc)}">
	{$doc//m:workList/m:work/m:title[1]/string()}
      </a>
      return $ref
    };

declare function app:public-view-document-reference($doc as node()) as node()* {
  let $langs :=
    comment{
      for $lang in distinct-values($doc//m:workList/m:work[1]/m:title[string()]/@xml:lang/string())
      return $lang
    }
    let $ref := 
      ($langs,
      element span {
	attribute lang {$doc//m:workList/m:work[1]/m:title[string()][not(@type/string())][1]/@xml:lang},
	$doc//m:workList/m:work[1]/m:title[string()][not(@type/string())][1]/string(),
	" ",
	element span {
	  attribute class {"list_subtitle"},
	  if ($doc//m:workList/m:work[1]/m:title[string()][@type/string()='subordinate'][1]/string()) 
	  then
	     element span {
	        element br {},
	        $doc//m:workList/m:work[1]/m:title[string()][@type/string()='subordinate'][1]/string()
	     }
	  else if ($doc//m:workList/m:work[1]/m:title[@type/string()='alternative'][1]/string()) 
	     then concat( '(',$doc//m:workList/m:work[1]/m:title[string()][@type/string()='alternative'][1]/string(),')') else " "
	}
      },
    element br {},
    if($doc//m:workList/m:work[1]/m:title[string()][not(@type/string())][1][@xml:lang!="en"]) then
    	element span {
	  attribute class {"alternative_language"},
	  attribute lang {"en"},
	  concat($doc//m:workList/m:work[1]/m:title[string()][@xml:lang='en' and not(@type/string())][1]/string()," "),
  	  element span {
  	  attribute class {"list_subtitle"},
	  if ($doc//m:workList/m:work[1]/m:title[string()][@xml:lang='en' and @type/string()='subordinate'][1]/string())
	  then 
	     element span {
	        element br {},
	        $doc//m:workList/m:work[1]/m:title[string()][@xml:lang='en' and @type/string()='subordinate'][1]/string()
	     }
	  else ""
	}
      } else element span {" "}
      )
      return $ref
};

    declare function app:view-document-notes($doc as node()) as node() {
      let $note := $doc//m:fileDesc/m:notesStmt/m:annot[@type='private_notes']/string()
      let $n :=  
        if (string-length($note)>20) then 
            <a class="help_plain" style="font-size: inherit; width: auto;">{concat(substring($note,1,20), substring-before(substring($note,21),' '))}...<span 
            class="comment" style="font-size: .9em; line-height: 1.2em; margin-top: 0; margin-left: -150px;">{$note}</span></a>
        else
            <span>{$note}</span>
      return $n
    };

    
    declare function app:edit-form-reference($doc as node()) as node() 
    {
      (: 
      Beware: Partly hard coded reference here!!!
      It still assumes that the document resides on the same host as this
      xq script but on port 80

      The old form is called edit_mei_form.xml the refactored one starts on
      edit-work-case.xml 
      :)

      let $form-id := util:document-name($doc)
      let $ref := <a href="../forms/edit-work-case.xml?doc={util:document-name($doc)}"><input type="image"
 	title="Edit" 
	src="../resources/images/edit.gif" 
	alt="Edit" /></a>

      return $ref

    };


    declare function app:copy-document-reference($doc as node()) as node() 
    {
      let $form-id := util:document-name($doc)
      let $uri     := concat($config:data-public-root, "/", util:document-name($doc))
      let $form := 
      <form id="copy{$form-id}" action="./copy-file.xq" method="post" style="display:inline;">
    	<input type="hidden" value="copy" name="{util:document-name($doc)}" />
    	<input type="image" src="../resources/images/copy.gif" name="button" value="copy" title="Copy"/>
      </form>
      return  $form
    };


    declare function app:rename-document-reference($doc as node()) as node() 
    {
      let $doc-name := util:document-name($doc)
      let $form-id  := concat("rename",$doc-name)
      let $uri      := concat($config:data-public-root,"/",$doc-name)
      let $form := 
      <form id="{$form-id}" action="./rename-file.xq" method="post" style="display:inline;">
    	<input type="hidden" name="doc" value="{$doc-name}" />
    	<input type="hidden" name="name" value=""/>
    	<img src="../resources/images/rename.png" name="button" value="rename" title="Rename {$doc-name}" alt="Rename" 
    	  onclick="filename_prompt('{$form-id}','{$doc-name}',{doc-available(concat($config:data-public-root, '/', $doc-name))}); return false;"/>
      </form>
      return  $form
    };



    declare function app:delete-document-reference($doc as node()) as node() 
    {
      let $form-id := util:document-name($doc)
      let $uri     := concat($config:data-public-root,"/",util:document-name($doc))
      let $form := 
    	if(doc-available($uri)) then
        <span>
        <img src="../resources/images/remove_disabled.gif" alt="Remove (disabled)" title="Only unpublished files may be deleted"/>
        </span>
        else
    	<form id="del{$form-id}" action="./delete-file.xq" method="post" style="display:inline;">
        	<input type="hidden" value="delete" name="{util:document-name($doc)}" />
        	<input 
        	    onclick="{string-join(('show_confirm(&quot;del',$form-id,'&quot;,&quot;',$doc//m:workList/m:work/m:title[string()][1]/string(),'&quot;);return false;'),'')}" 
        	    type="image" src="../resources/images/remove.gif" name="button" value="remove" title="Remove"/>
    	</form>
      return  $form
    };

    declare function app:list-title() 
    {
      let $title :=
	if(not(session:get-attribute("coll"))) then
	  "All documents"
	else
	  (session:get-attribute("coll"), " documents")

	  return $title
    };

declare function app:pass-as-hidden() as node()* {
  let $inputNames  := ("itemsPerPage", "genre", "notbefore", "notafter", "sortby")
  let $inputs := for $name in $inputNames
                    return 
                        if (request:get-parameter($name, ''))
                        then (<input name="{$name}" type="hidden" value="{request:get-parameter($name, '')}" />)
                        else ()
    (:
(:     <input name="page"           type="hidden" value="{request:get-parameter("page", "1")}"   />,:)
    <input name="itemsPerPage"   type="hidden" value="{request:get-parameter("itemsPerPage", "20")}" />,
    <input name="genre"          type="hidden" value="{request:get-parameter("genre", "")}" />,
    if request:get-parameter("notbefore", "")
      (<input name="notbefore"      type="hidden" value="{request:get-parameter("notbefore", "")}" />),
    <input name="notafter"       type="hidden" value="{request:get-parameter("notafter", "")}" />,
    <input name="sortby"         type="hidden" value="{request:get-parameter("sortby", "")}" />
    ) :)
    return $inputs
};

declare function app:pass-as-hidden-except(
    $field as xs:string)  as node()* {
  let $inputs:=
      for $input in app:pass-as-hidden()
      return
	    if($input/@name ne $field) then
	        $input
	    else
	        ()
    return $inputs
};
declare function app:query-with-form-vars(){
    let $inputNames   := ("itemsPerPage", "genre", "notbefore", "notafter", "sortby")
    let $queryParts   := for $name in $inputNames
                            return
                                if (request:get-parameter($name, ''))
                                then fn:concat($name,"=", request:get-parameter($name, ''))
                                else ()
    let $queryString  := if (fn:count($queryParts))
                            then fn:concat("&amp;", string-join($queryParts, "&amp;"))
                            else ()
    return $queryString
};


  
    declare function app:navigation( 
      $sort-options as node()*,
      $list as node()* ) as node()*
      {

	let $total := fn:count($list/m:meiHead)
(: 	let $nextpage := (xs:integer(session:get-attribute("page"))+1) cast as xs:string :)
     (: session variables require cookies. Not sure when these are added, 
     : but we have no user-facing cookie warning
    let $page     := session:get-attribute("page") cast as xs:integer
    let $number   := session:get-attribute("number") cast as xs:integer
:)

    let $page     := request:get-parameter("page", "1") cast as xs:integer
    let $number   := request:get-parameter("itemsPerPage", "20") cast as xs:integer
    let $nextpage := $page+1
    let $from     := (($page - 1) * $number + 1) cast as xs:integer
(:  :    let $to       := ($from  + $number - 1) cast as xs:integer :)
 
	let $next     :=
	  if($from + $number <$total) then
	    (element a {
	      attribute rel   {"next"},
	      attribute title {"Go to next page"},
	      attribute class {"paging"},
	      attribute href {fn:concat("?page=",$nextpage,app:query-with-form-vars())},
	      element img {
    		attribute src {"../resources/images/next.png"},
    		attribute alt {"Next"},
    		attribute border {"0"}
	      }
	    })
	  else
	    ("") 

	    let $prevpage := ($page - 1) cast as xs:string

	    let $previous :=
	      if($from - $number + 1 > 0) then
		(
		  element a {
		    attribute rel {"prev"},
		    attribute title {"Go to previous page"},
		    attribute class {"paging"},
            attribute href {fn:concat("?page=",$prevpage,app:query-with-form-vars() )},
		    element img {
			  attribute src {"../resources/images/previous.png"},
			  attribute alt {"Previous"},
			  attribute border {"0"}
			}
		  })
		else
		  ("")

		  let $app:page_nav := for $p in 1 to fn:ceiling( $total div $number ) cast as xs:integer
		  return 
		  (if( not($page = $p) ) then
		    element a {
		      attribute title {"Go to page ",xs:string($p)},
		      attribute class {"paging"},
		      attribute href {fn:concat("?page=",xs:string($p),app:query-with-form-vars())},
		      ($p)
		    }
		  else 
		    element span {
		      attribute class {"paging selected"},
		      ($p)
		    }
		  )

		  let $work := 
		    if($total=1) then
		      " file"
		    else
		      " files"
 
		  let $links := ( 
		    element div {
		      element strong {
			"Found ",$total, $work 
		      },
		      if($sort-options) then
			(<form action="" id="sortForm" style="display:inline;float:right;">
			    <input name="page" value="1" type="hidden"/>
    			<select name="sortby" onchange="this.form.submit();return true;"> 
    			{
    			  for $opt in $sort-options
    			    let $option:=
    			      if($opt/@value/string()=session:get-attribute("sortby")) then
    			        element option {
    				  attribute value {$opt/@value/string()},
    				  attribute selected {"selected"},
    				  concat("Sort by: ",$opt/string())}
    			      else
    			        element option {
    				  attribute value {$opt/@value/string()},$opt/string()}
       			    return $option
    			}
    			</select>
    			{app:pass-as-hidden-except("sortby")}
			  </form>)
		      else
			(),
		      (<form action="" id="itemsPerPageForm" style="display:inline;float:right;">
	              <input name="page" value="1" type="hidden"/>
    		      <select name="itemsPerPage" onchange="this.form.submit();return true;"> 
    			{(
    			  element option {attribute value {"10"},
    			  if($number=10) then 
    			    attribute selected {"selected"}
    			  else
    			    "",
    			    "10 results per page"},
    			    element option {attribute value {"20"},
    			    if($number=20) then 
    			      attribute selected {"selected"}
    			    else
    			      "",
    			      "20 results per page"},
    			      element option {attribute value {"50"},
    			      if($number=50) then 
    				attribute selected {"selected"}
    			      else
    				"",
    				"50 results per page"},
    				element option {attribute value {"100"},
    				if($number=100) then 
    				  attribute selected {"selected"}
    				else
    				  "",
    				  "100 results per page"},
    				  element option {attribute value {$total cast as xs:string},
    				  if($number=$total or $number>$total) then 
    				    attribute selected {"selected"}
    				  else
    				    "",
    				    "View all results"}
    			 )}
    		      </select>
		      {app:pass-as-hidden-except("itemsPerPage")}

		      </form>),
		      if ($total > $number) then
		         element div {
       		        attribute class {"paging_div"},
       			    $previous,"&#160;",
       			    $app:page_nav,
       			    "&#160;", $next}
       		  else "",
			  element br {
			     attribute clear {"both"}
			  }
		    }) 
		    return $links
      };

