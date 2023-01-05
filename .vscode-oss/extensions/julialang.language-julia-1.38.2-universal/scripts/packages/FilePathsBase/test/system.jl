ps = PathSet(; symlink=true)

@testset "$(typeof(ps.root))" begin
    testsets = [
        test_registration,
        test_show,
        test_cmd,
        test_parse,
        test_convert,
        test_components,
        test_indexing,
        test_iteration,
        test_parents,
        test_descendants_and_ascendants,
        test_join,
        test_splitext,
        test_basename,
        test_splitdir,
        test_filename,
        test_extensions,
        test_isempty,
        test_normalize,
        test_canonicalize,
        test_relative,
        test_absolute,
        test_isdir,
        test_isfile,
        test_stat,
        test_filesize,
        test_modified,
        test_created,
        test_cd,
        test_readpath,
        test_walkpath,
        test_read,
        test_write,
        test_mkdir,
        test_cp,
        test_mv,
        test_sync,
        test_symlink,
        test_touch,
        test_tmpname,
        test_tmpdir,
        test_mktmp,
        test_mktmpdir,
        test_download,
        test_include,
    ]

    if isa(ps.root, PosixPath)
        append!(
            testsets,
            [
                test_issocket,
                test_isfifo,
                test_ischardev,
                test_isblockdev,
                test_ismount,
                test_isexecutable,
                test_isreadable,
                test_iswritable,
                test_chown,
                test_chmod,
            ]
        )
    end

    # Run all of the automated tests
    test(ps, testsets)

    # Test the system path specific macros, behaviour and properties
    cd(absolute(parent(Path(@__FILE__)))) do
        @testset "Simple System Path Usage" begin
            reg = Sys.iswindows() ? "..\\src\\FilePathsBase.jl" : "../src/FilePathsBase.jl"
            @test ispath(reg)

            p = Path(reg)

            # Test calling the Path tryparse method with debug mode.
            p = tryparse(AbstractPath, reg; debug=true)

            @test p == p"../src/FilePathsBase.jl"
            @test string(p) == reg
            @test string(cwd()) == pwd()
            @test string(home()) == homedir()

            @test p.segments == ("..", "src", "FilePathsBase.jl")
            @test hasparent(p)
            @test parent(p) == p"../src"
            @test parents(p) == [p"..", p"../src"]
            @test parents(p".") == [p"."]

            @test basename(p) == "FilePathsBase.jl"
            @test join(parent(p), Path(basename(p))) == p
            @test joinpath(parent(p), Path(basename(p))) == p
            @test parent(p) / basename(p) == p
            @test parent(p) * "/" * basename(p) == p
            @test p"foo" / "bar" * ".txt" == p"foo/bar.txt"
            @test filename(p) == "FilePathsBase"

            @test extension(p) == "jl"
            @test extension(p"../REQUIRE") == ""
            @test extensions(p"foo.tar.gz") == ["tar", "gz"]
            @test length(extensions(p"../REQUIRE")) == 0

            @test exists(p)
            @test !isabsolute(p)
            @test string(normalize(p"../src/../src/FilePathsBase.jl")) == normpath("../src/../src/FilePathsBase.jl")
            @test string(absolute(p)) == abspath(string(p))
            @test sprint(show, p"../README.md") == "p\"../README.md\""

            # This works around an issue with Base.relpath: that function does not take
            # into account the paths on Windows should be compared case insensitive.
            homedir_patched = homedir()
            if Sys.iswindows()
                conv_f = isuppercase(abspath(string(p))[1]) ? uppercase : lowercase
                homedir_patched = conv_f(homedir_patched[1]) * homedir_patched[2:end]
            elseif Sys.isunix()
                contracted_path = p"~/opt/foo/bar.jl"
                expanded_path = joinpath(home(), "opt/foo/bar.jl")
                @test expanduser(contracted_path) == expanded_path
                @test contractuser(expanded_path) == contracted_path

                # relpath isn't entirely consistent for windows on julia 1.5
                # https://github.com/rofinn/FilePathsBase.jl/issues/107
                @test string(relative(p, home())) == relpath(string(p), homedir_patched)
            end

            @test isa(relative(Path(".")), AbstractPath)
            @test relative(Path(".")) == Path(".")

            @test canonicalize(p"../test/mode.jl") == Path(realpath("../test/mode.jl"))

            s = stat(p)
            lstat(p)

            show_str = sprint(show, s)
            #@test "device" in show_str
            #@test "blocks" in show_str

            @test filesize(p) == stat(p).size
            @test modified(p) == stat(p).mtime
            @test created(p) == stat(p).ctime

            @test isfile(p)
            @test isdir(parent(p))
            @test !islink(p)
            @test !issocket(p)
            @test !isfifo(p)
            @test !ischardev(p)
            @test !isblockdev(p)

            p1 = WindowsPath(("foo", "bar"))
            @test p1.segments == ("foo", "bar")
            @test p1.drive == ""
            @test p1.root == ""

            p2 = WindowsPath(("foo", "bar"); root="\\", drive="C:")
            @test p2.segments == ("foo", "bar")
            @test p2.drive == "C:"
            @test p2.root == "\\"

            p3 = WindowsPath(("foo", "bar"); drive="C:")
            @test p3.segments == ("foo", "bar")
            @test p3.drive == "C:"
            @test p3.root == ""

            p4 = WindowsPath("C:\\User\\Documents")
            @test p4.segments == ("User", "Documents")
            @test p4.drive == "C:"
            @test p4.root == "\\"

            @test @__PATH__() == Path(@__DIR__)
            @test @__FILEPATH__() == Path(@__FILE__)
            @test FilePathsBase.@LOCAL("foo.txt") == join(@__PATH__, "foo.txt")
            @test FilePathsBase.@LOCAL("foo.txt") == joinpath(@__PATH__, "foo.txt")
        end

        # Just to be safe we're going to ensure that all Filesystem aliases have the
        # same behaviour, apart from different return types.
        # NOTE: These tests aren't part of the TestPaths test suite because we explicitly want
        # to compare behaviour of the `SystemPath`s again what `Base.Filesystem` does.
        @testset "Filesystem Aliases" begin
            @testset "joinpath" begin
                # Test general usage
                segments = ("..", "src", "FilePathsBase.jl")
                res = joinpath(cwd(), segments...)
                @test res isa SystemPath
                @test string(res) == joinpath(pwd(), segments...)

                # Test trailing absolute path.
                segments = (segments..., pwd())
                res = joinpath(cwd(), segments...)
                @test string(res) == joinpath(pwd(), segments...)
            end

            @testset "basename" begin
                @test basename(p"../src/FilePathsBase.jl") == basename("../src/FilePathsBase.jl")
            end

            @testset "splitext" begin
                fp = p"../src/FilePathsBase.jl"
                pathname, ext = splitext(fp)
                @test pathname isa SystemPath
                @test ext isa AbstractString
                @test (string(pathname), ext) == splitext(string(fp))
            end

            @testset "ispath" begin
                fp = joinpath(cwd(), "..", "src", "FilePathsBase.jl")
                @test ispath(fp)
                @test ispath(string(fp))
            end

            @testset "normpath" begin
                fp = joinpath(cwd(), "..", "src", "FilePathsBase.jl")
                res = normpath(fp)
                @test res isa SystemPath
                @test string(res) == normpath(string(fp))
            end

            @testset "relpath" begin
                rel_str = joinpath("..", "src", "FilePathsBase.jl")
                rel_fp = Path(rel_str)
                @test relpath(abspath(rel_str)) == rel_str
                @test string(relpath(absolute(rel_fp))) == rel_str

                # Test the 2 argument form
                @test relpath(abspath(rel_str), pwd()) == rel_str
                @test string(relpath(absolute(rel_fp), cwd())) == rel_str

                # Test src as file
                res_str = joinpath("..", "..", "src", "FilePathsBase.jl")
                src_str = joinpath(pwd(), "system.jl")
                src_fp = Path(src_str)
                @test relpath(abspath(rel_str), src_str) == res_str
                @test string(relpath(absolute(rel_fp), src_fp)) == res_str
            end

            @testset "abspath" begin
                fp = joinpath("..", "docs", "src", "index.md")
                res = abspath(Path(fp))
                @test res isa SystemPath
                @test string(res) == abspath(fp)
            end

            @testset "realpath" begin
                # index.md is a symlink to README.md
                fp = joinpath(cwd(), "..", "docs", "src", "index.md")
                res = realpath(fp)
                @test res isa SystemPath
                @test string(res) == realpath(string(fp))
            end

            @testset "stat" begin
                function compare_stats(sp, ss)
                    @test sp isa FilePathsBase.Status
                    @test ss isa StatStruct

                    @test sp.device == ss.device
                    @test sp.inode == ss.inode
                    @test sp.mode != ss.mode
                    @test sp.mode.m == ss.mode
                    @test sp.nlink == ss.nlink
                    @test sp.user != ss.uid
                    @test sp.user.uid == ss.uid
                    @test sp.group != ss.gid
                    @test sp.group.gid == ss.gid
                    @test sp.rdev == ss.rdev
                    @test sp.size == ss.size
                    @test sp.blksize == ss.blksize
                    @test sp.blocks == ss.blocks
                    @test sp.mtime != ss.mtime
                    @test datetime2unix(sp.mtime) ≈ ss.mtime
                    @test sp.ctime != ss.ctime
                    @test datetime2unix(sp.ctime) ≈ ss.ctime
                end

                fp = joinpath(cwd(), "..", "docs", "src", "index.md")
                compare_stats(stat(fp), stat(string(fp)))
                compare_stats(lstat(fp), lstat(string(fp)))
            end

            @testset "User/Group constructors" begin
                my_user = FilePathsBase.User()
                my_group = FilePathsBase.Group()

                u_int = FilePathsBase.User(UInt(my_user.uid))
                g_int = FilePathsBase.Group(UInt(my_group.gid))

                @test u_int isa FilePathsBase.User
                @test g_int isa FilePathsBase.Group
                @test u_int.uid isa Unsigned
                @test g_int.gid isa Unsigned

                # Non-existent user or group on unix
                if Sys.isunix()
                    u_int = FilePathsBase.User(UInt(9999))
                    g_int = FilePathsBase.Group(UInt(9999))
                    @test u_int isa FilePathsBase.User
                    @test g_int isa FilePathsBase.Group
                    @test u_int.uid == UInt(9999)
                    @test g_int.gid == UInt(9999)
                    @test u_int.name == "NA"
                    @test g_int.name == "NA"
                end
            end
        end

        # We aren't going to do all the `isfifo`, `ischardev`, etc.
        # However, we'll double check a couple of the common ones.
        @testset "isfile" begin
            fp = joinpath(cwd(), "..", "src", "FilePathsBase.jl")
            @test isfile(fp)
            @test isfile(string(fp))

            @test !isfile(cwd())
            @test !isfile(pwd())

            fp = joinpath(cwd(), "..", "docs", "src", "index.md")
            @test isfile(fp)
            @test isfile(string(fp))
        end

        @testset "isdir" begin
            fp = joinpath(cwd(), "..", "src", "FilePathsBase.jl")
            @test !isdir(fp)
            @test !isdir(string(fp))

            @test isdir(cwd())
            @test isdir(pwd())

            fp = joinpath(cwd(), "..", "docs", "src", "index.md")
            @test !isdir(fp)
            @test !isdir(string(fp))
        end

        @testset "islink" begin
            fp = joinpath(cwd(), "..", "src", "FilePathsBase.jl")
            @test !islink(fp)
            @test !islink(string(fp))

            @test !islink(cwd())
            @test !islink(pwd())

            fp = joinpath(cwd(), "..", "docs", "src", "index.md")
            @test islink(fp)
            @test islink(string(fp))
        end

        @testset "isabspath" begin
            fp = joinpath(cwd(), "..", "src", "FilePathsBase.jl")
            @test isabspath(fp)
            @test isabspath(string(fp))

            fp = joinpath("..", "src", "FilePathsBase.jl")
            @test !isabspath(fp)
            @test !isabspath(string(fp))
        end

        @testset "expanduser" begin
            fp = joinpath(cwd(), "..", "src", "FilePathsBase.jl")
            @test string(expanduser(fp)) == expanduser(string(fp))

            fp = joinpath("~", "..", "src", "FilePathsBase.jl")
            @test string(expanduser(fp)) == expanduser(string(fp))
        end

        # Remainder of tests should be run in a tmp dir.
        mktempdir(SystemPath) do fp
            docsdir = joinpath(absolute(parent(parent(Path(@__FILE__)))), "docs")

            cd(fp) do
                @testset "mkdir" begin
                    newdirpath = joinpath(fp, "newdirpath")
                    newdirstr = joinpath(string(fp), "newdirstr")
                    @test mkdir(newdirpath) == newdirpath
                    @test ispath(newdirpath)
                    @test mkdir(newdirstr) == newdirstr
                    @test ispath(newdirstr)
                end

                @testset "mkpath" begin
                    newdirpath = joinpath(fp, "new", "recursive", "dir", "path")
                    newdirstr = joinpath(string(fp), "new", "recursive", "dir", "str")
                    @test mkpath(newdirpath) == newdirpath
                    @test ispath(newdirpath)
                    @test mkpath(newdirstr) == newdirstr
                    @test ispath(newdirstr)

                    # should not throw if path exists
                    @test mkpath(newdirpath) == newdirpath
                    @test mkpath(newdirstr) == newdirstr
                end

                @testset "symlink" begin
                    targetpath = joinpath(fp, "new", "recursive", "dir")
                    targetstr = joinpath(string(fp), "new", "recursive", "dir")
                    @test symlink(targetpath, p"pathlink") == nothing
                    @test ispath(p"pathlink")
                    @test symlink(targetstr, "strlink") == nothing
                    @test ispath("strlink")
                end

                @testset "touch" begin
                    @test touch(p"touchfp") == p"touchfp"
                    @test ispath(p"touchfp")
                    @test touch("touchstr") == "touchstr"
                    @test ispath("touchstr")
                end

                @testset "cp" begin
                    # Single file
                    @test cp(p"touchfp", p"cpfp") == p"cpfp"
                    @test ispath(p"cpfp")
                    @test cp("touchstr", "cpstr") == "cpstr"
                    @test ispath("cpstr")

                    # Recursive directory
                    @test cp(docsdir, p"cpdstpath"; force=true) == p"cpdstpath"
                    @test ispath(p"cpdstpath")
                    @test ispath(p"cpdstpath/src/api.md")
                    @test cp(string(docsdir), "cpdststr"; force=true) == "cpdststr"
                    @test ispath("cpdststr")
                    @test ispath("cpdststr/src/api.md")
                end

                @testset "mv" begin
                    # Single file
                    @test mv(p"cpfp", p"mvfp") == p"mvfp"
                    @test !ispath(p"cpfp")
                    @test ispath(p"mvfp")
                    @test mv("cpstr", "mvstr") == "mvstr"
                    @test ispath("mvstr")

                    # Recursive directory
                    @test mv(p"cpdstpath", p"mvdstpath") == p"mvdstpath"
                    @test ispath(p"mvdstpath")
                    @test ispath(p"mvdstpath/src/api.md")
                    @test !ispath(p"cpdstpath")
                    @test mv("cpdststr", "mvdststr") == "mvdststr"
                    @test ispath("mvdststr")
                    @test ispath("mvdststr/src/api.md")
                    @test !ispath("cpdststr")
                end

                @testset "download" begin
                    url = "https://github.com/rofinn/FilePathsBase.jl/blob/master/README.md"
                    @test download(url, p"README.md") == p"README.md"
                    @test ispath(p"README.md")

                    rm(p"README.md")
                    url = "https://github.com/rofinn/FilePathsBase.jl/blob/master/README.md"
                    @test download(url, "README.md") == "README.md"
                end

                @testset "readdir" begin
                    @test readdir(docsdir) == readdir(string(docsdir))
                end

                @testset "chmod" begin
                    @test chmod(p"touchfp", 0o755) == p"touchfp"
                    @test chmod("touchstr", 0o755) == "touchstr"
                    @test filemode(p"touchfp").m == filemode("touchstr")
                end

                @testset "chown" begin
                    if get(ENV, "USER", "") == "root"
                        @test chown(p"touchfp", -2, -1) == p"touchfp"
                        @test chown("touchstr", -2, -1) == "touchstr"
                        @test stat(p"touchfp").user.uid == stat("touchstr").uid

                        # Non-root user cannot change ownership to another user
                        @test_throws Base.IOError chown(p"touchfp", -2, -1)
                        @test_throws Base.IOError chown("touchstr", -2, -1)

                        # Non-root user cannot change group to a group they are not a member of (eg: nogroup)
                        @test_throws Base.IOError chown(p"touchfp", -1, -2)
                        @test_throws Base.IOError chown("touchstr", -1, -2)
                    end
                end

                @testset "rm" begin
                    @test rm(p"touchfp") == nothing
                    @test !ispath(p"touchfp")
                    @test rm("touchstr") == nothing
                    @test !ispath(p"touchstr")
                end

                @testset "read" begin
                    srcfp = joinpath(docsdir, "src", "api.md")
                    @test read(srcfp, String) == read(string(srcfp), String)
                end

                @testset "write" begin
                    content = read(joinpath(docsdir, "src", "api.md"), String)
                    @test write(p"writefp", content) == write("writestr", content)
                end

                @testset "Mmap.mmap" begin
                    fpmap, strmap = Mmap.mmap(p"README.md"), Mmap.mmap("README.md")
                    @test fpmap == strmap
                    # Ensure that the mmap objects get finalized before we cleanup our working directory.
                    finalize.([fpmap, strmap])
                end
            end
        end
    end
end
