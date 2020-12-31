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

function assert_eq(expected, actual, msg_parm)
{
    if (expected != actual)
    {
        var msg = "expected " + expected + ' but saw ' + actual
        if (msg_parm)
        {
            msg += ": " + msg_parm
        } 
        assert(false, msg)
    } 
}
