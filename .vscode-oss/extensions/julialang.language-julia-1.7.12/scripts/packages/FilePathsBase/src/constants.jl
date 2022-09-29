# Posix separator and regex
const POSIX_PATH_SEPARATOR    = "/"
const POSIX_PATH_SEPARATOR_RE = r"/+"
const POSIX_PATH_ABSOLUTE_RE  = r"^/"
const POSIX_PATH_DIRECTORY_RE = r"(?:^|/)\.{0,2}$"
const POSIX_PATH_DIR_SPLITTER = r"^(.*?)(/+)([^/]*)$"
const POSIX_PATH_EXT_SPLITTER = r"^((?:.*/)?(?:\.|[^/\.])[^/]*?)(\.[^/\.]*|)$"

# Windows separator and regex
const WIN_PATH_SEPARATOR    = "\\"
const WIN_PATH_SEPARATOR_RE = r"[/\\]+"
const WIN_PATH_ABSOLUTE_RE  = r"^(?:\w+:)?[/\\]"
const WIN_PATH_DIRECTORY_RE = r"(?:^|[/\\])\.{0,2}$"
const WIN_PATH_DIR_SPLITTER = r"^(.*?)([/\\]+)([^/\\]*)$"
const WIN_PATH_EXT_SPLITTER = r"^((?:.*[/\\])?(?:\.|[^/\\\.])[^/\\]*?)(\.[^/\\\.]*|)$"


# The common READ, WRITE and EXEC constants
# to make working with file permissions easier.
const READ = 0o4
const WRITE = 0o2
const EXEC = 0o1

const USER_COEFF = 0o0100
const GROUP_COEFF = 0o0010
const OTHER_COEFF = 0o0001

# Stardard C style file mode constants taken from cpython's
# stat.py file
const S_IFDIR  = 0o040000     # directory
const S_IFCHR  = 0o020000     # character device
const S_IFBLK  = 0o060000     # block device
const S_IFREG  = 0o100000     # regular file
const S_IFIFO  = 0o010000     # fifo (named pipe)
const S_IFLNK  = 0o120000     # symbolic link
const S_IFSOCK = 0o140000     # socket file

const S_ISUID = 0o4000        # set UID bit
const S_ISGID = 0o2000        # set GID bit
const S_ENFMT = S_ISGID       # file locking enforcement
const S_ISVTX = 0o1000        # sticky bit
const S_IREAD = 0o0400        # Unix V7 synonym for S_IRUSR
const S_IWRITE = 0o0200       # Unix V7 synonym for S_IWUSR
const S_IEXEC = 0o0100        # Unix V7 synonym for S_IXUSR
const S_IRWXU = 0o0700        # mask for owner permissions
const S_IRUSR = 0o0400        # read by owner
const S_IWUSR = 0o0200        # write by owner
const S_IXUSR = 0o0100        # execute by owner
const S_IRWXG = 0o0070        # mask for group permissions
const S_IRGRP = 0o0040        # read by group
const S_IWGRP = 0o0020        # write by group
const S_IXGRP = 0o0010        # execute by group
const S_IRWXO = 0o0007        # mask for others (not in group) permissions
const S_IROTH = 0o0004        # read by others
const S_IWOTH = 0o0002        # write by others
const S_IXOTH = 0o0001        # execute by others

const FILEMODE_TABLE = (
    ((S_IFLNK,         'l'),
     (S_IFREG,         '-'),
     (S_IFBLK,         'b'),
     (S_IFDIR,         'd'),
     (S_IFCHR,         'c'),
     (S_IFIFO,         'p')),

    ((S_IRUSR,         'r'),),
    ((S_IWUSR,         'w'),),
    ((S_IXUSR|S_ISUID, 's'),
     (S_ISUID,         'S'),
     (S_IXUSR,         'x')),

    ((S_IRGRP,         'r'),),
    ((S_IWGRP,         'w'),),
    ((S_IXGRP|S_ISGID, 's'),
     (S_ISGID,         'S'),
     (S_IXGRP,         'x')),

    ((S_IROTH,         'r'),),
    ((S_IWOTH,         'w'),),
    ((S_IXOTH|S_ISVTX, 't'),
     (S_ISVTX,         'T'),
     (S_IXOTH,         'x'))
)

const DATA_SUFFIX = ["", "K", "M", "G", "T", "P", "E", "Z", "Y"]
