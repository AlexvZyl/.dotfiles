using Test

mutable struct URLTest
    name::String
    url::String
    isconnect::Bool
    expecteduri::URI
    shouldthrow::Bool
end

struct Offset
    off::UInt16
    len::UInt16
end

function parse_connect_target(target)
    t = parse(URI, "dummy://$target")
    if !isempty(t.userinfo) ||
       !isempty(t.path) ||
        isempty(t.host) ||
        isempty(t.port)

        throw(URIs.ParseError(""))
    end
    return t.host, t.port
end

function offset_uri(uri, offset)
    if offset == Offset(0,0)
        return SubString(uri, 1, 0)
    else
        return SubString(uri, offset.off, offset.off + offset.len-1)
    end
end

function URLTest(nm::String, url::String, isconnect::Bool, shouldthrow::Bool)
    URLTest(nm, url, isconnect, URI(""), shouldthrow)
end

function URLTest(nm::String, url::String, isconnect::Bool, offsets::NTuple{7, Offset}, shouldthrow::Bool)
    uri = URI(url, (offset_uri(url, o) for o in offsets)...)
    URLTest(nm, url, isconnect, uri, shouldthrow)
end

urls = [("hdfs://user:password@hdfshost:9000/root/folder/file.csv#frag", ["root", "folder", "file.csv"]),
            ("https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r#frag", ["path1", "path2;paramstring"]),
            ("https://user:password@httphost:9000/path1/path2?q=a&p=r#frag", ["path1","path2"]),
            ("https://user:password@httphost:9000/path1/path2;paramstring#frag", ["path1","path2;paramstring"]),
            ("https://user:password@httphost:9000/path1/path2#frag", ["path1","path2"]),
            ("file:///path/to/file/with%3fshould%3dwork%23fine", ["path","to","file","with%3fshould%3dwork%23fine"]),
            ("ftp://ftp.is.co.za/rfc/rfc1808.txt", ["rfc","rfc1808.txt"]),
            ("http://www.ietf.org/rfc/rfc2396.txt", ["rfc","rfc2396.txt"]),
            ("ldap://[2001:db8::7]/c=GB?objectClass?one", ["c=GB"]),
            ("mailto:John.Doe@example.com", ["John.Doe@example.com"]),
            ("news:comp.infosystems.www.servers.unix", ["comp.infosystems.www.servers.unix"]),
            ("tel:+1-816-555-1212", ["+1-816-555-1212"]),
            ("telnet://192.0.2.16:80/", []),
            ("urn:oasis:names:specification:docbook:dtd:xml:4.1.2", ["oasis:names:specification:docbook:dtd:xml:4.1.2"])
            ]

urltests = URLTest[
    URLTest("proxy request"
     ,"http://hostname/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(8, 8) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(16, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("proxy request with port"
     ,"http://hostname:444/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(8, 8) # UF_HOST
         ,Offset(17, 3) # UF_PORT
         ,Offset(20, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("CONNECT request"
     ,"hostname:443"
     ,true
         ,(Offset(0, 0) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(1, 8) # UF_HOST
         ,Offset(10, 3) # UF_PORT
         ,Offset(0, 0) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("proxy ipv6 request"
     ,"http://[1:2::3:4]/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(9, 8) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(18, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("proxy ipv6 request with port"
     ,"http://[1:2::3:4]:67/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(9, 8) # UF_HOST
         ,Offset(19, 2) # UF_PORT
         ,Offset(21, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("CONNECT ipv6 address"
     ,"[1:2::3:4]:443"
     ,true
         ,(Offset(0, 0) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(2, 8) # UF_HOST
         ,Offset(12, 3) # UF_PORT
         ,Offset(0, 0) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("ipv4 in ipv6 address"
     ,"http://[2001:0000:0000:0000:0000:0000:1.9.1.1]/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(9,37) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(47, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("extra ? in query string"
     ,"http://a.tbcdn.cn/p/fp/2010c/??fp-header-min.css,fp-base-min.css,fp-channel-min.css,fp-product-min.css,fp-mall-min.css,fp-category-min.css,fp-sub-min.css,fp-gdp4p-min.css,fp-css3-min.css,fp-misc-min.css?t=20101022.css"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(8,10) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(18,12) # UF_PATH
         ,Offset(31,187) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("space URL encoded"
     ,"/toto.html?toto=a%20b"
     ,false
         ,(Offset(0, 0) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(0, 0) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(1,10) # UF_PATH
         ,Offset(12,10) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("URL fragment"
     ,"/toto.html#titi"
     ,false
         ,(Offset(0, 0) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(0, 0) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(1,10) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(12, 4) # UF_FRAGMENT
         )
     ,false
     ), URLTest("complex URL fragment"
     ,"http://www.webmasterworld.com/r.cgi?f=21&d=8405&url=http://www.example.com/index.html?foo=bar&hello=world#midpage"
     ,false
     ,(Offset(  1,  4) # UF_SCHEMA
      ,Offset(  0,  0) # UF_USERINFO
      ,Offset(  8, 22) # UF_HOST
      ,Offset(  0,  0) # UF_PORT
      ,Offset( 30,  6) # UF_PATH
      ,Offset( 37, 69) # UF_QUERY
      ,Offset(107,  7) # UF_FRAGMENT
      )
     ,false
     ), URLTest("complex URL from node js url parser doc"
     ,"http://host.com:8080/p/a/t/h?query=string#hash"
     ,false
     ,(   Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(8, 8) # UF_HOST
         ,Offset(17, 4) # UF_PORT
         ,Offset(21, 8) # UF_PATH
         ,Offset(30,12) # UF_QUERY
         ,Offset(43, 4) # UF_FRAGMENT
         )
         ,false
     ), URLTest("complex URL with basic auth from node js url parser doc"
     ,"http://a:b@host.com:8080/p/a/t/h?query=string#hash"
     ,false
     ,(   Offset(1, 4) # UF_SCHEMA
         ,Offset(8, 3) # UF_USERINFO
         ,Offset(12, 8) # UF_HOST
         ,Offset(21, 4) # UF_PORT
         ,Offset(25, 8) # UF_PATH
         ,Offset(34,12) # UF_QUERY
         ,Offset(47, 4) # UF_FRAGMENT
         )
        ,false
     ), URLTest("double @"
     ,"http://a:b@@hostname:443/"
     ,false
     ,true
     ), URLTest("proxy empty host"
     ,"http://:443/"
     ,false
     ,true
     ), URLTest("proxy empty port"
     ,"http://hostname:/"
     ,false
     ,true
     ), URLTest("CONNECT with basic auth"
     ,"a:b@hostname:443"
     ,true
     ,true
     ), URLTest("CONNECT empty host"
     ,":443"
     ,true
     ,true
     ), URLTest("CONNECT empty port"
     ,"hostname:"
     ,true
     ,true
     ), URLTest("CONNECT with extra bits"
     ,"hostname:443/"
     ,true
     ,true
     ), URLTest("space in URL"
     ,"/foo bar/"
     ,false
     ,true # s_dead
     ), URLTest("proxy basic auth with space url encoded"
     ,"http://a%20:b@host.com/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
          ,Offset(8, 6) # UF_USERINFO
          ,Offset(15, 8) # UF_HOST
          ,Offset(0, 0) # UF_PORT
          ,Offset(23, 1) # UF_PATH
          ,Offset(0, 0) # UF_QUERY
          ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("carriage return in URL"
     ,"/foo\rbar/"
     ,false
     ,true # s_dead
     ), URLTest("proxy double : in URL"
     ,"http://hostname::443/"
     ,false
     ,true # s_dead
     ), URLTest("proxy basic auth with double :"
     ,"http://a::b@host.com/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(8, 4) # UF_USERINFO
         ,Offset(13, 8) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(21, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("line feed in URL"
     ,"/foo\nbar/"
     ,false
     ,true # s_dead
     ), URLTest("proxy empty basic auth"
     ,"http://@hostname/fo"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(9, 8) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(17, 3) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("proxy line feed in hostname"
     ,"http://host\name/fo"
     ,false
     ,true # s_dead
     ), URLTest("proxy % in hostname"
     ,"http://host%name/fo"
     ,false
     ,true # s_dead
     ), URLTest("proxy ; in hostname"
     ,"http://host;ame/fo"
     ,false
     ,true # s_dead
     ), URLTest("proxy basic auth with unreservedchars"
     ,"http://a!;-_!=+\$@host.com/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(8, 9) # UF_USERINFO
         ,Offset(18, 8) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(26, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("proxy only empty basic auth"
     ,"http://@/fo"
     ,false
     ,true # s_dead
     ), URLTest("proxy only basic auth"
     ,"http://toto@/fo"
     ,false
     ,true # s_dead
     ), URLTest("proxy = in URL"
     ,"http://host=ame/fo"
     ,false
     ,true # s_dead
     ), URLTest("ipv6 address with Zone ID"
     ,"http://[fe80::a%25eth0]/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(9,14) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(24, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("ipv6 address with Zone ID, but '%' is not percent-encoded"
     ,"http://[fe80::a%eth0]/"
     ,false
         ,(Offset(1, 4) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(9,12) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(22, 1) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("ipv6 address ending with '%'"
     ,"http://[fe80::a%]/"
     ,false
     ,true # s_dead
     ), URLTest("ipv6 address with Zone ID including bad character"
     ,"http://[fe80::a%\$HOME]/"
     ,false
     ,true # s_dead
     ), URLTest("just ipv6 Zone ID"
     ,"http://[%eth0]/"
     ,false
     ,true # s_dead
     ), URLTest("tab in URL"
     ,"/foo\tbar/"
     ,false
         ,(Offset(0, 0) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(0, 0) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(1, 9) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     ), URLTest("form feed in URL"
     ,"/foo\fbar/"
     ,false
         ,(Offset(0, 0) # UF_SCHEMA
         ,Offset(0, 0) # UF_USERINFO
         ,Offset(0, 0) # UF_HOST
         ,Offset(0, 0) # UF_PORT
         ,Offset(1, 9) # UF_PATH
         ,Offset(0, 0) # UF_QUERY
         ,Offset(0, 0) # UF_FRAGMENT
         )
     ,false
     )
]

@testset "URI" begin
    @testset "Constructors" begin
        @test string(URI("")) == ""
        @test URI(scheme="http", host="google.com") == URI("http://google.com")
        @test URI(scheme="http", host="google.com", path="/") == URI("http://google.com/")
        @test URI(scheme="http", host="google.com", userinfo="user") == URI("http://user@google.com")
        @test URI(scheme="http", host="google.com", path="/user") == URI("http://google.com/user")
        @test URI(scheme="http", host="google.com", query=Dict("key"=>"value")) == URI("http://google.com?key=value")
        @test URI(scheme="http", host="google.com", query=Dict()) |> string == "http://google.com"
        @test URI(scheme="http", host="google.com", path="/", fragment="user") == URI("http://google.com/#user")

        # Precondition error messages refer to the function name (#32)
        @test_throws ArgumentError("URI() requires `scheme in uses_authority || isempty(host)`") URI(; host="example.com")
    end

    @testset "URIs.splitpath" begin
        @test URIs.splitpath("") == []
        @test URIs.splitpath("/") == []
        @test URIs.splitpath("a") == ["a"]
        @test URIs.splitpath("/a") == ["a"]
        @test URIs.splitpath("/a/bb/ccc") == ["a", "bb", "ccc"]
        # Support for stripping ? and # sufficies.
        # Shouldn't arise if used with url.path, where this part of the parsing
        # will already be done.
        @test URIs.splitpath("/a/b?query") == ["a", "b"]
        @test URIs.splitpath("/a/b#query/c") == ["a", "b"]
        @test URIs.splitpath("/a/b#frag") == ["a", "b"]

        # Support for non-ASCII code points — may arise after percent decoding
        @test URIs.splitpath("/α") == ["α"]
        @test URIs.splitpath("α/ββ/γγγ") == ["α", "ββ", "γγγ"]

        # Trailing slash handling
        @test URIs.splitpath("/a/") == ["a"]
        @test URIs.splitpath("/a/", rstrip_empty_segment=false) == ["a", ""]

        # URIs can be provided
        @test URIs.splitpath(URI("http://example.com/a/bb?query#frag")) == ["a", "bb"]
        @test URIs.splitpath(URI("http://example.com/a/bb/"),
                             rstrip_empty_segment=false) == ["a", "bb", ""]

        # Other cases
        @testset "$url - $splpath" for (url, splpath) in urls
            u = parse(URI, url)
            @test string(u) == url
            @test isvalid(u)
            @test URIs.splitpath(u) == splpath
        end
    end

    @testset "Parse" begin
        @test parse(URI, "hdfs://user:password@hdfshost:9000/root/folder/file.csv") == URI(host="hdfshost", path="/root/folder/file.csv", scheme="hdfs", port=9000, userinfo="user:password")
        @test parse(URI, "ssh://testuser@test.com") == URI(scheme = "ssh",  host="test.com", userinfo="testuser")
        @test parse(URI, "http://google.com:80/some/path") == URI(scheme="http", host="google.com", path="/some/path")

        @test parse(URI, "https://user:password@httphost:9000/path1/path2;paramstring?q=a&p=r#frag").userinfo == "user:password"

        @test false == isvalid(parse(URI, "file:///path/to/file/with?should=work#fine"))
        @test true == isvalid(parse(URI, "file:///path/to/file/with%3fshould%3dwork%23fine"))

        @test parse(URI, "s3://bucket/key") == URI(host="bucket", path="/key", scheme="s3")

        @test sprint(show, parse(URI, "http://google.com")) == "URI(\"http://google.com\")"
    end

    @testset "Characters" begin
        @test escapeuri(Char(1)) == "%01"

        @test escapeuri(Dict("key1"=>"value1", "key2"=>["value2", "value3"])) == "key2=value2&key2=value3&key1=value1"

        @test escapeuri("abcdef αβ 1234-=~!@#\$()_+{}|[]a;") == "abcdef%20%CE%B1%CE%B2%201234-%3D%7E%21%40%23%24%28%29_%2B%7B%7D%7C%5B%5Da%3B"
        @test unescapeuri(escapeuri("abcdef 1234-=~!@#\$()_+{}|[]a;")) == "abcdef 1234-=~!@#\$()_+{}|[]a;"
        @test unescapeuri(escapeuri("👽")) == "👽"

        @test escapeuri([("foo", "bar"), (1, 2)]) == "foo=bar&1=2"
        @test escapeuri(Dict(["foo" => "bar", 1 => 2])) in ("1=2&foo=bar", "foo=bar&1=2")
        @test escapeuri(["foo" => "bar", 1 => 2]) == "foo=bar&1=2"
    end

    @testset "Query Params" begin
        @test queryparams(URI("http://example.com"))::Dict{String,String} == Dict()
        @test queryparams(URI("https://httphost/path1/path2;paramstring?q=a&p=r#frag")) == Dict("q"=>"a","p"=>"r")
        @test queryparams(URI("https://foo.net/?q=a&malformed")) == Dict("q"=>"a","malformed"=>"")
        @test queryparampairs(URI("http://example.com?a=b&a=c&a=d"))::Vector{Pair{String, String}} == ["a" => "b", "a" => "c", "a" => "d"]
    end

    @testset "Parse Errors" begin
        # Non-ASCII characters
        @test_throws URIs.ParseError URIs.parse_uri("http://🍕.com", strict=true)
        # Unexpected start of URL
        @test_throws URIs.ParseError URIs.parse_uri(".google.com", strict=true)
        # Unexpected character after scheme
        @test_throws URIs.ParseError URIs.parse_uri("ht!tp://google.com", strict=true)
    end

    @testset "parse(URI, str) - $u" for u in urltests
        if u.isconnect
            if u.shouldthrow
                @test_throws URIs.ParseError parse_connect_target(u.url)
            else
                h, p = parse_connect_target(u.url)
                @test h == u.expecteduri.host
                @test p == u.expecteduri.port
            end
        elseif u.shouldthrow
            @test_throws URIs.ParseError URIs.parse_uri_reference(u.url, strict=true)
        else
            url = parse(URI, u.url)
            @test u.expecteduri == url
        end
    end

    @testset "Issue Specific" begin
        #  Issue #27
        @test escapeuri("t est\n") == "t%20est%0A"

        # Issue 323
        @test string(URI(scheme="http", host="example.com")) == "http://example.com"

        # Issue 475
        @test queryparams(URI("http://www.example.com/path/foo+bar/path?query+name=query+value")) ==
            Dict("query name" => "query value")
        @test queryparams(escapeuri(Dict("a+b" => "c d+e"))) == Dict("a+b" => "c d+e")

        # Issue 540
        @test escapeuri((a=1, b=2)) == "a=1&b=2"
    end

    @testset "Normalize URI paths" begin
        # Examples given in https://tools.ietf.org/html/rfc3986#section-5.2.4
        @test URIs.normpath("/a/b/c/./../../g") == "/a/g"
        @test URIs.normpath("mid/content=5/../6") == "mid/6"

        checknp = (x, y)->(@test URIs.normpath(URI(x)) == URI(y))

        # "Abnormal" examples in https://tools.ietf.org/html/rfc3986#section-5.4.2
        checknp("http://a/b/c/d/../../../g", "http://a/g")
        checknp("http://a/b/c/d/../../../../g", "http://a/g")
        checknp("http://a/b/c/g.", "http://a/b/c/g.")
        checknp("http://a/b/c/g..", "http://a/b/c/g..")

        # "Normal" examples
        checknp("http://a", "http://a")
        checknp("http://a/b/c/.", "http://a/b/c/")
        checknp("http://a/b/c/./", "http://a/b/c/")
        checknp("http://a/b/c/..", "http://a/b/")
        checknp("http://a/b/c/../", "http://a/b/")
        checknp("http://a/b/c/../g", "http://a/b/g")
        checknp("http://a/b/c/../..", "http://a/")
        checknp("http://a/b/c/../../", "http://a/")
        checknp("http://a/b/c/../../g", "http://a/g")
    end

    @testset "joinpath" begin
        @test joinpath(URIs.URI("http://a.b.c/d/e/f"), "a/b", "c") == URI("http://a.b.c/d/e/f/a/b/c")
        @test joinpath(URIs.URI("http://a.b.c/d/../f"), "a/b", "c") == URI("http://a.b.c/f/a/b/c")
        @test joinpath(URIs.URI("http://a.b.c/d/f"), "/b", "c") == URI("http://a.b.c/b/c")
        @test joinpath(URIs.URI("http://a.b.c/"), "b", "c") == URI("http://a.b.c/b/c")
        @test joinpath(URIs.URI("http://a.b.c"), "b", "c") == URI("http://a.b.c/b/c")
    end

    @testset "resolvereference" begin
        # Reference: IETF RFC 3986: https://datatracker.ietf.org/doc/html/rfc3986
        # Tests for resolving URI references, as defined in Section 5.4

        # Perform some basic tests resolving absolute and relative references to a base URI
        uri = URI("http://example.org/foo/bar/")
        @test resolvereference(uri, "/baz") == URI("http://example.org/baz")
        @test resolvereference(uri, "baz/") == URI("http://example.org/foo/bar/baz/")
        @test resolvereference(uri, "../baz/") == URI("http://example.org/foo/baz/")

        # If the base URI's path doesn't end with a /, we handle relative URIs a little differently
        uri = URI("http://example.org/foo/bar")
        @test resolvereference(uri, "baz") == URI("http://example.org/foo/baz")
        @test resolvereference(uri, "../baz") == URI("http://example.org/baz")

        # If the second URI is absolute, or the first URI isn't, we should just return the
        # second URI.
        @test resolvereference("http://www.example.org", "http://example.com") == URI("http://example.com")
        @test resolvereference("http://example.org/foo", "http://example.org/bar") == URI("http://example.org/bar")
        @test resolvereference("/foo", "/bar/baz") == URI("/bar/baz")

        # "Normal examples" specified in Section 5.4.1
        base = URI("http://a/b/c/d;p?q")
        @test resolvereference(base, "g:h") == URI("g:h")
        @test resolvereference(base, "g") == URI("http://a/b/c/g")
        @test resolvereference(base, "./g") == URI("http://a/b/c/g")
        @test resolvereference(base, "g/") == URI("http://a/b/c/g/")
        @test resolvereference(base, "/g") == URI("http://a/g")
        @test resolvereference(base, "//g") == URI("http://g")
        @test resolvereference(base, "?y") == URI("http://a/b/c/d;p?y")
        @test resolvereference(base, "g?y") == URI("http://a/b/c/g?y")
        @test resolvereference(base, "#s") == URI("http://a/b/c/d;p?q#s")
        @test resolvereference(base, "g#s") == URI("http://a/b/c/g#s")
        @test resolvereference(base, "g?y#s") == URI("http://a/b/c/g?y#s")
        @test resolvereference(base, ";x") == URI("http://a/b/c/;x")
        @test resolvereference(base, "g;x") == URI("http://a/b/c/g;x")
        @test resolvereference(base, "g;x?y#s") == URI("http://a/b/c/g;x?y#s")
        @test resolvereference(base, "") == URI("http://a/b/c/d;p?q")
        @test resolvereference(base, ".") == URI("http://a/b/c/")
        @test resolvereference(base, "./") == URI("http://a/b/c/")
        @test resolvereference(base, "..") == URI("http://a/b/")
        @test resolvereference(base, "../") == URI("http://a/b/")
        @test resolvereference(base, "../g") == URI("http://a/b/g")
        @test resolvereference(base, "../..") == URI("http://a/")
        @test resolvereference(base, "../../") == URI("http://a/")
        @test resolvereference(base, "../../g") == URI("http://a/g")

        # "Abnormal examples" specified in Section 5.4.2
        @test resolvereference(base, "../../../g") == URI("http://a/g")
        @test resolvereference(base, "../../../../g") == URI("http://a/g")

        @test resolvereference(base, "/./g") == URI("http://a/g")
        @test resolvereference(base, "/../g") == URI("http://a/g")
        @test resolvereference(base, "g.") == URI("http://a/b/c/g.")
        @test resolvereference(base, ".g") == URI("http://a/b/c/.g")
        @test resolvereference(base, "g..") == URI("http://a/b/c/g..")
        @test resolvereference(base, "..g") == URI("http://a/b/c/..g")

        @test resolvereference(base, "./../g") == URI("http://a/b/g")
        @test resolvereference(base, "./g/.") == URI("http://a/b/c/g/")
        @test resolvereference(base, "g/./h") == URI("http://a/b/c/g/h")
        @test resolvereference(base, "g/../h") == URI("http://a/b/c/h")
        @test resolvereference(base, "g;x=1/./y") == URI("http://a/b/c/g;x=1/y")
        @test resolvereference(base, "g;x=1/../y") == URI("http://a/b/c/y")

        @test resolvereference(base, "g?y/./x") == URI("http://a/b/c/g?y/./x")
        @test resolvereference(base, "g?y/../x") == URI("http://a/b/c/g?y/../x")
        @test resolvereference(base, "g#s/./x") == URI("http://a/b/c/g#s/./x")
        @test resolvereference(base, "g#s/../x") == URI("http://a/b/c/g#s/../x")
    end

    @testset "error testing tools" begin
        function foo(x, y)
            URIs.@require x > 10
            URIs.@ensure y > 10
        end

        @test_throws ArgumentError("foo() requires `x > 10`") foo(1, 11)
        @test_throws AssertionError("foo() failed to ensure `y > 10`\ny = 1\n10 = 10") foo(11, 1)
    end
end
