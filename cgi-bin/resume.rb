#!c:/perl/bin/perl.exe
my $__local = ((-d "c:/") && 0);
use strict;
use CGI qw(:standard);
use adyn_cgi_util;

my $__dftSize = 1;
my $__trace = 0;
my $__borderSize = $__dftSize;
my $__cellpadding = $__dftSize;
my $__cellspacing = $__dftSize;
my $__mailable = 0;

my $__webSite = ($__local ? "127.0.0.1" : "www.adyn.com");
my $__resumeVersion;
my $__minimalJavaScript = 0;
my %__employersAlreadySeen = ();
my %__employers = ();


my $query;
if (-d "c:/")
{
  $query = new CGI(\*STDIN);
}
else
{
  $query = new CGI;
}

print $query->header(
-status=>'200 OK',
-expires=>'-1d',
-type=>'text/html');


$__employers{"personal"} = "<b>1/1965--present Man on this earth</b>";
$__employers{"Oracle"} = "<b>6/2008-present Principal Member of the Technical Staff for\n<a href='http://www.oracle.com'>Oracle Corporation</a> (formerly <a href='http://www.bea.com'>BEA Systems</a>), San Francisco, CA</b>";
$__employers{"BEA"} = "<b>7/2003--5/2008 Senior Software Engineer for \n<a href='http://www.bea.com'>BEA</a> (formerly <a href='http://www.plumtree.com'>Plumtree Software</a>), San Francisco, CA</b>";
$__employers{"Monroe"} = "<b>2/2003--7/2003 Web Application Consultant for\n<a href=http://www.monroesecurities.com/>Monroe Securities</a>, Chicago, IL</b>";
$__employers{"adynware"} = "<b>7/2001--2/2003 Principal Consultant for \n<a href='http://www.adyn.com'>Adynware Corporation</a>, San Francisco, CA</b>";
$__employers{"extensity"} = "<b>1/1999--7/2001 Software Engineer for \n<a href='http://www.extensity.com'>Extensity Corporation</a>, Emeryville, CA</b>";
$__employers{"adynware.0"} = "<b>9/1997--1/1999 Principal Consultant for \n<a href='http://www.adyn.com'>Adynware Corporation</a>, San Francisco, CA</b>";
$__employers{"whitelight"} = "<b>4/1996--9/1997 Software Engineer for Whitelight Systems, Palo Alto CA </b>";
$__employers{"sybase"} = "<b>4/1992--4/1996 Software Engineer 2 for \n<a href='http://www.sybase.com'>Sybase Corporation</a>, Emeryville, CA </b>";
$__employers{"trw"} = "<b>7/1990--3/1992 Systems Analyst for TRW Corporation, Berkeley, CA </b>";
$__employers{"aion"} = "<b>6/1988--6/1990 Software Development Engineer for Aion Corporation. Palo Alto, CA </b>";
$__employers{"ibm"} = "<b>5/1985--12/1985, 6/1986--8/1986 Systems Programmer for I.B.M. Poughkeepsie, NY</b>";

my @projects = (
[
"personal", 0,
" <b>Photos</b>:  Took some \n<a href='http://$__webSite/pix/'>pictures</a> from various vacations."
],
[
"personal", 0,
" <b>Short Story</b>:  Wrote \n<a href='http://$__webSite/resume/personal/shorts/below_24th_st.html'>Below 24th Street</a>."
],
[
"Oracle", 1,
" <b>VMware Lab Manager farm management tools</b>: architected and implemented tooling to control, configure and monitor Oracle's \n<a href=http://www.google.com/search?hl=en&q=vmware+Lab+Manager&btnG=Google+Search>VMware's Lab Manager</a> farm.  \nThese tools support <ul><li>the parallel execution of tasks across many ESX servers (e.g., searching for processes, restarting agents, etc.)</li><li>analysis and exposure of the VM chains on disk</li><li>analysis of the undocumented database underlying Lab Manager</li><li>scriptable bulk updates of VMs' contents (e.g., software updates)</li></ul>\n These tools are implemented in Java and Bourne shell."
],
[
"Oracle", 1,
" <b>Oracle Business Intelligence graphical report comparison software</b>: Designed and implemented injected JavaScript report comparison software to analyze and highlight changes between reports produced by the Oracle Business Intelligence product.  Taking as its input xpath expressions indicating areas of interest in Oracle build reports, this software supports comparisons between any pair of builds, thus automating what has historically been a time-consuming manual task.  This software supports IE, Firefox, and Google Chrome, and uses Google Gears."
],
[
"BEA", 1,
" <b>Java OO VM farm controller API</b>: architected and implemented an object oriented API to control VM farms such as VMware's Lab Manager.  This API presents both synchronous and asynchronous interfaces with callbacks that eased integration into diverse contexts, including test scripts and AJAX monitoring web apps.  Structured the code to support multiple additional VM service providers (e.g., based on \n<a href=http://www.google.com/search?hl=en&q=Solaris+zones&btnG=Google+Search>Solaris zones</a> or \n<a href=http://www.google.com/search?hl=en&q=Dynamic+Logical+Partitioning+AIX&btnG=Google+Search>AIX logical partitions</a>)\n without trauma.  Used axis2 to generate initial wrapper code for VMware's SOAP APIs, and JDBC to operate directly on Lab Manager's undocumented internal database to provide functionality not exposed in their APIs (e.g., to allow merging VMs from building block configurations into new test configurations)."
],
[
"BEA", 1,
" <b>Java/AJAX SNMP resource monitor web application</b>: architected and implemented web application to allocate ownership and monitor the state of machines and other network resources.  The server side is a Java tomcat servlet tested and deployed on Windows, RedHat Linux, and Solaris Unix, using net-snmp to monitor the state of machines.  The client is a JavaScript AJAX app presenting a spreadsheet-like interface of resource attributes chosen by the user.   Used the VMware COM API to communicate with ESX and GSX servers to find and track deployed VMs.  <a href=/resume/testimony/bea_kuhnash_kleinschmidt.html>Feedback</a> was very positive."
],
[
"BEA", 1,
" <b>Java interface to NetApp LUN management</b>: designed and implemented Java interface to NetApp disk, to support controlling the state of Solaris, HP-UX and AIX machine state by means of controlling LUN snapshots.  Communicated with the NetApp server using SSH sessions managed using j2ssh.  The work was implemented in Java."
],
[
"BEA", 0,
" <b>ant Java coverage</b>: wired up BEA's build system to support pushbutton coverage using <a href=http://emma.sourceforge.net/>emma</a>, <a href=http://cobertura.sourceforge.net/>cobertura</a> or <a href=http://www.cenqua.com/clover/>clover</a>, with coverage reports integrated with existing test reporting."
],
[
"BEA", 1,
" <b>Java/C# <a href=http://www.openqa.org/selenium-rc/>Selenium Remote Control</a> AJAX test framework</b>: architected and implemented proxy injection mode (a solution to the cross domain testing problem and the problem of handling multiple frames and windows).  Designed and implemented browser session caching, an optimization which tripled Selenium RC's performance.  Designed and implemented various AJAX features including drag-and-drop support in <a href=http://www.openqa.org/selenium-core/>Selenium Core</a>.  The work was implemented in Java within the Selenium server, JavaScript within the browser AJAX client (with support for IE, Firefox, Navigator, Konqueror, and Safari), C#  in the remote test client, with build infrastructure using ant and maven."
],
[

"BEA", 1,
" <b>Java/C# .NET Tools Infrastructure</b>: reproduced and fixed bugs in testing infrastructure.  Isolated platform-specific components behind universal interfaces (e.g., designed uniform encapsulation for <a href=http://jakarta.apache.org/commons/jxpath/>Jakarta JXPath</a> and <a href='http://www.google.com/microsoft?hq=microsoft&hl=en&lr=&c2coff=1&q=XPathNavigator+%22.NET+Framework+Class+Library%22&btnG=Search'>.NET XPathNavigator</a>).  Improved integration of results reporting with bug database to allow easy navigation and analysis of trees of test suites and cases.  The work was executed in Java and C# under eclipse and Visual Studio.."
],
[
"BEA", 1,
" <b>Port from Solaris Unix to AIX, RedHat Linux, SUSE Linux</b>: Resolved platform differences between Sun JVM and runtime environment and AIX and Linux analogs.  Set up VMware and Microsoft Virtual PC virtual machines to facilitate testing of RedHat Linux and SUSE Linux despite a shortage of hardware running those systems natively.  Deployed first Plumtree AIX-based WebSphere portal at <a href=http://www.unicreditbanca.it/>Unicredit Group</a> in Milan, Italy, earning Employee Excellence Award presented by Plumtree's president."
],
[
"BEA", 0,
" <b>BugDB, a Java/JSP bug tracking system</b>: Analyzed and resolved numerous bugs, added bulk edit feature to allow mass updates of bug records.  Implemented and debugged on Windows and RedHat Linux, debugging Java and JSP using eclipse."
],
[
"BEA", 1,
" <b>C++ memory tuning and bug fixing for web portal components</b>: Diagnosed and corrected C++ memory leaks and other memory misdeeds, fixed bugs and designed and implemented C++ tests for Plumtree's Enterprise Portal components on Solaris Unix, Windows, and AIX, controlled by ant XML scripts.  Profiled coverage and performance using purify and purecov on Solaris Unix, LeakDiag on Windows."
],
[
"Monroe", 1,
" <b>ASP/Securities Trade Tracking Application</b>: Implemented a secure web-based application for tracking and managing the security inventory, trading activities, and capital management of Monroe Securities, a market-making firm.  The software was implemented using server-side JScript (Microsoft JavaScript) ASP pages served by IIS to generate client-side JavaScript, developed under Windows.  The data were stored in MS Access databases, then migrated to MS SQL Server.  Integrated with Sungard BRASS data feed to import trade data.  Implemented unit tests using an xUnit (language neutral version of JUnit) framework.  Tuned performance on MS SQL Server.  Configured security under IIS, using SSL.  <a href='/resume/testimony/monroe.html'>User feedback</a> was very positive."
],
[
"Monroe", 1,
" <b>FFIEC document monitor</b>: Designed and implemented a process to automatically detect corporate financial filings to the government, and report on changes from previous filings.  Using SOAP API calls this Java process detects document updates within seconds, caches the new documents and produces summary reports of changes to the PDF filing since the previous versions, allowing traders to quickly discern market moving aspects of these filings."
],
[
"Monroe", "only_trade",
" <b>Java Options Pricer</b>:  Designed, implemented and tested software to compute an efficient price for an option series based on the prices and implied volatilities of a related option series, as interpreted using Black-Scholes.  This software exposes inefficient prices for options which have the same underlying but trade on different exchanges with different spreads (e.g., QQQ and NDX options).  This software is implemented in Java interfacing with the <a href='http://www.interactivebrokers.com'>Interactive Brokers</a> Java API for its market feed."
],
[
"Monroe", "only_trade",
" <b>MetaStrategy</b>:  Designed, implemented and tested software infrastructure to execute <a href='http://www.tradestation.com/'>TradeStation</a>\n strategies against thousands of stocks.  The software acts to overcome the architectural limitation of TradeStation 6 which normally forces users to focus on a single stock at a time.  The software executes a series of strategies against each of an arbitrary number of symbols, logging the decision-making for later analysis.  The component controlling TradeStation 6 is implemented in Perl, Java and C.  The analytical software is implemented in Perl."
],
[
"adynware", 1,
# dp: Command-Action-Transaction pattern: to facilitate undoing commands, needed for when users parachute into exercises
# out of order.
# Relate the actors to my constructs:
#	Command
#	ConcreteCommand
#	Client
#	Invoker (MenuItem)
#	Receiver (Document, Application)
#
" <b>Java Adaptive Learning Educational Software</b>:  Designed, implemented and tested \n<a href='http://$__webSite/teacher/summary.html'>Teacher</a>\n, a Java-based educational tool for students of foreign languages.  This application allows students to study categories of vocabulary and/or conjugations in any of several languages.  The web site tracks each student's performance across categories of exercises, automatically emphasizing the student's weak areas when selecting new exercises.  The product was designed with the UML and written in Java, JavaScript and HTML under Windows NT and Windows XP,\n and tested using JUnit and XUnit.  Prototyped in Perl under Apache, then implemented in Java servlets under J2EE Tomcat with two versions: one managing a MySQL database via JDBC, and the other using an in-memory <a href='http://www.prevayler.org'>Prevayler</a> solution.  Build controlled by ant; server-side testing done using JUnit."
],
#[
#"adynware", 0,
#" <b>Java/Perl Dynamic Searchable Document</b>:  Designed and implemented this resume as a dynamic, searchable document.  JAX-P is used to execute XSLT to transform XML into Perl data, which then generates HTML and JavaScript when executed via cgi Perl to display my work history.  This document manages a simple database of my projects which can be searched via a form at the document's top.  Search terms are highlighted in the search results for ease of perusal.  Implemented under Solaris Unix and Windows XP."
#],
[
"adynware", 0,
" <b>Java Remote File Find Facility</b>:  Designed and implemented a Java servlet which processes XML-based SOAP find file queries.  JAXM is used to construct and transmit the data.  Implemented under Windows NT."
],
[
"adynware", 0,
" <b>Perl Web Translation Agent</b>:  Designed and implemented a Perl program to interface to online translation services for the first attempt at translating exercises for a foreign language educational software product.  This program provides a batch interface to interactive free translation tools on the Web, including\n<a href='http://www.babelfish.com'babelfish</a> and <a href='http://www.freetranslation.com/'>ets.freetranslation.com</a>."
],
[
"extensity", 1,
" <b>Java Accounting systems integration</b>:  Designed and implemented Java components integrating Extensity's expense report applications with customer accounting packages and HR Sybase, Oracle, and MS SQL servers.  Extensive performance tuning of WebLogic J2EE application servers, MS SQL Server, and Oracle.  Middleware customizations were implemented in Java using JDBC, SQL, and PL/SQL under Solaris Unix and Windows NT, combined with Apache and IIS.  WebLogic J2EE application servers deployed and tuned for large-scale use by thousands of users at customers such as AirTouch (now <a href='http://www.verizon.com'>Verizon</a>), <a href='http://www.incyte.com'>Incyte</a>, <a href='http://www.ogilvy.com'>Ogilvy</a>, and <a href='http://www.hbo.com'>HBO</a>.  <a href='/resume/testimony/ext_airtouch_kelly_al.html'>Client feedback</a> was excellent."
],
[
"extensity", 1,
" <b>Java Accounting systems migration</b>:  Designed and implemented Perl and Bourne shell scripts under Solaris Unix and Windows NT to manage the migration of customers between major releases.  Integrated and debugged Java conversion software to export data to XML and back in the new release.",
],
[
"extensity", 0,
" <b>JavaScript/Java JVM Sniffer</b>:  Designed, implemented and tested applet to determine Java virtual machine (JVM) vendor and, in the Microsoft case, use Microsoft's proprietary interface to determine the build version; this software would propose updating the JVM when incompatible versions were found.  Implemented in Java and JavaScript under Windows NT, this software was deployed to customers whose clients had many versions of the Microsoft JVM in use, only some of which worked correctly with Extensity's products.",
],
[
"extensity", 1,
" <b>Database Management Utilities</b>:  Designed and implemented Bourne shell, Perl and LISP scripts to generate SQL load scripts, to restore and Dump MS SQL Server and Oracle databases, and to edit database tables.  <a href='/resume/testimony/extensity_ronan.html'>Client feedback</a> was very positive."
],
[
"adynware.0", 1,
" <b>C++/Perl/JavaScript Keyboard Shortcut Facility for Netscape Navigator</b>:  Designed, implemented and tested \n<a href='http://$__webSite/web_key/summary.html'>Web Keyboard</a>\n, a software component which greatly increases the ability of Netscape Navigator users to enjoy efficient keyboard-based navigation of the web.  This product was designed with the UML and written in Perl, C++, JavaScript and HTML under Windows NT (and tested under Windows 95, 98, 2000, NT and XP).  This product's \n<a href='http://$__webSite/web_key/download.html'>download</a>\n is available for trial evaluation free of charge.  Also wrote complete product \n<a href='http://$__webSite/web_key/web_key.html'>documentation</a>\n and the \n<a href='http://$__webSite/web_key/faq.html'>FAQ</a>."
],
[
"adynware.0", 0,
" <b>C++/Perl/JavaScript Keyboard Shortcut Facility for Internet Explorer</b>:  Designed, implemented and tested \n<a href='http://$__webSite/web_key/summary.html'>Web Keyboard for Internet Explorer</a>\n, a software component which increases the ability of Internet Explorer 5.x+ users to enjoy efficient keyboard-based navigation of the web.  This product was designed using the UML and written in Perl, C++ and HTML under Windows NT (and tested under Windows 95, 98, 2000, NT and XP).  This product's \n<a href='http://$__webSite/wk_ie/download.html'>download</a>\n is available for trial evaluation free of charge.  Also wrote complete product \n<a href='http://$__webSite/wk_ie/wk_ie.html'>documentation</a>\n and the \n<a href='http://$__webSite/wk_ie/faq.html'>FAQ</a>."
],
[
"adynware.0", 1,
" <b>Java Web Agents</b>:  Designed and implemented Java agents to poll Web travel service databases on an automated basis in search of low air fares.  The query component interacting with Web servers was written in Java.  The parsing component which evaluates the query results was written in Perl under Windows NT."
],
[
"adynware.0", 0,
" <b>Java HTTP Network Sniffer</b>:  Designed, implemented and tested a tracing tool for logging all traffic on a given client machine to and from a web host.  Automatically performs hex Dumps of non-ASCII data.  Supports the analysis of web client-server interactions.  Written in Java under Windows NT."
],
[
"adynware.0", 1,
" <b>Perl CGI Web Site Credit Card Transaction Support</b>:  Designed, implemented and tested Perl CGI software at Adynware Corp.'s web site to support credit card software purchases using \n<a href='http://www.signio.com'>Signio</a>'s client.\n  Deployed on Solaris Unix."
],
[
"adynware.0", 0,
" <b>Perl CGI Web Site Search and Shopping Cart functionality</b>:  Designed, implemented and tested CGI scripts to search the inventory of the online book store www.herplit.com, and to maintain a shopping cart of selected items.  Written in Perl under Solaris Unix, and then ported to RedHat Linux."
],
[
"adynware.0", 1,
" <b>C++/Perl/JavaScript Browser Accelerator</b>:  Designed, implemented and tested Browser Spinach, a proxy server which works with any web browser to improve performance over slow connections.  This is accomplished by means of caching, prefetching, and other optimizations; this product's main functionality was implemented in Perl and C++ under Windows NT (and tested under Windows 95, 98 and NT), and uses multiple threads to allow executing multiple simultaneous HTTP queries.  This product's interface was written in JavaScript and HTML."
],
[
"adynware.0", 1,
" <b>Windows C++ Keyboard Macro Facility</b>:  Designed, implemented and tested \n<a href='http://$__webSite/macro/summary.html'>PC Macro32</a>\n, a program for automating tasks under Windows.  This program can generate keystrokes, spawn programs and do some simple manipulation of windows.  This product was written in C++ under Windows NT (and tested under Windows 95, 98, 2000, NT and XP),  and its \n<a href='http://$__webSite/macro/download.html'>download</a>\n is available for trial evaluation free of charge.  Also wrote complete product \n<a href='http://$__webSite/macro/macro.html'>documentation</a>\n and the \n<a href='http://$__webSite/macro/faq.html'>FAQ</a>."
],
[
"adynware.0", 0,
" <b>LISP Object Browser for C++ and Java</b>:  Designed and implemented a class browser under emacs, capable of navigating the object hierarchy and editing source code.  Also supports incremental updates to the class hierarchy database.  The code parser was written in Perl; the display code is written in LISP; and the run-time database is implemented by a combination of Perl and LISP programs under Windows NT and Solaris Unix."
],
[
"adynware.0", 0,
" <b>Speak, an Inspirational Phrase Generator</b>:  Designed and implemented CGI Perl under Solaris Unix and Windows NT to generate sentences composed of various sorts of jargon.  The business phrases were compiled by David Buxbaum and Ken Marx in meetings during their employment at TRW.  I gathered the new age phrases from advertising for alternative therapies and self-improvement courses here in California.  Give it a try:
<input value='Business' type=button onclick=\"Speak('biz')\">
<input value='New Age' type=button onclick=\"Speak('new_age')\">
<input value='Tech Business' type=button onclick=\"Speak('tech')\">
"
],
[
"whitelight", 1,
" <b>C++ OLAP Server Database Manager</b>:  Implemented C++ objects supporting communication with Oracle, Microsoft, Sybase, Teradata and Informix SQL Servers for Whitelight's OLAP product, used by <a href='http://www.barclays.com/'>Barclays</a> and <a href='http://www.jpmorgan.com/'>J. P. Morgan</a>.  These objects allow dynamic SQL and a full set of catalog queries, executed in multiple threads via ODBC and Sybase CT-Lib over connections pooled for scalable performance.  Database vendor differences hidden behind an object-oriented interface.  Written in C++ under Solaris Unix and Windows NT, and debugged using dbx and the Visual C++ IDE."
],
[
"sybase", 1,
" <b>QA test software</b>:  Designed and implemented software to test internal and external Sybase client libraries, verify their conformance to specification, and automatically report discrepancies and bugs.  Written in C on all major UNIX platforms and Windows NT."
],
[
"sybase", 0,
" <b>C++ Windows NT Window Navigator</b>:  Conceived and implemented software to facilitate jumping between Windows NT windows.  Evoked by a hot key, the program captures the screen, and labels possible destinations with single characters superimposed on the screen.  Entering one of those single characters takes the user to the corresponding window (or widget).  Written in C++ using the Win32 API under Windows NT.  <a href='/resume/testimony/sybase_ramiro.html'>Employer feedback</a> was very positive."
],
[
"sybase", 1,
" <b>Threaded Scripting Language</b>:  Conceived and implemented a programming language supporting thread control and synchronization.  This language was used for QA scripts exercising the Sybase XA transaction management product, and was written in C under Solaris Unix, using DCE.  <a href='/resume/testimony/sybase_ramiro_dce.html'>Employer feedback</a> was very positive."
],
[
"sybase", 0,
" <b>C++ Software Suite for PCs to Control NT or Unix Hosts</b>:  Conceived and implemented a set of programs which would allow a PC running DOS to send commands over a serial line to either an NT machine or a Sun Solaris Unix workstation.  The DOS program was written in C, and the controlled host program was written in C++ under Windows NT.  (For the Solaris Unix boxes, I used the freeware package a2x.)  <a href='/resume/testimony/sybase_ramiro.html'>Employer feedback</a> was very positive."
],
[
"sybase", 0,
" <b>Client Library Exerciser</b>: Implemented a program to exercise internal API calls to move data between Sybase CT-Lib clients and Sybase servers.  This program was written in C under Solaris Unix, and was debugged using gdb, dbx, and sdb.  <a href='/resume/testimony/sybase_ramiro.html'>Employer feedback</a> was very positive."
],
[
"sybase", 1,
" <b>Source Code Distribution Shell Script Suite</b>: Designed and implemented a suite of Bourne shell scripts to efficiently distribute the Sybase connectivity codeline (around 5000 files) to a set of host machines for build and test, and keep these distributed codelines in sync through incremental updates.  This suite smoothly handles partial network outages and host failures.  <a href='/resume/testimony/sybase_ramiro_codeline.html'>Employer feedback</a> was very positive."
],
[
"sybase", 0,
" <b>emacs Request Server</b>: Implemented a server process and interface library to handle requests for GNU emacs services over a network.  This program was written in C under Solaris Unix, and communicates over the network using TCP/IP.  <a href='/resume/testimony/sybase_ramiro.html'>Employer feedback</a> was very positive."
],
[
"trw", 1,
" <b>C: NextFile, a File-Processing, Application-Generating Language</b>: Conceived and implemented a language to operate on very large structured files.  Designed, implemented and tested a code generator <b>nf</b> which from NextFile specifications generates file processing applications in C, including integrity-checkers, file Dumpers and filters.  <b>nf</b> was writtten in C, its parser with lex and yacc."
],
[
"trw", 0,
" <b>C: cnf, a C-to-NextFile Translator</b>: Conceived and implemented a translator which, given C header files, generates equivalent NextFile definitions with appropriate adjustments for alignment according to the specified architecture and C compiler."
],
[
"trw", 1,
" <b>C: File Distribution Server</b>: Implemented a server process and interface library to distribute new revisions of files over a network.  This program was written in C under BSD Unix, and communicates over the network via TCP/IP, and was deployed at the credit receipt processing facilities of <a href='http://www.americanexpress.com/'>American Express</a>."
],
[
"trw", 1,
" <b>C: Swapping hex Editor</b>: Designed and wrote an editor which displays files in both character and hex Dump format, and which allows editing arbitrarily large files by paging portions into and out of memory.  This program was written in C under BSD Unix."
],
[
"trw", 0,
" <b>C: Login Server</b>: Implemented a server process and interface library to control and monitor user account activity, passwords and privileges over a network.  This program was written in C under BSD Unix, and communicates over the network via TCP/IP."
],
[
"trw", 1,
" <b>C: Image Archiver</b>: Designed, implemented and tested this multi-threaded program under OS/2 in C to archive massive data to hard drives.  Simultaneously driving seven hard drives, this program was able to keep pace with the projected voluminous output from IBM mainframe image processing peripherals."
],
[
"trw", 0,
" <b>C: OS/2-Based Mainframe Peripheral Control Program</b>: Designed and implemented under OS/2 in C, this program controls 370 peripherals from a PC by means of a 370-channel connection."
],
[
"trw", 1,
" <b>C: Image Server Processor Integration</b>: Integrated and debugged complex multi-tasking OS/2 program suite, designed to drive mainframe peripherals and process their output.  Combined system monitors, programs manipulating the 370-channel APPC (Token Ring), and the SCSI drives into a correctly functioning whole."
],
[
"aion", 1,
" <b>Pascal: Aion Development System (ADS) Port from OS/2 to MVS</b>: Assisted in porting Aion's artificial intelligence expert system shell from OS/2 MS Pascal code to MVS VS Pascal, resolving compiler and environmental differences.  Debugged with TSO TEST."
],
[
"aion", 0,
" <b>Pascal: ADS List Objects Editor</b>: Implemented programming editor to manage and display ADS expert system objects including an expert-system-wide search-and-replace facility, all in MS Pascal under OS/2."
],
[
"aion", 1,
" <b>Pascal: SQL Client</b>: Implemented full function SQL clients on OS/2 and AS/400, complete with network interfaces using LU 6.2 (APPC), giving ADS access to MS SQL Server data.  OS/2 code was written in Microsoft C interfacing with the IBM Database Manager and Communications Manager, fully integrated into ADS, and debugged using Codeview and SDLC traces.  AS/400 code was written in C/400 interfacing with SQL/400 and Intersystem Communications Files, and debugged using the OS/400 and EPM debuggers."
],
[
"ibm", 1,
" <b>PL/1 SAK PRINTF Function</b>: Designed and implemented library function providing mainframe PL/1 programmers automatic message storage allocation, data formatting and output writing, also in PL/1 and debugged using CP Per."
],
[
"ibm", 0,
" <b>PL/1 Storage Allocator and Memory Manager</b>: Designed and implemented for the mainframe SAK (System Assurance Kernel, an IBM-internal 370 operating system used for testing) in PL/1, debugged with CP Per."
],
[
"ibm", 1,
" <b>PL/1 370 Architecture Verification Test Programs</b>: Implemented SAK (System Assurance Kernel, an IBM-internal 370 operating system used for testing) programs testing the mainframe 3090 370 resource reconfiguration instruction, taking memory units, CPUs, vector units, etc. on and off line.  This software was written in PL/1 under VM and SAK (System Assurance Kernel, an IBM-internal 370 operating system used for testing), and debugged using CP Per."
],
[
"ibm", 0,
" <b>PL/1 Tape Drive Interface</b>: Wrote mainframe 370-channel I/O programs to allow SAK (System Assurance Kernel, an IBM-internal 370 operating system used for testing) access to tape drives.  This software was written in PL/1 under VM and SAK (System Assurance Kernel, an IBM-internal 370 operating system used for testing), and debugged using CP Per."
],
);


my $footer = "<table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%>
<tr>
<td>
<b>Education:</b>
<ul>
<li>University of California at Berkeley, B.S. Computer Science</li>
<li>University of California at Berkeley, B.A. French</li>
</ul>
</td>
</tr>
</table>
</form>
</body>
</html>";



my $cellBegin = "\n<tr><td>";
my $cellEnd = "\n</td></tr>";
my $fullTableBegin = "\n<center><table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%>$cellBegin\n";
my $tableBegin = "\n<center><table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=90%>$cellBegin\n";
my $tableEnd = "$cellEnd</table></center>";

my @__savedHtmlTags = ();


sub StripHtmlTags
{
  my($s) = @_;
  my $j = 0;
  $s =~ s/(<.*?>)//g;
  return $s;
}

sub SearchTarget
{
  my($breakLine, $matchWord, $target) = @_;
  my $patternParameter = CGI::escape($target);
  my $s;
  if ($__mailable || $__minimalJavaScript)
  {
    $s =  "\n<b>$target</b>&nbsp;&nbsp;&nbsp;\n";
  }
  else
  {
    $s =  "\n<input value='$target' type=button onclick='G1($matchWord, \"$target\")'>\n";
  }
  $s .= "\n<br>" if $breakLine;
  return $s;
}

sub CleanPattern
{
  my($originalPattern, $matchWord) = @_;
  my $pattern;

  if ($originalPattern and $matchWord)
  {
    $pattern = "\\b$originalPattern\\b";
  }
  else
  {
    $pattern = $originalPattern;
  }
  $pattern =~ s/([+])/\\$1/g;   # prevent '+' from being interpreted as a regexp character

  # prevent a match if the line begins with "<" or ends with "/"
  # the first qualification prevents HTML, the second, JavaScript
  $pattern = "^([^<].*?)?($pattern)" if $pattern;
  #$pattern = "(.)($pattern)" if $pattern;

  return $pattern;
}

sub PrintHeader
{
  my($originalPattern, $pattern, $showAll, $matchCase, $matchWord) = @_;
  print "<html><head><style type=\"text/css\"> td { font-family: sans-serif; font-size: 70%;  input {font-size: 80%}}</style>";

if (!$__mailable && !$__minimalJavaScript)
{
  print "<script language=JavaScript>
  function G1(matchWord, pattern)
  {
    document.searchForm.showAll.value = 0;
    if(matchWord)
    {
      document.searchForm.matchWord.checked = true
    }
    else
    {
      document.searchForm.matchWord.checked = false
    }
    //
    // for some reason, if I skip this substitution, plus signs get stripped off by the time adyn_cgi_util.param gets 'em.  Thus, 'C++' becomes 'C'!
    pattern = pattern.replace(/\\+/g, '%2B');
    pattern = pattern.replace(/#/g, '%23');	
      document.searchForm.pattern.value = pattern;
      //alert(document.searchForm.pattern.value);
            
      document.searchForm.submit();
    }
    function G2(all)
    {
      document.searchForm.showAll.value = all;
      document.searchForm.pattern.value = '';
      document.searchForm.submit();
    }
    </script>";
  }
  print "<title>Nelson Sproul's resume</title>
  </head>
  <body" . ($__local ? "" : " bgcolor=#cccccc") . "><font face='arial'>
  <script language=JavaScript> function Speak(category)
  {
    window.open('http://$__webSite/cgi-bin/speak.cgi?category=' + category,'Speak','width=300,height=250,screenX=100,screenY=100,alwaysRaised=yes,toolbar=no')
  }
  </script>

  <!--anchor file_consult-->\n";

  if (!$__mailable)
  {
    print "<form name=searchForm action='http://$__webSite/cgi-bin/resume.cgi#searchForm'>\n";
  }
  print "<table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%>
  <tr><td><tr><td colspan=2> <center> <font size=+1> <b><a href='mailto:nelson@"."adyn.com' alt='mail nelson@"."adyn.com'>Nelson Sproul</a></b> </font> </center> </td> </tr><tr> <td>
  <a href='mailto:nelson@"."adyn.com'>nelson@"."adyn.com</a><br>
  1209 Glen<br>
  Berkeley, CA 94708<br>
  510.868.0926<br></td><td>";

  if ($__mailable)
  {
    print "See <a href='http://www.adyn.com/resume/resume.html'>http://www.adyn.com/resume/resume.html</a> for an intelligent version of this resume, supporting searching and filtering.\n";
  }
  else
  {
    print "<input type=hidden name=showAll value=$showAll><input type=hidden name=resumeVersion value=$__resumeVersion>";

    if (!$__minimalJavaScript && !$__mailable)
    {
      if ($pattern)
      {
        print "
        \n<input type=button value='Click to show all projects'      name=x onclick='G2(1)'>
        \n<input type=button value='Click to show career highlights' name=x onclick='G2(0)'>";
      }
      elsif ($showAll)
      {
        print "All projects shown below.
        \n<input type=button value='Click to show only highlights' name=x onclick='G2(0)'><br>\n";
      }
      else
      {
        print "Abridged list of projects below.
        \n<input type=button value='Click to show all projects' name=x onclick='G2(1)'><br>\n";
      }
    }
    print " $fullTableBegin Or search:
    \n<input value=\"$originalPattern\" type=text name=pattern size=12>
    \n<input value='Search Work History' type=submit size=12>
    \n</td><td>
    \n<input value=1 type=checkbox name=matchCase " . ( $matchCase ? "checked":"") . ">Match case<br>
    \n<input value=1 type=checkbox name=matchWord " . ( $matchWord ? "checked":"") . ">Match whole word<br>";
  }
  print "$tableEnd</td> </tr> </table>";
}

sub PrintSearchTargets
{
  print "<table border=$__borderSize cellpadding=$__cellpadding cellspacing=$__cellspacing width=100%><tr><td>Objective:</td><td><b>Software position where I can use my strong software development skills.</b></td></tr><tr><td>Languages:</td><td>",
  SearchTarget(0, 1, "Java"),
  SearchTarget(0, 1, "Perl"),
  SearchTarget(0, 1, "UML"),
  SearchTarget(0, 1, "XML"),
  SearchTarget(0, 0, "C++"),
  SearchTarget(0, 0, "C#"),
  SearchTarget(0, 1, "SQL"),
  SearchTarget(0, 1, "PL/SQL"),
  SearchTarget(0, 1, "LISP"),
  SearchTarget(0, 1, "yacc"),
  SearchTarget(0, 1, "JavaScript"),
  SearchTarget(0, 1, "Bourne Shell"),
  "\n</td> </tr> <tr> <td> Software: </td> <td>",
  SearchTarget(0, 1, "J2EE"),
  SearchTarget(0, 1, "JDBC"),
  SearchTarget(0, 1, "ODBC"),
  SearchTarget(0, 1, "coverage"),
  SearchTarget(0, 1, "Network"),
  SearchTarget(0, 1, "VMware"),
  SearchTarget(0, 1, "Lab Manager"),
  SearchTarget(0, 1, "ant"),
  SearchTarget(0, 1, "Apache"),
  SearchTarget(0, 1, "Tomcat"),
  SearchTarget(0, 1, "IIS"),
  SearchTarget(0, 1, "JUnit"),
  SearchTarget(0, 1, "AJAX"),
  "\n</td> </tr> <tr> <td> Databases: </td> <td>",
  SearchTarget(0, 1, "Oracle"),
  SearchTarget(0, 1, "MS SQL Server"),
  SearchTarget(0, 1, "Sybase"),
  SearchTarget(0, 1, "MySQL"),
  SearchTarget(0, 1, "MS Access"),
  "\n</td> </tr> <tr> <td> OS: </td> <td>",
  SearchTarget(0, 1, "Unix"),
  SearchTarget(0, 1, "Windows"),

  "$tableEnd";
}

sub OnNewEmployer
{
  my($newEmployer) = @_;
  #print "resume::OnNewEmployer($newEmployer)\n";
  die "out of order project: $newEmployer already seen somewhere else" if defined $__employersAlreadySeen{$newEmployer};
  $__employersAlreadySeen{$newEmployer} = 1;
}


sub BuildResume
{
  my($originalPattern, $showAll, $matchCase, $matchWord) = @_;

  my $pattern = CleanPattern($originalPattern, $matchWord);
  #print "$originalPattern becomes $pattern\n";
  PrintHeader($originalPattern, $pattern, $showAll, $matchCase, $matchWord);
  PrintSearchTargets();

  my $lastEmployer = "";
  my $lastEmployerPrinted = "";
  my $nullResult = 1;
  my $employerHeader = "";
  my $currentEmployerMatchesPattern = 0;

  my $emphasize = "<b><font color=red>";
  my $relax = "</font></b>";

  foreach my $projectVector (@projects)
  {
    my($employer, $significant, $project) = @$projectVector;

    if ($employer ne $lastEmployer)
    {
      $employerHeader = $__employers{$employer};
      next if (!defined $employerHeader);

      OnNewEmployer($employer);

      if ($pattern)
      {
        if ($matchCase)
        {
          $currentEmployerMatchesPattern = ($employerHeader =~ s{$pattern}{$1$emphasize$2$relax}gm);
        }
        else
        {
          $currentEmployerMatchesPattern = ($employerHeader =~ s{$pattern}{$1$emphasize$2$relax}gim);
        }
      }
    }

    print STDERR "pattern=$pattern; project=$project, significant=$significant, resumeVersion=$__resumeVersion\n\n" if $__trace;
    my $printIt;
    if ($currentEmployerMatchesPattern)
    {
      $printIt = 1;
    }
    elsif (!$pattern)
    {
      if ($significant eq "1")
      {
        $printIt = 1;
      }
      elsif ($showAll and ($employer ne "personal") and ($significant !~ /^only_/))
      {
        $printIt = 1;
      }
      elsif ($significant =~ /^only_$__resumeVersion/)
      {
        $printIt = 1;
      }
    }
    else
    {
      my $strippedProject = StripHtmlTags($project);
      #
      # throw in the new line so that the second substitution in the body of the "if"
      # will have a chance to match (the pattern will normally have a prefix preventing
      # a match if there are <> around, as there will be from the font change).  Only by
      # adding a new line can we avoid the <> and match a second instance of the pattern
      # on the same line.  Of course, subsequent instances of the pattern will be ignored.
      #
      #print STDERR "trying: matchCase=$matchCase\npattern=$pattern\nproject=$strippedProject\nemphasize=$emphasize\nrelax=$relax\n";
      
      if (($matchCase and ($pattern and $strippedProject =~ s{$pattern}{$1$emphasize$2$relax\n}gm))
      or (!$matchCase and ($pattern and $strippedProject =~ s{$pattern}{$1$emphasize$2$relax\n}gim)))
      {
	$project =~ s{$pattern}{$1$emphasize$2$relax}gim;
	$printIt = 1;
      }
    }

    if ($printIt)
    {
      if ($employer ne $lastEmployerPrinted)
      {
	if ($lastEmployerPrinted)
	{
	  print $tableEnd;
	  print $tableEnd;
	}
	$lastEmployerPrinted = $employer;
	print $fullTableBegin;
	print $employerHeader;
	print $tableBegin;
      }
      else
      {
	print $cellBegin;
      }
      $nullResult = 0;
      print $project;
      print $cellEnd;
    }
    
    $lastEmployer = $employer;
  } # foreach project
  if ($nullResult)
  {
    print $fullTableBegin;
    print "Did not see '$originalPattern' in my history.";
  }
  else
  {
    print $tableEnd;
  }
  print $tableEnd;
  print $footer;
}

my $pattern = adyn_cgi_util::param($query, 'pattern');
$pattern = "" unless defined $pattern;

$__mailable      = adyn_cgi_util::param($query, 'mailable');
$__mailable = 0 unless defined $__mailable;

$__resumeVersion = adyn_cgi_util::param($query, 'resumeVersion');
$__resumeVersion = "default";

my $showAll = adyn_cgi_util::param($query, 'showAll');
$showAll = 0 unless defined $showAll;

$__minimalJavaScript = adyn_cgi_util::param($query, 'minimalJavaScript');
$__minimalJavaScript = 0 unless defined $__minimalJavaScript;


my $matchCase = adyn_cgi_util::param($query, 'matchCase');
$matchCase = 0 unless defined $matchCase;

my $matchWord = adyn_cgi_util::param($query, 'matchWord');
$matchWord = 0 unless defined $matchWord;

if ($pattern eq "C")
{
  $matchWord = 1;
}

$matchWord = 0 unless defined $matchWord;

BuildResume($pattern, $showAll, $matchCase, $matchWord);

# xtest with: cd $HOME/work/adyn.com/cgi-bin/; (echo showAll=0; echo pattern=picture;)|perl -w resume.cgi
# test with: cd $HOME/work/adyn.com/cgi-bin/; (echo showAll=0; echo pattern=C++;)|perl -w resume.cgi > c:/k.html; browser c:/k.html
