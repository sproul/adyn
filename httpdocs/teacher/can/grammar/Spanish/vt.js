function forms_split(s, delimiter) // needed because explorer 3 does not support split
{
    var strings = new Array;
    if(forms_split.arguments.length==1) 
    {
        strings[0] = s;
        return strings;
    }
    var x, y;
    y = 0;
    while (true)
    {
        x = s.indexOf(delimiter, y);        
        if(x==-1) break;
        if(y!=x) strings[strings.length] = s.substring(y, x);
        y = x+ 1;
    }
    strings[strings.length] = s.substring(y);
    return strings; 
}
function forms_isDigit(c)
{
    return c>='0' && c<='9';
}

function forms_isAlpha(c)
{
    return (c>='a' && c<='z') || (c>='A' && c<='Z');
}

function forms_verifyDigits(field, name)
{ 
    var s=field.value;
    var digitsSeen = false;
        
    if (name==null)
    {
	name = field.name;
    }
    
    for (var j=0; j<s.length; j++)
    {
        var c=s.charAt(j);
        if (c!='/' && c!='-' && (!forms_isDigit(c)))
        {
	    alert(name + ' has an invalid value.  Expected digits and possibly hyphens and/or slashes');
            field.focus();
            return false;
        }
	else
	{
	    digitsSeen = true;
	} 
    }
    if (!digitsSeen)
    {
	alert(name + ' is empty.  Expected a number.');
	return false;
    }
    return true;
}

function forms_verifyAlphanumeric(field)
{
    var s=field.value;
    for (var j=0; j<s.length; j++)
    {
        var c=s.charAt(j);
	if (forms_isDigit(c) || forms_isAlpha(c))
        {
	    ;
        }
	else
	{
	    return false;
	}
    }
    return true;
}

// get the name of the selected radio button or selected element of a combo box
function forms_getSelected(options)
{
    if (options.type=="select-one")
    	return options.value;
	
    var isComboBox = (options.type=="select-multiple");
    var i;
    var s = null;
    for(i = 0; i < options.length; i++)
    {
	if ((isComboBox && options[i].selected) || (!isComboBox && options[i].checked))
	{
	    //alert('gS found ' +  options[i].value);
	    if (s==null)
	    	s = options[i].value;
	    else
	       	s += "@" + options[i].value;
	}	    	    
    }
    //alert('gS: ' + s)
    return s;
}

// Set a radio button or an element of a combo box
function forms_setSelected(options, s)
{
    //alert('sS(' + s)
    var i;
    var values = forms_split(s, "@")
    for(i = 0; i < options.length; i++)
    {
	for (j = 0; j < values.length; j++)
	{
	    if (options[i].value==values[j])
	    {
		options[i].checked  = true
		options[i].selected = true
		//alert('sS: ' + options[i].value)
		break
	    }
	}
    }
}

function forms_startTable()
{
    document.write("<center><table bgcolor=white border=5 cellpadding=10 cellspacing=1 width=90%>")
}
function forms_field(label,type,name,instructions,val)
{
    if (instructions=="") instructions = "&nbsp;";
    if (type=='hidden')
    {
	document.write("<input type=hidden name=" + name + " size=256>")
    } 
    else
    {
	if (val==null)
	{
	    val = ""
	}
	else
	{
	    val = " value='" + val + "'"
	} 
	document.write("<tr><td width=90><b>" + label + "</b></td><td><input type=" + type + " name=" + name + val + " size=40></td><td><b>" + instructions + "</b></td></tr>") 
    } 
}
function forms_button(name, label, on_click_funcName)
{
    document.write('<input type=button name=' + name + ' value="' + label + '" onClick="' + on_click_funcName + '()">')
}

function forms_submitButton()
{
    document.write('<tr><td><input type=button name=submitButton value="Submit" onClick="on_submit_click()"></td><td>&nbsp;</td><td>&nbsp;</td></tr>')
}
function forms_endTable()
{
    document.write("</center></table>")
}
function forms_field_pw()
{
forms_field("password","password","pw","")
}
function forms_field_pw2()
{
forms_field("re-enter your password","password","pw2","To make sure there were no typos in your password.")
}
function forms_field_name()
{
forms_field("your name","text","userName","Adynware does not share any of this info with anyone.")
}
function forms_field_email()
{
forms_field("e-mail","text","email","Don't worry -- no spam is coming.")
}
var __appletLoaded = false
var firstEx=''
var nameOfLastClickedExerciseDispositionButton = "Keep_exercise"
var adyn_url_offset
if (adyn_url_offset == null)
{
    adyn_url_offset=""
}

function trim(inputString)
{
    if (typeof inputString != "string")
    {
	return inputString;
    }
    var retValue = inputString;
    var ch = retValue.substring(0, 1);
    while (ch == " ")
    {
	retValue = retValue.substring(1, retValue.length);
	ch = retValue.substring(0, 1);
    }
    ch = retValue.substring(retValue.length-1, retValue.length);
    while (ch == " ")
    {
	retValue = retValue.substring(0, retValue.length-1);
	ch = retValue.substring(retValue.length-1, retValue.length);
    }
    return retValue
}

function on_Answer_click(currentLocation)
{
    window.location='#' + currentLocation + '_post'

    var s = "document.control_button_form_" + currentLocation + "_post." + nameOfLastClickedExerciseDispositionButton + ".focus()"
    eval(s)
}

function on_Keep_click(currentLocation)
{
    nameOfLastClickedExerciseDispositionButton = "Keep_exercise"
    on_Keep_or_Discard("keep", currentLocation)
}

function on_Discard_click(currentLocation)
{
    nameOfLastClickedExerciseDispositionButton = "Discard_exercise"
    on_Keep_or_Discard("discard", currentLocation)
}

function on_Keep_or_Discard(op, currentLocation)
{
    var nextExercise = document.teacher._b(op, null, currentLocation)
    //-var nextExercise = document.teacher._(op, null);

    if (nextExercise == null)
    {
	AskIfUserWantsMore()
    }
    else
    {
	window.location='#' + nextExercise + '_pre'
	var s='document.control_button_form_' + nextExercise + '_pre.Answer.focus()'
	eval(s)
    }
}
function AskIfUserWantsMore()
{
    var nextFn
    if (pageFromWhichNewQueriesWillBeInitiated != null)
    {
	nextFn = pageFromWhichNewQueriesWillBeInitiated
    }
    else
    {
	nextFn = adyn_url_offset + "choose.html"
    }
    
    if (confirm("There are no more exercises in your table set.\nWould you like to go to the exercise selection panel to fetch some new exercises from the web site box set?"))
    {
	window.location = nextFn
    }
}

function showExerciseLang(langName, langText, langFootnotes)
{
    document.write("<table bgcolor=#ccceee border=1 cellpadding=5 cellspacing=5 width=100%>\n"
    + "<tr><td width=15%>\n")
    if (langName == "Q" || langName == "A")
    {
	document.write(langName)
    }
    else
    {
	document.write("<a href=" + adyn_url_offset + langName + ".html target=" + langName + ">" + langName + "</a>")
    }
    document.write("</td><td>\n<font size=+2>\n")

    if (langText == "")
    {
	document.write("<font color=gray size=-1>Click on the <i>Show Answer</i> button above to see the ")
	if (langName == "A")
	{
	    document.write("answer")
	}
	else
	{
	    document.write("exercise above done for " + langName)
	}
	document.write(".</font>")
    }
    else
    {
	document.write(langText)
    }
    document.write("</font>\n"
    + "<font size=-1><font size=-1><br>" + langFootnotes + "</font></td>\n"
    + "</tr>\n"
    + "</table>\n")
}

function on_Set_help_click()
{
    window.open(adyn_url_offset + "../teacher.html#setButtons", "teacher_help")
}

function TooEasy()
{
    if(confirm("Go to the long form to retrieve harder exercises."))
    window.location = "/teacher/html/choose.html"
}
function TooHard()
{
    if(confirm("Go to the long form to retrieve easier exercises."))
    window.location = "/teacher/html/choose.html"
}

function GetHelpButton()
{
    return "<input type=button value=\"Help\" title='Click to see the help documentation.' onClick=\"on_Set_help_click()\"></td><td>  <a title='Click to see a discussion of what \"correct\" means for us here.' target='teacher Help' href=../teacher/teacher.html#correct>What does \"correct\" mean?</a>"
}

function endForm(exId, weight)
{
    var s = "</table>"
    + "<input type=button name=pop        value=\"Change topic\" onClick=\"on_Change_topic_click(0)\" title='Click here to replace the current topic of study with a new topic.'>"
    + "<input type=button name=new        value=\"Add new topic\" onClick=\"on_Change_topic_click(1)\" title='Click here to start a new session in a separate window.'>"
    + "<input type=button name=logoff     value=\"Logoff\" onClick=\"on_Logoff_click()\" title='Click here to end this session.'>"
    + "<input type=button name=topic_help value=\"Help\" onClick=\"on_Topic_help_click()\" title='Click for more detailed explanations of these buttons.'>"
    + "<input type=button name=topic_TooHard value=\"This is too hard\" onClick=\"TooHard()\" title='Click to go retrieve easier exercises.'>"
    + "<input type=button name=topic_TooEasy value=\"This is too easy\" onClick=\"TooEasy()\" title='Click to go retrieve harder exercises.'>"
    + "<input type=button name=topic_TooEasy value=\"Contact us\" onClick=\"MailMe()\" title='Click to send mail to the creator of this software.'>"
    + "<br>This is exercise <b>" + exId + "</b>, whose pre-session <a href=/teacher/teacher.html#weight>weight</a> was <b>" + weight + "</b>"
    + "</form><br>"
    + "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><brbr><br><br><br><br><br><br><br><br><br><brbr><br><br><br><br><br><br><br><br><br><br><br><br>\n"

    document.write(s)
}


// showExercise, really.
function se(ex, preSessionWeight, promptLang, promptText, promptFootnotes, responseLang1, responseText1, responseFootnotes1, responseLang2, responseText2, responseFootnotes2, responseLang3, responseText3, responseFootnotes3, responseLang4, responseText4, responseFootnotes4)
{
    var weight = preSessionWeight

    if (firstEx=='')
    {
	firstEx = ex
    }

    var s = "<a name=" + ex + "_pre></a>\n"
    + "<form name=control_button_form_" + ex + "_pre><table bgcolor=#ccceee border=1 cellpadding=5 "
    + "cellspacing=0 width=100%><tr><td width=15%><center><input type=button name=Answer "
    + "value=\"Show Answer\"  onClick=\"on_Answer_click('" + ex + "')\""
    + " title='Click here to display the answer to the exercise.'>\n"
    + "</td><td><font size=+1>Translate the phrase below in your head and then click <b>Show Answer</b> to see if you were correct.</font></td></tr>\n"
    + "<tr><td><center>" + GetHelpButton()
    + "</td></tr></table></form>\n"

    document.write(s)

    showExerciseLang(promptLang, promptText, promptFootnotes)
    showExerciseLang(responseLang1, '', '')
    if (responseLang2 != null)
    {
	showExerciseLang(responseLang2, '', '')
    }
    if (responseLang3 != null)
    {
	showExerciseLang(responseLang3, '', '')
    }
    if (responseLang4 != null)
    {
	showExerciseLang(responseLang4, '', '')
    }
    endForm(ex, weight)





    s = "<a name=" + ex + "_post></a>\n"
    + "<form name=control_button_form_" + ex + "_post><table bgcolor=#ccceee border=1 cellpadding=5 cellspacing=0 width=100%><tr><td width=15%><center>"
    + "<input type=button name=Keep_exercise value=\"Keep flashcard\"  onClick=\"on_Keep_click('" + ex + "')\">\n"
    + "</td><td><font size=+1>If you were not correct click <b>Keep flashcard</b>.</font></td></tr><tr><td><center><input type=button name=Discard_exercise value=\"Discard flashcard\"  onClick=\"on_Discard_click('" + ex + "')\">\n"
    + "</td><td><font size=+1>If you were correct click <b>Discard flashcard</b>.</font></td></tr>\n"
    + "<tr><td><center>" + GetHelpButton()
    + "</td></tr></table>\n"

    document.write(s)

    showExerciseLang(promptLang, promptText, promptFootnotes)
    showExerciseLang(responseLang1, responseText1, responseFootnotes1)
    if (responseLang2 != null)
    {
	showExerciseLang(responseLang2, responseText2, responseFootnotes2)
    }
    if (responseLang3 != null)
    {
	showExerciseLang(responseLang3, responseText3, responseFootnotes3)
    }
    if (responseLang4 != null)
    {
	showExerciseLang(responseLang4, responseText4, responseFootnotes4)
    }
    endForm(ex, weight)
}

function ia(exerciseKeysString,htmlPrefix,idNumber,windowName,userID)
{
    __appletLoaded = true
    var s = (document.teacher.initApplet(exerciseKeysString,htmlPrefix,idNumber,windowName))
    eval(s)	// doesn't work under navigator -- no matter what s is!

    var currentLocation = htmlPrefix + "." + idNumber;
    document.teacher._b("z",userID, currentLocation)

    s = "document.control_button_form_" + htmlPrefix + "_" + idNumber + "_pre.Answer.focus()"
    eval(s)
}


function on_Logoff_click()
{
    document.teacher._b("logoff", null, null)
    //-document.teacher._("logoff", null);
    window.location= adyn_url_offset + 'logout.htm'
} 
function on_Change_topic_click(newWindow)
{
    document.teacher._b("save", null, null)
    //-document.teacher._("save", null);
    var nextFn
    if (pageFromWhichNewQueriesWillBeInitiated != null)
    {
	nextFn = pageFromWhichNewQueriesWillBeInitiated
    }
    else
    {
	nextFn = "/teacher/html/" + whichPanel
    }
    
    if (newWindow==1)
    {
	window.open(nextFn, "new_topic")
    }
    else
    {
	location = nextFn
    } 
}
function on_Topic_help_click()
{
    var s = adyn_url_offset + "../teacher.html#topicButtons"
    window.open(s, "teacher_topic_help")
} 
function Choose(area)
{
    if (userID == null)
    {
	alert('You do not seem to be logged in.  Please login and try again.')
	window.location='/teacher/html/login.htm'
    }
    else
    {
	var what
	var areaS = new String(area)
	if (areaS.indexOf("verb_") != -1)
	{
	    what='chosenVerbs=' + area + '&exerciseType=verb_selected'
	}
	else
	{
	    what='chosenCategories=' + area + '&exerciseType=vocab_selected'
	}
	if (lang_French_checked !="false")
	{
	    what = what + "&lang_French=1"
	}
	if (lang_German_checked !="false")
	{
	    what = what + "&lang_German=1"
	}
	if (lang_Italian_checked!="false")
	{
	    what = what + "&lang_Italian=1"
	}
	if (lang_Spanish_checked!="false")
	{
	    what = what + "&lang_Spanish=1"
	}
	window.open("/cgi-bin/choose.cgi?" + what + "&userID=" + userID, "exercisesWindow")
    }
}

function MailMe()
{
    window.location = "mailto:support@adyn.com"
}

function ChooseSpecial(topic, userID)
{
    if (userID == null)
    {
	alert('You do not seem to be logged in.  Please login and try again.')
	window.location='/teacher/html/login.htm'
    }
    else
    {
	var categoriesToDisplay = ""
	var what = ""
	var userID
	if (userID == "langs")
	{
	    what='exerciseType=verb_all'
	}
	else
	{
	    categoriesToDisplay = "&promptLang=Q&lang_A=1"
	    var topicS = new String(topic)
	    if (topicS.indexOf("verb_") != -1)
	    {
		what='chosenVerbs=' + topic + '&exerciseType=verb_selected'
	    }
	    else
	    {
		what='chosenCategories=' + topic + '&exerciseType=vocab_selected'
	    }
	}
	if (pageFromWhichNewQueriesWillBeInitiated != null)
	{
	    what += '&pageFromWhichNewQueriesWillBeInitiated=' + pageFromWhichNewQueriesWillBeInitiated;
	}
	var s = "/cgi-bin/choose.cgi?" + what + categoriesToDisplay + "&userID=" + userID
	window.location = s
    }
}
var vt_lang
var vt_verb_b
var vt_verb_a

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
        
    if(paradigm_verb_in_html != null || reflexive_b)
    {
	document.write(" <font size=-1>(")
	if (reflexive_b)
	{
	    document.write("this is a <a href=" + lang + ".html#=Verbs=reflexive>reflexive</a> verb")
	    if(paradigm_verb_in_html != null)
	    {
		document.write(", ")
	    }
	}
	if(paradigm_verb_in_html != null)
	{
	    if (paradigm_verb_cleaned_for_href == null)
	    {
		paradigm_verb_cleaned_for_href = paradigm_verb_in_html;
	    }
	    document.write("conjugated like <i><a target=" + lang + "_vt_" + paradigm_verb_cleaned_for_href
	    + ".html href=" + lang + "_vt_" + paradigm_verb_cleaned_for_href + ".html>" + paradigm_verb_in_html + "</a></i>")
	}
	document.write(")</font></h3>")
    }
    vt_lang = lang
    vt_verb_b = verb_b
    vt_verb_a = verb_a
}
function vt_cleanup()
{
    document.write("<hr align=bottom><b><font color=white size=-1><center>&copy 2002 Adynware Corp.  &nbsp All Rights Reserved.</center></font></b></body></html>");
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
    if(dataFile!=null || vtFn!=null)
    {
	s += "&nbsp;&nbsp;&nbsp;&nbsp; <font size=-1>("
	if(dataFile!=null)
	{
	    s += vt_VerbExerciseLink()
	    if(vtFn!=null)
	    {
		s += ", "
	    }
	}
	if(vtFn!=null)
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

function vt_onload()
{
}
onload=vt_onload
