function works()
    return 'a'*"bc"
end

function parseerr()
    s = 0
    for i [1,2,3]   # this line has a parsing error
        s += i
    end
    return s
end
