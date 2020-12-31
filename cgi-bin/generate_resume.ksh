:
cd $HOME/work/adyn.com/cgi-bin/

GenerateResume()
{
	name=$1
	resumeVersion=$2
	mailable=$3
	minimalJavaScript=$4

	if [ $mailable = 1 ]; then
		mx="mailable_"
	else
		mx=""
	fi

	name="$mx$name"

	(
	echo resumeVersion=$resumeVersion
	echo matchCase=0
	echo minimalJavaScript=$minimalJavaScript
	echo showAll=0
	echo mailable=$mailable
	) | perl.exe -w resume.cgi | tail +6 > ../httpdocs/resume/$name.htm # call to head removes http header
	cp ../httpdocs/resume/$name.htm ../httpdocs/resume/$name.html
}

GenerateLinkless()
{
	src=$1
	dest=$2
	cat $src|sed -e 's#<a[^>]*>##g' -e 's#</a>*##g' > $dest
}

GenerateLessFormatting()
{
	src=$1
	dest=$2
	cat $src|perl.exe -n -e 's/^   (.*[^:])\n$/$1 /; s/^   (.*:\n)$/\n$1/; print' > $dest
}

GenerateResume  resume 		default 0 0
GenerateResume  resume		default 1 0
#GenerateResume less_JavaScript 	default 0 1
GenerateResume  projects 	trade 	0 0	# the result will be called projects.htm.  It's really my trader resume.

cp -p ../httpdocs/resume/resume.html ../httpdocs/resume/searchable_resume.html
cat ../httpdocs/resume/resume.html| perl -w ../httpdocs/resume/nuke_html_bs_in_resume.pl |awk '/^Languages/ { print "See http://www.adyn.com/resume/resume.html for an intelligent version of\nthis resume supporting searches and filters.\n"; } { print }' > ../httpdocs/resume/resume.txt

GenerateLinkless ../httpdocs/resume/mailable_resume.html ../httpdocs/resume/linkless_mailable_resume.html
GenerateLessFormatting ../httpdocs/resume/resume.txt ../httpdocs/resume/resume_less_formatting.txt

echo 'b http://127.0.0.1:81/resume/resume.html &'
echo 'b http://127.0.0.1:81/resume/mailable_resume.html &'
echo $HOME/work/adyn.com/httpdocs/resume/resume.txt
echo 'b http://127.0.0.1:81/resume/projects.html &'

echo 'b http://www.adyn.com/resume/resume.html &'
echo 'b http://www.adyn.com/resume/mailable_resume.html &'
echo 'b http://www.adyn.com/resume/projects.html &'
echo done
exit 0
