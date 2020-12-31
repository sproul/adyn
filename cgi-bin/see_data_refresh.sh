:
trace=''
testSymbol=$1
HOME=/cygdrive/c/users/nsproul
dataDir=$HOME/work/adyn.com/httpdocs/see/data
oldData=$dataDir/all
newData=$dataDir/all.$$

GetDatum()
{
        key=$1
        if [ -f $oldData ]; then
                grep "^$key=" $oldData | tail -1 | sed -e 's/^[^=]*=//'
        fi
}


SetDatum()
{
        key=$1
        shift
        echo $key=$* >> $newData
}

LoadPositions()
{
        positionType=$1
        listFn=$2
        
        sed -e 's/,/ /g' < $listFn |
        while [ 1 ]; do
                read date whoSays symbol price
                if [ -z "$price" ]; then
                        break
                fi
                SetDatum "positionType.$symbol" $positionType
                SetDatum "positionOpenDate.$symbol" $date
                SetDatum "positionOpenPrice.$symbol" $price
                SetDatum "whoSays.$symbol" $whoSays
                FetchQuoteInfo $symbol
        done

}

FindInterestingSymbols()
{
        (
        interestingSymbols=`GetDatum interestingSymbols`
        echo $interestingSymbols

        if [ -z "$testSymbol" ]; then
                rm $dataDir/*
                $HOME/work/adyn.com/httpdocs/see/harvest_lists.sh
                # skipping -- no workie, AND I'm not interested for the moment
                #sh $HOME/work/adyn.com/httpdocs/see/get_msn_52_week_highs_and_lows.sh refresh
        else
                cat  $HOME/work/adyn.com/httpdocs/see/harvest_lists.sh.testData
        fi
        SetDatum date_generated `date`
        ) | sort -n -r | awk '{print $2}' | tr '\n' ' '
}

GetLastValue_marketwatch()
{
        fn=$1
        # <div class="BigQuoteClass QuoteUpColor"><h2 id="QuoteLastTrade1" class="BigPriceClass"><span class="currency">$</span><span>10.35</span>

        # return
        # I prefer the approach below, but for some reason, n is empty after the grep statement no matter what.  Why?
        # n=`grep '<div class="BigQuoteClass' $fn | sed -e 's;.*Color"><h2 id="QuoteLastTrade1" class="BigPriceClass"><span class="currency">\$;;' -e 's;.*<span>;;' -e 's;</span>.*;;'`

        t=$TMP/x.$$
        grep '<div class="BigQuoteClass' $fn | sed -e 's;.*Color"><h2 id="QuoteLastTrade1" class="BigPriceClass"><span class="currency">\$;;' -e 's;.*<span>;;' -e 's;</span>.*;;' -e 's/.*>//' > $t
        n=`cat $t`
        rm -f $t





        if [ -z "`echo $n|grep '^[0-9\.]*$'`" ]; then
                echo "could not find last value in $fn (got $n)"
                exit
        fi
        echo $n
}

GetPercentChange_marketwatch()
{
        fn=$1
        #old: grep 'PercentChange" mwformat="+2%" mwsymbol="' $fn | sed -e 's/.*PercentChange" mwformat="+2%" mwsymbol="[A-Z\.]*">//' -e 's/%.*//' -e 's/+//g'
        # class="livequoteupdown priceup">+27.86%</span>
        # <span class="livequoteupdown pricedown">-2.42</span> <span class="livequoteupdown pricedown">-38.23%</span></h2><h4 id='QuoteVolume1'><span class='QuoteText'>Volume:</span>11,631,800</h2></div><div class='clearall'></div><h5 id='QuoteTime1'>4:08pm 09/07/2007</h5></div></div><div id="syncpredictions"></div><div id="clearboth"></div><div class="tablecontainer"><div class="table afterhourstable afterhours"><span class="mutedfont alignright">7:50pm 09/07/07</span><span><a href="http://www.marketwatch.com/tools/stockresearch/screener/afterhours.asp">After Hours</a>: <strong>$4.25</strong></span><span class="aligncenter">Change: <strong id='' class="priceup">+0.34 +8.70%</strong></span>
        # class="livequoteupdown pricedown">-29.32%</span>

        x=`grep 'price\(down\|unch\|up\)' $fn`
        if [ -n "$trace" ]; then
                echo "GetPercentChange ========================================================================="
                echo "0: $x"
        fi
        x=`echo $x | sed -e 's/.*class="BigPriceClass"//'`
        if [ -n "$trace" ]; then
                echo "1: $x"
        fi
        x=`echo $x | sed -e 's/mwformat="+2%"//g'`
        if [ -n "$trace" ]; then
                echo "1.5: $x"
        fi
        x=`echo $x | sed -e 's/%.*//'`
        if [ -n "$trace" ]; then
                echo "2: $x"
        fi
        x=`echo $x | sed -e 's/.*>//'`
        if [ -n "$trace" ]; then
                echo "3: $x"
        fi
        x=`echo $x | sed -e 's/^\+//'`
        if [ -n "$trace" ]; then
                echo "4: $x"
        fi
        #x=`echo $input | perl -p -e 's/mwformat="\+2%"//; s/.*?price(down|unch|up).*?price(down|unch|up).*?>//; s/%.*//; s/.*>//; s/\+//'`
        if [ -n "`echo $x|grep '^[-0-9\.]*$'`" ]; then
                echo $x
                return
        fi
        echo "Could not extract percent change from $x (from $fn)"
        exit
}

GetOffHoursPercentChange_marketwatch()
{
        fn=$1
        x=`grep 'After Hours' $fn`
        if [ -n "$trace" ]; then
                echo "GetOffHoursPercentChange ========================================================================="
                echo "0: $x"
        fi
        x=`echo $x | sed -e 's/class="BigPriceClass.*"//'`
        if [ -n "$trace" ]; then
                echo "1: $x"
        fi
        if [ -z "`echo $x|grep %`" ]; then
                return
        fi
        x=`echo $x | sed -e 's/mwformat="+2%"//g'`
        if [ -n "$trace" ]; then
                echo "1.5: $x"
        fi
        x=`echo $x | sed -e 's/%.*//'`
        if [ -n "$trace" ]; then
                echo "2: $x"
        fi
        x=`echo $x | sed -e 's/.*>//'`
        if [ -n "$trace" ]; then
                echo "3: $x"
        fi
        x=`echo $x | sed -e 's/^\+//'`
        if [ -n "$trace" ]; then
                echo "4: $x"
        fi
        if [ -n "`echo $x|grep '^[-0-9\.]*$'`" ]; then
                echo $x
                return
        fi
        #
        # This is normal during the session, so don't exit:
        #echo "Could not extract off hours percent change from $x ($fn)"
        #exit
}

ParseAndSetDatum_marketwatch()
{
        fn=$1
        symbol=$2
        datumType=$3

        if [ ! -f $fn ]; then
                echo "see_data_refresh.sh: could not find $fn"
                exit
        fi
        datumTypeParse=`echo $datumType|sed -e 's/_/ /g'`

        # <p>High:</p></div><div class="td sixcol2"><p id="QuoteHigh1" class="alignright rightspacing bold">$9.81</p>

        # return
        # I prefer the approach below, but for some reason, n is empty after the grep statement no matter what.  Why?
        # n=`grep "<p>$datumTypeParse:</p>" $fn | sed -e 's/.*<p id="Quote.*" class="alignright rightspacing bold">\$//' -e 's/<.*//'`

        t=$TMP/x.$$
        grep "<p>$datumTypeParse:</p>" $fn | sed -e 's/.*<p id="Quote[A-Za-z0-9]*" class="alignright rightspacing bold">\$//' -e 's/<.*//' > $t
        #cat $t
        n=`cat $t`
        rm -f $t





        if [ -z "`echo $n|grep '^-*[0-9\.]*$'`" ]; then
                echo "could not find $datumTypeParse in $fn (got: $n)"
                return
                #exit
        fi
        SetDatum $datumType.$symbol $n
}

GetCompanyId_goog()
{
        fn=$1

        if [ ! -f $fn ]; then
                echo error: could not find $fn
                exit
        fi
        
        # var _companyId = 713951;
        grep 'var _companyId = ' $fn | sed -e 's/.*= //' -e 's/;//'
}

GetDatum_goog()
{
        fn=$1
        id=$2
        fieldType=$3
        emptyOk=$4
        
        # <span class="chr" id="ref_713951_cp">(-1.69%)</span>
        x="ref_${id}_$fieldType"
        n=`grep "$x" $fn | sed -e 's;</span>;;' -e 's/.*>//' -e 's/[()]//g' -e 's/%//'`
        if [ -n "$emptyOk" ]; then
                if [ -z "$n" ]; then
                        return
                fi
        fi
        if [ -z "$n" ]; then
                echo error: could not extract $x from $fn
        fi
        echo $n
}

GetPercentChange_goog()
{
        fn=$1
        id=$2
        GetDatum_goog $fn $id "cp"
}

GetOffHoursPercentChange_goog()
{
        fn=$1
        id=$2
        # <span id="ref_697001_ecp" class="">(-0.59%)</span>
        GetDatum_goog $fn $id "ecp" ok
}

FetchQuoteInfo_marketwatch()
{
        symbol=$1
        fn=$HOME/work/adyn.com/httpdocs/see/data/${symbol}_mw.htm

        if [ -z "$testSymbol" ]; then
                wget -q http://www.marketwatch.com/quotes/$symbol -O `cygpath --mixed $fn`
        fi
        ParseAndSetDatum_marketwatch $fn $symbol 52-Wk_High
        ParseAndSetDatum_marketwatch $fn $symbol 52-Wk_Low
        ParseAndSetDatum_marketwatch $fn $symbol Open
        ParseAndSetDatum_marketwatch $fn $symbol High
        ParseAndSetDatum_marketwatch $fn $symbol Low
        # no 'Close' -- just use the value
        # ParseAndSetDatum_marketwatch $fn $symbol Close

        SetDatum change.$symbol `GetPercentChange_marketwatch $fn`
        SetDatum Last.$symbol `GetLastValue_marketwatch $fn`
        SetDatum changeOffHours.$symbol `GetOffHoursPercentChange_marketwatch $fn`
}

ExtractBlock_goog()
{
        blocks=$1
        label=$2
        echo $blocks|sed -e "s;.*>$label</span>;;" -e 's/[^>]*>//' -e 's/<.*//'
}

Range0()
{
        range=$1
        echo $range|sed -e 's/ .*//'
}

Range1()
{
        range=$1
        echo $range|sed -e 's/.* //'
}

FetchQuoteInfo_goog()
{
        symbol=$1
        fn=$HOME/work/adyn.com/httpdocs/see/data/${symbol}_mw.htm

        if [ -z "$testSymbol" ]; then
                wget -q http://finance.google.com/finance?q=$symbol -O `cygpath --mixed $fn`
        fi
        id=`GetCompanyId_goog $fn`
        blocks=`grep goog-inline-block $fn`
        open=`ExtractBlock_goog "$blocks" Open`
        range_52=`ExtractBlock_goog "$blocks" "52 week"`
        range_day=`ExtractBlock_goog "$blocks" "Range"`
        lo52=`Range0 "$range_52"`
        hi52=`Range1 "$range_52"`
        lo=`Range0 "$range_day"`
        hi=`Range1 "$range_day"`

        if [ -n "$trace" ]; then
                echo block processing: $lo/$hi/$lo52/$hi52 from $range_52 or $range_day
        fi
        SetDatum 52-Wk_High.$symbol $hi52
        SetDatum 52-Wk_Low.$symbol $lo52
        SetDatum Open.$symbol $open
        SetDatum High.$symbol $hi
        SetDatum Low.$symbol $lo
        
        sessionLast=`GetDatum_goog $fn $id l`
        afterHoursLast=`GetDatum_goog $fn $id el ok`
        if [ -n "$afterHoursLast" ]; then
                last=$afterHoursLast
        else
                last=$sessionLast
        fi
        SetDatum Last.$symbol $last
        
        SetDatum changeOffHours.$symbol `GetOffHoursPercentChange_goog $fn $id`
                
        x=`GetPercentChange_goog $fn $id`
        if [ -z "`echo $x|grep '^-*[0-9\.]*$'`" ]; then
                if [ -n "$trace" ]; then
                        echo "Could not get percent change out of $fn $id"
                fi
                return
        fi
        SetDatum change.$symbol $x
}

FetchQuoteInfo()
{
        FetchQuoteInfo_goog $*
}

if [ -n "$testSymbol" ]; then
        trace="yes"
        #LoadPositions long $HOME/data/remember_trade.long; exit

        fn=c:/users/nsproul/work/adyn.com/httpdocs/see/data/${testSymbol}_mw.htm
        FetchQuoteInfo $testSymbol
        echo result:
        cat $newData
else
        #FetchQuoteInfo SAPX
        for symbol in `FindInterestingSymbols`; do
                FetchQuoteInfo $symbol
        done

        #LoadPositions long $HOME/data/remember_trade.long
        #LoadPositions short $HOME/data/remember_trade.short
                
        mv $newData $oldData
fi
echo Done
exit
sh -x $HOME/work/adyn.com/cgi-bin/see_data_refresh.sh