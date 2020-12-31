var questions = new Array()
var questions_to_answers = new Object()

function faq1(q, a)
{
    questions.push(q)
    questions_to_answers[q] = a
}
function faq_index(x)
{
    return "" + x + ".&nbsp;"
}

function faq_show_all()
{
    var questions_html = '<ul>'
    var questions_and_answers_html = '<ul>'
    
    for (var j = 0; j < questions.length; j++)
    {
        var index = j + 1
        var q = questions[j]
        var a = questions_to_answers[q]
        questions_html += "<li>" + faq_index(index) + "<a href=#q" + index + ">" + q + "?</a></li>"
        questions_and_answers_html += "<li><p><a name=q" + index + ">" + faq_index(index) + q + "?<br>" + a + "</p></li>"
    }
    questions_html += '</ul>'
    questions_and_answers_html += '</ul>'
    
    $("#questions").html(questions_html)
    $("#questions_and_answers").html(questions_and_answers_html)
}
