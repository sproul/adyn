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

function forms_getSelected_as_url_addend(options)
{
    var s = forms_getSelected(options)
    if (!s)
    {
        return ""
    }
    var a = s.split(/@/)
    s = ""
    for (var j = 0; j < a.length; j++)
    {
        var val = a[j]
        s += "&" + options.name + "=" + val
    }
    return s
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
function forms_field(label,type,name,instructions,val, on_click_funcName)
{
    var s = ""
    if (instructions=="") instructions = "&nbsp;";
    if (type=='hidden')
    {
        s += ("<input type=hidden name=" + name + " id=" + name + " size=256>")
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
        s += "<tr><td width=90><b>" + label + "</b></td><td><input type=" + type + " id=" + name + " name=" + name + val + " size=40"
        if (on_click_funcName)
        {
            s += " onClick='" + on_click_funcName + "()'"
        }

        s += "></td><td><b>" + instructions + "</b></td></tr>"
    } 
    document.write(s)
}
function forms_button(name, label, on_click_funcName)
{
    if (!label)
    {
        label = name
    } 
    if (!on_click_funcName)
    {
        on_click_funcName = "on_" + name + "_click"
    } 
    document.write('<tr><td><input type=button name=' + name + ' id=' + name + ' value="Login" onClick="' + on_click_funcName + '()"></td><td>&nbsp;</td><td>&nbsp;</td></tr>')
}

function forms_submitButton()
{
    document.write('<tr><td><input type=button name=submitButton id=submitButton value="Submit" onClick="on_submit_click()"></td><td>&nbsp;</td><td>&nbsp;</td></tr>')
}
function forms_endTable()
{
    document.write("</table></center>")
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

function forms_watch_for_enter_to_submit(e)
{
    if(e && e.keyCode == 13)
    {
        document.forms[0].submit();
    }
    return false
}

function forms_init()
{
    document.onkeypress = forms_watch_for_enter_to_submit
}
