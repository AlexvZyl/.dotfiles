function main()
    println(devnull, 1)
    println(devnull, 2) # COV_EXCL_LINE
    println(devnull, 3)
    # COV_EXCL_START
    println(devnull, 4)
    # COV_EXCL_STOP
    println(devnull, 5)
end
