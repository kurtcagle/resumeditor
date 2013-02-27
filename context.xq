module namespace context = "http://metaphoricalweb.com/xmlns/context";

declare function context:create-context($uri as xs:string) as item(){
    let $context := map:map()
    (: Hard coding these for now, will need to retrieve them from request context :)
    let $host := "prototype.eccnet.com"
    let $protocol := "http:"
    let $port := "8011"
    let $path := fn:substring-before($uri,"?")
    let $param-str := fn:substring-after($uri,"?")
    let $params := map:map()
    let $_ := for $paramSet in fn:tokenize($param-str,";|&amp;") return
        let $key := fn:substring-before($paramSet,"=")
        let $value := fn:substring-after($paramSet,"=")
        return map:put($params,$key,(map:get($params,$key),$value))
    let $_ := (map:put($params,"method",xdmp:get-request-method()),
            map:put($params,"face",(map:get($params,"face"),"xml")[1]),
            map:put($context,"path",$path),
            map:put($context,"host",$host),
            map:put($context,"port",$port),
            map:put($context,"protocol",$protocol),
            map:put($context,"params",$params)
            )
    return $context
    };
    
declare function context:create-param-string($context as item()) as xs:string {
    let $params := map:get($context,"params")
    return
    fn:string-join(for $key in map:keys($params) return fn:string-join(
          for $value in map:get($params,$key) return fn:concat($key,"=",$value),";"),";")
    };

declare function context:create-server-string($context as item()) as xs:string {
    fn:concat(map:get($context,"protocol"),"//",map:get($context,"host"),":",map:get($context,"port"),map:get($context,"path"))
    };


declare function context:clone($context as item()) as item(){
    let $new-context := map:map()
    let $_ :=  for $key in map:keys($context) return map:put($new-context,$key,map:get($context,$key))
    return $new-context
    };
