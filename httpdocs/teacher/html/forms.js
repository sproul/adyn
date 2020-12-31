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
    document.write("<center><table bgcolor=white border=1 cellpadding=5 cellspacing=1 width=90%>")
}
function forms_field(label,type,name,instructions,val, on_click_funcName, size)
{
    if (!size)
    {
        size = 15
    }

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
        s += "<tr><td width=90 rowspan=2><b>" + label + "</b></td><td><b>" + instructions + "</b></td></tr><tr><td><input type=" + type + " id=" + name + " name=" + name + val + " size=" + size
        if (on_click_funcName)
        {
            s += " onClick='" + on_click_funcName + "()'"
        }

        s += "></td></tr>"
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
    document.write('<tr><td><input type=button name=' + name + ' id=' + name + ' value="Login" onClick="' + on_click_funcName + '()"></td><td>&nbsp;</td></tr>')
}

function forms_submitButton()
{
    document.write('<tr><td><input type=button name=submitButton id=submitButton value="Submit" onClick="on_submit_click()"></td><td>&nbsp;</td></tr>')
}
function forms_endTable()
{
    document.write("</table></center>")
}
function forms_field_pw(area_by_pw)
{
    if (area_by_pw == null)
    {
        area_by_pw = ""
    }
    forms_field("password","password","pw", area_by_pw)
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

function forms_get_fld_val(fld)
{
    if (!fld)
    {
        return null
    }
    if (!fld.attr)
    {
        var fld_name = fld
        fld = $('#' + fld_name)
        if (!fld)
        {
            return null     // e.g., lang_English has no check box in simple_choose.htm
        } 
    }
    if (fld.attr('type') != 'checkbox' && fld.attr('type') != 'radio')
    {
        return fld.val()
    }
    // jquery 1.6+
    return (fld.prop('checked') ? fld.val() : "")
}

function onLine()
{
    //return false; return // forcing onLine mode for testing
    return navigator.onLine
}

function make_button(val, title, img, on_click)
{
    var img_size = "width=15 height=18"
    img_size = "width=25 height=25"
    if (img == "no-icon")
    {
        img = ""
    }
    else
    {
        img = "<img src='/teacher/html/icons/" + img + "' " + img_size + ">"
    }
    var name = val.replace(/ /g, "_")
    var text = (ui_compression_level > 1 ? "" : val)
    return "<button type=button name='" + name + "' value='" + val + "' title='" + title + "' onClick=\"" + on_click + "; return false;\">" + img + text + "</button>"
}

function GetHelpButton()
{
    return make_button("Help", "Click to see the help documentation.", "help.jpg", "on_Help_click()")
}
function on_Help_click()
{
    url = "/teacher/teacher.html#setButtons"
    window.open(url)
}

