if(typeof(String.prototype.trim) === "undefined")
{
    String.prototype.trim = function() 
    {
        return String(this).replace(/^\s+|\s+$/g, '');
    }
}

function log(s)
{
    if (window["console"] && console["debug"])
    {
        console.debug("u.js.log: " + s)
    }
}

function merge_urls(url, url_addend)
{
    if (url_addend)
    {
        url_addend = url_addend.replace(/^&/, '')
        var url_addend_parms_array = url_addend.split(/&/)
        // in the event of a conflict between parms in url_addend and url_parms, url_addend must rule.  To achieve this, remove matching parms from url_parms:
        url = url.replace(/\?/, "&")         // simplifies the algorithm below, fix later...
        for (var j = 0; j < url_addend_parms_array.length; j++)
        {
            var addend_parm_name = url_addend_parms_array[j].replace(/=.*/, "")
            var re = RegExp("&" + addend_parm_name + "=[^&]*")
            url = url.replace(re, "")
        }
        url += "&" + url_addend
        url = url.replace(/&/, '?')          // ...undoing temporary switch to all &s above
        var MAX_IE_URI_LEN = 2083
        url = escaped_truncate_at_char(url, MAX_IE_URI_LEN, ';')
    }
    return url
}

function escaped_truncate(escaped_s, maxlen)
{
    escaped_s = escaped_s.substring(0, maxlen)
    if (escaped_s.charAt(maxlen-1) == "%")
    {
        escaped_s = escaped_s.substring(0, maxlen-1)
    }
    else if (escaped_s.charAt(maxlen-2) == "%")
    {
        escaped_s = escaped_s.substring(0, maxlen-2)
    }
    return escaped_s
}

function escaped_truncate_at_char(escaped_s, maxlen, preceding_char)
{
    if (escaped_s.length <= maxlen)
    {
        return escaped_s
    }
    var escaped_preceding_char = escape(preceding_char)
    var last_x = escaped_s.lastIndexOf(escaped_preceding_char)
    assert(last_x != -1, "could not find " + escaped_preceding_char + " in " + escaped_s)
    escaped_s = escaped_s.substring(0, last_x)
    return escaped_s
}
