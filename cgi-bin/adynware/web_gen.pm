use strict;
#use diagnostics;
package web_gen;
use adynware::utility_file;
use IO::File;
use adynware::web_site;

my %w__anchors = ();
my %w__chunks = ();
my @w__fileNames = ();


my $web_gen__linkmenuIsGenerated = 0;
my $web_gen__inForm = 0; 
my %web_gen__variables = ();
 
sub Init
{
	;
}

sub Cleanup
{
        unlink("etc/linkmenu.htm") if $web_gen__linkmenuIsGenerated;
}

sub LinkMenu
{
        my($color_1, $color_2, $itemsReference) = @_;
        #die "tmp file etc/linkmenu.htm already exists" if (-f "etc/linkmenu.htm");
        $web_gen__linkmenuIsGenerated = 1;
        my $file = new IO::File("> etc/linkmenu.htm") or die "cannot create etc/linkmenu.htm\n"; 
        my $linkMenuStart =<<'EOS';
        <html>
        <head>
        <base target="content_frame">
        </head>
        <body bgcolor=black link=white vlink=white text=white>
EOS
        print $file $linkMenuStart;
        web_gen::Colored_table2($file, "100%", undef, 1, 25, $color_1, $color_2, $itemsReference);
                                
        print $file "</body></html>";
        $file->close();
}


sub SetVariables
{
        my($fileSpecification, $key, $value) = @_;
        if (defined $fileSpecification)
        {
                $web_gen__variables{$fileSpecification, $key} = $value;
                #print "web_gen__variables{$fileSpecification, $key} = $value;\n";
        }
        else
        {
                $web_gen__variables{$key} = $value;
                #print "web_gen__variables{$key} = $value;\n";
        } 
}

sub GetVariable
{
        my($directory, $key, $mustResolve, $default) = @_;
	my $value = $web_gen__variables{$directory, $key};
	if (!defined $value)
	{
		$value = $web_gen__variables{$key};
	} 
	if ((!defined $value) && $mustResolve)
	{
		die "GetVariable($directory, $key): did not see anything";
	} 
	if (!defined $value)
	{
		$value =  $default;
	}
	#print "GetVariable($directory, $key, $mustResolve, $default): $value\n";
	return $value;
}

sub InterpolateVariables
{
        my($fileName, $data) = @_;
        $data = InterpolateVariables_2($fileName, $data, 0);
        $fileName =~ m{(.*)/} or die "interpolate variables: cannot get directory out of $fileName";
        my $directory = $1;
        $data = InterpolateVariables_2($directory, $data, 1);
        return $data;
}
sub InterpolateVariables_2
{
        my($fileSpecification, $data, $mustResolve) = @_;
        $data =~ s/(\@\@([\w_]+)\{(.*?)\})/GetVariable($2, $3, $mustResolve, $1)/eg;
        $data =~ s/(\@\@(\w+))/GetVariable($fileSpecification, $2, $mustResolve, $1)/eg;
        $data =~ s/(\@\@\{([_\w]+)\})/GetVariable($fileSpecification, $2, $mustResolve, $1)/eg;
        return $data;
}


sub SiteHeader
{
        my($fileName, $title, $subtitle, $textReference, $color_1, $color_2) = @_;
        web_gen::SetVariables(undef, "siteTitle", $title);
        my @text = @$textReference;
                                                
        my $file = new IO::File("> $fileName") or die "cannot open $fileName\n";
                        
        print $file "<html>\n";
        print $file "<header>\n";
        print $file "<title>$title</title>\n";
        print $file "</header>\n";
        print $file "<body bgcolor=black link=white vlink=white text=white>\n";
                
        unshift(@text, ["<font size=7>$title</font><font size=5>$subtitle</font>"]);
                
        Colored_table2($file, "100%", undef, 0, 0, $color_1, $color_2, \@text);
        $file->close();
} 


sub Link
{
        my($linkText, $linkDestination) = @_;
                
        if ($linkDestination =~ m{[ :/]})
        {
                return "<a href=$linkDestination>" . $linkText . "</a>";
        }
        return "<!--link $linkDestination " . $linkText . "-->";
}

sub FormBegin
{
        my($name) = @_;
        $web_gen__inForm = 1;
        return "<form name=$name>\n";
}
sub FormEnd
{
        $web_gen__inForm = 0;
        return "</form>\n";
}
 
sub Button
{
        my($name, $label, $attributes) = @_;
        my $begin = "";
        my $end = "";
        if (!$web_gen__inForm)
        {
                $begin = FormBegin("form_" . $name);
                $end = FormEnd();
        }

        return "$begin <input type=button value='$label' name=$name $attributes> $end";
}

sub Select
{
        my($fieldName, $attributes, $displaySize, $valueArrayReference, $labelArrayReference) = @_;
        my $field = "<select name=$fieldName size=$displaySize $attributes";
        $field .= ">\n";
                
        my @valueArray = (); @valueArray = @$valueArrayReference if defined $valueArrayReference;
        my @labelArray = (); @labelArray = @$labelArrayReference if defined $labelArrayReference;
        
        die "web_gen::Select: mismatched value and label arrays" unless scalar(@valueArray)==scalar(@labelArray);
                
        for (my $j = 0; $j < scalar(@valueArray); $j++)
        {
                $field .= "<option ";
                $field .= "selected " unless $j;
                $field .= "value='$valueArray[$j]'>$labelArray[$j]\n";
        }
        $field .= "</select>\n";
        return $field;
}

sub Radio
{
        my($fieldName, $valueArrayReference, $labelArrayReference, $selectedValue, $attributes) = @_;
        my $field = "";
                
        my @valueArray = (); @valueArray = @$valueArrayReference if defined $valueArrayReference;
        my @labelArray = (); @labelArray = @$labelArrayReference if defined $labelArrayReference;
        
        die "web_gen::Radio: mismatched value and label arrays" unless scalar(@valueArray)==scalar(@labelArray);
                
        for (my $j = 0; $j < scalar(@valueArray); $j++)
        {
                $field .= "<input type=radio name=$fieldName ";
                $field .= "checked " if ($valueArray[$j] eq $selectedValue);
                $field .= "$attributes value='$valueArray[$j]'>$labelArray[$j]<br>\n";
        }
        return $field;
}


sub CheckBox
{
        my($fieldName, $value, $checked, $label, $attributes) = @_;
        my $field = "<input type=checkbox name=$fieldName value='$value'";
        if ($checked)
        {
                $field .= " checked";
        }
        $field .= " $attributes>$label\n";
        return $field;
}

sub TextField
{
        my($fieldName, $displayLength, $attributes) = @_;
        return "<input type=text name=$fieldName size=$displayLength $attributes>";
}

sub Colored_table
{
        my($fileName, $width, $formName, $cellspacing, $rowCount, $colorStart, $colorEnd, $rowsReference) = @_;
                        
        my $file = new IO::File("> $fileName") or die "cannot open $fileName\n";
                                
        Index_preamble($file);
        print $file "<body bgcolor=black link=white vlink=white text=white>\n";
        
        Colored_table2($file, $width, $formName, $cellspacing, $rowCount, $colorStart, $colorEnd, $rowsReference);
        $file->close();
}

sub Colored_table2
{
        my($file, $width, $formName, $cellspacing, $rowCount, $colorStart, $colorEnd, $rowsReference) = @_;
                                                        
        (length($colorStart)==6) || die "$colorStart parameter is not a 6-digit hex number";
        (length($colorEnd  )==6) || die "$colorEnd   parameter is not a 6-digit hex number";
                
        my   $redStart = hex(substr($colorStart, 0, 2));
        my $greenStart = hex(substr($colorStart, 2, 2));
        my  $blueStart = hex(substr($colorStart, 4, 2));
                
        my   $redEnd = hex(substr($colorEnd, 0, 2));
        my $greenEnd = hex(substr($colorEnd, 2, 2));
        my  $blueEnd = hex(substr($colorEnd, 4, 2));
                
        my @rows = @$rowsReference;
        $rowCount = scalar(@rows) unless $rowCount; 
        
        print $file "<form name=$formName>\n" if $formName;
        print $file "<table bgcolor=black width=$width cellpadding=0 cellspacing=$cellspacing border=0>\n";
                                
        my $red = $redStart;
        my $redIncrement = int(($redEnd - $redStart)/$rowCount);
        my $green = $greenStart;
        my $greenIncrement = int(($greenEnd - $greenStart)/$rowCount);
        my $blue = $blueStart;
        my $blueIncrement = int(($blueEnd - $blueStart)/$rowCount);
        
        my $firstRowReference = $rows[0];
        my $columnCount = scalar(@$firstRowReference);
                                
        for (my $row = 0; $row < $rowCount; $row++)
        {
                my $color = sprintf("%0.2x%0.2x%0.2x", $red, $green, $blue);
                                                                                        
                print $file "<tr>\n";
                if ($row < scalar(@rows))
                {
                        my $rowReference = $rows[$row];
                        my @columns;
                        if (defined $rowReference)
                        {
                                @columns = @$rowReference;
                        }
                        else
                        {
                                @columns = ( undef );
                        }
                        
                        for (my $column = 0; $column < $columnCount; $column++)
                        {
                                my $text = $columns[$column];
                                $text = "&nbsp" unless defined $text;
                                
                                print $file "<td bgcolor=#$color> $text</td>\n";
                        }
                }
                else
                {
                        for (my $column = 0; $column < $columnCount; $column++)
                        {
                                print $file "<td bgcolor=#$color>&nbsp</td>\n";
                        }
                }
                print $file "</tr>\n";
                $red += $redIncrement;
                $green += $greenIncrement;
                $blue += $blueIncrement;
        }
        print $file "</table>\n";
        print $file "</form>\n" if $formName;
}

sub DocumentBegin
{
        my($title, $fileName) = @_;
        my $anchorName = $fileName;
        $anchorName =~ s|/|_|g;
        $anchorName =~ s/\.[^\.]*//;
        
        return "<html>
        <head>
        <title>$title</title>
        </head>
        <body bgcolor=#cccce2>
        <!--anchor file_" . $anchorName . "-->
        ";                
}
sub DocumentEnd
{
        return "\n<!--include copyright-->\n</body>\n</html>";
}

sub ReadFAQElement
{
        my($input) = @_;
        my $element = <$input>;
        return 0 unless $element;
        $element =~ s/^(.)/\U$1/;	# capitalize
        while (<$input>)
        {
                last unless ($_ and ($_ ne "\n"));
                $element .= $_;
        }
        $element =~ s/\s*$//;		# trim trailing white
        return $element;
}

sub GenerateFAQ
{
        my($inFileName) = @_;
        print "GenerateFAQ $inFileName\n";
        die "bad FAQ file name (expected '.faq' suffix)" unless $inFileName =~ /(.*)\.FAQ/i;
        my $outFileName = "$1.htm";
        
        my  $input = new IO::File("<  $inFileName") or die "could not open $inFileName";
        my $output = new IO::File("> $outFileName") or die "could not open $outFileName";

        print $output DocumentBegin("\@\@product FAQ", $outFileName);
        print $output "<h1>\@\@product FAQ</h1>";

        my @questions = ();
        my @answers = ();
        for (my $j = 1;; $j++)
        {
                my $question = ReadFAQElement($input);
                last unless $question;
                $questions[$j-1] = $question;
                $answers[$j-1] = ReadFAQElement($input);
        }
        $input->close();
                                
        for (my $j = 1; $j <= scalar(@questions); $j++)
        {
                print $output "<p><a href=#$j>", $j, ". $questions[$j-1]?</a>\n";
        }
        for (my $j = 1; $j <= scalar(@questions); $j++)
        {
                print $output "<h3><a name=$j>", $j, ". $questions[$j-1]?</a></h3>\n";
                print $output $answers[$j-1];
        }

        print $output DocumentEnd();
        $output->close();
}

sub Add_to_input_document_list
{
  my($fn) = @_;
  push(@w__fileNames, $fn);
}

sub Gather_input_document_list
{
        my($suffix, @directories) = @_;
        push(@directories, ".");
        
        @w__fileNames = ();
        foreach my $directory (@directories)
        {
                opendir(DIR, $directory) or die "cannot open directory $directory:$!";
                foreach my $file (readdir(DIR))
                {
                        if ($file =~ /\.$suffix$/)
                        {
                                push(@w__fileNames, "$directory/$file");
                        }
                }
                closedir(DIR);
        }
}

sub GenerateFAQs
{
        my(@directories) = @_;
        Gather_input_document_list("faq", @directories);
        foreach my $fileName (@w__fileNames)
        {
                GenerateFAQ($fileName);
        }
}


sub Gather_chunks_in_string
{
        my($rawContent, $fileName) = @_;
        #print "Gather_chunksin string($rawContent, $fileName) \n";
        while ($rawContent =~ /(<!--chunk ([@\w]+)-->(.*?)<!--chunkEnd \2-->)/gs)
        {
                my $chunkContentIncludingTags = $1;
                my $chunkName = $2;
                my $chunkContent = $3;
                                                
                #print "saw chunk $chunkName in $fileName\n";
                defined $w__chunks{$chunkName} and die "chunk $chunkName multiply defined";
                $chunkContentIncludingTags =~ s/(<!--anchor) /$1: copy /g;
                
                $w__chunks{ $chunkName} = $chunkContentIncludingTags; 
                Gather_chunks_in_string($chunkContent, $fileName);
        }
}

sub Gather_chunks
{
        foreach my $fileName (@w__fileNames)                
        { 
                my $rawContent = utility_file::getContent("$fileName");
                Gather_chunks_in_string($rawContent, $fileName);
        }
}

sub Gather_links2
{
        my($copies) = @_;
        foreach my $inputFileName (@w__fileNames) 
        { 
                my $fileName = $inputFileName . "l";
                my $rawContent = utility_file::getContent("$fileName");
                while ($rawContent =~ /<!--anchor$copies ([@\w]+)-->/g)
                {
                        if (defined $w__anchors{$1})
                        {
                                if ($copies)
                                {
                                        #print "ignored copied anchor $1 in $fileName\n";
                                }
                                else
                                {
                                        die "anchor $1 multiply defined in $fileName";
                                }
                        }
                        else
                        {
                                #print "anchor $1 in $fileName\n";
                                $w__anchors{$1} = "$fileName" . "#$1";
                        }
                }
        }
}

sub Gather_links
{
        Gather_links2("");
        Gather_links2(": copy");
}


sub AccessHash
{
        my($hashElementName, $key, $hashReference, $fileName) = @_;
        my $value = $$hashReference{$key};
        die "!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n!\n$key is not a defined $hashElementName in $fileName" unless defined $value;
        return $value;
}

sub ResolveLink
{
        my($fileName, $logicalLinkName, $hashReference) = @_;
        my $link = AccessHash("anchor", $logicalLinkName, $hashReference, $fileName);
                                                
        my $offset = "";
        $offset = $1 if $link =~ s/(#.*)//;
                                
        $offset = "" if $offset =~ /^#file_/;
                        
                
        my $resolvedLink;
        if ($link eq $fileName)
        {
                $resolvedLink = $offset; 
        }
        else
        {
                my $level = utility_file::directoryDepth($fileName);
                $resolvedLink = "";
                for (my $j = 0; $j < $level; $j++)
                {
                        $resolvedLink .= "../";
                }
                $resolvedLink .= $link;
                $resolvedLink .= $offset;
        }
        return $resolvedLink;
}

sub EvaluateIf
{
        my($expression, $data, $fileName) = @_;
        #print STDERR "about to evaluate '$expression' in EvaluateIf in $fileName\n";
        my $value = eval($expression);
        if ($@)
        {
                print STDERR "error evaluating '$expression' in EvaluateIf in $fileName\n";
                return "";
        }
        return $data if $value;
        return "";
}

sub Resolve_chunks_in_string
{
        my($content, $fileName) = @_;
        $content =~ s/(<!--include ([@\w]+)-->)/$1 . Resolve_chunks_in_string(AccessHash("chunk", $2, \%w__chunks, $fileName), $fileName)/ge;
        return $content;
}

sub Resolve_chunks
{
        foreach my $inputFileName (@w__fileNames)                
        { 
                my $rawContent = utility_file::getContent("$inputFileName");
                my $fileName = $inputFileName . "l";
                utility_file::setContent($fileName, Resolve_chunks_in_string($rawContent, $fileName));
        }
}


sub Resolve_links_and_includes
{
        Gather_chunks();
        Resolve_chunks();
        foreach my $inputFileName (@w__fileNames)                
        {
		#print "c:/perl/lib/adynware/web_gen.pm Resolve_links_and_includes($inputFileName)\n";
		
                my $fileName = $inputFileName . "l";
                my $content = utility_file::getContent("$fileName");
                                                
                $content = InterpolateVariables($fileName, $content); 
		$content = InterpolateVariables($fileName, $content); # 2nd for nested vars
                $content =~ s/(<!--if +(.*?)-->.*?<!--endif \2-->)/EvaluateIf($2, $1, $fileName)/egms;
                
                utility_file::setContent($fileName, $content);
        }
        Gather_links();
        foreach my $inputFileName (@w__fileNames)                
        {
                my $fileName = $inputFileName . "l";
                my $content = utility_file::getContent("$fileName");
                                                                
                $content =~ s{(<!--anchor(: copy)? (\w+)-->)}{$1<a name=$3></a>}g;
                $content =~ s{(<!--link +(\w+) (.*?)-->)}{"$1<a href=" . ResolveLink($fileName, $2, \%w__anchors) . ">$3</a>"}egms;
                                                
                utility_file::setContent($fileName, $content);
        }
}

sub Strip_comments_and_leading_space
{
        foreach my $inputFileName (@w__fileNames)                
        {
                my $fileName = $inputFileName . "l";
                my $content = utility_file::getContent("$fileName");
                $content =~ s/<!--.*?-->//gs;
                $content =~ s/^\s+</</gm;
                utility_file::setContent($fileName, $content);
        }
}



sub Get_links_to_be_verified
{
        my %linksToBeVerified = ();
        foreach my $inputFileName (@w__fileNames)                
        {
                my $fileName = $inputFileName . "l";
                my $content = utility_file::getContent("$fileName");
                                                                
                while ($content =~ m{(-->)?<a href=['"]?([^'"\s>]*)}gms)
                {
                        next if $1;
                        my $link = $2;
                        next if $link =~ /^#\d+$/;  # next if this is a generated faq link we can trust
                        $link = web_site::makeAbsolute($link, $fileName);
                        next if $link !~ m{^https?://}; # we only check http, https
                        print "verify links: saw $link in $fileName\n";
                        $linksToBeVerified{$link} = 1;
                }
        }
        return [keys %linksToBeVerified];
}

sub web_gen__variable_get
{
        my($fileSpecification, $variable) = @_;
        my $value = $web_gen__variables{$fileSpecification, $variable};
        return $value if defined $value;
                
        
        $fileSpecification =~ m{(.*)/} or die "web_gen__variable_get: cannot get directory out of $fileSpecification";
        my $directory = $1;
        $value = $web_gen__variables{$directory, $variable};
        return $value if defined $value;
        return 0;
}
1;
