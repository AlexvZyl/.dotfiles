baremodule CoreTypes # Convenience
using ..SymbolServer
using Base: ==, @static

const Any = SymbolServer.stdlibs[:Core][:Any]
const DataType = SymbolServer.stdlibs[:Core][:DataType]
const Function = SymbolServer.stdlibs[:Core][:Function]
const Module = SymbolServer.stdlibs[:Core][:Module]
const String = SymbolServer.stdlibs[:Core][:String]
const Char = SymbolServer.stdlibs[:Core][:Char]
const Symbol = SymbolServer.stdlibs[:Core][:Symbol]
const Bool = SymbolServer.stdlibs[:Core][:Bool]
const Int = SymbolServer.stdlibs[:Core][:Int]
const UInt8 = SymbolServer.stdlibs[:Core][:UInt8]
const UInt16 = SymbolServer.stdlibs[:Core][:UInt16]
const UInt32 = SymbolServer.stdlibs[:Core][:UInt32]
const UInt64 = SymbolServer.stdlibs[:Core][:UInt64]
const Float64 = SymbolServer.stdlibs[:Core][:Float64]
const Vararg = SymbolServer.FakeTypeName(Core.Vararg)

iscoretype(x, name) = false
iscoretype(x::SymbolServer.VarRef, name) = x isa SymbolServer.DataTypeStore && x.name.name == name && x.name isa SymbolServer.VarRef && x.name.parent.name == :Core
iscoretype(x::SymbolServer.DataTypeStore, name) = x isa SymbolServer.DataTypeStore && x.name.name.name == name && x.name.name isa SymbolServer.VarRef && x.name.name.parent.name == :Core
isdatatype(x) = iscoretype(x, :DataType)
isfunction(x) = iscoretype(x, :Function)
ismodule(x) = iscoretype(x, :Module)
isstring(x) = iscoretype(x, :String)
ischar(x) = iscoretype(x, :Char)
issymbol(x) = iscoretype(x, :Symbol)
@static if Core.Int == Core.Int64
    isint(x) = iscoretype(x, :Int64)
else
    isint(x) = iscoretype(x, :Int32)
end
isfloat(x) = iscoretype(x, :Float64)
isvector(x) = iscoretype(x, :Vector)
isarray(x) = iscoretype(x, :Array)
isva(x::SymbolServer.FakeUnionAll) = isva(x.body)
@static if Core.Vararg isa Core.Type
    function isva(x)
        return (x isa SymbolServer.FakeTypeName && x.name.name == :Vararg &&
            x.name.parent isa SymbolServer.VarRef && x.name.parent.name == :Core)
    end
else
    isva(x) = x isa SymbolServer.FakeTypeofVararg
end
end
