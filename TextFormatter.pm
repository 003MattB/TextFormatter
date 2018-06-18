=head1 NAME

TextFormatter.pm 

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

I<new()>

Returns a new TextFormatter object.

=item C<wrapLine>

I<< wrapLine(text => 'some text', width => integer) >>

Takes two parameters B<'some text'> and B<width>.
Wraps a string of text by words to a max length of width.
Returns the wrapped string.

=item C<formatText>

I<< formatText(text => 'some text', width => integer, align => 'left'|'right'|'center' newline => 0|1) >>

Takes 4 parameters B<text> , B<width>, B<align>, and B<newline>.
Returns text wrapped by words aligned by the parameter.
B<align> and B<newline> may be omitted, if so align will default to 'center' and newline will default to 0.
If newline = 1 then a newline character will be apended to the end of the string.

=back

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
