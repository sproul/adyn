:
(
#echo pattern=adynware
echo pattern=java
echo matchCase=0
echo showAll=1
) | perl -w resume.cgi > c:/k.html
browser c:/k.html
exit 0
