// ia("verb_eat_11;verb_come_11/1004;verb_enjoy_4;verb_eat_24/1005;verb_meet_9/1001;verb_enjoy_54/1003;verb_forget_6;verb_wait_for_43/1002;verb_give_6;verb_come_67/1004;verb_find_37;verb_drink_54;verb_go_6;verb_finish_46;verb_fall_11","verb_eat",11,window.name,"nsproul")

var browser_stg_show = false
var browser_stg_show_values = false
var browser_stg_show_all_keys = false
var categories
var consecutive_fail_count = 0
var consecutive_success_count = 0
var current_topic_and_index
var discardedSet
var ex_info = new Object()
var handSet
var hand_set_target_size = 4
var hardestSet
var hardestSet_gathering_phase = true
var nameOfLastClickedExerciseDispositionButton = "Hold_flashcard"
var progress_bar_html = ""
var question_mode = true        // initial mode where only question is shown, not the answers
var tableSet
var trace_mode = false
var ui_compression_level
var userInteractionSeen = false
var whichPanel = $.cookie("whichPanel")

function Command(ex, delta, src_set, dest_set)
{
    this.delta = delta
    this.ex = ex
    this.src_set = src_set
    this.dest_set = dest_set
    if (this.ex)
    {
        assert(ex.topic_and_index)
    }

    this.do = function()
    {
        if (this.delta)
        {
            this.ex.change += this.delta
        } 
        if (this.src_set)
        {
            assert(this.dest_set)
            if (this.ex)
            {
                assert(this.src_set.current() == this.ex)
            } 
            else
            {
                this.ex = this.src_set.current()
            } 
            this.dest_set.add(this.src_set.current_remove())
        }
        
    }
    this.invert = function()
    {
        this.delta = - this.delta
        if (this.src_set)
        {
            var t = this.src_set
            this.src_set = this.dest_set
            this.dest_set = t
        }
    }
}

Command.undo_stack = new Array()

Command.do = function(ex, delta, src_set, dest_set, clear_undo_stack_first)
{
    if (clear_undo_stack_first)
    {
        Command.undo_stack.length = new Array()
    }
    var cmd = new Command(ex, delta, src_set, dest_set)
    cmd.do()
    Command.undo_stack.push(cmd)
}


function Exercise(topic_and_index_and_weight)
{
    var a = topic_and_index_and_weight.split("/")
    this.topic_and_index = a[0]
    if (a.length > 1)
    {
        this.weight = parseInt(a[1])
    }
    else
    {
        this.weight = EXERCISE_DEFAULT_WEIGHT
    }
    this.change = 0
    this.get_weight = function()
    {
        return this.weight + this.change
    }
    this.goto = function(question_mode_setting)
    {
        question_mode = question_mode_setting
        current_topic_and_index = this.topic_and_index
        make_screen()
    }
    this.to_s = function()
    {
        var s = this.topic_and_index
        if (this.weight != EXERCISE_DEFAULT_WEIGHT || this.change)
        {
            s += "/" + this.weight
            if (this.change)
            {
                if (this.change > 0)
                {
                    s += "+"
                }
                s += this.change
            }
        }
        return s
    }
    this.weight_change = function(addend)
    {
        this.change += addend
    }
}

function ExerciseSet()
{
    this.exercises = new Array()
    this.current_index = 0

    this.next = function()
    {
        this.current_index++
        return this.current()
    }
    this.getWeightChanges = function()
    {
        var s = ""
        for (j in this.exercises)
        {
            var ex = this.exercises[j]
            if (ex.change != 0)
            {
                s += ex.topic_and_index + "/" + ex.change + ":"
            }
        }
        return s
    }
    this.applyWeightChangesToWebStorage = function()
    {
        for (j in this.exercises)
        {
            var ex = this.exercises[j]
            if (ex.change != 0)
            {
                stg_set_weight(ex.topic_and_index, ex.get_weight())
            }
        }
    }
    this.current = function(ex)
    {
        if (ex)
        {
            for (var j = 0; j < this.exercises.length; j++)
            {
                if (ex==this.exercises[j])
                {
                    this.current_index = j
                    return
                }
            }
            assert(false, "ExerciseSet.current(" + ex.to_s() + ") could not find ex in " + this.to_s())
        }

        if (this.exercises.length == 0) return null
        if (this.current_index >= this.exercises.length) this.current_index = 0
        return this.exercises[this.current_index]
    }
    this.current_remove = function()
    {
        if (this.exercises.length == 0) return null
        if (this.current_index >= this.exercises.length) this.current_index = 0
        return this.exercises.splice(this.current_index, 1)[0]
    }
    this.add = function(ex)
    {
        if (ex) 
        {
            // use splice to assure that the new exercise is seen first, maximizing visible variety.  In particular, I didn't like the scenario where the user struggles over 2 hard exericses X and 
            // Y for an extended time and then finally discards X; I want the newly added exercise to show, not X.
            this.exercises.splice(this.current_index, 0, ex)
        }
    }
    this.to_s = function()
    {
        var s = "{ "
        for (j in this.exercises)
        {
            var ex = this.exercises[j]
            s += ex.to_s() + " "
        }
        s += "}"
        return s
    }
    this.to_s_html = function()
    {
        var s = ""
        for (j in this.exercises)
        {
            var ex = this.exercises[j]
            s += ex.to_s() + "<br>"
        }
        if (s == "")
        {
            s = "&nbsp;"        // to keep the table formatting from looking funny
        }
        return s
    }
}

function on_Hold_click()
{
    consecutive_success_count = 0
    consecutive_fail_count++
    Command.do(handSet.current(), 1, null, null, true)
    if (consecutive_fail_count % 3 == 0)
    {
        if (hand_set_target_size > 2)
        {
            hand_set_target_size--
            if (hand_set_target_size > handSet.exercises.length)
            {
                Command.do(null, null, handSet, tableSet)
            }
        }
    }
    nameOfLastClickedExerciseDispositionButton = "Hold_flashcard"
    handSet.next().goto(true)
}

function on_Show_Answer_click()
{
    handSet.current().goto(false)
}

function on_Undo_click()
{
    if (Command.undo_stack.length > 0)
    {
        //  Key assumption here: although a user click can provoke multiple
        // operations, which are then reflected in multiple nodes on the undo
        // stack, the visible exercise will be the first one which was affected.
        // Therefore we know that the visible exercise is referenced in the first
        // node of the undo stack. Record which exercise that was now so that we
        // can correctly reset the current_index in the handSet and display the
        // same exercise that was being displayed before the most recent
        // operation, i.e., the operation which is being canceled.
        var displayed_ex_before_recent_operation = Command.undo_stack[0].ex
        var new_undo_stack = new Array()
        while (Command.undo_stack.length > 0)
        {
            var cmd = Command.undo_stack.pop()
            cmd.invert()
            cmd.do()
            new_undo_stack.push(cmd)
        }
        Command.undo_stack = new_undo_stack
        handSet.current(displayed_ex_before_recent_operation)
        displayed_ex_before_recent_operation.goto(true)
        progress_bar_update()
    }
}

function add_exercise_to_handset()
{
    var src_set = null
    if (tableSet.exercises.length > 0)
    {
        src_set = tableSet
    }
    else if (hardestSet.exercises.length > 0)
    {
        src_set = hardestSet
    }
    if (src_set)
    {
        Command.do(null, null, src_set, handSet)
        return true
    }
    return false
}

function on_Drop_click()
{
    discard_current(-1)
}

function on_Discard_click()
{
    discard_current(-100)
}

function discard_current(delta)
{
    consecutive_success_count++
    consecutive_fail_count = 0

    nameOfLastClickedExerciseDispositionButton = "Drop_flashcard"
    var ex = handSet.current()

    if (ex)
    {
        var dest_set
        // you would think it would be impossible for the if-test above to fail, but clicking multiple times on a loaded box can do it
        if (ex.change >= 2 && tableSet.exercises.length > 0 && hardestSet_gathering_phase)
        {
            dest_set = hardestSet
        }
        else
        {
            dest_set = discardedSet
        }
        Command.do(ex, delta, handSet, dest_set, true)
    }
    progress_bar_update()
    if (handSet.exercises.length < hand_set_target_size)
    {
        if (!add_exercise_to_handset() && handSet.exercises.length==0)
        {
            save()
            if (whichPanel=="")
            {
                if (confirm("There are no more exercises in your table set.\nWould you like some more?"))
                {
                    window.location = window.location   // just refresh for arbitrary topic (e.g., ruby2)
                }
            }
            else if (confirm("There are no more exercises in your table set.\nWould you like to go to the exercise selection panel to fetch some new exercises from the web site box set?"))
            {
                if (whichPanel==null)
                {
                    whichPanel =  "simple_choose.htm"
                }
                else
                {
                    window.location = "/teacher/html/" + whichPanel
                } 
            }
        }
    }
    if (consecutive_success_count % 3 == 0)
    {
        hand_set_target_size++
        if (handSet.exercises.length < hand_set_target_size)
        {
            add_exercise_to_handset()
        }
    }
    var ex = handSet.current()
    if (ex)
    {
        ex.goto(true)
    }
}

function progress_bar_update()
{
    var done_count = discardedSet.exercises.length + (0.5 * hardestSet.exercises.length)
    var total_count = discardedSet.exercises.length + tableSet.exercises.length + handSet.exercises.length + (1.0 * hardestSet.exercises.length)
    var done_percentage = 100.0 * done_count / total_count
    
    var old_progress_bar_html = progress_bar_html
    progress_bar_html = progress_bar_make_html(done_percentage)
    if (old_progress_bar_html != progress_bar_html)
    {
        $('#progress_bar').html(progress_bar_html)
    } 
}

function progress_bar_make_html(done_percentage)
{
    done_percentage = Math.round(done_percentage)
    var not_done_percentage = 100 - done_percentage
    var done_bar_content
    var not_done_bar_content
    var txt = "" + done_percentage + "% done"
    if (done_percentage < 10)
    {
        done_bar_content = "&nbsp;"
        not_done_bar_content = txt
    }
    else
    {
        not_done_bar_content = "&nbsp;"
        done_bar_content = "<font color=white>" + txt + "</font>"
    }
    var s
    if (done_percentage == 100)
    {
        s = "<table border=1 width=100% ><tr><td bgcolor=blue >" + done_bar_content + "</td></tr></table>"
    }
    else if (done_percentage == 0)
    {
        s = "<table border=1 width=100% ><tr><td>" + not_done_bar_content + "</td></tr></table>"
    }
    else
    {
        s = "<table border=1 width=100% ><tr><td bgcolor=blue width=" + done_percentage + "% >" + done_bar_content + "</td><td width=" + not_done_percentage + "% >" + not_done_bar_content + "</td></tr></table>"
    } 
    return s
}


function showExerciseLang(langName, langText, langFootnotes)
{
    if (!langText) langText = ''
    if (!langFootnotes) langFootnotes = ''
    
    if (ui_compression_level && langText=="")
    {
        return ""
    } 
    
    var s
    var potential_reduced_size = ""
    if (ui_compression_level)
    {
        padding_and_spacing = 1
    }
    else
    {
        padding_and_spacing = 5
        potential_reduced_size = " size=-1 "
    }

    s = "<table bgcolor=#ccceee border=1 cellpadding=" + padding_and_spacing + " cellspacing=" + padding_and_spacing + " width=100%>\n"
    if (!ui_compression_level)
    {
        s += "         <tr>"
        + "                 <td width=15%>\n"
        
        if (langName == "Q" || langName == "A" || langName == "English")
        {
            s += langName
        }
        else
        {
            s += "<a href=/teacher/html/" + langName + ".html target=" + langName + ">" + langName + "</a>"
        }
        
        s += "              </td>"
    } 
    s += "                  <td>"
    + "                         <font size=+2>\n"

    if (langText == "")
    {
        s += "<font color=gray size=-1>Click on the <i>Show Answer</i> button above to see the "
        if (langName == "A")
        {
            s += "answer"
        }
        else
        {
            s += "exercise above done for " + langName
        }
        s += ".</font>"
    }
    else
    {
        if (langName == "Spanish"
        || langName == "French"
        || langName == "German"
        || langName == "Italian")
        {
            langText = linkWordsToSite(langText, "http://dictionary.reverso.net/" + langName.toLowerCase() + "-english/%s")
        }
        s += langText
    }
    s += "                      </font>\n"
    + "                         <font" + potential_reduced_size + "><br>" + langFootnotes + "</font>"
    + "                </td>\n"
    + "         </tr>\n"
    + "</table>\n"
    return s
}

function strip_html(s)
{
    s = s.replace(/<[^>]*>/g, "")
    return s
}

function strip_footnote_numbers_and_punctuation(s)
{
    return s.replace(/[(),\\.!\\?0-9]*/g, "")
}

function strip_accents(s)
{
    return s.replace(/&(.)[^;]*;/g, "$1")
}

function make_placeholder(x)
{
    return " __" + x + "__ "
}

function linkWordsToSite(s, url_pattern)
{
    var words = s.split(/ /)
    var unique_words_hash = new Object()
    for (var j = 0; j < words.length; j++)
    {
        var word = words[j]
        word = strip_footnote_numbers_and_punctuation(word)
        word = strip_html(word)
        if (word.indexOf("<") == -1)
        {
            unique_words_hash[word] = true
        } 
    }
    var unique_words = new Array()
    for (word in unique_words_hash)
    {
        unique_words.push(word)
    }
    // get the longer words first to protect against the possibility that one word is a superset of another (which is fairly common due to all those short determiners); we'll get
    // the longer words out of the equation first to avoid unintended substitutions:
    unique_words.sort(function(a,b) 
    {
        if (     a.length <  b.length) return 1
        else if (a.length == b.length) return 0
        else                           return -1
    })
    
    // sub these guys out first to avoid unintended substitutions
    unique_words.unshift("<sup>")
    unique_words.unshift("</sup>")
    
    var placeholders_to_links = new Object()
    var placeholder_index = -1
    for (var j = 0; j < unique_words.length; j++)
    {
        var word = unique_words[j]
        placeholder_index++
        var placeholder = make_placeholder(placeholder_index)
        var replace_word_with
        var re_mods = "g"
        if (word.indexOf("<") != -1)
        {
            replace_word_with = word                            // just preventing word from being parsed by replacing it w/ a placeholder
        }
        else
        {
            var url = url_pattern.replace(/%s/, word)
            replace_word_with = "<a target='" + url_pattern + "' href='" + url + "'>" + word + "</a>"
        } 
        placeholders_to_links[placeholder] = replace_word_with
        var re = RegExp(word, re_mods)
        s = s.replace(re, placeholder)
    }
    for (placeholder in placeholders_to_links)
    {
        var link = placeholders_to_links[placeholder]
        s = s.replace(new RegExp(placeholder, "g"), link)       // g needed to match every <sup> and </sup>
    }
    return s
}

function on_FAQ_click()
{
    url = "/teacher/faq.htm"
    window.open(url)
}

function is_full_screen()
{
    var b = (document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement || document.msFullscreenElement)
    return (b != null)
}

function full_screen(enable, not_in_user_event)
{
    if (enable)
    {
        var elem = document.getElementById("ex")
        if (elem)
        {
            req = elem.requestFullScreen || elem.webkitRequestFullScreen || elem.mozRequestFullScreen
            if (req)
            {
                if (not_in_user_event)
                {
                    // here we would need to queue this until there is some user event -- but the delayed action leads to unintuitive behavior -- I think I'll wait on this one for now...
                }
                else
                {
                    req.call(elem)
                } 
            }
        }
    }
    else
    {
        if (document.exitFullscreen)
        {
            document.exitFullscreen();
        }
        else if (document.msExitFullscreen)
        {
            document.msExitFullscreen();
        }
        else if (document.mozCancelFullScreen)
        {
            document.mozCancelFullScreen();
        }
        else if (document.webkitExitFullscreen)
        {
            document.webkitExitFullscreen();
        }
    }
}

$(document).on('webkitfullscreenchange mozfullscreenchange fullscreenchange', function()
{
    if (is_full_screen())
    {
        //alert('going full screen')
    }
    else
    {
        //alert('stopping full screen')
    }
    //make_screen()
}
)

function make_scratch_area_span(content)
{
    return "<span id='scratch_area'>" + (content != null ? content : "") + "</span>"
} 

function endForm(buttons)
{
    var ex = handSet.current()
    var s = "</table>"
    if (buttons)
    {
        s += buttons
    } 
    s += "</form><br><span id=trace_output_span>"
    if (trace_mode)
    {
        s += trace_current_world_state()
    }
    s += "</span>"
    return s
}

function trace_current_world_state()
{
    var ws = "<table border=1><tr><td>hand set</td><td>table set</td><td>hardest set</td><td>discarded set</td>"
    if (browser_stg_show)
    {
        ws += "<td>browser stg</td>"
    }
    ws += "</tr>"
    ws += "<tr>"
    ws += "<td>" + handSet.to_s_html() + "</td>"
    ws += "<td>" + tableSet.to_s_html() + "</td>"
    ws += "<td>" + hardestSet.to_s_html() + "</td>"
    ws += "<td>" + discardedSet.to_s_html() + "</td>"
    if (browser_stg_show)
    {
        ws += "<td>" + stg_2html(browser_stg_show_all_keys, browser_stg_show_values) + "</td>"
    } 
    ws += "</tr>"
    ws += "</table>"
    
    return ws
}

function se(ex_id, preSessionWeight, promptLang, promptText, promptFootnotes, responseLang1, responseText1, responseFootnotes1, responseLang2, responseText2, responseFootnotes2, responseLang3, responseText3, responseFootnotes3, responseLang4, responseText4, responseFootnotes4)
{
    log("entering se()...")
    var ex_props
    if (!onLine())
    {
        ex_props = new Array()
        ex_props.push(preSessionWeight)
        for (var k = 0; k < categories.length; k++)
        {
            var category = categories[k]
            ex_props.push(               category        )
            ex_props.push(stg_get(ex_id, category, "text"))
            ex_props.push(stg_get(ex_id, category, "footnotes"))
        }
    }
    else
    {
        if (!special_op || special_op=="load_and_dump")
        {
            ex_props = new Array(preSessionWeight, promptLang, promptText, promptFootnotes, responseLang1, responseText1, responseFootnotes1, responseLang2, responseText2, responseFootnotes2, responseLang3, responseText3, responseFootnotes3, responseLang4, responseText4, responseFootnotes4)
            stg_set_weight(ex_id, preSessionWeight)
            stg_lang_ex_save_possibly(ex_id, promptLang, promptText, promptFootnotes)
            stg_lang_ex_save_possibly(ex_id, responseLang1, responseText1, responseFootnotes1)
            stg_lang_ex_save_possibly(ex_id, responseLang2, responseText2, responseFootnotes2)
            stg_lang_ex_save_possibly(ex_id, responseLang3, responseText3, responseFootnotes3)
            stg_lang_ex_save_possibly(ex_id, responseLang4, responseText4, responseFootnotes4)
        } 
    } 
    var ex = new Exercise(ex_id)
            
    if (ex.get_weight() > 1000)
    {
        ex.weight_change(-1)    // optimistic on the rvw exercises
    }
    if (!tableSet)
    {
        tableSet = new ExerciseSet()        
    }
    tableSet.add(ex)
    ex_info[ex_id] = ex_props
    log("exit se()")
}

function buttons_left_and_right(left_buttons, right_buttons)
{
    return "<table width=100% ><tr><td align='left'>" + left_buttons + "</td><td align='right'>" + right_buttons + "</td></tr></table>"
}

function make_screen()
{
    change_css_for_display_style(ui_compression_level)
    
    ex = current_topic_and_index
    if (!ex || !ex_info || !ex_info[ex])
    {
        return
    }
    var preSessionWeight        = ex_info[ex][0]
    var promptLang              = ex_info[ex][1]
    var promptText              = ex_info[ex][2]
    var promptFootnotes         = ex_info[ex][3]
    var responseLang1           = ex_info[ex][4]
    var responseText1           = ex_info[ex][5]
    var responseFootnotes1      = ex_info[ex][6]
    var responseLang2           = ex_info[ex][7]
    var responseText2           = ex_info[ex][8]
    var responseFootnotes2      = ex_info[ex][9]
    var responseLang3           = ex_info[ex][10]
    var responseText3           = ex_info[ex][11]
    var responseFootnotes3      = ex_info[ex][12]
    var responseLang4           = ex_info[ex][13]
    var responseText4           = ex_info[ex][14]
    var responseFootnotes4      = ex_info[ex][15]

    var weight = preSessionWeight

    var buttons = make_button("Change topic", "Click here to replace the current topic of study with a new topic.", "green_triangle.jpg", "on_Change_topic_click(0)")
    + make_button("Logoff", "Click here to end this session.", "logoff_red_square.jpg", "on_Logoff_click()")
    + make_button("Discard", "Click here to get rid of this exercise for a long time.", "trash_light.jpg", "on_Discard_click()")
    if (!ui_compression_level)
    {
        buttons += make_button("FAQ", "Click here to visit the teacher FAQ.", "faq.jpg", "on_FAQ_click()")
    }
    buttons += make_button("Contact us", "Click to send mail to the creator of this software.", "contact_us.png", "MailMe()")
    
    var s = "<span id=progress_bar>" + progress_bar_html + "</span>"
    if (question_mode)
    {
        var show_answer_button = make_button("Show Answer", "Click here to display the answer to the exercise.", "open_book.jpg", "on_Show_Answer_click('" + ex + "')")

        s += "<form name=control_button_form_all_pre>"
        if (ui_compression_level)
        {
            s += make_scratch_area_span() + buttons_left_and_right(show_answer_button, buttons)
        }
        else
        {
            s += "      <table bgcolor=#ccceee border=1 cellpadding=5 cellspacing=0 width=100%>"
            + "                 <tr>"
            + "                         <td width=15%>"
            + "                                 <center>"
            + "                                 " + show_answer_button + "\n"
            + "                                 </center>"
            + "                         </td>"
            + "                         <td><font size=+1>Translate the phrase below in your head and then click <b>Show Answer</b> to see if you were correct.</font></td>"
            + "                 </tr>\n"
            + "                 <tr>"
            + "                     <td>"
            + "                         <center>"
            +                               GetHelpButton()
            + "                         </center>"
            + "                     </td>"
            + "                     <td>"
            + "                         " + make_scratch_area_span("<a title='Click to see a discussion of what \"correct\" means for us here.' target='teacher Help' href=/teacher/teacher.html#correct>What does \"correct\" mean?</a>")
            + "                     </td>"
            + "                 </tr>"
            + "         </table>"
        }
        s += showExerciseLang(promptLang, promptText, promptFootnotes)
        s += showExerciseLang(responseLang1, '', '')
        if (responseLang2 != null)
        {
            s += showExerciseLang(responseLang2, '', '')
        }
        if (responseLang3 != null)
        {
            s += showExerciseLang(responseLang3, '', '')
        }
        if (responseLang4 != null)
        {
            s += showExerciseLang(responseLang4, '', '')
        }
        s += endForm(ui_compression_level ? null : buttons)
        $('#ex').html(s)
        document.control_button_form_all_pre.Show_Answer.focus()
    }
    else
    {
        s += make_scratch_area_span()
        
        var keep_button = make_button("Hold flashcard", "Hold flashcard in the handset for further study", "keep_card.jpg", "on_Hold_click('" + ex + "')")
        var discard_button = make_button("Drop flashcard", "Do not show me this flashcard again during this session", "drop_card.jpg", "on_Drop_click('" + ex + "')")

        s += "<form name=control_button_form_all_post>"
        if (ui_compression_level)
        {
            //s += keep_button + discard_button + buttons
            s += buttons_left_and_right(keep_button + discard_button, buttons)
        }
        else
        {
            s += "         <table bgcolor=#ccceee border=1 cellpadding=5 cellspacing=0 width=100%>"
            + "                 <tr>"
            + "                         <td width=15%>"
            + "                                 <center>"
            + "                                         " + keep_button + "\n"
            + "                                 </center>"
            + "                         </td>"
            + "                         <td><font size=+1>If you were not correct click <b>Hold flashcard</b>.</font></td>"
            + "                 </tr>"
            + "                 <tr>"
            + "                         <td><center>" + discard_button + "</center></td>\n"
            + "                         <td><font size=+1>If you were correct click <b>Drop flashcard</b>.</font></td>"
            + "                 </tr>\n"
            + "                 <tr><td><center>" + GetHelpButton() + "</center></td></tr>"
            + "         </table>\n"
        }

        s += showExerciseLang(promptLang, promptText, promptFootnotes)
        s += showExerciseLang(responseLang1, responseText1, responseFootnotes1)
        if (responseLang2 != null)
        {
            s += showExerciseLang(responseLang2, responseText2, responseFootnotes2)
        }
        if (responseLang3 != null)
        {
            s += showExerciseLang(responseLang3, responseText3, responseFootnotes3)
        }
        if (responseLang4 != null)
        {
            s += showExerciseLang(responseLang4, responseText4, responseFootnotes4)
        }

        if (ui_compression_level)
        {
            s += endForm()
        }
        else
        {
            s += endForm(buttons)
        }
        $('#ex').html(s)
        var button = document.control_button_form_all_post[nameOfLastClickedExerciseDispositionButton]
        assert(button)
        button.focus()
    }
}

function trace_mode_toggle()
{
    trace_mode = !trace_mode
    if (trace_mode) refresh_trace_area()
}

function refresh_trace_area()
{
    var z = ""
    if (trace_mode)
    {
        z = trace_current_world_state()
    }
    $('#trace_output_span').html(z)
}

function ia()
{
    log("entering ia()...")
    if (tableSet)
    {
        document.onkeypress = watch_for_hot_keys
        //$( "#target" ).keypress(watch_for_hot_keys)
        document.title = "Teacher for " + userID

        if (special_op)
        {
            if (special_op == "stg_delete_all")
            {
                stg_delete_all()
            }
            else if (special_op == "load_and_dump" || special_op == "dump_only")
            {
                ;
            }
            else
            {
                assert(false, "unrecognized special_op " + special_op)
            }
            $('#ex').html("special_op " + special_op + " done")
        }
        if (!special_op || (special_op == "load_and_dump"))
        {
            discardedSet = new ExerciseSet()
            handSet = new ExerciseSet()
            hardestSet = new ExerciseSet()

            for (var j = 0; j < hand_set_target_size; j++)
            {
                handSet.add(tableSet.current_remove())
            }
            var ex = handSet.current()
            possibly_change_ui_compression_level()
            progress_bar_update()
            ex.goto(true)
        }

        if (test_output_fn || window.opener)
        {
            if (window.opener)
            {
                var out_fn = window.opener.window_to_out_fn[window]
                assert(out_fn, 'odd, I see an opener, but no out_fn setting...')
                test_output_fn = out_fn
            }
            log("       ia: about to write state")
            write_state(test_output_fn)

            var pauseForInteraction = (special_op ? 0 : 5000)
            log("       ia: about to setTimeout")
            setTimeout(function()
            {
                if (userInteractionSeen)
                {
                    if (confirm("new2.ia asks: debug?"))
                    {
                        debugger
                        return
                    }
                }
                if (window.opener && window.opener.window_to_out_fn && window.opener.window_to_out_fn[window])
                {
                    delete(window.opener.window_to_out_fn[window])
                }
                if (window.opener)
                {
                    window.close()
                }
            }, pauseForInteraction)
        }
    }
    log("exit ia()")
}

function save(next_fn)
{
    var weightChanges = handSet.getWeightChanges() + ":" + tableSet.getWeightChanges() + ":" + discardedSet.getWeightChanges()
    weightChanges = weightChanges.replace(/::*/, ':')
    weightChanges = weightChanges.replace(/^:/, '')
    weightChanges = weightChanges.replace(/:$/, '')
    
    if (!weightChanges)
    {
        if (next_fn)
        {
            next_fn()
        }
        return
    }
    tableSet.applyWeightChangesToWebStorage()
    discardedSet.applyWeightChangesToWebStorage()
    
    if (!onLine())
    {
        if (next_fn)
        {
            next_fn()
        }
    }
    else
    {
        var url = "/cgi-bin/update.cgi?userID=" + userID + "&weightChanges=" + escape(weightChanges)
        $.ajax(
        {
            url: url,
            async: true,
            complete: function(jqXHR, textStatus)
            {
                assert(textStatus == "success")
                if (next_fn)
                {
                    next_fn()
                }
            }
        }
        )
    }
}

function on_Logoff_click()
{
    save(function() { window.location= '/teacher/html/logout.htm' })
}

function on_Change_topic_click(newWindow)
{
    if (!onLine())
    {
        alert('Changing the topic is only supported when you are working online.')
        return
    }

    
    var nextFn
    /*
    doesn't make sense to go to simple screen if we are trying to make changes to the search criteria
    if (whichPanel)
    {
        nextFn = whichPanel
    }
    else
    {
        nextFn = "simple_choose.htm"
    }
    */
    nextFn = "choose.htm"
  
    
    
    nextFn = "/teacher/html/" + nextFn
    if (newWindow==1)
    {
        save()
        window.open(nextFn, "new_topic")
    }
    else
    {
        save(function() { window.location = nextFn })
    }
}
// used from the verb tables (and possibly elsewhere?)
function Choose(area)
{
    if (userID == null)
    {
        alert('You do not seem to be logged in.  Please login and try again.')
        window.location='/teacher/html/login.htm'
    }
    else
    {
        // the context is probably an exercise, where the user is clicking through a link (in a footnote) for specialized exercises
        var special_request
        var areaS = new String(area)
        if (areaS.indexOf("verb_") != -1)
        {
            special_request='chosenVerbs=' + area + '&exerciseType=verb_selected'
        }
        else
        {
            special_request='chosenCategories=' + area + '&exerciseType=vocab_selected'
        }
        special_request += "&reviewPercentage=0"
        var new_url
        if (window.location.pathname == "/cgi-bin/choose.cgi")
        {
            // called from an exercise
            new_url = merge_urls(window.location.href, special_request)
        }
        else
        {
            // called from a verb table or other content
            new_url = '/cgi-bin/choose.cgi?userID=' + $.cookie("userID") + "&" + cookie_field__retrieve_all_for_url()
            new_url = merge_urls(new_url, special_request)
        }
        window.open(new_url, special_request)
    }
}

function scratch_area_html(h)
{
    var fix_color_begin
    var fix_color_end
    if (is_full_screen())
    {
        // oops, full screen background is black
        fix_color_begin =  "<font color=\"white\">"
        fix_color_end   =  "</font>"
    }
    else
    {
        fix_color_begin = ""
        fix_color_end = ""
    }
    h = fix_color_begin + h + fix_color_end
    $("#scratch_area").html(h)
}

function MailMe()
{
    if (!onLine())
    {
        alert('Contacting the author is only supported when you are working online.')
        return
    }

    var label
    if (handSet && handSet.current())
    {
        label = handSet.current().topic_and_index
    }
    else
    {
        label = window.location.href
    }
    label += " user " + userID
    // trouble w/ this is that it only works on firefox, in my tests on my box.
    // window.location = "mailto:nelson@adyn.com?subject=comment from " + label
    
    var b = make_button("Send", "Send your message", "no-icon", "MailMe_submit('feedback from " + userID + " about " + ex + "')")
    var h = "<font size=+1>Message from " + label + "</font><br><textarea id=scratch_textarea rows=4 cols=50 ></textarea>" + b + "</font>"
    scratch_area_html(h)
    $("#scratch_textarea").focus()
}

function MailMe_submit(alert_subject)
{
    if (!onLine())
    {
        alert('Sending your message is only supported when you are working online.')
        return        
    }
    var msg = $("#scratch_textarea").val()
    var url = "/cgi-bin/alert.cgi?userID=" + userID + "&subject=" + escape(alert_subject)
    var MAX_POST_DATA_SIZE = 10235 // I have determined that this is the exact max post data size for my nginx/wsgi
    var data_val_pair = escaped_truncate("body=" + escape(msg), MAX_POST_DATA_SIZE)
    
    $.ajax(
    {
        url: url,
        async: true,
        type: 'POST',
        data: data_val_pair,
        complete: function(jqXHR, textStatus)
        {
            if (textStatus == "success")
            {
                scratch_area_html("Message sent -- thank you!")
                setTimeout(function(){ scratch_area_html("") }, 5000)
            } 
            else
            {
                scratch_area_html(jqXHR.responseText)
            } 
        }
    }
    )
}

function write_state(out_fn)
{
    if (!onLine())
    {
        return
    }

    var state = "stg_all2s=" + stg_all2s() + "\n" + "all_cached_keys=" + stg_list_cached_keys().join(';') + "\n"
    
    var url = "/cgi-bin/alert.cgi?userID=" + userID + "&subject=state&out_fn=" + out_fn
    var MAX_POST_DATA_SIZE = 10235 // I have determined that this is the exact max post data size for my nginx/wsgi
    var data_val_pair = escaped_truncate("body=" + escape(state), MAX_POST_DATA_SIZE)
    
    $.ajax(
    {
        url: url,
        async: true,
        type: 'POST',
        data: data_val_pair,
        complete: function(jqXHR, textStatus)
        {
            if (textStatus != "success")
            {
                scratch_area_html(jqXHR.responseText)
            }
        }
    }
    )
}

function ChooseSpecial_UNUSED(topic, userID)
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
        if (whichPanel != null)
        {
            what += '&whichPanel=' + whichPanel;
        }
        var s = "/cgi-bin/choose.cgi?" + what + categoriesToDisplay + "&userID=" + userID
        window.location = s
    }
}

function alert_to_server(msg)
{
    if (!onLine())
    {
        return
    }
    var subject = msg + " -- " + userID + " looking at " + handSet.current().to_s()
    var body = ""
    var url = "/cgi-bin/alert.cgi?subject=" + escape(subject) + "&body=" + body
    $.ajax(
    {
        url: url,
        async: true,
        complete: function(jqXHR, textStatus)
        {
            assert(textStatus == "success")
        }
    }
    )
}

$(document).ready(function()
{
    ia()
}
)

function watch_for_hot_keys(e)
{
    var handled = false
    if (e)
    {
        userInteractionSeen = true
        var control_depressed = e.getModifierState('Control')
        
        var ascii_code = e.charCode
        var c = String.fromCharCode(ascii_code)
        
        if (control_depressed && c != 'z')
        {
            return !handled        // we generally ignore keystrokes if the control key is depressed, except for ^Z, since that is not meaningful in normal web browsing, so may as well grab it
        }
        if (trace_mode)
        {
            handled = true
            if (c=='D') debugger
            else if (c=='d') browser_stg_show_all_keys = !browser_stg_show_all_keys
            else if (c=='0' || c=='1' || c=='2') ui_compression_level = parseInt(c)
            else if (c=='q') trace_mode_toggle()
            else if (c=='v' || c=='V') browser_stg_show_values = !browser_stg_show_values
            else if (c=='w' || c=='W') browser_stg_show = !browser_stg_show
            else if (c=='x' && confirm('clear all local stg')) stg_delete_all()
            else handled = false
            
            if (handled)
            {
                if (trace_mode) refresh_trace_area()
                make_screen()
            } 
        }
        if (!handled)
        {
            handled = true
            if (c=='y') alert_to_server("examine")
            else if (c=='b' || c=='B') on_Discard_click()
            else if (c=='c' || c=='C') on_Change_topic_click()
            else if (c=='d' || c=='D' || c=='0') on_Drop_click()
            else if (c=='h' || c=='s' || c=='H' || c=='3') on_Hold_click()
            else if (c=='K') alert('The old keyboard shortcut K (for keep) is not H (for hold)')
            else if (c=='l' && confirm("logoff?")) on_Logoff_click()
            else if (c=='q') trace_mode_toggle()
            else if (c=='z' || c=='Z') on_Undo_click()
            else if (question_mode)
            {
                if (c=='s' || c=='S') on_Show_Answer_click()
                else handled = false 
            } 
            else handled = false
        }
    }
    return !handled
}
