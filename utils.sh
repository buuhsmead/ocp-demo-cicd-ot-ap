

function semver_parse_into() {
    local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    #MAJOR
    eval $2=`echo $1 | sed -e "s#$RE#\1\#"`
    #MINOR
    eval $3=`echo $1 | sed -e "s#$RE#\2\#"`
    #PATCH
    eval $4=`echo $1 | sed -e "s#$RE#\3\#"`
    #SPECIAL
    eval $5=`echo $1 | sed -e "s#$RE#\4\#"`
}

