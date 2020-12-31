// my wrapper for the jquery cookies.  See https://github.com/carhartl/jquery-cookie/blob/master/README.md for more info on the jq plugin
var __flds = new Array("session_id")
var DEFAULT_SUFFIX = "__default"
var userID = $.cookie("userID")
var always_raw = new Object()
always_raw["session_id"] = true
always_raw["userID"] = true

function c2a(grep_string)
{
    if (!grep_string)
    {
        grep_string = ""
    }

    var a = new Array()
    for (key in $.cookie())
    {
        var val = $.cookie(key)
        var s = key + "=" + val
        if (s.match(grep_string))
        {
            a.push(s)
        }
    }
    return a
}

function __get_cookie(name, raw_mode)
{
    if (always_raw[name]) 
    {
        raw_mode = true
    }
    if (!raw_mode)
    {
        name = userID + "." + name
    } 
    var val = $.cookie(name)
    //console.log('__get_cookie(name=' + name + '): ' + val)
    return val
}

// set (or if val is null, __delete__)
function __set_cookie(name, val, raw_mode)
{
    if (name == "pw")
    {
        alert('cookie_field.js: pw should not be saved as a cookie')
        return
    }

    if (always_raw[name]) 
    {
        raw_mode = true
    }
    if (!raw_mode)
    {
        name = userID + "." + name
    } 
    //console.log('__set_cookie(name=' + name + ', val=' + (val==null ? "(null)" : val) + ')')
    if (val===null)
    {
        $.removeCookie(name)
    }
    else
    {
        $.cookie(name, val, { expires: 9999 })
    } 
}


// save name/val as cookie
function __retrieve_from_cookie(field_name)
{
    var cookie_val = __get_cookie(field_name)
    var val = null
    if (cookie_val)
    {
        val = cookie_val
    }
    else
    {
        var default_val = __get_cookie(field_name + DEFAULT_SUFFIX)
        if (default_val)
        {
            val = default_val
        }
    }
    return val
}

function __set_fld_val(fld, val)
{
    //console.log('__set_fld_val(fld=' + fld + ', val=' + val + ')')
    if (!fld)
    {
        return
    }
    if (val == null)
    {
        return
    }

    if (fld.attr('type') != 'checkbox' && fld.attr('type') != 'radio')
    {
        fld.val(val)
    }
    else
    {
        // jquery 1.6+
        fld.prop('checked', (val != ""))
    }
}

function cookie_field_init1(field_name, default_val)
{
    var cookie_val = __retrieve_from_cookie(field_name)
    var val = null
    if (cookie_val != null)
    {
        val = cookie_val
    }
    else
    {
        val = default_val
    }
    var fld = get_fld(field_name)
    if (fld)
    {
        __set_fld_val(fld, val)
    }
    __flds.push(field_name)
    __set_cookie(field_name + DEFAULT_SUFFIX, default_val)
}

function get_fld(field_name)
{
    var flds = $("#" + field_name)
    if (flds.length == 0)
    {
        return null
    }
    return flds
}

function cookie_field_reset_all_to_defaults()
{
    for (var j = 0; j < __flds.length; j++)
    {
        var field_name = __flds[j]
        var val = __get_cookie(field_name + DEFAULT_SUFFIX)
        __set_fld_val($('#' + field_name), val)
    }
}

// get escaped value for an exercise-retrieving URL from:
//      1.) field
//      2.) cookie (if it exists)
//      3.) default
//
// If the source is a field, remember that value in a cookie.
function __retrieve1_for_url(field_name)
{
    var val
    var fld = get_fld(field_name)
    if (fld)
    {
        val = forms_get_fld_val(fld)
        __set_cookie(field_name, val)
    }
    else
    {
        val = __retrieve_from_cookie(field_name)
    }
    if (val)
    {
        return field_name + "=" + escape(val)
    }
    return ""
}

function cookie_field__retrieve_all_for_url()
{
    var url_parms = null
    for (var j = 0; j < __flds.length; j++)
    {
        var field_name = __flds[j]
        if (url_parms)
        {
            url_parms += "&"
        }
        else
        {
            url_parms = ""
        }
        url_parms += __retrieve1_for_url(field_name)
    }
    url_parms = url_parms.replace(/&&*/g, "&")
    url_parms = url_parms.replace(/&$/, "")
    url_parms = url_parms.replace(/^&/, "")
    url_parms = url_parms.replace(/__[a-zA-Z0-9_]*=/g, "=")
    return url_parms
}
