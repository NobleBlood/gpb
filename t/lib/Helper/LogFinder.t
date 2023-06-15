use strict;
use warnings;

use Test::Spec;
use Test::More;

use Helper::LogFinder;

describe 'Helper::LogFinder' => sub {
    my $dbh;

    before each => sub {
        $dbh = mock();

        Helper::LogFinder->stubs( dbh_ro => $dbh );
    };

    it 'invalid address' => sub {
        my $finder = Helper::LogFinder->new( 'blabla' );

        ok !$finder->is_valid_address();
        is $finder->get_error(), 'address is invalid!';
        is_deeply $finder->get_payload(), [];
    };

    it 'empty address' => sub {
        my $finder = Helper::LogFinder->new( undef );

        ok !$finder->is_valid_address();
        is $finder->get_error(), 'address is invalid!';
        is_deeply $finder->get_payload(), [];
    };

    it 'valid address, no overlimit' => sub {
        $dbh->expects( 'selectall_arrayref' )->returns( [
            { created => '2020-01-01 00:00', str => 'some_str1' },
            { created => '2020-01-01 00:00', str => 'some_str2' },
            { created => '2020-01-01 00:00', str => 'some_str3' },
        ] );

        my $finder = Helper::LogFinder->new( 'abc@abc.ru' );

        ok $finder->is_valid_address();
        ok !$finder->is_overlimit();
        is_deeply $finder->get_payload(), [
            { created => '2020-01-01 00:00', str => 'some_str1' },
            { created => '2020-01-01 00:00', str => 'some_str2' },
            { created => '2020-01-01 00:00', str => 'some_str3' },
        ];
    };

    it 'valid address, overlimit' => sub {
        # увы, константы в тестах не переопределить, так что приходится делать вот так криво
        $dbh->expects( 'selectall_arrayref' )->returns( [ 1..101 ] );

        my $finder = Helper::LogFinder->new( 'abc@abc.ru' );

        ok $finder->is_valid_address();
        ok $finder->is_overlimit();
        is_deeply $finder->get_payload(), [ 1..100 ];
    }
};

runtests;
