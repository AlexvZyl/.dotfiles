@testset "Core" begin
    @test sprint(showerror, JSONRPC.JSONRPCError(-32700, "FOO", "BAR")) == "ParseError: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32600, "FOO", "BAR")) == "InvalidRequest: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32601, "FOO", "BAR")) == "MethodNotFound: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32602, "FOO", "BAR")) == "InvalidParams: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32603, "FOO", "BAR")) == "InternalError: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32099, "FOO", "BAR")) == "serverErrorStart: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32000, "FOO", "BAR")) == "serverErrorEnd: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32002, "FOO", "BAR")) == "ServerNotInitialized: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32001, "FOO", "BAR")) == "UnknownErrorCode: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32800, "FOO", "BAR")) == "RequestCancelled: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(-32801, "FOO", "BAR")) == "ContentModified: FOO (BAR)"
    @test sprint(showerror, JSONRPC.JSONRPCError(1, "FOO", "BAR")) == "Unkonwn: FOO (BAR)"
end
