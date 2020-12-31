// UNUSED: ended up using css instead
// http://stackoverflow.com/questions/21680629/getting-the-physical-screen-dimensions-dpi-pixel-density-in-chrome-on-androi
//  screenPixelToMillimeterX, screenPixelToMillimeterY, which spit out some numbers in latest version Chrome, and is documented for IE and Firefox (e.g. https://developer.mozilla.org/en/docs/Web/API/SVGSVGElement).

var MOBILE_CSS = "mobile"
var DESKTOP_CSS = "desktop"

function UNUSED_seems_unstable_on_ff__load_css(css_name)
{
    var cssId = css_name
    var css_opposite = null
    if (!document.getElementById(cssId))
    {
        debugger
        if (css_name == MOBILE_CSS)
        {
            css_opposite = DESKTOP_CSS
        }
        else if (css_name == DESKTOP_CSS)
        {
            css_opposite = MOBILE_CSS
        }
        var head  = document.getElementsByTagName('head')[0];
        var link  = document.createElement('link');
        link.id   = cssId;
        link.rel  = 'stylesheet';
        link.type = 'text/css';
        link.href = '/' + css_name + '.css';
        link.media = 'all';
        var css_opposite_link = document.getElementById(css_opposite)
        if (css_opposite_link == null)
        {
            head.appendChild(link);
        }
        else
        {
            head.replaceChild(link, css_opposite_link)
        }
    }
}

function UNUSED_make_screen__with_font_multiplier()
{
    log('make_screen()...')
    var z = $("#item_we_want_to_span_window_width")[0]
    debugger
    var adynware_text_width = z.offsetWidth
    var multiplier
    if (!adynware_text_width)
    {
        multiplier = 1
    }
    else
    {
        var window_width = $(window).width()
        var adynware_text_width_ratio_to_window_width = adynware_text_width / window_width
        var adynware_text_width_ratio_to_window_width_with_white_space = adynware_text_width_ratio_to_window_width // * 1.1
        // we want this ratio to be around 1
        var old_multiplier = 1
        try
        {
            old_multiplier = parseInt(z.style.fontSize)
            if (isNaN(old_multiplier))
            {
                old_multiplier = 1
            }
        }
        catch(e)
        {
            log('parseInt e: ' + e)
            old_multiplier = 1
        }
        multiplier = old_multiplier / adynware_text_width_ratio_to_window_width_with_white_space
    }
    alert('multiplier=' + multiplier)
    if (multiplier > 1)
    {
        var fonts = $("font")
        try
        {
            var f = fonts[0]    // the all-encapsulating arial font
            alert('reseting font...')
            f.style.fontSize = "" + multiplier + "em"
            if (!f.offsetWidth)
            {
                alert('zero offsetWidth, so resetting to dft=')
                f.style.fontSize = ""
            }
        }
        catch(e)
        {
            alert('error seen: ' + e)
        }
    }
}


var ui_compression_level
var resizeTimer

function change_css_for_display_style(ui_compression_level)
{
    var font_multiplier_percentage
    
    if (ui_compression_level >= 2)
    {
        //load_css("mobile")
        font_multiplier_percentage = "300%"
    }
    else
    {
        //load_css("desktop")
        font_multiplier_percentage = "100%"
    }
    
    
    
    
    
    
    
    font_multiplier_percentage = "100%"
    
    
    
    
    
    
    
    
    $("font").css("font-size", font_multiplier_percentage)
}


function possibly_change_ui_compression_level()
{
    try
    {
        if (devicePixelRatio > 1999999)
        {
            ui_compression_level = 2
        }
        else
        {
            var window_width = $(window).width()
            if (window_width > 800)
            {
                ui_compression_level = 0
            }
            else if (window_width > 620)
            {
                ui_compression_level = 1
            }
            else
            {
                ui_compression_level = 2
            }
        }
        make_screen()
    }
    catch(e)
    {
        ;
    }
}

$(window).resize(function() 
{
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(possibly_change_ui_compression_level, 100);
}
)
