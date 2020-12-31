function merge_urls(url, url_addend)
{
    if (url_addend)
    {
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
    }
    return url
}
