#!/usr/bin/perl

use strict;
use warnings;
use JSON;
use LWP::Simple;
use URI;
use HTML::TreeBuilder::XPath;
use Text::Xslate;

my $style = HTML::Element->new('style');
$style->attr('type', 'text/css');
$style->push_content(<<STYLE);
h1, h2, h3, h4, h5, h6, p, ul, ol, dl, pre, blockquote, table
{margin-top:0.6em; text-indent:0em;}
.font_size
{font-size:x-large;}
STYLE

my $book = from_json(do { local $/; <STDIN>});

my $chapter_cnt = 1;

mkdir 'tmp' unless -d 'tmp';
mkdir 'out' unless -d 'out';

for my $chapter ( @{ $book->{chapters} } ) {
    my $section_cnt = 1;
    for my $section ( @{ $chapter->{sections} } ) {
        my $uri = URI->new($section->{uri});
        my $file = ($uri->path_segments)[-1];
        mirror($uri, "tmp/$file") unless -f "tmp/$file";

        my $tree = HTML::TreeBuilder::XPath->new;
        $tree->parse_file("tmp/$file");
        my $content = ($tree->findnodes($book->{content_xpath}))[0];
        my $exclude = ($content->findnodes($book->{exclude_xpath}))[0];
        $exclude->detach;

        my $body = HTML::Element->new('body');
        $body->push_content($style);

        if ( $section_cnt == 1 ) {
            my $chapter_title = HTML::Element->new('h1');
            $chapter_title->push_content($chapter->{title});
            $body->push_content($chapter_title);
        }

        $body->push_content($content);

        $file =~ s/\..+/.html/ unless $file =~ /\.html$/;

        open my $out, '>', "out/$file" or die $!;
        print $out $body->as_XML;
        close $out;

        $section->{href} = $file;
        $section_cnt++;
    }
    $chapter_cnt++;
}

my $tx = Text::Xslate->new( syntax => 'TTerse' );

open my $out, '>', 'out/index.html' or die $!;
print $out $tx->render('index.tx', $book);
close $out;

open $out, '>', 'out/toc.ncx' or die $!;
print $out $tx->render('ncx.tx', $book);
close $out;

my $book_title = $book->{title};
$book_title =~ s/\s/_/g;

open $out, '>', "out/${book_title}.opf" or die $!;
print $out $tx->render('opf.tx', $book);
close $out;

`kindlegen out/${book_title}.opf`;

exit;

