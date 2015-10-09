#!/usr/bin/perl

use strict;
use YAML::Syck; 
use XML::Writer;
use Data::Dumper;

$YAML::Syck::ImplicitTyping = 1;

my $pattern = '.*';
my @layouts;
my $layouts_file = $ENV{'HOME'} . '/Library/Application Support/LaunchBar/Actions Support/layouts.yaml';

if ( -e $layouts_file ) {
	@layouts = @{LoadFile($layouts_file)}
} else {
	@layouts = @{LoadFile('../Resources/default_layouts.yaml')};
}

if ( scalar(@ARGV) > 0 ) {
	$pattern = quotemeta(@ARGV[0]);
}

my @filtered;
my $screenOffset = '';

if ( scalar(@ARGV) > 1 ) {
  @filtered = grep { $_->{'name'} =~ /$pattern/ && $_->{'forOtherScreen'} } @layouts;  
  $screenOffset = ':' . @ARGV[1];
} else {
  @filtered = grep { $_->{'name'} =~ /$pattern/ } @layouts;
}

my $writer = XML::Writer->new();

$writer->startTag('items');
foreach my $layout (@filtered) {
	$writer->startTag('item', "valid" => "yes", "arg" => $layout->{'command'} . $screenOffset, "uid" => $layout->{'name'});
	$writer->startTag('title');
	$writer->characters($layout->{'display'});
	$writer->endTag('title');
	$writer->startTag('icon');
	$writer->characters(sprintf('icon_%s.png',$layout->{'name'}));
	$writer->endTag('icon');
	$writer->startTag('action');
	$writer->characters('layout.pl');
	$writer->endTag('action');
	$writer->startTag('actionArgument');
	$writer->characters($layout->{'command'});
	$writer->endTag('actionArgument');
	$writer->endTag('item');
}
$writer->endTag('items');
$writer->end();
