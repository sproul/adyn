:
user=$1
weightDeltaString=$2

if [ -z "$user" ]; then
	user="ava"
fi

if [ -z "$weightDeltaString" ]; then
	#weightDeltaString='peRl_4/1:peRl_43/1'
        weightDeltaString='verb_return_35/2'
fi

cd $DROP/adyn/cgi-bin/

Update()
{
	userID=$1
	weightChanges=$2
			
	fn=../httpdocs/teacher/usr/$userID/data
 
	echo "Will update $fn: $weightChanges"
	#cat $fn
	
	(
	echo "debugMode=1"
	echo "userID=$userID"
	#echo "weightChanges=$weightChanges"
	)|perl -w update.cgi
		
	#echo "post update:"; cat $fn
}


Update $user $weightDeltaString

exit
bx $DROP/teacher/test_update.sh 