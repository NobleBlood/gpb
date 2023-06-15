use strict;
use warnings;

use Test::Spec;
use Test::More;

use Parser;

describe 'Parser' => sub {
    it 'resiving message' => sub {
        my $parser = Parser->new( '2012-02-13 14:39:22 1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 id=120213143628.DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru' );

        ok $parser->is_recieving_message();

        is_deeply
            $parser->get_payload(),
            {
                created => '2012-02-13 14:39:22',
                int_id  => '1RwtJa-0009RI-7W',
                str     => '1RwtJa-0009RI-7W <= tpxmuwr@somehost.ru H=mail.somehost.com [84.154.134.45] P=esmtp S=2229 id=120213143628.DOMAIN_FEEDBACK_MAIL.503141@whois.somehost.ru',
                id      => 120213143628,
            };
    };

    it 'post message' => sub {
        my $parser = Parser->new( '2012-02-13 14:57:25 1RwtZn-000Hp3-BF => kumqpqobomitzdu@gmail.com R=dnslookup T=remote_smtp H=gmail-smtp-in.l.google.com [209.85.137.27] X=TLSv1:RC4-SHA:128 C="250 2.0.0 OK 1329130645 b5si5289243lbn.22"' );

        ok !$parser->is_recieving_message();

        is_deeply
            $parser->get_payload(),
            {
                created => '2012-02-13 14:57:25',
                int_id  => '1RwtZn-000Hp3-BF',
                str     => '1RwtZn-000Hp3-BF => kumqpqobomitzdu@gmail.com R=dnslookup T=remote_smtp H=gmail-smtp-in.l.google.com [209.85.137.27] X=TLSv1:RC4-SHA:128 C="250 2.0.0 OK 1329130645 b5si5289243lbn.22"',
                address => 'kumqpqobomitzdu@gmail.com',
            };
    };

    it 'unable to post message' => sub {
        my $parser = Parser->new( '2012-02-13 14:59:20 1Rujzc-00025m-V0 ** fwxvparobkymnbyemevz@london.com: retry timeout exceeded' );

        ok !$parser->is_recieving_message();

        is_deeply
            $parser->get_payload(),
            {
                created => '2012-02-13 14:59:20',
                int_id  => '1Rujzc-00025m-V0',
                str     => '1Rujzc-00025m-V0 ** fwxvparobkymnbyemevz@london.com: retry timeout exceeded',
                address => 'fwxvparobkymnbyemevz@london.com',
            };
    };

    it 'additional address' => sub {
        my $parser = Parser->new( '2012-02-13 15:02:15 1Rwtd1-0000Ac-Cx -> yiimxwfx@nthost.ru R=dnslookup T=remote_smtp H=mail-tel.nthost.ru [194.63.140.35] C="250 ok 1329130935 qp 28670"' );

        ok !$parser->is_recieving_message();

        is_deeply
            $parser->get_payload(),
            {
                created => '2012-02-13 15:02:15',
                int_id  => '1Rwtd1-0000Ac-Cx',
                str     => '1Rwtd1-0000Ac-Cx -> yiimxwfx@nthost.ru R=dnslookup T=remote_smtp H=mail-tel.nthost.ru [194.63.140.35] C="250 ok 1329130935 qp 28670"',
                address => 'yiimxwfx@nthost.ru',
            };
    };

    it 'normal post' => sub {
        my $parser = Parser->new( '2012-02-13 15:08:25 1RwtlS-000Bg6-Ix => ms@list.ru R=dnslookup T=remote_smtp H=mxs.mail.ru [94.100.176.20] C="250 OK id=1Rwtlh-0004tA-2n"' );

        ok !$parser->is_recieving_message();

        is_deeply
            $parser->get_payload(),
            {
                created => '2012-02-13 15:08:25',
                int_id  => '1RwtlS-000Bg6-Ix',
                str     => '1RwtlS-000Bg6-Ix => ms@list.ru R=dnslookup T=remote_smtp H=mxs.mail.ru [94.100.176.20] C="250 OK id=1Rwtlh-0004tA-2n"',
                address => 'ms@list.ru',
            };
    };

    it 'normal post (blackhole)' => sub {
        my $parser = Parser->new( '2012-02-13 15:07:44 1Rwtl2-000KDi-Jd => :blackhole: <tpxmuwr@somehost.ru> R=blackhole_router' );

        ok !$parser->is_recieving_message();

        is_deeply
            $parser->get_payload(),
            {
                created => '2012-02-13 15:07:44',
                int_id  => '1Rwtl2-000KDi-Jd',
                str     => '1Rwtl2-000KDi-Jd => :blackhole: <tpxmuwr@somehost.ru> R=blackhole_router',
                address => 'tpxmuwr@somehost.ru',
            };
    };

    it 'log' => sub {
        my $parser = Parser->new( '2012-02-13 15:08:16 1RwtlY-000FG9-QX Completed' );

        ok !$parser->is_recieving_message();

        is_deeply
            $parser->get_payload(),
            {
                created => '2012-02-13 15:08:16',
                int_id  => '1RwtlY-000FG9-QX',
                str     => '1RwtlY-000FG9-QX Completed',
            };
    };
};

runtests;
