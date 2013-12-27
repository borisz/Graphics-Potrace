package inc::PotraceMakeMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_args => sub {
   return {
      %{super()},
      INC => '-I/opt/local/include',
      LIBS => ['-L/opt/local/lib -lpotrace'],
   };
};

override _build_MakeFile_PL_template => sub {
    my $template = <<'TEMPLATE';
# This Makefile.PL for {{ $distname }} was generated by Dist::Zilla.
# Don't edit it but the dist.ini used to construct it.
{{ $perl_prereq ? qq[BEGIN { require $perl_prereq; }] : ''; }}
use strict;
use warnings;
use ExtUtils::MakeMaker {{ $eumm_version }};
{{ $share_dir_block[0] }}

if (open my $olderr, '>&', \*STDERR) {
   close STDERR;
   my $exists = open my $fh, '|-', 'potrace';
   close $fh;
   open STDERR, '>&', $olderr;
   if (! $exists) {
      warn "potrace not found, avoiding generating Makefile\n";
      exit 0;
   }
}

my {{ $WriteMakefileArgs }}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
{{ $share_dir_block[1] }}
TEMPLATE

  return $template;
};

__PACKAGE__->meta->make_immutable();

1;