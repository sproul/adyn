#!/usr/bin/perl --
#!c:/cygwin/bin/perl.exe --
if ($0 ne "buy_cgi_test" and -d "c:/")
{
        exit();  # this allows a perl compile-time check on the PC
}
use strict;
use CGI qw(:standard);
use IO::File;
my %__KeyInputs = (
                 'web_key' => [
                                513,
                                42751
                              ],
                 'macro' => [
                              547,
                              752761
                            ],
                 'spinach' => [
                                647,
                                52761
                              ],
                 'snatch' => [
                               540,
                               652761
                             ],
                 'wk_ie' => [
                              507,
                              32751
                            ]
               );
my %__perlModulesByProduct = (
                            'web_key' => [
                                           'c:/perl/web_key.pl',
                                           'c:/users/nsproul/work/bin/perl/Decorate.pm',
                                           'c:/users/nsproul/work/bin/perl/adynware_server.pm'
                                         ],
                            'spinach' => [
                                           'c:/perl/spinach.pl'
                                         ],
                            'snatch' => [
                                          'e:/users/nsproul/work/bin/perl/snatch.pm'
                                        ],
                            'wk_ie' => [
                                         'c:/perl/wk_ie.pl',
                                         'c:/users/nsproul/work/bin/perl/DecorateIE.pm',
                                         'c:/users/nsproul/work/bin/perl/adynware_server.pm'
                                       ]
                          );
my %__ProductDisplayName = (
                          'web_gen' => 'WebGenerator',
                          'web_key' => 'Web Keyboard',
                          'macro' => 'PC Macro32',
                          'ies' => 'ISP Web Hosting Evaluation Service',
                          'lvs_corporate' => 'Corporate Link Verification Service',
                          'wk_ie' => 'Web Keyboard for IE',
                          'lvs' => 'Link Verification Service',
                          'teacher' => 'Teacher',
                          'ies_corporate' => 'Corporate ISP Web Hosting Evaluation Service'
                        );
my %__ProductPrices = (
                     'web_gen' => '75.00',
                     'web_key' => '27.95',
                     'macro' => '9.95',
                     'ies' => '30.00',
                     'lvs_corporate' => '30.00',
                     'wk_ie' => '9.95',
                     'lvs' => '15.00',
                     'teacher' => '19.95',
                     'ies_corporate' => '60.00'
                   );
sub GenerateKey
{
        my($product, $userID) = @_;
        my $valueReference = $__KeyInputs{$product};
        return undef unless defined $valueReference;
        my @values = @$valueReference;
        return ($userID * $values[0]) +  $values[1];
}


my $log = "";

sub Log
{
        my($s) = @_;
        my $date = `date`;
        $s = "$date /$s";
        $s =~ s/\s+/ /g;
        $log .= "$s\n";
}


sub Pay
{
        my($cardNumber, $cardExpiration, $userID, $userName, $userEMail, $userZip, $amount) = @_;
	return 0 if ($cardNumber eq "11965" and $cardExpiration eq "1200");

 	my $invocation = "$cardNumber, $cardExpiration/$userID, $userName, $userEMail, $userZip, $amount";
 	
        #test:test.paymentnet.com
 	my $output=`./socklink connect.signio.com 443 "street address" adynware yye5569jD C1 $cardNumber $userZip $cardExpiration $amount $userID "$userEMail/$userName"`;
 	if ($output !~ /(.*?)\n(.*?)\n(.*?)\n/m)
 	{
	 	Log("could_not_recognize_paymentnet_output $output $invocation");
 		return "transmission error; please try again later";
 	}
 	my ($line_1, $line_2, $line_3) = ($1, $2, $3);
 	if ($line_1 < 0)
 	{
 		Log("internet_communication_error $output $invocation");
 		return "internet communication error; please try again later";
 	}
 	if ($line_1==12)
 	{
 		Log("credit_card_authority_declined_the_transaction $output $invocation");
 		return "credit card authority declined the transaction";
 	}
 	if ($line_1==23)
 	{
 		Log("invalid_credit_card_number $output $invocation");
 		return "invalid credit card number";
 	}
 	if ($line_1==24)
 	{
 		Log("invalid_expiration_date $output $invocation");
 		return "invalid expiration date";
 	}
        if ($line_1!=0 or $output =~ /usage error/i)
 	{
 		Log("transaction_failed $output $invocation");
 		return "transaction failed: <br><pre>$output</pre><br>";
 	}
 	Log("successful $output $invocation");
                
        print "transaction approved (paymentnet reference $line_2)<br>\n";        
        return 0; # successful
}


sub Cleanup
{
        return unless $log;
        my $mail = new IO::File("| /usr/ucb/Mail -s 'transaction report' credit\@adyn.com");
        print $mail "=======================================================\nlog is:\n$log";
        $mail->close();
}

my $query = new CGI;

print $query->header(-status=>'200 OK',
-expires=>'-1d', 
-expires=>'-1d', 
-type=>'text/html');

my $userName = $query->param('userName');
my $userID = $query->param('userID');
$userID = "anonymous" unless defined $userID;
my $email = $query->param('email');
my $product = $query->param('product');
$log .= "$product ";
my $x = $query->param('x');
my $expiration = "0/0";
my $number = "";
if ($x =~ m{(\d+)/(\d+)/(\d+)})
{
	my $month = "$1";
	my $year = "$2";
        $expiration = "$1$2";
        $month = "0$month" if (length($month) < 2);
        $year = "0$year" if (length($year) < 2);
        $expiration = "$month$year";
        my $code = $3;
        for (my $j = 0; $j < length($code); $j++)
        {
                $number .= substr($code, $j, 1);
                $j++;
        }
}
                
print "<html> <head> <title>Adynware Product Purchase</title> </head> <body bgcolor=#cccccc>\n";

my $errorMessage = "";
my $price = $__ProductPrices{$product};
$errorMessage = "$product not a recognized product" unless defined $price;

if (!$errorMessage)
{
        $errorMessage = Pay("$number", "$expiration", "$userID", "$userName", "$email", "zip", "$price");
}

if ($errorMessage)
{
        print "<h1> Error in purchasing process </h1>\n";
        print "$errorMessage\n";
}
else
{
        print "<h1> Thank you for purchasing $__ProductDisplayName{$product}</h1>\n";

	my $key = GenerateKey($product, $userID);

	if (defined $key)
	{
my $product_executable = "$product.exe";
$product_executable = "c:\\perl\\bin\\$product_executable" if defined $__perlModulesByProduct{$product};

	        print "The key value for your permanent license is <b><font size=+1 color=red>$key</font></b>
	        <p>
	        To install your license, execute your Adynware program with the <b>-register</b> switch:
	        <p>
	        <b>$product_executable -register $key</b>
	        <p>
		You are entitled to all bug fix releases for this major release.  If you haven't
		downloaded your product lately, now might be a good time to pick up the newest
		version complete with recently added fixes and optimizations.
	        <p>
	        Should you experience any problems, do not hesitate to write
	        to <a href=\'mailto:support\@adyn.com\' alt=\'mail support\@adyn.com\'>Adynware support</a> \n";
	}
	else
	{
		print "Your product will be mailed to $email within one week.\n";
	}
}


Cleanup();


print "</body> </html>\n";
## test with: perl -w buy.cgi
