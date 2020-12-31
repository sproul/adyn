package o_token;

use strict;
use diagnostics;

sub GetNotes
{
  my($self) = @_;
  my $noteArrayRef = $self->{"noteArray"};
  my $s;
  if (!$self->HasNotes())
  {
    $s = undef;
  }
  else
  {
    $s = "";
    foreach my $note (@$noteArrayRef)
    {
      $s .= $self->{"noteDivider"} if $s;
      $s .= $note;
    }
  }
  return $s;
}

sub ToString
{
  my($self) = @_;
  my $noteArrayRef = $self->{"noteArray"};
  my $s = "o_token("
  . $self->{"g"}->GetLang()
  . ": "
  . $self->GetToken();
  if ($self->HasNotes())
  {
    $s .= ": " . $self->GetNotes();
    foreach my $note (@$noteArrayRef)
    {
      $s .= $self->{"noteDivider"} if $s;
      $s .= $note;
    }
  }
  $s .= ")\n";
  return $s;
}

sub SaveAnyNotes
{
  my($self, $id) = @_;
  my $notes = $self->GetNotes();
  if (defined $notes)
  {
    #my $noteKey = $self->{"g"}->MakeTokenNoteKey($self->{"token"}, "tmp");
    #
    #my $old = tdb::Get($id, $noteKey);
    #if (defined $old)
    #{
    #if ($old eq $notes)
    #{
    #warn "$id: cleaning";
    #tdb::Set($id, $noteKey, undef);
    #}
    #else
    #{
    #warn "$id: " . $self->{"g"}->GetLang() . ": o_token.SaveAnyNotes overwriting $old\nwith\n$notes";
    #}
    #}
        
    $self->{"g"}->SetNote($id, $self->GetToken(), $notes);
  } 
}

sub AddNote
{
  my($self, $note, $insertAtBeginningOfNotes) = @_;
  $insertAtBeginningOfNotes = 0 unless defined $insertAtBeginningOfNotes;
  my $noteArrayRef = $self->{"noteArray"};
  if (!defined $noteArrayRef)
  {
    my @tmp = ();
    $noteArrayRef = \@tmp;
  }
      
  if ($insertAtBeginningOfNotes)
  {
    unshift @$noteArrayRef, $self->{"g"}->ResolveNote($note);
  }
  else
  {
    push    @$noteArrayRef, $self->{"g"}->ResolveNote($note);
  }
  
  
  $self->{"noteArray"} = $noteArrayRef;
  #print "o_token::Add($note): " . $self->ToString() . "\n";
}

sub InsertNote
{
  my($self, $note) = @_;
  $self->AddNote($note, 1);
}

sub GetToken
{
  my($self) = @_;
  return $self->{"token"};
}

sub SetToken
{
  my($self, $token) = @_;
  $self->{"token"} = $token;
  $self->{"hasChanged"} = 1;
}

sub HasChanged
{
  my($self) = @_;
  return $self->{"hasChanged"};
}


sub HasNotes
{
  my($self) = @_;
  my $noteArrayRef = $self->{"noteArray"};
  return defined $noteArrayRef;
} 

sub new
{
  my $this = shift;
  my $class = ref($this) || $this;
  my $self = {}; 
  bless $self, $class;
  $self->{"g"} = shift;
  $self->{"token"} = shift;
    
  die unless defined $self->{"token"};
    
  $self->{"noteDivider"} = "<br>&nbsp;&nbsp;";
  return $self;
}

1;
