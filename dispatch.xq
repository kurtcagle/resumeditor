import module namespace context="http://metaphoricalweb.com/xmlns/context" at "/modules/context.xq";

declare function local:main(){
    let $uri := xdmp:get-request-url()
    let $pre-question := if (fn:matches($uri,"\?")) then fn:substring-before($uri,"?") else $uri
    let $invoked-service := fn:replace($uri,"^/(.*?)/.*","$1")
    let $virtual-url := fn:replace($uri,"^/.*?/(.*)","$1")
    let $context := context:create-context($uri)
    let $param-str := context:create-param-string($context)
    let $server-str := context:create-server-string($context)
    let $url := 
        if (fn:matches($uri,"^/lib/.+")) then $uri else
        if (fn:matches($uri,"^/resume/.*|^/resume\?.*|/resume$")) then 
            fn:concat("/apps/resume/app.xq?uri=",$server-str,"?",$param-str)
        else
            fn:concat("/lib/sandbox/test.xq?uri=",$server-str,"?",$param-str)
    return $url
    };
        
local:main()































