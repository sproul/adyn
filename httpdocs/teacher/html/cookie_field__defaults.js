function cookie_field__defaults(whichPanel)
{
    if (!whichPanel)
    {
        whichPanel = "simple_choose.htm"
    }
    __set_cookie("whichPanel", whichPanel)
    cookie_field_init1("whichPanel", whichPanel)
    cookie_field_init1("promptLang__Spanish", "Spanish")
    cookie_field_init1("promptLang__French", null)
    cookie_field_init1("promptLang__German", null)
    cookie_field_init1("promptLang__Italian", null)
    cookie_field_init1("promptLang__English", null)
    if (userID=="ava" || userID=="b" || userID=="nsproul" || userID=="pay")
    {
        cookie_field_init1("exerciseSetTargetSize", "50")
        cookie_field_init1("lang_French", "French")
        cookie_field_init1("lang_German", "German")
        cookie_field_init1("lang_Italian", "Italian")
        cookie_field_init1("lang_Spanish", "Spanish")
    }
    else
    {
        cookie_field_init1("exerciseSetTargetSize", "30")
        var f = __retrieve_from_cookie("lang_French")
        var g = __retrieve_from_cookie("lang_German")
        var i = __retrieve_from_cookie("lang_Italian")
        var s = __retrieve_from_cookie("lang_Spanish")
        //alert('fgis=' + f + '/' + g + '/' + i + '/' + s)
        if (f==null && g==null && i==null && s==null)
        {
            cookie_field_init1("lang_Spanish", "Spanish")
        }
        else
        {
            cookie_field_init1("lang_French", null)
            cookie_field_init1("lang_German", null)
            cookie_field_init1("lang_Italian", null)
            cookie_field_init1("lang_Spanish", null)
        } 
    }
    cookie_field_init1("exerciseType__base", null)
    cookie_field_init1("exerciseType__verb_common", "verb_common")
    cookie_field_init1("exerciseType__reviewExercises", null)
    cookie_field_init1("exerciseType__verb_all", null)
    cookie_field_init1("exerciseType__verb_selected", null)
    cookie_field_init1("exerciseType__vocab_selected", null)
    cookie_field_init1("reviewPercentage", "50")
    cookie_field_init1("tense__all", null)
    cookie_field_init1("tense__present", "present")
    cookie_field_init1("tense__preterite", null)
    cookie_field_init1("tense__past", null)
    cookie_field_init1("tense__imperfect", null)
    cookie_field_init1("tense__future", null)
    cookie_field_init1("tense__conditional", null)
    cookie_field_init1("tense__past_conditional", null)
    cookie_field_init1("tense__future_perfect", null)
    cookie_field_init1("tense__pluperfect", null)
    cookie_field_init1("tense__subjunctive", null)
    cookie_field_init1("tense__past_subjunctive", null)
    cookie_field_init1("tense__imperative", null)
    //cookie_field_init1("tense__k1", null)
    //cookie_field_init1("tense__k2", null)
    //cookie_field_init1("tense__past_k2", null)
}
