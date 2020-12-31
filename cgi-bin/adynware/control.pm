package control;
use strict;
use diagnostics;
use adynware::web_gen;

my %__lists = ();

sub displayList
{
        my($infoReference) = @_;
        my($writable, $isMapping, $valueLabel, $shortName, $title, $keyLabel, $textBelowTitle, $hashReference) = @$infoReference;
                                                 
                        
        my $content = "<tr>";
        $content .= "<td>";
        $content .= "<a name=$shortName></a>\n";
        $content .= ButtonLinkToHelp($shortName);
        $content .= CellHeader($title);
        $content .= $textBelowTitle;
                                                                                        
        $content .= "</td>\n";
        $content .= "<td><table>\n";
                                        
        my %hash = %$hashReference;
        my @hashKeys = sort keys %hash;
        my $listEmpty = !scalar(@hashKeys);
        if ($isMapping)
        {
                $content .= "<script language=\"JavaScript\">var $shortName" . "_values = new Array();\n";
                for (my $j = 0; $j <  scalar(@hashKeys); $j++)
                {
                        $content .= $shortName . "_values[$j] = \"$hash{$hashKeys[$j]}\";\n";
                }
                $content .= "</script>\n";
        }
                
                                
        if ($writable)
        {
                $content .= "<tr><td>\n";
                my $handler;
                if ($isMapping)
                {
                        $handler = "'AddToMapping(\"$shortName\", \"site\", \"$valueLabel\", mostRecentDocument, \"\")'";
                }
                else
                {
                        $handler = "'AddToSet(\"$shortName\", \"site\", mostRecentDocument)'";
                }
                $content .= web_gen::Button("add_$shortName", "Add", "onClick=$handler");
                if (!$listEmpty)
                {
                        $content .= " &nbsp ";
                        if ($isMapping)
                        {
                                $content .= web_gen::Button("edit_$shortName", "Edit $valueLabel", "onClick='EditMapping(\"$shortName\", \"$keyLabel\", \"$valueLabel\")'");
                        }
                        else
                        {
                                $content .= web_gen::Button("edit_$shortName", "Edit $valueLabel", "onClick='Edit(\"$shortName\", \"$keyLabel\", \"$valueLabel\")'");
                        }                
                        $content .= " &nbsp ";
                        $content .= web_gen::Button("delete_$shortName", "Delete", "onClick='DeleteFromSet(\"$shortName\")'");
                }
                $content .= "</td>";
                $content .= "</tr>\n";
        }
        $content .= "<tr><td>\n";
        if (!$listEmpty)
        {
                $content .= web_gen::Select($shortName, "multiple", 4, \@hashKeys, \@hashKeys);
        }
        $content .= "</td></tr>\n";
        $content .= "</table></td>\n";
        $content .= "</tr>\n";
        return $content;
}

sub CellHeader
{
        my($header) = @_;
        return "<font size=+2>	$header</font><br>\n";
}

sub Header
{
        my($mostRecentDocument, $version) = @_;
                
        my $header1 = "<head><title>Spinach $version Control</title><script language=\"JavaScript\">var mostRecentDocument = '$mostRecentDocument';";
                
        my $header2 =<<'EOS';
        var originalIntegerSettings = "";
                
        function IsWhite(c)
        {
                return (c==' ') || (c=='\t') || (c=='\n');
        }
                
        function Trim(s)
        {
                if (s=="") return "";
                var start = 0;        
                while (IsWhite(s.charAt(start))) 
                {
                        start++;
                        if (start>=s.length) return "";
                }
                var end = s.length - 1;        
                while (IsWhite(s.charAt(end))) 
                {
                        if (end<=0) return "";
                        end--;
                }
                return s.substring(start, end+1);
        }
                
        function AddToSet(listName, label, defaultItem)
        {
                var key = PromptForMappingKey(listName, label, defaultItem);
                if(!key) return;
                var stuff = "$spinach__" + listName + '{' + key + '} = 1;\n';
                if (listName == "noCache")
                {
                        stuff += 'RemovePageAndItsChildren(' + key + ');\n';
                } 
                Save(stuff, listName);
        }
                
                
        function DeleteFromSet(listName)
        {
                var item = 0;
                var field = eval("document.spinach_main." + listName);
                for (var j = 0; j<field.options.length; j++)
                {
                        if(field.options[j].selected)
                        {
                                item = Trim(field.options[j].value);
                                if(!confirm("remove " + item + " from " + listName + " list?")) return;
                                var stuff = 'delete($spinach__' + listName + '{"' + item + '"});\n';
                                if ((listName == "useCache") || (listName == "userSpecifiedPrefetchTargets"))
                                {
                                        stuff += 'RemovePageAndItsChildren("' + item + '");\n';
                                } 
                                Save(stuff, listName);
                        }
                }
        }
                        
        function PromptForMappingKey(listName, keyLabel, defaultKey)
        {
                var key = prompt("enter the " + keyLabel + " for the " + listName + " list:", defaultKey);
                if(!key) return null;
                return '"' + Trim(key) + '"';
        }
                
        function PromptForMappingValue(listName, keyLabel, valueLabel, key, defaultValue)
        {
                var value = prompt("enter the " + valueLabel + " to associate with " + keyLabel + " " + key, defaultValue);
                if(!value) return null;
                return '"' + Trim(value) + '"';
        }
                
        function AddToMapping(listName, keyLabel, valueLabel, defaultKey, defaultValue)
        {
                var key = PromptForMappingKey(listName, keyLabel, defaultKey);
                if(!key) return;
                var value = PromptForMappingValue(listName, keyLabel, valueLabel, key, defaultValue);
                if(!value) return;
                Save( "$spinach__" + listName + '{' + key + '} = ' + value + ';\n', listName);
        }
                        
                                
        function verifyDigits(s)
        {
                for (var j=0; j<s.length; j++)
                {
                        var c=s.charAt(j);
                        if (c<'0' || c>'9')
                        {
                                alert('invalid value: expected digits');
                                return false;
                        }
                }
                return true;
        }
        
        function Edit(listName, keyLabel, valueLabel)
        {
                var field = eval("document.spinach_main." + listName);
                for (var j = 0; j<field.options.length; j++)
                {
                        if(field.options[j].selected)
                        {
                                var key = field.options[j].value;
                                var value = PromptForMappingKey(listName, keyLabel, key);
                                if(!value) return;
                                Save( "delete($spinach__" + listName + '{"' + key + '"});\n$spinach__' + listName + '{' + value + '} = 1;\n', listName);
                                return;
                        }
                }
                if(!item) return;
        }
                        
        function EditMapping(listName, keyLabel, valueLabel)
        {
                var field = eval("document.spinach_main." + listName);
                for (var j = 0; j<field.options.length; j++)
                {
                        if(field.options[j].selected)
                        {
                                var key = '"' + field.options[j].value + '"';
                                var value = PromptForMappingValue(listName, keyLabel, valueLabel, key, eval(listName + "_values[" + j + "]"));
                                if(!value) return;
                                Save( "$spinach__" + listName + '{' + key + '} = ' + value + ';\n', listName);
                                return;
                        }
                }
                if(!item) return;
        }
                        
        function Save(stuff, nextAnchor)
        {
                location = "http://www.adyn.com/spinach/backstop/control.html?" + escape(stuff) + "#" + nextAnchor;
        }
        function utility_getSelected(options)
        {
                var i;
                for(i = 0; i < options.length; i++)
                {
                        if (options[i].checked) break;
                        if (options[i].selected) break;
                }
                return options[i].value;
        }
        function CheckBoxChanged(variableName)
        {
                Save( "$spinach__" + variableName + "=" + eval("document.spinach_main." + variableName + ".checked?1:0") + ";\n", variableName);
        }
        function Shutdown()
        {
                location = "http://__spinach__/close.html?" + escape( "ShutdownAtNextCheckPoint()" );
        }
        
        function RadioChanged(variableName)
        {
                Save( "$spinach__" + variableName + "=" + eval("utility_getSelected(document.spinach_main." + variableName + ")") + ";\n", variableName);
        }
        function ChangeInteger(variableName, what, multiplier)
        {
                ChangeField(variableName, what, multiplier, 1);
        }
        function ChangeField(variableName, what, multiplierOrEmptyAllowed, numeric)
        { 
                var value = prompt("enter " + what + ":", "");
                if (numeric)
                {
                        if (!value) return;
                        var multiplier = multiplierOrEmptyAllowed;
                        if (!verifyDigits(value)) return;
                        value *= multiplier;
                }
                else
                {
                        var emptyAllowed = multiplierOrEmptyAllowed;
                        if (!emptyAllowed && !value) return;
                        value = '"' + value + '"';
                }

                Save( "$spinach__" + variableName + "=" + value + ";\n", variableName);
        }
        function ClearBrowserCacheCatalog(variableName)
        {
                if (confirm("tell Spinach that the browser cache has been cleared?"))
                {
                        Save( "ClearBrowserCacheCatalog();", variableName);
                }
                else
                {
                        document.spinach_main.clearBrowserCacheCatalog.checked = 0;
                }
        }
                
        </script>
        </head>
EOS
	return $header1 . $header2;
}

sub ButtonLinkToHelp
{
        my($linkName) = @_;
        
        return "<!--link $linkName label-->" . 
        "<input type=button value='Help' name=help_$linkName onclick='window.location=\"http://__spinach__/spinach.html#$linkName\"'>\n";
}

sub DataField
{
        my($name, $label, $multiplierOrEmptyAllowed, $isNumeric) = @_;
        return "<a name=data_field$label></a>" . web_gen::Button($name, "Change", "onClick='ChangeField(\"$name\", \"$label\", $multiplierOrEmptyAllowed, $isNumeric)'");
}

sub generate
{
        my($proxyServer, $proxyPort, $port, $version, $suppressAds, $noPrefetchBeforeFirstBrowserQuery, $prefetchEnabled, $prefetchMaxItems, $imageCaching,
        #$popupControlMode,
        $cacheSizeLimit, $cacheSize, $customerID, $stalenessTime, $mostRecentDocument, $arrayOfListReferences) = @_;
                
        
        my $content = Header($mostRecentDocument, $version);
        $content .= "<body>";
        $content .= web_gen::FormBegin("spinach_main");
        $content .= "<font size=6><b>Spinach";
        $content .= "ControlPage</b></font>";
                
        $content .= web_gen::Button("shutdown", "Shutdown", "onClick='Shutdown()'");
                
        $content .= "<br>This page controls Spinach Browser's behavior";
                
        $content .= "<table border cellpadding=5>\n";
                                                                                       
        foreach my $list (@$arrayOfListReferences)
        {
                my($writable, $isMapping, $valueLabel, $shortName, $title, $textBelowTitle, $hashReference) = @$list;
                $__lists{$shortName} = $list;
        }
                                                                                
        $content .= "<tr><td>";
        $content .= "<a name=suppressAds></a>\n";
        $content .= ButtonLinkToHelp("suppressAds");
        $content .= CellHeader("Ad Suppression");
        $content .= "</td><td>\n"; 
        $content .= web_gen::CheckBox("suppressAds", 1, $suppressAds, 
        
        "suppress ad banners", # THIS STRING IS QUOTED IN THE DOCUMENTATION!
        
        "onClick='CheckBoxChanged(\"suppressAds\")'");
        $content .= "</td></tr>\n";
                             
                
        $content .= displayList(delete($__lists{"advertisers"}));
        
                
                
                        
                                           
                                
                                                         
        $content .= "<tr><td>";
        $content .= "<a name=prefetchEnabled></a>\n";
        $content .= ButtonLinkToHelp("prefetchEnabled");
        $content .= CellHeader("Prefetching");
        $content .= "direct Spinach to prefetch web pages you frequently access";
        $content .= "</td><td>\n"; 
        $content .= web_gen::CheckBox("prefetchEnabled", 1, $prefetchEnabled, "prefetching enabled", "onClick='CheckBoxChanged(\"prefetchEnabled\")'");
        $content .= "<br>\n";
        $content .= web_gen::CheckBox("noPrefetchBeforeFirstBrowserQuery", 1, $noPrefetchBeforeFirstBrowserQuery, "no prefetching until browser's first HTTP query", "onClick='CheckBoxChanged(\"noPrefetchBeforeFirstBrowserQuery\")'");
        $content .= "<br>\n";
        $content .= DataField("prefetchMaxItems", "maximum pages which will be prefetched at startup", 1, 1);
        $content .= $prefetchMaxItems . " is maximum pages which will be prefetched at startup\n";
        $content .= "</td></tr>\n";
                
        
                
        $content .= displayList(delete($__lists{"userSpecifiedPrefetchTargets"}));
        
                
                                
        $content .= "<tr><td>";
        $content .= "<a name=imageCaching></a>\n";
        $content .= ButtonLinkToHelp("imageCaching");
        $content .= CellHeader("Supplemental Image Caching");
        $content .= "</td><td>\n";
                                                                               
        $content .= web_gen::CheckBox("imageCaching", 1, $imageCaching, "aggressively use the image cache", "onClick='CheckBoxChanged(\"imageCaching\")'");
        $content .= "<br>";
        $content .= "<a name=clearBrowserCacheCatalog></a>\n";
        $content .= web_gen::Button("clearBrowserCacheCatalog", "Tell Spinach browser cache was cleared", "onClick='ClearBrowserCacheCatalog(\"clearBrowserCacheCatalog\")'");
        $content .= "</td></tr>\n";
                                           
                
                        
        $content .= displayList(delete($__lists{"noCache"}));
        $content .= displayList(delete($__lists{"useCache"}));
        
        
        
        
        #$content .= "<tr><td>";
        #$content .= "<a name=popupControlMode></a>\n";
        #$content .= ButtonLinkToHelp("popupControlMode");
        #$content .= CellHeader("Popup Mode");
        #$content .= "If a site is on the popup control list, one of the following policies is enforced:</td><td>\n";
                                                                       #
        #$content .= web_gen::Radio("popupControlMode", [0,1,2], ["off: do not interfere", "allow with confirmation", "silently suppress"], $popupControlMode, "onClick='RadioChanged(\"popupControlMode\")'");
        #$content .= "</td></tr>\n";
         #
        #
                        #
        #$content .= displayList(delete($__lists{"popupControl"}));
        
                
                
                
                                        
        $content .= "<tr><td>";
        $content .= ButtonLinkToHelp("cacheSizeLimit");
        $content .= CellHeader("Cache Size Limit");
        $content .= "current cache size is $cacheSize kilobytes";
        $content .= "</td><td>";
                
        $content .= DataField("cacheSizeLimit", "cache size limit in kilobytes", 1024, 1);
        $content .= int($cacheSizeLimit) . " kilobytes\n";
        $content .= "</td></tr>\n";
                                                                    
        $content .= "<tr><td>";
        $content .= ButtonLinkToHelp("stalenessTime");
        $content .= CellHeader("Cache Item Age Limit");
        $content .= "number of days before items are dropped from the cache";
        $content .= "</td><td>";
        $content .= DataField("stalenessTime", "time limit in days after which cached items are discarded", (24 * 60 * 60), 1);
        $content .= "$stalenessTime\n"; 
        $content .= "days</td></tr>\n";
                        
                        
                        
                
        $content .= "<tr><td>";
        $content .= ButtonLinkToHelp("auditMode");
        $content .= CellHeader("Audit Mode");
        $content .= "open audit window";
        $content .= "</td><td>\n";
        $content .= web_gen::Button("auditMode", "Audit Mode", "onClick='window.location=\"http://www.adyn.com/spinach/backstop/audit.html\"'");
        $content .= "</td></tr>\n";
                
                        

        $content .= "<tr><td>";
        $content .= ButtonLinkToHelp("customerIDspinach");
        $content .= CellHeader("Customer ID");
        $content .= "</td><td>$customerID\n"; 
        $content .= "</td></tr>\n";
                                                                        
        $content .= "<tr><td>";
        $content .= "<a name=proxyServer></a>\n";
        $content .= ButtonLinkToHelp("proxyServer");
        $content .= CellHeader("Proxy Server");
        $content .= "proxy server to which spinach should forward queries";
        $content .= "</td><td>\n"; 
        $content .= web_gen::Button("proxyServer", "Change", "onClick='ChangeField(\"proxyServer\", \"proxy server\", 1, 0)'");
        if ($proxyServer)
        {
                $content .= "next chained proxy host is $proxyServer\n<br>"; 
                $content .= DataField("proxyPort", "proxy port", 1, 1);
                $content .= "on port $proxyPort\n<br>"; 
                $content .= "</td></tr>\n";
                                                                                
                $content .= "<tr><td>";
                $content .= displayList($__lists{"noProxy"});
        }
        else
        {
                $content .= "there is no additional proxy host\n"; 
        }
        delete($__lists{"noProxy"});
        
        $content .= "</td></tr>\n";
                                                                
        $content .= "<tr><td>";
        $content .= ButtonLinkToHelp("portspinach");
        $content .= CellHeader("Spinach Port");
        $content .= "browsers send queries to this port, which spinach listens to";
        $content .= "</td><td>\n"; 
        $content .= DataField("port", "spinach port", 1, 1);
        $content .= "Port $port\n"; 
        $content .= "</td></tr>\n";
        
                
                        
        foreach my $listName (keys %__lists)
        {
                $content .= displayList($__lists{$listName});
        }
                
                        
        $content .= "</table>\n";
        $content .= "<br><a href='mailto:spinach_bugs@" . "adyn.com?subject=problem with Spinach' alt='mail spinach_bugs@" . "adyn.com'>To report a bug</a>\n";
        $content .= "<br><a href='mailto:spinach_user_feedback@" . "adyn.com' alt='mail spinach_user_feedback@" . "adyn.com'>To send feedback concerning Browser Spinach</a>\n";
        $content .= "<br><a href='mailto:support@" . "adyn.com' alt='mail support@" . "adyn.com'>To contact Adynware Corp.</a>\n";
        $content .= "<br><a href='http://www.adyn.com/spinach/summary.html'>To purchase Browser Spinach</a>\n";
        $content .= web_gen::FormEnd();
        $content .= "</body>\n";
        return $content;
}
1;
