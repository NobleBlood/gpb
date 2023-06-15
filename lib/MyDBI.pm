=encoding utf8

=head1 NAME

MyDBI

=head1 DESCRIPTION

Обертка над хендлером БД DBI.
Создает 2 хендлера для соединения с БД: один с правами на чтение, другой - на чтение и запись.
Данные для соединения берутся из переменных окружения.

=cut

package MyDBI;

use strict;
use warnings;

use DBI;
use Exporter 'import';

use constant {
    RO_FLAG => 'ro',
    RW_FLAG => 'rw',
};

our @EXPORT = qw( dbh_rw dbh_ro );

my ( $dbh_rw, $dbh_ro );

=head2 C<dbh_rw>()

Возвращает хендлер с правами на чтение и запись

OUT:
    Объект DBI

=cut

sub dbh_rw {
    return $dbh_rw if $dbh_rw;

    $dbh_rw = __init( RW_FLAG );
    return $dbh_rw;
}

=head2 C<dbh_ro>()

Возвращает хендлер с правами на чтение

OUT:
    Объект DBI

=cut

sub dbh_ro {
    return $dbh_rw if $dbh_rw;

    $dbh_rw = __init( RO_FLAG );
    return $dbh_rw;
}

=head2 C<__init>( $flag )

Создает хендлер на основе переданного флага.
Дохнет, если не установлены переменные окружения:
    DB_NAME
    DB_HOST
    DB_PORT
    DB_CUSTOMER
    DB_CUSTOMER_PASS
    DB_ADMIN
    DB_ADMIN_PASS

IN:
    $flag - флаг типа соединения.
            Если имеет значение RO_FLAG, то будет создан хендлер с правами на чтение.
            Если RW_FLAG - то с правами на чтение и на запись.
            В ином случае метод дохнет.

OUT:
    Объект DBI

=cut

sub __init {
    my ( $flag ) = @_;

    my $dbname = $ENV{DB_NAME} or die 'DB_NAME doesnt set!';
    my $host   = $ENV{DB_HOST} or die 'DB_HOST doesnt set!';
    my $port   = $ENV{DB_PORT} or die 'DB_PORT doesnt set!';

    my ( $username, $password );

    if ( $flag eq RO_FLAG ) {
        $username = $ENV{DB_CUSTOMER}      or die 'DB_CUSTOMER doesnt set!';
        $password = $ENV{DB_CUSTOMER_PASS} or die 'DB_CUSTOMER_PASS doesnt set!';
    }
    elsif( $flag eq RW_FLAG ) {
        $username = $ENV{DB_ADMIN}      or die 'DB_ADMIN doesnt set!';
        $password = $ENV{DB_ADMIN_PASS} or die 'DB_ADMIN_PASS doesnt set!';
    }
    else {
        die "Invalid flag $flag!";
    }

    my $dbh = DBI->connect(
        "dbi:Pg:dbname=$dbname;host=$host;port=$port",
        $username,
        $password,
        { AutoCommit => 1, RaiseError => 1, PrintError => 0 },
    );

    return $dbh;
}

1;
