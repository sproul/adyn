var vt_lang
var vt_verb_b
var vt_verb_a

function vti_init(lang, verb_b, verb_a, reflexive_b, paradigm_verb_in_html, paradigm_verb_cleaned_for_href, suppress_to)
{
    // for inline use (in the grammars) -- no <head> stuff
    vt_init(lang, verb_b, verb_a, reflexive_b, paradigm_verb_in_html, paradigm_verb_cleaned_for_href, suppress_to, true)
}

function vt_init(lang, verb_b, verb_a, reflexive_b, paradigm_verb_in_html, paradigm_verb_cleaned_for_href, suppress_to, noDocTitle)
{
    var possible_to = "to ";
    if (reflexive_b==null)
    {
	reflexive_b = false;
    }

    if (suppress_to!=null)
    {
	possible_to = "";
    }
    if (noDocTitle==null)
    {
	document.write("<head><title>" + verb_b + ": " + lang + " Verb Table</title>"
	+ "</head><body bgcolor=#cccccc>"
	+ "<font face='arial'>")
    }
    document.write("<h3><i>" + verb_b + "</i>: " + possible_to + verb_a + "</h3>")
        
    if (paradigm_verb_in_html != null || reflexive_b)
    {
	document.write(" <font size=-1>(")
	if (reflexive_b)
	{
	    document.write("this is a <a href=" + lang + ".html#=Verbs=reflexive>reflexive</a> verb")
            if (paradigm_verb_in_html != null)
	    {
		document.write(", ")
	    }
	}
        if (paradigm_verb_in_html != null)
	{
	    if (paradigm_verb_cleaned_for_href == null)
	    {
		paradigm_verb_cleaned_for_href = paradigm_verb_in_html;
	    }
	    document.write("conjugated like <i><a target=" + lang + "_vt_" + paradigm_verb_cleaned_for_href
	    + ".html href=" + lang + "_vt_" + paradigm_verb_cleaned_for_href + ".html>" + paradigm_verb_in_html + "</a></i>")
	}
	document.write(")</font>")
    }
    vt_lang = lang
    vt_verb_b = verb_b
    vt_verb_a = verb_a
}
function vt_cleanup_UNUSED()
{
    document.write("<hr align=bottom><b><font color=white size=-1><center>&copy 2014 Adynware Corp.  &nbsp All Rights Reserved.</center></font></b></body></html>");
}
function vt_cell(english, other)
{
    var s = "<tr><td>" + english + "</td><td>" + other + "</td></tr>"
    return s
}

function vt_column(pairs)
{
    var s = "<table bgcolor=#eeeeee border=1 cellpadding=5 cellspacing=5 width=90%>"
    for (var j = 0; j < pairs.length; j += 2)
    {
	s += vt_cell(pairs[j], pairs[j+1])
    }
    s += "</table></p></center>"
    return s
}

var userID
function vt_VerbExerciseLink()
{
    return "<a href='javascript:Choose(\"verb_" + vt_verb_a + "\")' title='Click here to bring up a new window of exercises using this verb.'>exercises using this verb</a>"
}

function vt_tense(tense, singularPairs, pluralPairs, cookedTense, dataFile, vtFn)
{
    if (cookedTense==null)
    {
	cookedTense = tense;
    }

    var s = "<a name='#$tense'></a><table bgcolor=#eeeeee border=1 cellpadding=5 cellspacing=5 width=100%><tr><td><center>"
    + "<a href=" + vt_lang + ".html#=Verbs=" + tense + ">" + cookedTense + "</a></a> form of " + vt_verb_b + ": " + vt_verb_a
    if (dataFile!=null || vtFn!=null)
    {
	s += "&nbsp;&nbsp;&nbsp;&nbsp; <font size=-1>("
        if (dataFile!=null)
	{
	    s += vt_VerbExerciseLink()
            if (vtFn!=null)
	    {
		s += ", "
	    }
	}
        if (vtFn!=null)
	{
	    s += "<a href=" + vtFn + ">all tenses of " + vt_verb_b + " conjugated</a>"
	}
	s += ")</font>"
    }
    s += "</center></td></tr><tr><td><p><center><table border=0 cellpadding=0 cellspacing=0 width=100%><tr><td><p><center>"
    
    if (pluralPairs==null)
    {
	s += singularPairs[0]
    }
    else
    {
	s += vt_column(singularPairs) 
	s += "</td><td>"
	s += vt_column(pluralPairs)
    }
    s += "</center></p></td></tr></table></center></p></td></tr></table>"
    document.write(s)
}
