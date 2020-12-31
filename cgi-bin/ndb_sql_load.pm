package ndb_sql_load;

use strict;
use diagnostics;

my %__tableNameToLoadFile = ();
my $__databaseName;
my $__refresh;
my $__workDirectory;

sub Init
{
  my($workDirectory, $databaseName, $refresh) = @_;
  $__workDirectory = $workDirectory;
  $__databaseName = $databaseName;
  $__refresh = $refresh;
}

sub GetFile
{
  my($tableName) = @_;
  my $f = $__tableNameToLoadFile{$tableName};
  if (!defined $f)
  {
    my $fn = "$__workDirectory/$tableName.dat";

    print "ndb_sql_load::GetFile($tableName) >> $fn\n";

    $f = $__tableNameToLoadFile{$tableName} = new IO::File(">> $fn");
    die "could not open $fn" unless defined $f;
  }
  return $f;
}

sub GetLoadFileFn
{
  my($tableName) = @_;
  return "$__workDirectory/$tableName.dat";
}


sub Cleanup
{
  return unless defined $__databaseName;
  
  my $sqlFn = "$__workDirectory/load.sql";
  my $sql = new IO::File("> $sqlFn");
  if (!defined $sql)
  {
    warn "ndb_sql_load.Cleanup: could not open $sqlFn";
    return;
  }

  if ($__refresh)
  {
    print $sql "drop database $__databaseName;\n";
    print $sql "create database $__databaseName;\n";
  }

  foreach my $tableName (keys %__tableNameToLoadFile)
  {
    my $f = $__tableNameToLoadFile{$tableName};
    $f->close();
    delete($__tableNameToLoadFile{$tableName});

    print $sql "drop table $__databaseName.$tableName;\n";
    print $sql "create table $__databaseName.$tableName(id varchar(32) not null, category varchar(32) not null, s text not null);\n";
    print $sql "LOAD DATA LOCAL INFILE \"" . GetLoadFileFn($tableName) . "\" INTO TABLE $__databaseName.$tableName;\n";
  }
  $sql->close();
  print "sh ex_isql < $sqlFn\n";
}

sub Add
{
  my($tableName, $id, $key, $value) = @_;
  if (defined $value)
  {
    my $f = GetFile($tableName);
    print $f "$id	$key	$value	\n";
  }
}

sub Add_insert_stmt
{
  my($table, @values) = @_;
  my $values = join(';;;', @values);
  $values =~ s/'/''/g;
  $values =~ s/;;;/','/g;
  $values =~ s/^/'/;
  $values =~ s/$/'	/;	# if the load line does not end with a tab, MySQL appends ^M.
  $values =~ s/([^'])'(\d+)'([^'])/$1$2$3/g;
  
  die "not impl anymore...";  #print $__f "insert into $table values($values);\n";
}


1;
