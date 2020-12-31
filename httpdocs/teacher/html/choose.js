var adyn_url_offset = "/teacher/html/"
    
if (window.location.pathname.match(/\/teacher\/html\//))
{
    if (!$.cookie("userID"))
    {
        //alert('no userID cookie, so sending to login from ' + window.location.pathname)
        window.location = adyn_url_offset + "login.htm"
    } 
} 

function on_Help_click()
{
    window.location= adyn_url_offset + '../teacher.html#exerciseSelectionPanel'
}
function watch_for_enter_to_submit(e)
{
    if(e && e.keyCode == 13)
    {
        on_submit_click()
        return false
    }
}
function on_Overview_click()
{
    window.location= adyn_url_offset + '../teacher.html'
}
function get_the_only_lang_selected_iff_just_one_is_selected()
{
    var langs = get_langs_selected(true)
    if (langs.length==1)
    {
        return langs[0]
    }
    return null
}

function get_langs_selected_cnt()
{
    return get_langs_selected().length
}
function get_langs_selected(but_suppress_implicit_English_selection)
{
    var a = new Array()
    if (!but_suppress_implicit_English_selection)
    {
        var en = forms_get_fld_val("lang_English")
        if (en || en==null)
        {
            // simple_choose.htm has no English checkbox, and so will return null.  On choose.htm, an unset check box yields false (not null).
            a.push("English")
        } 
    }
    if (forms_get_fld_val("lang_French")) a.push("French")
    if (forms_get_fld_val("lang_German")) a.push("German")
    if (forms_get_fld_val("lang_Italian")) a.push("Italian")
    if (forms_get_fld_val("lang_Spanish")) a.push("Spanish")
    return a
}

function pick_offline_exercises(exerciseSetTargetSize)
{
    var cached_keys = stg_list_cached_keys()
    var n = Math.min(exerciseSetTargetSize, cached_keys.length)
    var cached_keys_heaviest_first = cached_keys.sort(function(a,b){ return stg_get_weight(b) - stg_get_weight(a) })
    return cached_keys_heaviest_first.slice(0, n)
}

function show_offline_exercises(exerciseSetTargetSize, langs)
{
    var sc = $('#simple_choose_div')
    var oe = $('#ex')
    assert(sc.length==1, "cannot find simple_choose_span")
    assert(oe.length==1, "cannot find offline_ex_span")
    
    var chosen_exercises = pick_offline_exercises(exerciseSetTargetSize)
    if (!chosen_exercises || !chosen_exercises.length)
    {
        alert('You can only run teacher offline if you have review exercises to do, but unfortunately I do not see any on this machine.')
    }
    else
    {
        categories = langs
        var ia_str = ''
        for (var j = 0; j < chosen_exercises.length; j++)
        {
            var ex_id = chosen_exercises[j]
            var weight = stg_get_weight(ex_id)
            se(ex_id, weight)
        }
        ia()
        sc.hide()
        oe.show()
    } 
}

function choose_shared_submit(url_addend, new_window_id)
{
    if (document["teacher_form"])
    {
        if (!forms_verifyDigits(document.teacher_form.exerciseSetTargetSize, 'requested number of exercises') || (document.teacher_form.exerciseSetTargetSize.value < 1) || (document.teacher_form.exerciseSetTargetSize.value > 100))
        {
            alert('The number of exercises which will be retrieved has to be a number from 1 to 100.\nPlease make it so and resubmit')
            document.teacher_form.exerciseSetTargetSize.focus()
            return
        }
    }
    var langs = get_langs_selected()
    stg_set_mutually_dependent_category_groups(new Array(langs))
    if (!onLine())
    {
        show_offline_exercises(document.teacher_form.exerciseSetTargetSize.value, langs)
    }
    else
    {
        if (url_addend == null)
        {
            url_addend = ""
        }
        
        var url_parms = cookie_field__retrieve_all_for_url()
        
        var url = "/cgi-bin/choose.cgi?" + url_parms + "&userID=" + $.cookie("userID") // CAUSES BROWSER EXCESS url LENGTH FAILURE + "&cached_keys=" + escape(stg_list_cached_keys().join(';'))
        url = merge_urls(url, url_addend)
        defaultStatus = 'Gathering exercises...'
        
        if (new_window_id)
        {
            window.open(url, new_window_id)
        }
        else
        {
            window.location = url
        } 
    } 
}
