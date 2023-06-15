=encoding utf8

=head1 NAME

Helper

=head1 DESCRIPTION

Вспомогательные функции для работы скрипта для заполнения БД.

=cut

package Helper;

use strict;
use strict;
use warnings;

use MyDBI;
use Parser;

use constant {
    MESSAGE_TABLE => 'message',
    LOG_TABLE     => 'log',
};

=head2 C<fill_db>( $string )

Проводит парсинг строки и заполняет БД.

В случае, есле это полученное сообщение, то запись идет в message.
При этом если id отсутствует не производит запись в БД.
В случае дублирующегося id в таблице message также не производит запись в БД.

В иных случаях запись идет в таблицу log.

IN:
    $string - строка лога

=cut

sub fill_db {
    my ( $string ) = @_;

    my $parser  = Parser->new( $string );
    my $payload = $parser->get_payload();
    my $table;

    if ( $parser->is_recieving_message() ) {
        return unless $payload->{id};
        return if __is_id_exists( $payload->{id} );

        $table = MESSAGE_TABLE;
    }
    else {
        $table = LOG_TABLE;
    }

    my ( @fields, @placeholders, @values );
    while ( my ( $field, $value ) = each %$payload ) {
        push @fields,       $field;
        push @values,       $value;
        push @placeholders, '?';
    }

    local $" = ', ';
    my $sql = qq{
        INSERT INTO
            $table( @fields )
        VALUES
            ( @placeholders )
    };

    dbh_rw->do( $sql, undef, @values );
}

=head2 C<__is_id_exists>( $id )

Проверяет наличие записи с id в таблице message

IN:
    $id - id сообщения

OUT:
    TRUE  - если запись с таким id найдена
    FALSE - в ином случае

=cut

sub __is_id_exists {
    my ( $id ) = @_;

    return dbh_ro->selectcol_arrayref( 'SELECT COUNT(*) FROM message WHERE id = ?', undef, $id )->[0];
}

1;
