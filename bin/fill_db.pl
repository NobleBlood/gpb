#!/usr/bin/env perl

=encoding utf8

=head1 NAME

bin/fill_db.pl

=head1 DESCRIPTION

Скрипт для заполнения БД.
В корне проекта ищет файл лога out и заполняет данные из него в БД.
Дохнет, если не нашел этот файл.

=cut

use strict;
use warnings;

use Helper;

my $fh;
open $fh, '<', '/app/out' or die 'Cannot open logfile!';

while (<$fh>) {
    chomp $_;

    Helper::fill_db( $_ );
}
