xquery version "1.0" encoding "UTF-8";

module  namespace  filter="http://kb.dk/this/app/filter";
import module namespace config="https://github.com/edirom/mermeid/config" at "/db/apps/mermeid/modules/config.xqm";

declare namespace m="http://www.music-encoding.org/ns/mei";

declare variable $filter:sortby := request:get-parameter("sortby", "") cast as xs:string;
declare variable $filter:page   := request:get-parameter("page",   "1") cast as xs:integer;
declare variable $filter:number := request:get-parameter("itemsPerPage","20") cast as xs:integer;
declare variable $filter:genre := request:get-parameter("genre", "") cast as xs:string;
declare variable $filter:uri    := "";
declare variable $filter:vocabulary := 
        doc("/db/apps/mermeid/project/resources/page_xml/delius-keywords.xml");

declare function filter:print-filters(
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $number          as xs:string,
  $genre           as xs:string,
  $query           as xs:string,
  $list as node()*) as node()* 
{
  let $notafter  := request:get-parameter("notafter","1931")
  let $notbefore := request:get-parameter("notbefore","1880")
  let $anthology := if (request:get-parameter("excludeAnthologies", "")="yes")
    then "checked"
    else ""
  let $anthology_toggle := if (request:get-parameter("excludeAnthologies", "")="yes")
	    then filter:get-filtered-link(request:get-parameter("genre", ""))
	    else fn:concat(filter:get-filtered-link(request:get-parameter("genre", "")), "&amp;excludeAnthologies=yes")
  let $filter:=
    <div class="filter_block">
      <form action="" method="get" class="search" id="query_form" name="query_form">
        <div class="label">Keywords</div>
            <input name="query"  value='{request:get-parameter("query","")}' id="query_input"/>
        {if (string-length(request:get-parameter("itemsPerPage", ""))>0)
            then (<input name="itemsPerPage" value='{request:get-parameter("itemsPerPage", "")}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("sortby", ""))>0)
            then (<input name="sortby"  value='{$filter:sortby}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("genre", ""))>0)
            then (<input name="genre"  value='{$genre}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("notbefore", ""))>0)
            then (<input name="notbefore" value='{request:get-parameter("notbefore","")}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("notafter", ""))>0)
            then (<input name="notafter" value='{request:get-parameter("notafter","")}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("excludeAnthologies", ""))>0)
            then (<input name="exludeAnthologies" value='yes' type='hidden' />)
            else () }
        <a class="help">?<span class="comment">Search is case insensitive. 
        Search terms may be combined using boolean operators. Wildcards allowed. Some examples:<br/>
        <span class="help_table">
          <span class="help_example">
            <span class="help_label">carl or nielsen</span>
            <span class="help_value">Boolean OR (default)</span>
          </span>                        
          <span class="help_example">
            <span class="help_label">carl and nielsen</span>
            <span class="help_value">Boolean AND</span>
          </span>
          <span class="help_example">
            <span class="help_label">"carl nielsen"</span>
            <span class="help_value">Exact phrase</span>
          </span>
          <span class="help_example">
            <span class="help_label">niels*</span>
            <span class="help_value">Match any number of characters. Finds Niels, Nielsen and Nielsson<br/>
            (use only at end of word)
            </span>
          </span>
          <span class="help_example">
            <span class="help_label">niels?n</span>
            <span class="help_value">Match 1 character. Finds Nielsen and Nielson, but not Nielsson</span>
          </span>
        </span>
      </span>
      </a>
      <div class="search_submit">
        <input type="submit" value="Search" id="search_submit"/>
      </div>
      </form>
      <form action="" method="get" class="search" id="year_form" name="year_form">
	<div class="label">Year of composition</div>
	<table cellpadding="0" cellspacing="0" border="0">
         <tr>
            <td style="padding-left: 0;">
            <input id="notbefore" name="notbefore" value="{$notbefore}" onblur="setYearSlider()"/>
            </td>
            <td>
	      <div class="slider" id="year_slider">
		{" "}
	      </div>
            </td>
            <td>
	      <input id="notafter" 
	      name="notafter" 
	      value="{$notafter}" 
	      onblur="setYearSlider()"/>
            </td>
        </tr>
	</table>
	<div class="search_submit">
          <input type="submit" value="Search" id="year_submit"/>
	</div>
        {if (string-length(request:get-parameter("itemsPerPage", ""))>0)
            then (<input name="itemsPerPage" value='{request:get-parameter("itemsPerPage", "")}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("sortby", ""))>0)
            then (<input name="sortby"  value='{$filter:sortby}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("genre", ""))>0)
            then (<input name="genre"  value='{$genre}' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("excludeAnthologies", ""))>0)
            then (<input name="exludeAnthologies" value='yes' type='hidden' />)
            else () }
        {if (string-length(request:get-parameter("query", ""))>0)
            then (<input name="query"  value='{request:get-parameter("query","")}' type="hidden"/>)
            else () }
      </form>     
      <div class="genre_filter filter_block">
	{
	  for $genre in $filter:vocabulary/m:classification/m:termList[@label="level1" or @label="level2"]/m:term/string()
	    let $selected :=
          if ($genre=$filter:genre) then "selected" else ""

    let $link := filter:get-filtered-link($genre)		  
 	return 
	  if ($filter:vocabulary/m:classification/m:termList[m:term/string()=$genre]/@label="level2")
	    then 
	    (
	    <a class="genre_filter_row level2 {$selected}"
	        href="{$link}" title="Select genre: {$genre}">
              <span class="genre_indicator {translate(translate($genre,' ,','_'),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')}">
              &#160;
              </span> &#160; {$genre} 
	    </a>
	    )
          else
          <a class="genre_filter_row level1 {$selected}"
              href="{$link}" title="Select genre: {$genre}">
	    {$genre} 
          </a>
        }
      </div>

      <div class="filter_block anthologies">
        
        <a class="genre_filter_row anthology_filter {$anthology}" href="{$anthology_toggle}">Exclude song collections</a>
        </div>
      </div>
    return $filter
};


declare function filter:count-hits(
  $term as xs:string,
  $list as node()*) as xs:integer* 
{
  let $number :=
  for $count in count($list//m:workList[contains(m:work/m:classification/m:termList/m:term/string(),$term) ])
    return $count
  return $number
};

declare function filter:filter-elements() 
{
  let $notafter  := request:get-parameter("notafter","")
  let $notbefore := request:get-parameter("notbefore","")
  let $query := request:get-parameter("query","")
  let $genre := request:get-parameter("genre","")
  let $this_uri := fn:concat($filter:uri,"?",request:get-query-string())
 
  let $year_block :=
      if($notbefore or $notafter) then
       <a class="filter_element"
           href="{fn:replace(fn:replace($this_uri,'notbefore=\d*','notbefore='),'notafter=\d*','notafter=')}">
           Year of composition: {$notbefore}–{$notafter} 
       </a>
    else
       ""
  let $query_block :=
      if($query) then
       <a class="filter_element"
           href="{fn:replace($this_uri,'query=[^&amp;]+','query=')}">
           Keyword(s): {$query} 
       </a>
    else
       ""
  let $genre_block :=
      if($genre) then
       <a class="filter_element" 
           href="{fn:replace($this_uri,'&amp;genre=[^&amp;]+','')}">
           Genre: {$genre} 
       </a>
    else
       ""
  let $anthologies_block :=
    if(request:get-parameter("excludeAnthologies", "") eq "yes")
      then <a class="filter_element" href="{fn:replace($this_uri, '&amp;excludeAnthologies=[^&amp;]+', '')}">
        Excluding song collections</a>
      else ""
  let $reset_block :=
      if($genre_block or $year_block or $query_block) then
       <a class="filter_element reset" 
           href="{fn:concat($filter:uri,'?itemsPerPage=',$filter:number)}">
           Reset all
       </a> 
    else
       ""
  let $clear :=
      <br style="clear:both"/>
  return ($year_block, $query_block, $genre_block, $anthologies_block, $reset_block, $clear)
};


declare function filter:print-filtered-link(
  $database        as xs:string,
  $published_only  as xs:string,
  $coll            as xs:string,
  $number          as xs:string,
  $query           as xs:string,
  $term            as xs:string) as node()*
{
    let $inputNames   := ("itemsPerPage", "query", "notbefore", "notafter", "sortby")
    let $queryParts   := for $name in $inputNames
                            return
                                if (request:get-parameter($name, ''))
                                then fn:concat($name,"=", request:get-parameter($name, ''))
                                else ()
    let $queryString  := if (fn:count($queryParts))
                            then fn:concat("&amp;", string-join($queryParts, "&amp;"))
                            else ()
    let $link := (
        element a 
        {
            attribute title {"Filter with ",$term},
            attribute href {
    	        concat($filter:uri,"?","page=",1,$queryString)},
	        $term
        }
    )
    return $link
};


declare function filter:get-filtered-link(
  $term            as xs:string) as xs:string
{
    let $inputNames   := ("itemsPerPage", "query", "notbefore", "notafter", "sortby")
    let $queryParts   := for $name in $inputNames
                            return
                                if (request:get-parameter($name, ''))
                                then fn:concat($name,"=", request:get-parameter($name, ''))
                                else ()
    let $queryString  := if (fn:count($queryParts))
                            then fn:concat("&amp;", string-join($queryParts, "&amp;"))
                            else ()
  let $link := if (string-length($term) > 0)
    then concat($filter:uri,"?",
	    "page=",1,$queryString,
	    "&amp;genre=",fn:escape-uri($term,true()))
    else concat($filter:uri,"?","page=",1,$queryString)
  return $link
};

declare function filter:get-date($date as xs:string) as xs:string
{
  let $xsdate :=
      substring($date,1,4)

  return $xsdate
};

