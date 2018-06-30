=head1 NAME
TextTable.pm - 
=head1 SYNOPSIS
     use TextTable;
     #uses 1 base indexing
     #TODO
     
=head1 DEPENDENCIES
Carp
TextFormatter
=head1 AUTHOR
Matt Bundy 
=cut

package TextTable;

use Carp;
use warnings;
use strict;
use POSIX;
use Data::Dumper;

use lib "$ENV{GENESIS_DIR}/sys/scripts/matt";
#inherite TextFormatter
use base "TextFormatter";

sub new {
#constructor
#required parameters rows=>#rows, cols=>#columns width => int
     my $class = shift;
     my $self = {@_};
     bless $self, $class;
     $self->{width} = 80 unless defined $self->{'width'};
     $self->{title} = '' unless defined $self->{'title'};
     #colWidth needs to be an integer otherwise stuff gets screwy
     $self->{'_colWidth'} = floor($self->{'width'} / $self->{'cols'});
     #initialize the table with empty strings
     for (my $i = 1; $i <= $self->{'cols'}; $i++){
          $self->{'_headers'}{$i}{'text'} = '';
          $self->{'_headers'}{$i}{'align'} = 'center';
          for (my $j = 1; $j <= $self->{'rows'}; $j++){
               $self->{'_cellData'}{$i}{$j}{'text'} = '';
               $self->{'_cellData'}{$i}{$j}{'align'} = 'left';
          }
     }


     return $self;
}

sub setWidth{
     my $self = shift;
     $self->{'width'} = @_ ? shift : 80;
     $self->{'_colWidth'} = floor($self->{'width'} / $self->{'cols'});
     return $self->{'width'}
}

sub getWidth {
     my $self = shift;
     return $self->{'width'};
}

sub setTitle {
     my $self = shift;
     $self->{'title'} = @_ ? $self->formatText(text => shift, width => $self->{'width'}) : '';
     return $self->{'title'};
}

sub getTitle {
     my $self = shift;
     return $self->{'title'};
}

sub setHeader {
#sets the header for the given column
#required parameters
#col | text | align
     my $self = shift;
     my %params = @_;
     $self->{'_headers'}{$params{'col'}}{'align'} = defined $params{'align'} ? $params{'align'} : 'center';
     $self->{'_headers'}{$params{'col'}}{'text'} = defined $params{'text'} ? $params{'text'} : '';
}

sub setCell {
#required parameters
#text | row | col | align 
     my $self = shift;
     my %params = @_;

     my $align = defined $params{'align'} ? $params{'align'} : 'left';
     $self->{'_cellData'}{$params{'col'}}{$params{'row'}}{'text'} = $params{'text'};
     $self->{'_cellData'}{$params{'col'}}{$params{'row'}}{'align'} = $align;
     return $self->{'_cellData'}{$params{'col'}}{$params{'row'}};
}

sub getCellText {
#returns the data in the specified cell
#required parameters
#row | col
     my $self = shift;
     my %params = @_;
     return $self->{'_cellData'}{$params{'col'}}{$params{'row'}}{'text'};
}

sub getCellFormat {
#returns the format type of the cell
#required parameters
#row | col
     my $self = shift;
     my %params = @_;
     return $self->{'_cellData'}{$params{'col'}}{$params{'row'}}{'align'};
}

sub getTable {
#returns the table as a scalar
     my $self = shift;
     my $table = '';
     my @data;
     my @headers;
     #prep the headers for flattening;
     for (my $row = 1; $row <= 1; $row++){
          my @cols;
          for(my $col = 1; $col <= $self->{'cols'}; $col++){
               my @cell = split(/\n/,$self->SUPER::formatText(text => $self->{'_headers'}{$col}{'text'},
                                                              width => $self->{'_colWidth'},
                                                              align => $self->{'_headers'}{$col}{'align'}));

               push (@cols,[@cell]);
          }
          push(@headers,[@cols]);
     }
     #prep the rest of the table for flattening
     for (my $row = 1; $row <= $self->{'rows'}; $row++){
          my @cols;
          for(my $col = 1; $col <= $self->{'cols'}; $col++){
               my @cell = split(/\n/,$self->SUPER::formatText(text => $self->getCellText(row => $row, col => $col),
                                                              width => $self->{'_colWidth'},
                                                              align => $self->getCellFormat(row => $row, col => $col)));

               push (@cols,[@cell]);
          }
          push(@data,[@cols]);
     }
     $table .= $self->_flatten(@headers);
     $table .= $self->_flatten(@data);
     return $table;
}

sub _normalize{
#iterates through each row and finds the column with the max number of lines,
#and fills the rest of the collumns with empty lines '\s' to normalize with the rest
#of them
     my $self = shift;
     #iterate through the rows
     for (my $row = 1; $row <= $self->{'rows'}; $row++){
          for(my $col = 1; $col <= $self->{'cols'}; $col++){
               my @array = split (/\n/, $self->SUPER::formatText(text => $self->getCellText(row => $row, col => $col),
                                                                 width => $self->{'_colWidth'},
                                                                 align => $self->getCellFormat(row => $row, col => $col)));
               my $length = length($array[-1]);
               my $dif = $self->{'_colWidth'} - $length;
               my $fill = ' ' x $dif;

               $self->{'_cellData'}{$col}{$row}{'text'} .= $fill;
          }
     }
}


sub _flatten {
#flattens the array into a scalar
     my $self = shift;
     my @data = @_;
     my $table = '';
     foreach my $row (@data){
          my $num = 0;
          foreach (@{$row}){
               $num = scalar(@{$_}) if (scalar(@{$_}) > $num);
          }
          for (my $i = 0; $i < $num; $i++){
               foreach my $col (@{$row}){
                    my $text;
                    if (defined $col->[$i]){
                         $text = $col->[$i];
                         $text =~ s/\n+$//g;
                    }else{
                         $text = ' 'x$self->{'_colWidth'};
                    }
                    $table .= $text .' ';
               }
               $table .= "\n";
          }
          $table .= "\n";
     }
     return $table;
}


1;
