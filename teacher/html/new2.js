// ia("verb_eat_11;verb_come_11/1004;verb_enjoy_4;verb_eat_24/1005;verb_meet_9/1001;verb_enjoy_54/1003;verb_forget_6;verb_wait_for_43/1002;verb_give_6;verb_come_67/1004;verb_find_37;verb_drink_54;verb_go_6;verb_finish_46;verb_fall_11","verb_eat",11,window.name,"nsproul")
var hand_set_target_size = 4
var userID
var handSet
var tableSet
var discardedSet
var nameOfLastClickedExerciseDispositionButton = "Keep_exercise"
var ex_info = new Object()
var logout_requested = false

var progress_bar_html = ""

var consecutive_fail_count = 0
var consecutive_success_count = 0

var whichPanel = $.cookie("whichPanel")

function forms_show()
{
    for (key in document.forms)
    {
        console.log(document.forms[keys].name)
    }
}

function assert(condition, msg)
{
    if (!condition)
    {
        if (!msg) msg = "assertion failed"
        else      msg = "assertion failed: " + msg

        alert(msg)
        debugger
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
    this.current = function()
    {
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
        if (ex) this.exercises.push(ex)
    }
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
        this.weight = 1000 
    }
    this.change = 0
    this.get_weight = function()
    {
        return this.weight + this.change
    }
    this.goto = function(question)
    {
        //window.location='#' + this.topic_and_index + '_pre'
        //var s='document.control_button_form_' + this.topic_and_index + '_pre.Answer.focus()'
        //safe_eval(s)
        show_exercise(this.topic_and_index, question)
    }
    this.weight_change = function(addend)
    {
        this.change += addend
    }
}

function on_Answer_click(currentLocation)
{
    handSet.current().goto(false)
    //window.location='#' + currentLocation + '_post'

    //var s = "document.control_button_form_" + currentLocation + "_post." + nameOfLastClickedExerciseDispositionButton + ".focus()"
    //safe_eval(s)
}

function on_Keep_click(currentLocation)
{
    consecutive_success_count = 0
    consecutive_fail_count++
    if (consecutive_fail_count % 3 == 0)
    {
        if (hand_set_target_size > 2)
        {
            hand_set_target_size--
            if (hand_set_target_size > handSet.exercises.length)
            {
                tableSet.add(handSet.current_remove())
            }
        }
    }
    nameOfLastClickedExerciseDispositionButton = "Keep_exercise"
    handSet.current().weight_change(1)
    handSet.next().goto(true)
}

function on_Discard_click(currentLocation)
{
    consecutive_success_count++
    consecutive_fail_count = 0

    nameOfLastClickedExerciseDispositionButton = "Discard_exercise"
    discardedSet.add(handSet.current_remove())
    if (tableSet.exercises.length > 0 && handSet.exercises.length < hand_set_target_size)
    {
        handSet.add(tableSet.current_remove())
    }
    if (handSet.exercises.length==0)
    {
        if (confirm("There are no more exercises in your table set.\nWould you like to go to the exercise selection panel to fetch some new exercises from the web site box set?"))
        {
            save()
            if (whichPanel==null)
            {
                whichPanel =  "simple_choose.html"
            }
            window.location = "/teacher/html/" + whichPanel
        }
    }
    if (consecutive_success_count % 3 == 0)
    {
        hand_set_target_size++
        if (tableSet.exercises.length > 0 && handSet.exercises.length < hand_set_target_size)
        {
            handSet.add(tableSet.current_remove())
        }
    }
    progress_bar_update()
    handSet.current().goto(true)
}

function progress_bar_update()
{
    var done_count = discardedSet.exercises.length
    var total_count = discardedSet.exercises.length + tableSet.exercises.length + handSet.exercises.length
    var done_percentage = 100.0 * done_count / total_count
    progress_bar_html = progress_bar_make(done_percentage)
}

function progress_bar_make(done_percentage)
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

    var s = "<table border=1 width=100% ><tr><td bgcolor=blue width=" + done_percentage + "% >" + done_bar_content + "</td><td width=" + not_done_percentage + "% >" + not_done_bar_content + "</td></tr></table>"
    return s
}


function showExerciseLang(langName, langText, langFootnotes)
{
    var s = "<table bgcolor=#ccceee border=1 cellpadding=5 cellspacing=5 width=100%>\n"
    + "         <tr>"
    + "                 <td width=15%>\n"

    if (langName == "Q" || langName == "A")
    {
        s += langName
    }
    else
    {
        s += "<a href=/teacher/html/" + langName + ".html target=" + langName + ">" + langName + "</a>"
    }

    s += "              </td>"
    + "                 <td>"
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
        s += langText
    }
    s += "                      </font>\n"
    + "                         <font size=-1><br>" + langFootnotes + "</font>"
    + "                </td>\n"
    + "         </tr>\n"
    + "</table>\n"
    return s
}

function on_Set_help_click()
{
    window.open("../teacher.html#setButtons", "teacher_help")
}

function GetHelpButton()
{
    return "<input type=button value=\"Help\" title='Click to see the help documentation.' onClick=\"on_Set_help_click()\"></td><td>  <a title='Click to see a discussion of what \"correct\" means for us here.' target='teacher Help' href=/teacher/teacher.html#correct>What does \"correct\" mean?</a>"
}

function endForm()
{
    var ex = handSet.current()
    var s = "</table>"
    + "<input type=button name=pop        value=\"Change topic\" onClick=\"on_Change_topic_click(0)\" title='Click here to replace the current topic of study with a new topic.'>"
    //+ "<input type=button name=new        value=\"Add new topic\" onClick=\"on_Change_topic_click(1)\" title='Click here to start a new session in a separate window.'>"
    + "<input type=button name=logoff     value=\"Logoff\" onClick=\"on_Logoff_click()\" title='Click here to end this session.'>"
    + "<input type=button name=topic_help value=\"Help\" onClick=\"on_Topic_help_click()\" title='Click for more detailed explanations of these buttons.'>"
    + "<input type=button name=contactUs value=\"Contact us\" onClick=\"MailMe()\" title='Click to send mail to the creator of this software.'>"
    + "<br><div id=progress_bar>" + progress_bar_html + "</div>"
    + "<br>This is exercise <b>" + ex.topic_and_index + "</b>, whose <a href=/teacher/teacher.html#weight>weight</a> is <b>" + ex.get_weight() + "</b>"
    if (handSet)
    {
        s += "<br>The hand set contains the following exercises (with a target size of " + hand_set_target_size + "):<br><ul>"
        for (key in handSet.exercises)
        {
            var ex = handSet.exercises[key]
            s += "<li><b>" + ex.topic_and_index + "</b>"
            if (ex.get_weight() != 1000)
            {
                // we only add this comment if the weight is different from the default 1000
                s += " (with a weight of <b>" + ex.get_weight() + "</b>)</li>"
            } 
        }
        s += "</ul>"
    } 
    s += "</form><br>"

    return s
}


function se(ex, preSessionWeight, promptLang, promptText, promptFootnotes, responseLang1, responseText1, responseFootnotes1, responseLang2, responseText2, responseFootnotes2, responseLang3, responseText3, responseFootnotes3, responseLang4, responseText4, responseFootnotes4)
{
    ex_info[ex] = new Array(preSessionWeight, promptLang, promptText, promptFootnotes, responseLang1, responseText1, responseFootnotes1, responseLang2, responseText2, responseFootnotes2, responseLang3, responseText3, responseFootnotes3, responseLang4, responseText4, responseFootnotes4)
}

function show_exercise(ex, question)
{
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

    var s
    if (question)
    {
        //s = "<a name=" + ex + "_pre></a>\n"
        //+ "<form name=control_button_form_" + ex + "_pre>"
        s = "<form name=control_button_form_all_pre>"
        + "         <table bgcolor=#ccceee border=1 cellpadding=5 cellspacing=0 width=100%>"
        + "                 <tr>"
        + "                         <td width=15%>"
        + "                                 <center>"
        + "                                 <input type=button name=Answer value=\"Show Answer\"  onClick=\"on_Answer_click('" + ex + "')\" title='Click here to display the answer to the exercise.'>\n"
        + "                                 </center>"
        + "                         </td>"
        + "                         <td><font size=+1>Translate the phrase below in your head and then click <b>Show Answer</b> to see if you were correct.</font></td>"
        + "                 </tr>\n"
        + "                 <tr><td><center>" + GetHelpButton() + "</center></td></tr>"
        + "         </table>"
        //+ "</form>\n"   // endForm responsible for this

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
        s += endForm()
        $('#ex').html(s)
        document.control_button_form_all_pre.Answer.focus()
    }
    else
    {
        //s += "<a name=" + ex + "_post></a>\n"
        //+ "<form name=control_button_form_" + ex + "_post>"
        s = "<form name=control_button_form_all_post>"
        + "         <table bgcolor=#ccceee border=1 cellpadding=5 cellspacing=0 width=100%>"
        + "                 <tr>"
        + "                         <td width=15%>"
        + "                                 <center>"
        + "                                         <input type=button name=Keep_exercise value=\"Keep flashcard\"  onClick=\"on_Keep_click('" + ex + "')\">\n"
        + "                                 </center>"
        + "                         </td>"
        + "                         <td><font size=+1>If you were not correct click <b>Keep flashcard</b>.</font></td>"
        + "                 </tr>"
        + "                 <tr>"
        + "                         <td><center><input type=button name=Discard_exercise value=\"Discard flashcard\"  onClick=\"on_Discard_click('" + ex + "')\"></center></td>\n"
        + "                         <td><font size=+1>If you were correct click <b>Discard flashcard</b>.</font></td>"
        + "                 </tr>\n"
        + "                 <tr><td><center>" + GetHelpButton() + "</center></td></tr>"
        + "         </table>\n"
        //+ "</form>\n"   // endForm responsible for this

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
        s += endForm()
        $('#ex').html(s)
        var button = document.control_button_form_all_post[nameOfLastClickedExerciseDispositionButton]
        assert(button)
        button.focus()
    }
}

function ia(exerciseKeysString,htmlPrefix,idNumber,windowName,userID_parm)
{
    userID = userID_parm
    document.title = "Teacher for " + userID
    handSet = new ExerciseSet()
    tableSet = new ExerciseSet()
    discardedSet = new ExerciseSet()
    var a = exerciseKeysString.split(';')
    for (var j = 0; j < a.length; j++)
    {
        var ex_string = a[j]
        var ex = new Exercise(ex_string)

        if (ex.get_weight() > 1000) ex.weight_change(-1)    // optimistic on the rvw exercises

        tableSet.add(ex)
    }
    for (var j = 0; j < hand_set_target_size; j++)
    {
        handSet.add(tableSet.current_remove())
    }
    var ex = handSet.current()
    progress_bar_update()
    ex.goto(true)
}

function save()
{
    var weightChanges = handSet.getWeightChanges() + ":" + tableSet.getWeightChanges() + ":" + discardedSet.getWeightChanges()
    weightChanges = weightChanges.replace(/::*/, ':')
    weightChanges = weightChanges.replace(/^:/, '')
    weightChanges = weightChanges.replace(/:$/, '')

    if (!weightChanges)
    {
        return false
    }
    else
    {
        var url = "/cgi-bin/update.cgi?userID=" + userID + "&weightChanges=" + weightChanges
        $.ajax(
        {
            url: url,
            async: true,
            complete: function(jqXHR, textStatus)
            {
                assert(textStatus == "success")
                if (logout_requested)
                {
                    //alert('save ok')
                    goto_logout()
                }
            }
        }
        )
        return true
    }
}

function on_Logoff_click()
{
    logout_requested = true
    if (!save())
    {
        goto_logout()
    }
}
function goto_logout()
{
    window.location= '/teacher/html/logout.htm'
}

function on_Change_topic_click(newWindow)
{
    save()
    var nextFn
    if (whichPanel != null)
    {
        nextFn = whichPanel
    }
    else
    {
        nextFn = whichPanel
    }
    nextFn = "/teacher/html/" + nextFn
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
    var s = "../teacher.html#topicButtons"
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
        var new_url = merge_urls(window.location.href, special_request)
        window.open(new_url, special_request)
    }
}

function MailMe()
{
    window.location = "mailto:nelson@adyn.com"
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
