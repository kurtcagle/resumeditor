(:@ app.xq :)
declare namespace app = "http://metaphoricalweb.com/xmlns/app";
declare namespace resume = "http://metaphoricalweb.com/xmlns/resume";
declare namespace atom = " http://www.w3.org/2005/Atom";
import module namespace context="http://metaphoricalweb.com/xmlns/context" at "/modules/context.xq";
import module namespace json="http://marklogic.com/xdmp/json"
     at "/MarkLogic/json/json.xqy";
declare variable $resume:ns := "http://metaphoricalweb.com/xmlns/resume";
declare variable $resume:services := map:map(
    <map:map xmlns:map="http://marklogic.com/xdmp/map">
     <map:entry>
       <map:key>bio</map:key>
       <map:value xsi:type="xs:string"
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">bio</map:value>
     </map:entry>
     <map:entry>
       <map:key>education</map:key>
       <map:value xsi:type="xs:string"
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">education</map:value>
     </map:entry>
     <map:entry>
       <map:key>projects</map:key>
       <map:value xsi:type="xs:string"
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">projects</map:value>
     </map:entry>
    </map:map>    
);
(: App:main()  :)
declare function app:main(){
    let $uri := xdmp:get-request-field("uri")
    let $context := context:create-context($uri)
    let $params := map:get($context,"params")
    let $method := map:get($params,"method")
    let $face := map:get($params,"face")
    let $output := if ($method = "GET") then
            if ($face = "xml") then
                app:xml-page($context)
            else
            if ($face = "json") then
                app:json-page($context)
            else
            if ($face = "feed.xml") then
                app:xml-feed-page($context)
            else
                app:html-edit-page($context)
        else if ($method = "POST") then
            app:xml-post-page($context)
        else ()
    return ($output)
    };

declare function app:query($context as item()) as node()*{
    let $params := map:get($context,"params")
    let $submap := fn:replace(map:get($context,"path"),"^.*/resume/(.*?)$","$1")
    let $id := map:get($params,"id")
    let $query-text := map:get($params,"q")
    let $user := map:get($params,"user")
    let $query := if ($id) then
            cts:and-query((
                cts:element-attribute-value-query(fn:QName($resume:ns,"resume"),fn:QName("","id"),$id) ,
                cts:directory-query("/apps/resume/data/","infinity") 
            ))
        else
            cts:and-query((
                if ($query-text) then cts:element-word-query(fn:QName($resume:ns,"presentationName"),$query-text) else (),
                if ($user) then cts:element-value-query(fn:QName($resume:ns,"userName"),$user) else (),
                cts:directory-query("/apps/resume/data/","infinity")
            ))
    return for $entry in cts:search(/resume:resume,$query) order by $entry/property::prop:last-modified descending return 
        if ($submap != "") then 
            if ($submap = "bio") then $entry//resume:bio
            else if ($submap = "education") then $entry//resume:education
            else if ($submap = "projects") then  $entry//resume:projectSet
            else ()
        else $entry
    };

declare function app:xml-page($context as item()) as item()*{
    let $entries := app:query($context)
    let $page := (xdmp:set-response-content-type("text/xml"),
        <app:datafeed count="{cts:remainder($entries[1])}">{$entries}</app:datafeed>
        )
    return $page
    };

declare function app:xml-post-page($context as item()) as item()*{
    let $body := xdmp:get-request-body("xml")
    let $resume := $body//resume:resume
    let $id := $resume/@id/fn:string(.)
    let $_ := xdmp:document-insert(fn:concat("/apps/resume/data/",$id,".xml"),$resume)
    return $body
    };

declare function app:json-page($context as item()) as item()*{
    let $entries := app:query($context)
    let $xml := <datafeed count="{cts:remainder($entries[1])}">{$entries}</datafeed>
    let $page := (xdmp:set-response-content-type("text/json"),
        xdmp:to-json($xml)
        )
    return $page
    };


declare function app:xml-feed-page($context as item()) as item()*{
    let $entries := app:query($context)
    let $page := (xdmp:set-response-content-type("text/xml"),
        <app:datafeed count="{cts:remainder($entries[1])}">{
            for $entry in $entries return
            <app:entry>
                <app:label>{$entry/resume:resumeLabel/fn:string(.)}</app:label>
                <app:value>{$entry/@id/fn:string(.)}</app:value>
                <app:lastModified>{fn:string($entry/property::prop:last-modified)}</app:lastModified>
                <app:user>{$entry/resume:userName/fn:string(.)}</app:user>
                <app:dataLink>{map:get($context,"path")}?id={$entry/@id/fn:string(.)};face=xml</app:dataLink>
                <app:editLink>{map:get($context,"path")}?id={$entry/@id/fn:string(.)};face=edit</app:editLink>
            </app:entry>
        }</app:datafeed>
        )
    return $page
    };

declare function app:html-edit-page($context){
    let $entries := app:query($context)
    let $params := map:get($context,"params")
    let $id := map:get($params,"id")
    let $page := (xdmp:set-response-content-type("text/xml"),
    processing-instruction {'xml-stylesheet'} {'type="text/xsl" href="/lib/xsltforms/xsltforms.xsl"'},
    processing-instruction {'xsltforms-options'} {'debug="no" lang="en"'},
 
    
<html xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
    xmlns:res="http://metaphoricalweb.com/xmlns/resume"
    xmlns:mw="http://metaphoricalweb.com/xforms/new-functions/"
    xmlns:xsltforms="http://www.agencexml.com/xsltforms" 
    xmlns:rte="http://www.agencexml.com/xsltforms/rte"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    >
      <head>
          <script type="text/javascript" src="/lib/js/tiny_mce/tiny_mce.js">/* */</script>        
          <xf:model id="model">
          <xf:instance id="data" src="/resume/?id={$id};face=xml"/>
          <xf:instance id="state">
            <state>
                <updateName>true</updateName>
                <enableEdit>false</enableEdit>
                <backgroundColor>lightBlue</backgroundColor>
                <currentProject>1</currentProject>
                <currentInstitution>1</currentInstitution>
            </state>
          </xf:instance>
          <xf:instance id="phoneTypes">
            <itemSet>
                <item>
                    <itemLabel>Home</itemLabel>
                    <itemValue>home</itemValue>
                </item>
                <item>
                    <itemLabel>Business</itemLabel>
                    <itemValue>business</itemValue>
                </item>
                <item>
                    <itemLabel>Fax</itemLabel>
                    <itemValue>fax</itemValue>
                </item>
                <item>
                    <itemLabel>Mobile</itemLabel>
                    <itemValue>mobile</itemValue>
                </item>
                <item>
                    <itemLabel>Deprecated</itemLabel>
                    <itemValue>deprecated</itemValue>
                </item>
            </itemSet>
          </xf:instance>
          <xf:instance id="emailTypes">
            <itemSet>
                <item>
                    <itemLabel>Primary</itemLabel>
                    <itemValue>primary</itemValue>
                </item>
                <item>
                    <itemLabel>Work</itemLabel>
                    <itemValue>work</itemValue>
                </item>
                <item>
                    <itemLabel>Personal</itemLabel>
                    <itemValue>personal</itemValue>
                </item>
                <item>
                    <itemLabel>Deprecated</itemLabel>
                    <itemValue>deprecated</itemValue>
                </item>
            </itemSet>
          </xf:instance>
          <xf:instance id="institutionTypes">
            <itemSet>
                <item>
                    <itemLabel>High School</itemLabel>
                    <itemValue>high_school</itemValue>
                </item>
                <item>
                    <itemLabel>Community College</itemLabel>
                    <itemValue>community_college</itemValue>
                </item>
                <item>
                    <itemLabel>University</itemLabel>
                    <itemValue>university</itemValue>
                </item>
                <item>
                    <itemLabel>Graduate School</itemLabel>
                    <itemValue>graduate_school</itemValue>
                </item>
                <item>
                    <itemLabel>Medical School</itemLabel>
                    <itemValue>medical_school</itemValue>
                </item>
                <item>
                    <itemLabel>Law School</itemLabel>
                    <itemValue>law_school</itemValue>
                </item>
                <item>
                    <itemLabel>Certification Program</itemLabel>
                    <itemValue>certification</itemValue>
                </item>
                <item>
                    <itemLabel>Other School</itemLabel>
                    <itemValue>other_school</itemValue>
                </item>

            </itemSet>
          </xf:instance>
          <xf:instance id="email-template">
            <email xmlns="http://metaphoricalweb.com/xmlns/resume">
                <emailAddress>someone@mymail.com</emailAddress>
                <emailType>primary</emailType>
            </email>
          </xf:instance>
          <xf:instance id="phone-template">
            <phone xmlns="http://metaphoricalweb.com/xmlns/resume">
                <phoneNumber>000-000-0000</phoneNumber>
                <phoneType>home</phoneType>
            </phone>
          </xf:instance>
          <xf:instance id="projectDateEnd-template">
            <res:projectDateEnd>{fn:substring(fn:string(fn:current-date()),1,10)}</res:projectDateEnd>
          </xf:instance>
          <xf:instance id="institutionDateEnd-template">
            <res:institutionDateEnd>{fn:substring(fn:string(fn:current-date()),1,10)}</res:institutionDateEnd>
          </xf:instance>
          <xf:instance id="project-template">
            <project id="" xmlns="http://metaphoricalweb.com/xmlns/resume">
                <client>Client Name</client>
                <role>Role</role>
                <agency>Agency</agency>
                <description>A description about what you did - you can use HTML here.</description>
                <projectInterval>
                    <projectDateStart>{fn:substring(fn:string(fn:current-date()),1,10)}</projectDateStart>
                    <projectDateEnd>{fn:substring(fn:string(fn:current-date()),1,10)}</projectDateEnd>
                </projectInterval>
                <projectProficiencyRefSet>
                    <projectProficiencyRef>Term</projectProficiencyRef>
                </projectProficiencyRefSet>
                <projectLocation>
                    <city>City</city>
                    <stateProvince>CA</stateProvince>
                    <country>USA</country>
                </projectLocation>
            </project>
          </xf:instance>
          <xf:instance id="countryData" src="/lib/data/countryRegions.xml"/>
          <xf:bind nodeset="instance('state')/updateName" type="xs:boolean"/>
          <xf:bind nodeset="instance('state')/enableEdit" type="xs:boolean"/>
          <xf:bind nodeset="instance('state')/currentProject" type="xs:double"/>
          <xf:bind nodeset="instance('data')//res:projectDateStart" type="xs:date"/>
          <xf:bind nodeset="instance('data')//res:projectDateEnd" type="xs:date"/>
          <xf:bind nodeset="instance('data')//res:institutionDateStart" type="xs:date"/>
          <xf:bind nodeset="instance('data')//res:institutionDateEnd" type="xs:date"/>
          <xf:bind nodeset="instance('data')//res:presentationName" readonly="instance('state')/updateName = true()"/>

			<xs:schema xmlns="http://www.w3.org/2001/XMLSchema" targetNamespace="http://www.agencexml.com/xsltforms/rte">
				<xs:simpleType name="standardHTML">
					<xs:restriction base="xsd:string" xsltforms:rte="TinyMCE"/>
					<xs:annotation>
						<xs:appinfo><![CDATA[
							{
								theme : "advanced",
								skin : "o2k7",
								plugins : "lists,pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template,inlinepopups,autosave",
								theme_advanced_buttons1 : "save,newdocument,|,bold,italic,underline,strikethrough,|,justifyleft,justifycenter,justifyright,justifyfull,styleselect,formatselect,fontselect,fontsizeselect",
								theme_advanced_buttons2 : "cut,copy,paste,pastetext,pasteword,|,search,replace,|,bullist,numlist,|,outdent,indent,blockquote,|,undo,redo,|,link,unlink,anchor,image,cleanup,help,code,|,insertdate,inserttime,preview,|,forecolor,backcolor",
								theme_advanced_buttons3 : "tablecontrols,|,hr,removeformat,visualaid,|,sub,sup,|,charmap,emotions,iespell,media,advhr,|,print,|,ltr,rtl,|,fullscreen",
								theme_advanced_buttons4 : "insertlayer,moveforward,movebackward,absolute,|,styleprops,|,cite,abbr,acronym,del,ins,attribs,|,visualchars,nonbreaking,template,pagebreak,restoredraft",
								theme_advanced_toolbar_location : "top",
								theme_advanced_toolbar_align : "left",
								theme_advanced_statusbar_location : "bottom",
								theme_advanced_resizing : true
							}]]>
						</xs:appinfo>
					</xs:annotation>
				</xs:simpleType>
			</xs:schema>
			<xf:bind nodeset="//res:description" type="rte:standardHTML"/>
			<xf:submission method="post" action="/resume/?id={$id}"
			replace="instance" id="xml-post" instance="data"/>
        </xf:model>
        <style type="text/css"><![CDATA[
@namespace xf url("http://www.w3.org/2002/xforms");
body {margin:0.25in;font-family:Arial;font-size:9pt;}
.container {border:solid 1px lightBlue;width:500px;padding:4px;}
.property label {display:inline-block;width:150px;text-align:right;font-weight:bold;}
.view-property label {font-weight:bold;}
.link {font-style:italic;}
.institutionLinkDiv, .projectLinkDiv {position:absolute;display:block;left:10px;top:0px;width:400px;height:350px;overflow-y:auto;}
.institutionDiv, .projectDiv {position:absolute;display:block;left:480px;top:-54px;}
.institutionContainer, .projectContainer {position:relative;display:block;}
.description {width:500px;border:solid 1px lightBlue;padding:5px;margin-top:10px;}
.large-textarea textarea {
				font-family: Courier, sans-serif;
				height: 10em;
				width: 400px;
			}
.projectLinkBtn {padding-left:2px;}
.projectLink {}
.insertBtn {font-weight:bold;color:green;font-size:14pt;}
.deleteBtn {font-weight:bold;color:red;font-size:14pt;}
.resumeFor {font-size:18pt;}
.resumeLabel {font-size:26pt;padding-bottom:5px;border-bottom:solid 3px blue;}
.statementDiv {padding-bottom:5px;margin-bottom:5px;border-bottom:solid 2px blue;}
.statement {width:400px;font-style:italic;font-size:11pt;}
.xforms-repeat-item-selected {background-color: lightYellow;max-width:400px;} 
        ]]></style>
        <script type="text/javascript"><![CDATA[
XPathCoreFunctions['http://metaphoricalweb.com/xforms/new-functions/ formatMonthYear'] =
        new XPathFunction(
            false,                       /* is accepting context as 1st-arg? */
            XPathFunction.DEFAULT_NODE,  /* context-form as 1st-arg, when (args.length == 0): [ DEFAULT_NONE | DEFAULT_NODE | DEFAULT_NODESET | DEFAULT_STRING ] */ 
            false,                       /* is returning nodes? */
            function(arg1) {
                try {
                var months=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
                  var monthYear = arg1[0].textContent;
                  var pair = monthYear.split("-");
                  var year = pair[0];
                  var month = months[parseInt(pair[1])-1];
                  return month+" "+year;
                  }
              catch(e){return "present"}
            } 
        );        
        ]]></script>        
      </head>
      <body style="color:{{instance('state')/backgroundColor}}">
        <div style="float:right"><xf:input ref="instance('state')/enableEdit"><xf:label>Enable Edit Mode</xf:label></xf:input></div>
        <xf:group ref="res:resume">
        <xf:group ref="res:resumeLabel">
            <xf:switch>
                <xf:case id="resumeLabel-view" select="true">
                <h1>
                <div class="resumeFor"><xf:output ref="../res:bio/res:personName/res:presentationName"/></div>
                <div class="resumeLabel"><xf:output ref="."/>
                <xf:trigger appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                    <xf:label><img src="http://openclipart.org/people/darth_schmoo/1307548250.svg"
                        width="32px" height="32px"/>
                    </xf:label>
                    <xf:action ev:event="DOMActivate">
                        <xf:toggle case="resumeLabel-edit"/>
                    </xf:action>
                </xf:trigger>
                <xf:submit submission="xml-post" appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                    <xf:label><img src="http://openclipart.org/people/warszawianka/document-save.svg"
                    width="32" height="32"/></xf:label>
                    
                </xf:submit>
                </div>
                </h1>
                <div class="statementDiv">
                    <div class="statement">
                    <xf:output ref="../res:statement" mediatype="application/xhtml+xml"/>
                    </div>
                </div>
                </xf:case>
                <xf:case id="resumeLabel-edit" select="false">
                <h1><xf:output ref="."/>
                <xf:trigger appearance="minimal">
                <xf:label><img src="http://openclipart.org/people/warszawianka/go-previous.svg"
                                width="28px" height="28px"/></xf:label>                    
                             <xf:action ev:event="DOMActivate">
                        <xf:toggle case="resumeLabel-view"/>
                    </xf:action>
                </xf:trigger>
                </h1>
                <div class="container">
                <div class="property">
                    <xf:input ref="." incremental="true">
                        <xf:label>Resume Label: </xf:label>
                    </xf:input>
                </div>
                <div class="property">
                    <xf:textarea ref="../res:statement" class="large-textarea" mediatype="application/xhtml+xml">
                        <xf:label>Statement</xf:label>
                    </xf:textarea>                
                </div>
                </div>
                </xf:case>
            </xf:switch>
        </xf:group>
        <div>
            <xf:trigger>
                <xf:label>Biography</xf:label>
                <xf:toggle ev:event="DOMActivate" case="bio"/>                
            </xf:trigger>
            <xf:trigger>
                <xf:label>Education</xf:label>
                <xf:toggle ev:event="DOMActivate" case="education"/>                
            </xf:trigger>
            <xf:trigger>
                <xf:label>Projects</xf:label>
                <xf:toggle ev:event="DOMActivate" case="projects"/>                
            </xf:trigger>
        </div>
        <xf:switch>
        <xf:case id="bio" selected="true">
        <h2>Biographical Information </h2>
        <xf:group ref="res:bio/res:personName">
            <xf:switch>
                <xf:case id="personName-view" selected="true">
                    <div class="view-property">
                        <xf:output ref="res:presentationName">
                            <xf:label>Name: </xf:label>
                        </xf:output>
                        <xf:trigger appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                            <xf:label><img src="http://openclipart.org/people/darth_schmoo/1307548250.svg"
                        width="28px" height="28px"/></xf:label>
                            <xf:action ev:event="DOMActivate">
                                <xf:toggle case="personName-edit"/>
                            </xf:action>
                        </xf:trigger>   
                    </div>
                </xf:case>
                <xf:case id="personName-edit" selected="false">
                    <div>
                        <div class="view-property">
                        <xf:output ref="res:presentationName">
                            <xf:label>Name: </xf:label>
                        </xf:output>
                        <xf:trigger appearance="minimal">
                                <xf:label><img src="http://openclipart.org/people/warszawianka/go-previous.svg"
                                width="28px" height="28px"/></xf:label>
                                <xf:action ev:event="DOMActivate">
                                <xf:toggle case="personName-view"/>
                            </xf:action>
                        </xf:trigger>                
                        </div>
                        <div class="container">
                            <div class="property">
                                <xf:input ref="res:givenName" incremental="true">
                                    <xf:label>Given Name: </xf:label>
                                    <xf:action ev:event="xforms-value-changed">
                                        <xf:setvalue ref="../res:presentationName" value="concat(string(../res:givenName),' ',string(../res:surName))"
                                            if="instance('state')/updateName = true()"/>
                                    </xf:action>
                                </xf:input>
                            </div>
                            <div class="property"><xf:input ref="res:middleNames"><xf:label>Middle Names: </xf:label></xf:input></div>
                            <div class="property">
                                <xf:input ref="res:surName" incremental="true">
                                    <xf:label>Surname: </xf:label>
                                    <xf:action ev:event="xforms-value-changed">
                                        <xf:setvalue ref="../res:presentationName" value="concat(string(../res:givenName),' ',string(../res:surName))"
                                            if="instance('state')/updateName = true()"/>
                                    </xf:action>
                                </xf:input>
                            </div>
                            <div class="property">
                                <xf:input ref="res:presentationName" incremental="true">
                                    <xf:label>Display Name: </xf:label>
                                </xf:input>
                                <xf:input ref="instance('state')/updateName">
                                    <xf:label>Update Display Name</xf:label>
                                    <xf:action ev:event="DOMActivate">
                                        <xf:setvalue ref="." value="fn:not(.)"/>
                                    </xf:action>
                                </xf:input>
                            </div>
                        </div>
                    </div>
                </xf:case>
            </xf:switch>
        </xf:group>
        <xf:group ref="res:bio/res:contactInfo">
            <xf:switch>
                <xf:case id="contactInfo-view" selected="true">
                    <div class="view-property">
                        <xf:group ref="res:currentAddress">
                            <xf:output value="concat(res:street,' ',res:city,', ',res:stateProvince,' ',res:postalCode,', ',res:country)"/>
                            <xf:trigger appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                            <xf:label><img src="http://openclipart.org/people/darth_schmoo/1307548250.svg"
                        width="28px" height="28px"/></xf:label>
                                <xf:action ev:event="DOMActivate">
                                    <xf:toggle case="contactInfo-edit"/>
                                </xf:action>
                            </xf:trigger>   
                        </xf:group>
                    </div>
                </xf:case>
                <xf:case id="contactInfo-edit" selected="false">
                    <div class="view-property">
                        <xf:group ref="res:currentAddress">
                            <xf:output value="concat(res:street,' ',res:city,', ',res:stateProvince,' ',res:postalCode,', ',res:country)"/>
                            <xf:trigger appearance="minimal">
                                <xf:label><img src="http://openclipart.org/people/warszawianka/go-previous.svg"
                                width="28px" height="28px"/></xf:label>
                                <xf:action ev:event="DOMActivate">
                                    <xf:toggle case="contactInfo-view"/>
                                </xf:action>
                            </xf:trigger>   
                        </xf:group>
                    </div>
                    <div class="container">
                        <xf:group ref="res:currentAddress">
                            <div class="property">
                                <xf:input ref="res:street" incremental="true">
                                    <xf:label>Street: </xf:label>
                                </xf:input>
                            </div>
                            <div class="property">
                                <xf:input ref="res:city" incremental="true">
                                    <xf:label>City: </xf:label>
                                </xf:input>
                            </div>
                            <div class="property">
                                <xf:select1 ref="res:stateProvince" incremental="true">
                                    <xf:label>State or Province: </xf:label>
                                    <xf:itemset nodeset="instance('countryData')/country[countryCode = current()/../res:country]/stateProvinceSet/stateProvince">
                                        <xf:label ref="stateProvinceName"/>
                                        <xf:value ref="stateProvinceCode"/>
                                    </xf:itemset>
                                </xf:select1>
                            </div>
                            <div class="property">
                                <xf:select1 ref="res:country" incremental="true">
                                    <xf:label>Country: </xf:label>
                                    <xf:itemset nodeset="instance('countryData')/country">
                                        <xf:label ref="countryName"/>
                                        <xf:value ref="countryCode"/>
                                    </xf:itemset>
                                </xf:select1>
                            </div>
                            <div class="property">
                                <xf:input ref="res:postalCode" incremental="true">
                                    <xf:label>PostalCode: </xf:label>
                                </xf:input>
                            </div>
                        </xf:group>
                    </div>
                </xf:case>
            </xf:switch>
        </xf:group>
            <xf:switch>
                <xf:case id="email-view" selected="true">
                   <xf:group ref="res:bio/res:contactInfo/res:emailSet">
                    <h2>Email Addresses                        
                    <xf:trigger appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                            <xf:label><img src="http://openclipart.org/people/darth_schmoo/1307548250.svg"
                        width="28px" height="28px"/></xf:label>
                            <xf:action ev:event="DOMActivate">
                                <xf:toggle case="email-edit"/>
                            </xf:action>
                        </xf:trigger>   
                    </h2>
                    <div class="view-property">
                        <xf:repeat nodeset="res:email">
                            <xf:trigger appearance="minimal" class="link">
                                <xf:label><xf:output value="concat(res:emailAddress,' (',res:emailType,')')"/></xf:label>
                                <xf:load show="new" ev:event="DOMActivate"><xf:resource value="concat('mailto:',res:emailAddress)"/></xf:load> 
                            </xf:trigger> 
                        </xf:repeat>
                    </div>
                   </xf:group>
                </xf:case>
                <xf:case id="email-edit" selected="true">
                   <xf:group ref="res:bio/res:contactInfo/res:emailSet">
                    <h2>Email Addresses                        
                    <xf:trigger appearance="minimal">
                        <xf:label><img src="http://openclipart.org/people/warszawianka/go-previous.svg"
                                width="28px" height="28px"/></xf:label>
                            <xf:action ev:event="DOMActivate">
                                <xf:toggle case="email-view"/>
                            </xf:action>
                        </xf:trigger>   
                    </h2>
                    <div class="container">
                      <xf:trigger ref=".[not(res:email)]">
                            <xf:label>Add Email</xf:label>
                            <xf:action ev:event="DOMActivate">
                                <xf:insert nodeset="res:email" 
                                origin="instance('email-template')"
                                at="index('email-repeat')" position="after"/>
                            </xf:action>
                        </xf:trigger>
                        <xf:repeat nodeset="res:email" id="email-repeat">
                            <div class="view-property">
                                <xf:input ref="res:emailAddress" id="emailAddress">
                                    <xf:label>Email Address: </xf:label>
                                    <xf:action ev:event="xforms-insert">
                                        <xf:message>Insert called</xf:message>
                                    </xf:action>
                                </xf:input>
                                <xf:select1 ref="res:emailType">
                                    <xf:itemset nodeset="instance('emailTypes')/item">
                                        <xf:label ref="itemLabel"/>
                                        <xf:value ref="itemValue"/>
                                    </xf:itemset>
                                </xf:select1>
                                <xf:trigger ref=".">
                                    <xf:label>+</xf:label>
                                    <xf:action ev:event="DOMActivate">
                                        <xf:insert nodeset="." 
                                        origin="instance('email-template')"
                                        at="index('email-repeat')" position="after"/>
                                    </xf:action>
                                </xf:trigger>
                                <xf:trigger ref=".">
                                    <xf:label>&#215;</xf:label>
                                    <xf:action ev:event="DOMActivate">
                                        <xf:delete nodeset="."/> 
                                    </xf:action>
                                </xf:trigger>
                            </div>
                        </xf:repeat>
                    </div>
                   </xf:group>
                </xf:case>
           </xf:switch>
           <xf:switch>
                <xf:case id="phone-view" selected="true">
                   <xf:group ref="res:bio/res:contactInfo/res:phoneSet">
                    <h2>Phones                        
                    <xf:trigger appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                            <xf:label><img src="http://openclipart.org/people/darth_schmoo/1307548250.svg"
                        width="28px" height="28px"/></xf:label>
                            <xf:action ev:event="DOMActivate">
                                <xf:toggle case="phone-edit"/>
                            </xf:action>
                        </xf:trigger>   
                    </h2>
                    <div class="view-property">
                        <xf:repeat nodeset="res:phone">
                            <xf:trigger appearance="minimal" class="link">
                                <xf:label><xf:output ref="res:phoneNumber"/> (<xf:output ref="res:phoneType"/>)</xf:label>
                                <xf:load show="new" ev:event="DOMActivate"><xf:resource value="concat('tel:',res:phoneNumber)"/></xf:load> 
                            </xf:trigger> 
                        </xf:repeat>
                    </div>
                   </xf:group>
                </xf:case>
                <xf:case id="phone-edit" selected="true">
                   <xf:group ref="res:bio/res:contactInfo/res:phoneSet">
                    <h2>Phones                        
                    <xf:trigger appearance="minimal">
                        <xf:label><img src="http://openclipart.org/people/warszawianka/go-previous.svg"
                                width="28px" height="28px"/></xf:label>
                            <xf:action ev:event="DOMActivate">                                
                                <xf:toggle case="phone-view"/>
                                <xf:rebuild/>
                                <xf:recalculate/>
                                <xf:validate/>
                                <xf:refresh/>
                            </xf:action>
                        </xf:trigger>   
                    </h2>
                    <div class="container">
                      <xf:trigger ref=".[not(res:phone)]">
                            <xf:label>Add Phone</xf:label>
                            <xf:action ev:event="DOMActivate">
                                <xf:insert nodeset="res:phone" 
                                origin="instance('phone-template')"
                                at="index('phone-repeat')" position="after"/>
                            </xf:action>
                        </xf:trigger>
                        <xf:repeat nodeset="res:phone" id="phone-repeat">
                            <div class="view-property">
                                <xf:input ref="res:phoneNumber" id="phoneNumber">
                                    <xf:label>Phone Number: </xf:label>
                                    <xf:action ev:event="xforms-insert">
                                        <xf:message>Insert called</xf:message>
                                    </xf:action>
                                </xf:input>
                                <xf:select1 ref="res:phoneType">
                                    <xf:itemset nodeset="instance('phoneTypes')/item">
                                        <xf:label ref="itemLabel"/>
                                        <xf:value ref="itemValue"/>
                                    </xf:itemset>
                                </xf:select1>
                                <xf:trigger ref=".">
                                    <xf:label>+</xf:label>
                                    <xf:action ev:event="DOMActivate">
                                        <xf:insert nodeset="parent::res:phoneSet/res:phone" 
                                        origin="instance('phone-template')"
                                        at="index('phone-repeat')" position="after"/>
                                    </xf:action>
                                </xf:trigger>
                                <xf:trigger ref=".">
                                    <xf:label>&#215;</xf:label>
                                    <xf:action ev:event="DOMActivate">
                                        <xf:delete nodeset="."/> 
                                    </xf:action>
                                </xf:trigger>
                            </div>
                        </xf:repeat>
                    </div>
                   </xf:group>
                </xf:case>
           </xf:switch>
        </xf:case>
        <xf:case id="education" selected="false">
        <xf:group ref="res:bio/res:education">
            <h2>Education</h2>
            <div class="projectContainer">
            <ul class="projectLinkDiv">
            <xf:repeat nodeset="res:institution" id="institutionLink-repeat">
                <li class="institutionLink">
                    <xf:trigger ref="." appearance="minimal">
                    <xf:label>
                    <xf:output value="concat(res:institutionLabel,' (',res:institutionType,')')"/>
                    </xf:label>
                    <xf:action ev:event="DOMActivate">
<!--                        <xf:setvalue ref="instance('state')/currentProject"
                            value="../res:project[index('projectLink-repeat')]/@id"/> -->
                        <xf:setvalue ref="instance('state')/currentInstitution"
                            value="index('institutionLink-repeat')"/>
                    </xf:action>
                    </xf:trigger>
                    <xf:trigger  ref=".[instance('state')/enableEdit=true()]" appearance="minimal" class="projectLinkBtn">
                        <xf:label class="insertBtn">+</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:insert nodeset="." 
                            origin="instance('institution-template')"
                            at="index('instituionLink-repeat')" position="after"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger ref=".[instance('state')/enableEdit=true()]" appearance="minimal" class="projectLinkBtn">
                        <xf:label class="deleteBtn">&#215;</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:delete nodeset="."/> 
                        </xf:action>
                    </xf:trigger>
                </li>
            </xf:repeat>
            </ul>
            <xf:switch>
            <xf:case id="institution-view" selected="true">
            <div class="institutionDiv">
                <xf:group ref="res:institution[position() = instance('state')/*:currentInstitution]">
                    <h2><xf:output ref="res:institutionLabel"/>
                        <xf:trigger appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                            <xf:label><img src="http://openclipart.org/people/darth_schmoo/1307548250.svg"
                        width="28px" height="28px"/></xf:label>
                            <xf:toggle case="institution-edit" ev:event="DOMActivate"/>
                        </xf:trigger>
                    </h2>
                    <!-- ######## -->
                    
                    <h3 class="institutionType"><xf:output ref="res:institutionType"/></h3>
                    <div class="certificate"><xf:output value="concat(res:certificate,' in ',res:courseOfStudy)"/></div>
                    <div class="institutionDates"><xf:output value="concat(mw:formatMonthYear(res:institutionInterval/res:institutionDateStart),' to ', mw:formatMonthYear(res:institutionInterval/res:institutionDateEnd))"/></div>
                    <xf:group ref="res:institutionLocation"><div class="institutionLocation"><xf:output value="concat(res:city,', ',res:stateProvince,' ',if(res:country = 'CAN',res:country,''))"/></div></xf:group>
                </xf:group>
            </div>
            </xf:case>
            <xf:case id="institution-edit" selected="false">
            <div class="institutionDiv">
                <xf:group ref="res:institution[position() = instance('state')/*:currentInstitution]">
                    <h2><xf:output ref="res:institutionLabel"/>
                        <xf:trigger appearance="minimal">
                            <xf:label><img src="http://openclipart.org/people/warszawianka/go-previous.svg"
                                width="28px" height="28px"/></xf:label>
                            <xf:toggle case="institution-view" ev:event="DOMActivate"/>
                        </xf:trigger>
                    </h2>
                    <div class="property">
                        <xf:input ref="res:institutionLabel" incremental="true">
                            <xf:label>Institution Name: </xf:label>
                        </xf:input>
                    </div>
                    <div class="property">
                        <xf:select1 ref="res:institutionType">
                            <xf:label>Institution Type: </xf:label>
                            <xf:itemset nodeset="instance('institutionTypes')/item">
                                <xf:label ref="itemLabel"/>
                                <xf:value ref="itemValue"/>
                            </xf:itemset>
                        </xf:select1>
                    </div>
                    <div class="property">
                        <xf:input ref="res:courseOfStudy">
                            <xf:label>Course(s) of Study: </xf:label>
                        </xf:input>
                    </div>
                    <div class="property">
                        <xf:input ref="res:certificate">
                            <xf:label>Certiface: </xf:label>
                        </xf:input>
                    </div>
                    <div class="property">
                        <xf:group ref="res:institutionInterval">
                        <xf:input ref="res:institutionDateStart">
                            <xf:label>Start Date: </xf:label>
                        </xf:input>
                        </xf:group>
                    </div>
                    <div class="property">
                        <xf:group ref="res:institutionInterval">
                        <xf:group ref=".[not(res:institutionDateEnd)]">
                            <div class="property">
                            <xf:trigger ref=".">
                                <xf:label>Add End Date</xf:label>
                                <xf:insert nodeset="res:institutionDateEnd" origin="instance('institutionDateEnd-template')"
                                at="1" position="after"
                                ev:event="DOMActivate"/>
                            </xf:trigger>
                            </div>
                        </xf:group>
                        <xf:input ref="res:institutionDateEnd">
                            <xf:label>End Date: </xf:label>
                        </xf:input>
                        <xf:trigger ref="res:institutionDateEnd">
                            <xf:label>&#215;</xf:label>
                            <xf:delete nodeset="." ev:event="DOMActivate"/>
                        </xf:trigger>
                        </xf:group>
                    </div>
                    <xf:group ref="res:institutionLocation">
                        <div class="property">
                            <xf:input ref="res:city" incremental="true">
                                <xf:label>City: </xf:label>
                            </xf:input>
                        </div>
                        <div class="property">
                            <xf:select1 ref="res:stateProvince" incremental="true">
                                <xf:label>State or Province: </xf:label>
                                <xf:itemset nodeset="instance('countryData')/country[countryCode = current()/../res:country]/stateProvinceSet/stateProvince">
                                    <xf:label ref="stateProvinceName"/>
                                    <xf:value ref="stateProvinceCode"/>
                                </xf:itemset>
                            </xf:select1>
                        </div>
                        <div class="property">
                            <xf:select1 ref="res:country" incremental="true">
                                <xf:label>Country: </xf:label>
                                <xf:itemset nodeset="instance('countryData')/country">
                                    <xf:label ref="countryName"/>
                                    <xf:value ref="countryCode"/>
                                </xf:itemset>
                            </xf:select1>
                        </div>
                    </xf:group>
                    <xf:textarea ref="res:description" class="large-textarea" mediatype="application/xhtml+xml"/>
                </xf:group>            
            </div>
            </xf:case>
            </xf:switch>
            </div>
        </xf:group>
        </xf:case>
        <xf:case id="projects" selected="false">
        <xf:group ref="res:projectSet">
            <h2>Projects and Employment</h2>
            <div class="projectContainer">
            <ul class="projectLinkDiv">
            <xf:repeat nodeset="res:project" id="projectLink-repeat">
                <li class="projectLink">
                    <xf:trigger ref="." appearance="minimal">
                    <xf:label>
                    <xf:output value="res:client"/>
                    </xf:label>
                    <xf:action ev:event="DOMActivate">
<!--                        <xf:setvalue ref="instance('state')/currentProject"
                            value="../res:project[index('projectLink-repeat')]/@id"/> -->
                        <xf:setvalue ref="instance('state')/currentProject"
                            value="index('projectLink-repeat')"/>
                    </xf:action>
                    </xf:trigger>
                    <xf:trigger appearance="minimal" class="projectLinkBtn" ref=".[instance('state')/enableEdit=true()]">
                        <xf:label class="insertBtn">+</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:insert nodeset="." 
                            origin="instance('project-template')"
                            at="index('projectLink-repeat')" position="after"/>
                        </xf:action>
                    </xf:trigger>
                    <xf:trigger appearance="minimal" class="projectLinkBtn" ref=".[instance('state')/enableEdit=true()]">
                        <xf:label class="deleteBtn">&#215;</xf:label>
                        <xf:action ev:event="DOMActivate">
                            <xf:delete nodeset="."/> 
                        </xf:action>
                    </xf:trigger>
                </li>
            </xf:repeat>
            </ul>
            <xf:switch>
            <xf:case id="project-view" selected="true">
            <div class="projectDiv">
                <xf:group ref="res:project[position() = instance('state')/*:currentProject]">
                    <h2><xf:output ref="res:client"/>
                        <xf:trigger appearance="minimal" ref=".[instance('state')/enableEdit=true()]">
                            <xf:label><img src="http://openclipart.org/people/darth_schmoo/1307548250.svg"
                        width="28px" height="28px"/></xf:label>
                            <xf:toggle case="project-edit" ev:event="DOMActivate"/>
                        </xf:trigger>
                    </h2>
                    <h3 class="projectRole"><xf:output ref="res:role"/></h3>
                    <div class="projectDates"><xf:output value="concat(mw:formatMonthYear(res:projectInterval/res:projectDateStart),' to ', mw:formatMonthYear(res:projectInterval/res:projectDateEnd))"/></div>
                    <xf:group ref="res:agency"><div class="projectAgency"><b>Agency: </b><xf:output ref="."/></div></xf:group>
                    <xf:group ref="res:projectLocation"><div class="projectLocation"><xf:output value="concat(res:city,', ',res:stateProvince,' ',if(res:country = 'CAN',res:country,''))"/></div></xf:group>
                    <div class="description"><xf:output value="res:description" mediatype="application/xhtml+xml"/></div>
                </xf:group>
            </div>
            </xf:case>
            <xf:case id="project-edit" selected="false">
            <div class="projectDiv">
                <xf:group ref="res:project[position() = instance('state')/*:currentProject]">
                    <h2><xf:output ref="res:client"/>
                        <xf:trigger appearance="minimal">
                            <xf:label><img src="http://openclipart.org/people/warszawianka/go-previous.svg"
                                width="28px" height="28px"/></xf:label>
                            <xf:toggle case="project-view" ev:event="DOMActivate"/>
                        </xf:trigger>
                    </h2>
                    <div class="property">
                        <xf:input ref="res:client" incremental="true">
                            <xf:label>Client: </xf:label>
                        </xf:input>
                    </div>
                    <div class="property">
                        <xf:input ref="res:role" incremental="true">
                            <xf:label>Role: </xf:label>
                        </xf:input>
                    </div>
                    <div class="property">
                        <xf:input ref="res:agency" incremental="true">
                            <xf:label>Agency: </xf:label>
                        </xf:input>
                    </div>
                    <div class="property">
                        <xf:group ref="res:projectInterval">
                        <xf:input ref="res:projectDateStart">
                            <xf:label>Start Date: </xf:label>
                        </xf:input>
                        </xf:group>
                    </div>
                    <div class="property">
                        <xf:group ref="res:projectInterval">
                        <xf:group ref=".[not(res:projectDateEnd)]">
                            <div class="property">
                            <xf:trigger ref=".">
                                <xf:label>Add End Date</xf:label>
                                <xf:insert nodeset="res:projectDateEnd" origin="instance('projectDateEnd-template')"
                                at="1" position="after"
                                ev:event="DOMActivate"/>
                            </xf:trigger>
                            </div>
                        </xf:group>
                        <xf:input ref="res:projectDateEnd">
                            <xf:label>End Date: </xf:label>
                        </xf:input>
                        <xf:trigger ref="res:projectDateEnd">
                            <xf:label>&#215;</xf:label>
                            <xf:delete nodeset="." ev:event="DOMActivate"/>
                        </xf:trigger>
                        </xf:group>
                    </div>
                    <xf:group ref="res:projectLocation">
                        <div class="property">
                            <xf:input ref="res:city" incremental="true">
                                <xf:label>City: </xf:label>
                            </xf:input>
                        </div>
                        <div class="property">
                            <xf:select1 ref="res:stateProvince" incremental="true">
                                <xf:label>State or Province: </xf:label>
                                <xf:itemset nodeset="instance('countryData')/country[countryCode = current()/../res:country]/stateProvinceSet/stateProvince">
                                    <xf:label ref="stateProvinceName"/>
                                    <xf:value ref="stateProvinceCode"/>
                                </xf:itemset>
                            </xf:select1>
                        </div>
                        <div class="property">
                            <xf:select1 ref="res:country" incremental="true">
                                <xf:label>Country: </xf:label>
                                <xf:itemset nodeset="instance('countryData')/country">
                                    <xf:label ref="countryName"/>
                                    <xf:value ref="countryCode"/>
                                </xf:itemset>
                            </xf:select1>
                        </div>
                    </xf:group>
                    <xf:textarea ref="res:description" class="large-textarea" mediatype="application/xhtml+xml"/>
                </xf:group>            
            </div>
            </xf:case>
            </xf:switch>
            </div>
        </xf:group>
        </xf:case>
        </xf:switch>
        </xf:group>
    </body>
    </html>)
    
    return $page
};

app:main()