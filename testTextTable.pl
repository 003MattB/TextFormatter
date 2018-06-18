#!/usr/bin/perl

use warnings;
use strict;
use lib "$ENV{GENESIS_DIR}/sys/scripts/matt";
use TextTable;

my $table = TextTable->new(rows => 4, cols => 4, width => 80, align => 'right');

$table->setTitle("This is a test table");
for (my $i = 1; $i < 5; $i ++){
     for (my $j = 1; $j < 5; $j ++){
          $table->setCell(row => $i, col => $j, text =>"< some text here row: $i col: $j >");
     }
}

my $text = $table->getTable();

print ($text);




