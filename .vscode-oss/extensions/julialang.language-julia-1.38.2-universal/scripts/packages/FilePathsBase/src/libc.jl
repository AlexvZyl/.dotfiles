@static if Sys.isapple()
    struct Cpasswd
        pw_name::Cstring
        pw_passwd::Cstring
        pw_uid::Cint
        pw_gid::Cint
        pw_change::Cint
        pw_class::Cstring
        pw_gecos::Cstring
        pw_dir::Cstring
        pw_shell::Cstring
        pw_expire::Cint
        pw_fields::Cint
    end
elseif Sys.islinux()
    struct Cpasswd
       pw_name::Cstring
       pw_passwd::Cstring
       pw_uid::Cint
       pw_gid::Cint
       pw_gecos::Cstring
       pw_dir::Cstring
       pw_shell::Cstring
    end
else
    struct Cpasswd
        pw_name::Cstring
        pw_uid::Cint
        pw_gid::Cint
        pw_dir::Cstring
        pw_shell::Cstring
    end

    Cpasswd() = Cpasswd(pointer("NA"), 0, 0, pointer("NA"), pointer("NA"))
end

struct Cgroup
    gr_name::Cstring
    gr_passwd::Cstring
    gr_gid::Cint
end

Cgroup() = Cgroup(pointer("NA"), pointer("NA"), 0)

struct User
    name::String
    uid::UInt64
    gid::UInt64
    dir::String
    shell::String
end

function User(ps::Cpasswd)
    User(
        unsafe_string(ps.pw_name),
        UInt64(ps.pw_uid),
        UInt64(ps.pw_gid),
        unsafe_string(ps.pw_dir),
        unsafe_string(ps.pw_shell)
    )
end

User(passwd::Ptr{Cpasswd}) = User(unsafe_load(passwd))
Base.show(io::IO, user::User) = print(io, "$(user.uid) ($(user.name))")

@static if Sys.isunix()
    function User(name::String)
        Libc.errno(0)
        ps = ccall(:getpwnam, Ptr{Cpasswd}, (Ptr{UInt8},), name)
        ret = Libc.errno()

        systemerror(:getpwnam, !iszero(ret))
        ps == C_NULL && throw(ArgumentError("User $name not found."))

        return User(ps)
    end

    function User(uid::UInt)
        Libc.errno(0)
        ps = ccall(:getpwuid, Ptr{Cpasswd}, (UInt64,), uid)
        ret = Libc.errno()

        systemerror(:getpwuid, !iszero(ret))

        if ps == C_NULL
            @warn "User $uid not found."
            return User("NA", uid, uid, "NA", "NA")
        else
            return User(ps)
        end
    end

    User() = User(UInt(ccall(:geteuid, Cint, ())))
else
    User(name::String) = User(Cpasswd())
    User(uid::UInt) = User(Cpasswd())
    User() = User(UInt64(0))
end

struct Group
    name::String
    gid::UInt64
end

Group(gr::Cgroup) = Group(unsafe_string(gr.gr_name), UInt64(gr.gr_gid))
Group(group::Ptr{Cgroup}) = Group(unsafe_load(group))
Base.show(io::IO, group::Group) = print(io, "$(group.gid) ($(group.name))")

@static if Sys.isunix()
    function Group(name::String)
        Libc.errno(0)
        gr = ccall(:getgrnam, Ptr{Cgroup}, (Ptr{UInt8},), name)
        ret = Libc.errno()

        systemerror(:getgrnam, !iszero(ret))
        gr == C_NULL && throw(ArgumentError("Group $name not found."))
        return Group(gr)
    end

    function Group(gid::UInt)
        Libc.errno(0)
        gr = ccall(:getgrgid, Ptr{Cgroup}, (UInt64,), gid)
        ret = Libc.errno()

        systemerror(:getgrgid, !iszero(ret))
        if gr == C_NULL
            @warn "Group $gid not found."
            return Group("NA", gid)
        else
            return Group(gr)
        end
    end

    Group() = Group(UInt(ccall(:getegid, Cint, ())))
else
    Group(name::String) = Group(Cgroup())
    Group(uid::UInt) = Group(Cgroup())
    Group() = Group(UInt64(0))
end
