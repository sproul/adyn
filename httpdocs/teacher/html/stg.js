var EXERCISE_DEFAULT_WEIGHT = 1000

// These are sets of categories where having an incomplete set of data (e.g., only English + Spanish, yet the dependence set contains English, Spanish + French) is treated as 
// worthless and warranting a refresh of the data from the server...
var stg_mutually_dependent_category_groups = null

function stg_delete_all()
{
    log("stg_delete_all()...")
    var keys = $.localStorage.keys()
    for (var j = 0; j < keys.length; j++)
    {
        var key = keys[j]
        $.localStorage.remove(key)
    }
    log("stg_delete_all exit")
}

function stg_all2s()
{
    return s2a().join("\n")
}

function s2a(grep_string)
{
    log("entering s2a()...")
    var a = new Array()
    var keys = $.localStorage.keys()
    keys.sort(function(a,b) 
    {
        return a.localeCompare(b)
    })
    if (grep_string==null)
    {
        grep_string = ""
    }

    for (var j = 0; j < keys.length; j++)
    {
        var key = keys[j]
        var val = $.localStorage.get(key)
        var s1 = key + "=" + val
        if (s1.match(grep_string))
        {
            a.push(s1)
        } 
    }
    log("s2a exit")
    return a
}

function stg_all2html()
{
    log("entering stg_all2html()...")
    s = stg_all2s()
    if (!s)
    {
        s = "[nothing]"        
    }
    else
    {
        s = s.replace(/$/,     "<br>")
    }
    log("stg_all2html exit")
    return s
}

function stg_ex_keys()
{
    log("stg_ex_keys()...")
    var a = new Array()
    var keys = $.localStorage.keys()
    for (var j = 0; j < keys.length; j++)
    {
        var key = keys[j]
        if (key.match(/:weight$/))
        {
            var ex_id = key.replace(/:weight$/, '')
            a.push(ex_id)
        }
    }
    log("stg_ex_keys exit")
    return a
}

function stg_all_keys2html()
{
    log("stg_all_keys2html()...")
    var a = new Array()
    var keys = $.localStorage.keys()
    for (var j = 0; j < keys.length; j++)
    {
        a.push(keys[j])
    }
    var z = a.join('<br>\n')
    log("stg_all_keys2html exit")
    return z
}

function stg_key(ex_id, category, subcategory)
{
    var key = ex_id + ":" + category
    if (subcategory)
    {
        key += "/" + subcategory
    } 
    return key
}

function stg_set(ex_id, prop, subprop, val)
{
    try
    {
        $.localStorage.set(stg_key(ex_id, prop, subprop), val)
    }
    catch(e)
    {
        ;
    }
}

function stg_get(ex_id, prop, subprop)
{
    var weight = $.localStorage.get(stg_key(ex_id, prop, subprop))
    if (weight==null)
    {
        weight = EXERCISE_DEFAULT_WEIGHT
    }
    return weight
}

function stg_set_weight(ex_id, weight)
{
    if (weight==null)
    {
        weight = EXERCISE_DEFAULT_WEIGHT
    }
    stg_set(ex_id, "weight", null, weight)
}

function stg_get_weight(ex_id)
{
    return $.localStorage.get(stg_key(ex_id, "weight"))
}

function stg_lang_ex_save_possibly(ex_id, category, text, footnotes)
{
    if (category && text)
    {
        stg_set(ex_id, category, "text", text)
    }
    if (footnotes)
    {
        stg_set(ex_id, category, "footnotes", footnotes)
    }
}

function stg_list_cached_keys()
{
    log("stg_list_cached_keys()...")
    assert(stg_mutually_dependent_category_groups, "call to stg_set_mutually_dependent_category_groups required")
    var cached_keys_hash = new Object()
    var keys = $.localStorage.keys()
    for (var j = 0; j < keys.length; j++)
    {
        var key = keys[j]
        if (key.match(/.+:.+\/.+/))
        {
            var ex_id = key.replace(/:.*/, '')
            if (cached_keys_hash[ex_id])
            {
                continue
            }
            var ex_processed = false
            var category = key.replace(/.*:/, '').replace(/\/.*/, '')
            //var subcategory = key.replace(/.*\//, '')
            for (var k = 0; k < stg_mutually_dependent_category_groups.length; k++)
            {
                var mutually_dependent_category_group_hash = stg_mutually_dependent_category_groups[k]
                if (mutually_dependent_category_group_hash[category])
                {
                    var nothing_missing = true
                    for (mutually_dependent_category in mutually_dependent_category_group_hash)
                    {
                        if (!$.localStorage.get(stg_key(ex_id, mutually_dependent_category, "text")))
                        {
                            nothing_missing = false
                            break
                        }
                    }
                    if (nothing_missing)
                    {
                        cached_keys_hash[ex_id] = true
                    }
                    ex_processed = true
                    break
                }
            }
            if (!ex_processed)
            {
                cached_keys_hash[ex_id] = true
            }
        }
    }
    log("       stg_list_cached_keys loop1 done")
    var cached_keys = new Array()
    for (key in cached_keys_hash)
    {
        var weight = $.localStorage.get("$key/weight")
        
        var key_and_weight = key
        if (weight)
        {
            key_and_weight += "/" + weight
        } 
        cached_keys.push(key_and_weight)
    } 
    log("stg_list_cached_keys exit")
    return cached_keys
}

function stg_2html(browser_stg_show_all_keys, browser_stg_show_values)
{
    log("stg_2html()...")
    var keys = (browser_stg_show_all_keys ? $.localStorage.keys() : stg_ex_keys())
    var h = '<table>'
    for (var j = 0; j < keys.length; j++)
    {
        var key = keys[j]
        h += '<tr><td>' + key
        if (browser_stg_show_values)
        {
            var val
            if (browser_stg_show_all_keys)
            {
                val = $.localStorage.get(key)
            }
            else
            {
                val = stg_get_weight(key)
            }
            h += '</td><td>' + val
        }
        h += '</td></tr>'
    }
    h += '</table>'
    log("stg_2html exit")
    return h
}

function stg_set_mutually_dependent_category_groups(mutually_dependent_category_groups)
{
    log("stg_set_mutually_dependent_category_groups()...")
    stg_mutually_dependent_category_groups = new Array()
    // convert array of arrays to an array of hashes -- makes its use simpler:
    for (var j = 0; j < mutually_dependent_category_groups.length; j++)
    {
        var a = mutually_dependent_category_groups[j]
        var h = new Object()
        for (var k = 0; k < a.length; k++)
        {
            h[a[k]] = true
        }
        stg_mutually_dependent_category_groups.push(h)
    }
    log("stg_set_mutually_dependent_category_groups exit")
}

function stg_size_all()
{
    log("stg_size_all()...")
    var n = 0
    var keys = $.localStorage.keys()
    for (var j = 0; j < keys.length; j++)
    {
        var key = keys[j]
        var val = $.localStorage.get(key)
        n += key.length + val.length
    }
    log("stg_size_all exit")
    return n
}

function stg_find_max_size()
{
    log("stg_find_max_size()...")
    // firefox 30.0: 5.1mb
    stg_delete_all()
    var j = 0
    var n = 0
    try
    {
        for (;; j++)
        {
            var key = "" + j
            var val_1k = Array(255).join("abcd")
            $.localStorage.set(key, val_1k)
            n++
            log('stg size = ' + n + 'k')
        }
    }
    catch(e)
    {
        log('error at ' + n + 'k: ' + e)
    }
    log("stg_find_max_size exit")
}
