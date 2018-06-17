=head1 NAME
TextFormatter.pm - 
=head1 SYNOPSIS
     use TextFormatter;
     my $formatter = TextFormatter->new();
     my $origText = "some long string of text";
     my $formattedText = $formatter->formatText(align => 'center', width => '10', text => $origText);
     print "$formattexText\n";
     #output:
     ##some long 
     ##string of 
     ##   text  
=head2 METHODS
=over 12
=item C<new>
returns a new TextFormatter object
=item C<wrapLine>
takes two parameters B<< text => 'some text' >> and B<< width => int >>
wraps a string of text by words to a max length of width
returns the wrapped string
=item C<formatText>
takes a 4 parameters B<< text => 'some text' >> , B<< width => int >>, B<< align => 'left'|'right'|'center' >>, and B<< newline => 1|0 >>
returns text wrapped by words aligned by the parameter
B<align> and B<newline> may be omitted, if so align will default to 'center' and newline will default to 0
if newline = 1 then a newline character will be apended to the end of the string
=head1 DEPENDENCIES
Carp
=head1 AUTHOR
Matt Bundy (mattb@protechmn.com)
=cut

package TextFormatter;

use Carp;
use warnings;
use strict;
use POSIX;


sub new {
#constructor
     my $class = shift;
     my $self = {@_};
     bless $self, $class;

     return $self;
}

sub wrapLine {
#returns a string with new lines after $width characters
#parameters:
#text => $text, width => int
     my $self = shift;
     my %params = @_;
     my $wrappedText = '';
     return '' if !defined $params{'text'};

     #make an array of words (ie split the text by spaces)
     my @origText = split (/ /,$params{'text'});
     my $lineLength = 0;
     #add the words with new line characters to the wrappedText - hopefully the first word isn't greater than $width
     foreach my $word (@origText){
          $word .= " ";
          $lineLength += length($word);
          if ($lineLength <= $params{'width'}){
               $wrappedText .= $word;
          }
          else{
               $wrappedText .= "\n$word";
               $lineLength = length($word);
          }
     }
     return "$wrappedText\n";
}

sub formatText {
#returns a string formated with the given parameters...
#align => center|left|right, text => $text, width => $width newline => 1|0
     my $self = shift;
     my %params = @_;
     my $align = defined $params{'align'} ? $params{'align'} : 'center';
     my $text = defined $params{'text'} ? $params{'text'} : '';
     my $hasNewLine = defined $params{'newline'} ? $params{'newline'} : 0; #default no new line

     $text = $self->wrapLine(text => $text, width => $params{'width'});
     my @text = split(/\n/, $text);
     
     my $finalText = '';
     for (my $i = 0; $i < @text; $i++){
          #trim the leading and trailing spaces
          $text[$i] =~ s/^\s+|\s+$//g;
          if ($align eq 'right'){
               my $format = "%". $params{'width'} ."s";
               $text[$i] = sprintf($format,$text[$i]);
          }
          elsif ($align eq 'left'){
               my $format = "%-". $params{'width'} ."s";
               $text[$i] = sprintf($format,$text[$i]);
          }
          elsif ($align eq 'center'){
               my $leftPadding = floor(abs((length($text[$i]) - $params{'width'})/2));
               my $rightPadding = ceil(abs((length($text[$i]) - $params{'width'})/2));
               $text[$i] = ' 'x $leftPadding . $text[$i] . ' 'x $rightPadding;
          }
          $finalText .= $text[$i] ."\n";
     }
     $finalText =~ s/\n$//g unless ($hasNewLine);
     return $finalText
}

1;
