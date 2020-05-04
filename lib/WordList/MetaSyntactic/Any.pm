package WordList::MetaSyntactic::Any;

# AUTHORITY
# DATE
# DIST
# VERSION

use parent qw(WordList);

use Role::Tiny::With;
with 'WordListRole::FirstNextResetFromEach';

our $DYNAMIC = 1;

our %PARAMS = (
    theme => {
        summary => 'Acme::MetaSyntactic theme name, e.g. "dangdut" '.
            'for Acme::MetaSyntactic::dangdut',
        schema => 'perl::modname*',
        req => 1,
        completion => sub {
            my %args = @_;
            require Complete::Module;
            Complete::Module::complete_module(
                word => $args{word},
                ns_prefix => 'Acme::MetaSyntactic',
            );
        },
    },
);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    my $mod = "Acme::MetaSyntactic::$self->[2]{theme}";
    (my $mod_pm = "$mod.pm") =~ s!::!/!g;
    require $mod_pm;

    my @names = @{"$mod\::List"};
    unless (@names) {
        @names = map { @{ ${"$mod\::MultiList"}{$_} } }
            sort keys %{"$mod\::MultiList"};
    }
    $self->[1] = \@names;
    $self;
}

sub each_word {
    my ($self, $code) = @_;

    for (@{ $self->[1] }) {
        no warnings 'numeric';
        my $ret = $code->($_);
        return if defined $ret && $ret == -2;
    }
}

1;
# ABSTRACT: Wordlist from any Acme::MetaSyntactic::* module

=head1 SYNOPSIS

 use WordList::MetaSyntactic::Any;

 my $wl = WordList::MetaSyntactic::Any->new(theme => 'dangdut');
 $wl->each_word(sub { ... });


=head1 DESCRIPTION

This is a dynamic, parameterized wordlist to get list of words from an
Acme::MetaSyntactic::* module.


=head1 SEE ALSO

L<WordList>

L<Acme::MetaSyntactic>

Some C<Acme::MetaSyntactic::*> modules get their names from wordlist, e.g.
L<Acme::MetaSyntactic::countries>.
