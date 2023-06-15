use strict;
use warnings;

use Test::Spec;
use Test::More;

use Helper;

describe 'Helper::fill_db' => sub {
	it 'fills message table' => sub {
		my $parser = mock();
		my $dbh    = mock();

		Parser->expects( 'new' )->returns( $parser );
		$parser->expects( 'get_payload' )->returns( {
			created => '2012-02-13 14:39:22',
            int_id  => '1RwtJa-0009RI-7W',
            str     => '1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 id=120213143628.DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru',
            id      => 120213143628,
		} );
		$parser->expects( 'is_recieving_message' )->returns( 1 );
		Helper->expects( '__is_id_exists' )->returns( undef );
		Helper->expects( 'dbh_rw' )->returns( $dbh );
		$dbh->expects( 'do' );

		Helper::fill_db( '2012-02-13 14:39:22 1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 id=120213143628.DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru' );

		ok 1;
	};

	it 'fills log table' => sub {
		my $parser = mock();
		my $dbh    = mock();

		Parser->expects( 'new' )->returns( $parser );
		$parser->expects( 'get_payload' )->returns( {
            created => '2012-02-13 14:57:25',
            int_id  => '1RwtZn-000Hp3-BF',
            str     => '1RwtZn-000Hp3-BF => kumqpqobomitzdu@gmail.com R=dnslookup T=remote_smtp H=gmail-smtp-in.l.google.com [209.85.137.27] X=TLSv1:RC4-SHA:128 C="250 2.0.0 OK 1329130645 b5si5289243lbn.22"',
            address => 'kumqpqobomitzdu@gmail.com',
		} );
		$parser->expects( 'is_recieving_message' )->returns( undef );
		Helper->expects( 'dbh_rw' )->returns( $dbh );
		$dbh->expects( 'do' );

		Helper::fill_db( '2012-02-13 14:57:25 1RwtZn-000Hp3-BF => kumqpqobomitzdu@gmail.com R=dnslookup T=remote_smtp H=gmail-smtp-in.l.google.com [209.85.137.27] X=TLSv1:RC4-SHA:128 C="250 2.0.0 OK 1329130645 b5si5289243lbn.22"' );

		ok 1;
	};

	it 'skip duplicate id' => sub {
		my $parser = mock();
		my $dbh    = mock();

		Parser->expects( 'new' )->returns( $parser );
		$parser->expects( 'get_payload' )->returns( {
			created => '2012-02-13 14:39:22',
            int_id  => '1RwtJa-0009RI-7W',
            str     => '1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 id=120213143628.DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru',
            id      => 120213143628,
		} );
		$parser->expects( 'is_recieving_message' )->returns( 1 );
		Helper->expects( '__is_id_exists' )->returns( 1 );

		Helper::fill_db( '2012-02-13 14:39:22 1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 id=120213143628.DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru' );

		ok 1;
	};

	it 'skip if id doesnt exist' => sub {
		my $parser = mock();
		my $dbh    = mock();

		Parser->expects( 'new' )->returns( $parser );
		$parser->expects( 'get_payload' )->returns( {
			created => '2012-02-13 14:39:22',
            int_id  => '1RwtJa-0009RI-7W',
            str     => '1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru',
		} );
		$parser->expects( 'is_recieving_message' )->returns( 1 );

		Helper::fill_db( '2012-02-13 14:39:22 1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru' );

		ok 1;
	};
};

describe 'Helper::__is_id_exists' => sub {
	it 'returns TRUE' => sub {
		my $dbh = mock();

		Helper->expects( 'dbh_ro' )->returns( $dbh );
		$dbh->expects( 'selectcol_arrayref' )->returns( [ 1 ] );

		ok Helper::__is_id_exists( 1 );
	};

	it 'returns FALSE' => sub {
		my $dbh = mock();

		Helper->expects( 'dbh_ro' )->returns( $dbh );
		$dbh->expects( 'selectcol_arrayref' )->returns( [ 0 ] );

		ok !Helper::__is_id_exists( 1 );
	};
};

runtests;
