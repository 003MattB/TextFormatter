=head1 NAME

SimpleReport.pm

=head1 SYNOPSIS

     use SimpleReport;
     my $report = SimpleReport->new();
     #the default width is 80 characters, but I want it to be 100
     $report->{'width'} = 100;
     
     my $body = "a very long string";
     
     #if align is omitted the default is left so this is kind of redundant
     $report->appendBody( align => 'left', text => $body);
     
     my $moreText = "here is some more stuff for the body of the report";
     
     #lets change the alignment just for fun
     $report->appendBody( align => 'center', text => $moreText);
     
     #lets get some header and footers
     $report->setHeader(char => '=', text => 'Check out my awsome report');
     $report->setFooter(align => 'right', char => '*', text => 'This is the end of the report');
     
     #I also have a table module I'm working on lets add a table to the report
     #pretend like there is already a table object here
     #see TextTable for documentation
     
     $report->appendBody(text => $table->getTable());
     
     print $report->getReport();
     
     #this is what it should look like
     
                                          Check out my awsome report                                     
                                                                                                    
====================================================================================================
a very long string                                                                                  
                                                                                                    
                         here is some more stuff for the body of the report                         
                                                                                                    
  col 1      col 2      col 3      col 4    

           <1, 2>                <1, 4>     


<3, 1>     <3, 2>     <3, 3>                

<4, 1>                                      

****************************************************************************************************
                                                                       This is the end of the report

=head2 METHODS

=over 12

=item C<new>

I<new()>

Returns a new SimpleReport object.

=item C<setHeader>

I<< setHeader(align => 'right|left|center', char=> 'some character', text=> 'some text') >>

Sets and formats the header for the report. Adds a line break at the end using B<char>. 
If B<char> and B<align> are omitted their default values are '_' and 'center' respectively.
Returns the formatted header.

=item C<getHeader>

I<getHeader()>

Returns the formatted header.

=item C<appendBody>

I<< appendBody(align => 'right|left|center', text => 'some text') >>

Appends the body of the report with the formatted text. If B<align> is omitted the default is left.

=item C<getBody>

I<getBody()>

Returns the formatted body of the report.

=item C<setFooter>

I<< setFooter(align => 'right|left|center', char=> 'some character', text=> 'some text') >>

Sets and formats the footer for the report. Adds a line break at the top using B<char>. 
If B<char> and B<align> are omitted their default values are '_' and 'center' respectively.
Returns the formatted footer.

=item C<getFooter>

I<getFooter()>

Returns the formatted footer of the report.

=item C<setWidth>

I<setWidth(width)>

Sets the width of the report to B<width>.

=item C<getWidth>

I<getWidth()>

Returns the width of the report.

=item C<getReport>

I<getReport>

Returns the formatted report with header and footer as text.


=back

=head1 DEPENDENCIES

Carp
TextFormatter

=head1 SEE ALSO

B<TextFormatter> for inherited methods.

=head1 AUTHOR

Matt Bundy 

=cut

package SimpleReport;

use Carp;
use warnings;
use strict;
use POSIX;

use lib "$ENV{GENESIS_DIR}/sys/scripts/matt";
#inherite TextFormatter
use base "TextFormatter";

sub new {
#constructor
     my $class = shift;
     my $self = {@_};
     bless $self, $class;
     $self->{errors} = ();
     $self->{numTests} = 0;
     $self->{passed} = 0;
     $self->{failed} = 0;
     #$self->{stats} = ($self->{numTests},$self->{passed},$self->{fialed});
     $self->{header} = '';
     $self->{footer} = '';
     $self->{body} = '';
     $self->{width} = 80; #default page width in characters

     $self->{DEBUG} = 0;

     return $self;
}

sub setHeader {
#sets the header formated by align and adds a line under with width characters
#params align => right|left|center, char => '#' (any character), text => $text
     my $self = shift;
     my %params = @_;
     my $align = defined $params{'align'} ? $params{'align'} : 'center';
     my $char = defined $params{'char'} ? $params{'char'} : '_';
     my $text = defined $params{'text'} ? $params{'text'} : '';

     my $lineBreak = $char x $self->{'width'} ."\n";
     my $header = $self->formatText(align =>$align, text =>$text, newline => 1);
     
     $self->{'header'} = $header . $lineBreak;
     return $self->{'header'};
}

sub getHeader {
     my $self = shift;
     return $self->{'header'};
}

sub appendBody {
#appends the body text formatting by the given parameters:
#align => right|left|center, text => $text
     my $self = shift;
     my %params = @_;
     my $align = defined $params{'align'} ? $params{'align'} : 'left';
     my $text = defined $params{'text'} ? $params{'text'} : '';
     $self->{'body'} .= $self->formatText(text => $text, align => $align, newline => 1);
}

sub getBody{
     my $self = shift;
     return $self->{'body'};
}

sub setFooter {
#sets the footer formated by align and adds a line under with width characters
#params align => right|left|center, char => '#' (any character), text => $text
     my $self = shift;
     my %params = @_;
     my $align = defined $params{'align'} ? $params{'align'} : 'center';
     my $char = defined $params{'char'} ? $params{'char'} : '_';
     my $text = defined $params{'text'} ? $params{'text'} : '';

     my $lineBreak = $char x $self->{'width'} ."\n";
     my $footer = $self->formatText(align =>$align, text =>$text);
     
     $self->{'footer'} = $lineBreak . $footer;
     return $self->{'footer'};
}

sub getFooter {
     my $self = shift;
     return $self->{'footer'};
}

sub setWidth{
     my $self = shift;
     $self->{'width'} = @_ ? shift : 80;
     return $self->{'width'}
}

sub getWidth {
     my $self = shift;
     return $self->{'width'};
}

sub getReport {
#returns the entire report as a scalar string (header body footer)
     my $self = shift;
     return $self->{'header'} . $self->{'body'} . $self->{'footer'};
}

sub printStats {
#prints the stats in a formated manner
     my $self = shift;
     my $statistics = $self->formatStats();
     print "$statistics\n";
}
#TODO
sub formatStats {
#returns a string of the formated statistics
     my $self = shift;
}

sub formatText {
#returns a string formated with the given parameters
#overrides TextFormatter::formatText() ~ just uses instance variables
#align => center|left|right, text => $text, width => $width
     my $self = shift;
     my %params = @_;
     my $align = defined $params{'align'} ? $params{'align'} : 'center';
     my $text = defined $params{'text'} ? $params{'text'} : '';
     my $width = defined $params{'width'} ? $params{'width'} : $self->{'width'};

     $text = $self->wrapLine(text => $text, width => $width);
     my $finalText = $self->SUPER::formatText(text => $text, width => $width, align => $align, newline => 1);

     return $finalText
}


1;
