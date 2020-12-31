my $__enabled = 0;

package ndb_sql;
use strict;
use diagnostics;
use ndb_sql_load;

use vars '@ISA';
require ndb;
@ISA = qw(ndb);

# To transparently support the storage of some ndb stuff in an SQL
# database, I put into place this module.  Each time GetA() is called, the
# fileKey is compared against the regular expression
# $__regexpForFileKeysMappedToTheDatabase.  If there is a match, then this
# means that the data really lived in the SQL database, and that this module
# is responsible for fetching those data.  If there is not a match, then we
# simply call SUPER::GetA().

my $__databaseName;
my $__regexpForFileKeysMappedToTheDatabase;
my $__regexpForFileKeysMappedToTheDatabase_saved;
my $__dbh = undef;
my $__sth = undef;

sub PropagatePerlToSql_table
{
  my($self, $fileKey) = @_;
  my $len = $self->GetUnderlyingArraySize($fileKey);
  for (my $j = 0; $j < $len; $j++)
  {
    my $kRef = $self->KeysA($fileKey, $j);
    foreach my $key (@$kRef)
    {
      my $val = $self->GetA($fileKey, $j, $key);
      ndb_sql_load::Add("all", "$fileKey.$j", $key, $val);
    }
  }
}

sub PropagatePerlToSql_init
{
  my($self, $workDir, $refresh) = @_;
  mkdir($workDir) unless -d $workDir;

  $__regexpForFileKeysMappedToTheDatabase_saved = $__regexpForFileKeysMappedToTheDatabase;
  $__regexpForFileKeysMappedToTheDatabase = "disable__db_access_by ndb_sql::PropagatePerlToSql_init";

  $refresh = 0 if !defined $refresh;

  #if ($refresh)
  #{
  #nutil::Warn("ndb_sql::PropagatePerlToSql_init($workDir, $refresh): initializing $workDir\n");
  #system("rm -rf $workDir");
  #system("mkdir -p $workDir");
  #}


  print "ndb_sql::PropagatePerlToSql_init($workDir, $refresh)\n";
  ndb_sql_load::Init($workDir, $__databaseName, $refresh);
}

sub PropagatePerlToSql_finish
{
  my($self, $workDir) = @_;
  ndb_sql_load::Cleanup();

  $__regexpForFileKeysMappedToTheDatabase = $__regexpForFileKeysMappedToTheDatabase_saved;
}

sub Cleanup
{
  my($self) = @_;
  if (defined $__sth)
  {
    $__sth->finish();
    $__dbh->disconnect();

    $__sth = undef;
    $__dbh = undef;
  }
}


sub GetA
{
  my($self, $fileKey, $x, $key) = @_;
  if (!$__enabled || $fileKey !~ $__regexpForFileKeysMappedToTheDatabase)
  {
    return $self->SUPER::GetA($fileKey, $x, $key);
  }
  return $self->GetA_sql($fileKey, $x, $key);
}

sub GetA_sql
{
  my($self, $fileKey, $x, $key) = @_;

  if (!defined $__sth)
  {
    my %attr;
    require DBI;
    $__dbh = DBI->connect("DBI:mysql:$__databaseName", undef, undef, \%attr);
    if (!defined $__dbh)
    {
      die "dbh bad\n";
    }
    #  $sql = "SELECT s from $__databaseName.all where id = '$fileKey.$x' and category = '$key'";
    my $sql = "SELECT s from $__databaseName.all where id = ? and category = ?";
    $__sth = $__dbh->prepare($sql);
  }
  $__sth->execute("$fileKey.$x", $key);
  my @row = $__sth->fetchrow_array();
  return $row[0];
}


sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {};
  bless $self, $class;
  my $dataDir = shift;
  $self->Init($dataDir);
  $__databaseName = shift;
  $__regexpForFileKeysMappedToTheDatabase = shift;
  die "not enough arguments" unless defined $__regexpForFileKeysMappedToTheDatabase;
  return $self;
}

#my $ndbSql = new ndb_sql("../httpdocs/teacher/data");
#$ndbSql->PropagatePerlToSql_init("/tmp/sql");
#$ndbSql->PropagatePerlToSql_table("out_verb_have");
#$ndbSql->PropagatePerlToSql_finish();

1;
