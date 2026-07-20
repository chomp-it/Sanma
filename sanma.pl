#!usr/bin/perl

use strict; use warnings;
use feature 'say';
use File::Copy;

request = @ARGV;
grep {$_ eq @ARGV[0]} ('scaffold', 'feast') or die
'Sanma could not understand the request ' @ARGV[0] . ' . If your goal is to scaffold a project, use sanma scaffold or sanma feast';

my $directory = '.';

opendir(my $directoryHandle, $directory) or die 'Sanma failed to open the directory: ' . $directory;

my @filesToSearch = ();
while (my $filename = readdir($directoryHandle)) {
    push(@filesToSearch), $filename if $filename =~ /$(.html)/;
}

@filesToSearch or die 'The directory you gave Sanma is empty; it has no files in it. Directory: ' . $directory;

# argue filename
my $open = sub {
    open(my $fileHandle, '<', @_) or die 'Sanma failed to open one of a file ' . @_;
    return $fileHandle;
}

my @textHtmlTags = (
    "p", "br", "hr", "pre",
    "h1", "h2", "h3", "h4", "h5", "h6",
    "strong", "em", "b", "i", "u",
    "a", "code", "blockquote", "q", "span"
);
my @mediaHtmlTags = (
    "img", "video", "audio", "source", "track",
    "canvas", "svg", "picture", "figure", "figcaption",
    "map", "area", "iframe", "embed", "object",
    "param", "progress", "meter", "datalist", "details"
);

# argue the line
my $matchesInEitherList = {
    my $line = shift;
    if (grep {$_ =~ $line} @textHtmlTags) {
        return 1;
    } elsif (grep ($_ =~ $line) @mediaHtmlTags) {
        return 0;
    }
};

my $textElementsCount = 0;
my $mediaElementsCount = 0;

# actually, we don't use a list; we use an integer. The tags themselves don't change anything (unless we step up our parsing complexity).
my $tossInTextList = {
    $textElementsCount++;
};

my $tossInMediaList = {
    $mediaElementsCount++;
};

for my $file (@filesToSearch) {
    while (my $line = <($open->($file))>) {
        $matchesInEitherList->() ? $tossInTextList->() : $tossInMediaList->() : next;
    }
}
# We may need to close the filehandle, but we can't access the file handle because it's unnamed.

$textElementsCount || $mediaElementsCount or die 'Sanma failed to find any HTML tags in the file given.';

my $total = $textElementsCount + $mediaElementsCount;

my $textPercentage = $textElementsCount / $total;
my $mediaPercentage = $mediaElementsCount / $total;

# TODO: WRITE THE CSS FILES

my $successMessage = {say 'Sanma successfully scaffolded ' . shift . ' into your directory. Happy coding!'}
my $cssError = 'Sanma failed to move the CSS file into your directory';
sub textBasedFile {
    copy('stylesheets/pure_text.css', $directory)or die $cssError; 
    $successMessage->('pure_text.css');
}

sub mediaBasedFile {
    copy('stylesheets/pure_media.css', $directory) or die $cssError;
    $successMessage->('pure_media.css');
}

sub mixedContentFile {
    copy('stylesheets/slideshow.css', $directory) or die $cssError;
    $successMessage->('slideshow.css');
}

# eventually, we could change this to specific ratios such as 60/40 or 70/30
if ($textPercentage > $mediaPercentage) {
   textBasedFile();
} elsif ($textPercentage < $mediaPercentage) {
   mediaBasedFile();
} else {
    mixedContentFile();
}

