:
whoSays=$1
shortOrLong=$2
symbol=$3
price=$4

Usage()
{
        echo "Usage: $0 whoSays shortOrLong symbol price"
        exit
}


if [ -z "$price" ]; then
        Usage
fi
case "$shortOrLong" in
        short|long)
        ;;
        *)
                Usage
        ;;
esac


t=`c:/users/nsproul/work/bin/get_date today`
f=c:/users/nsproul/data/remember_trade.$shortOrLong
s="$t,$whoSays,$symbol,"
if [ -z "`grep $s $f`"  ]; then
        echo "$s$price" >> $f
fi
exit
sh -x $HOME/work/adyn.com/cgi-bin/remember_trade.sh KR short LZR 42
