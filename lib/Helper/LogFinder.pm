=encoding utf8

=head1 NAME

Helper::LogFinder

=head1 DESCRIPTION

Класс для поиска логов в БД.

=cut

package Helper::LogFinder;

use strict;
use warnings;

use MyDBI;
use Email::Valid;

use constant {
    LIMIT => 100,
};

=head2 C<new>( $class, $string )

Конструктор

IN:
    $address - адрес

OUT:
    Объект Helper::LogFinder

=cut

sub new {
    my ( $class, $address ) = @_;

    my $self = bless { address => $address };
    $self->__init();

    return $self;
}

=head2 C<is_valid_address>( $self )

Проверяет, является ли адрес валидным. Выставляет в объекте ошибку, если адрес не валиден.

OUT:
    TRUE  - если адрес валиден
    FALSE - в ином случае

=cut

sub is_valid_address {
    my ( $self ) = @_;

    $self->{error} = 'address is invalid!' unless Email::Valid->address( $self->{address} );

    return if $self->{error};
    return 1;
}

=head2 C<is_overlimit>( $self )

Проверяет, превышает ли количество найденных записей лимит.

OUT:
    TRUE  - если лимит превышен
    FALSE - в ином случае

=cut

sub is_overlimit {
    my ( $self ) = @_;

    return scalar @{ $self->{payload} || [] } > LIMIT;
}

=head2 C<get_payload>( $self )

Получить полезную нагрузку из БД. Если лимит записей превышен,
то вернет только LIMIT записей.

OUT:
    [
        {
            created => '2020-01-01 dslfa ...',
            str     => 'some_str',
        },
        ...
    ]

=cut

sub get_payload {
    my ( $self ) = @_;

    if ( $self->is_overlimit() ) {
        return [ @{ $self->{payload} }[ 0 .. LIMIT - 1 ] ];
    }

    return $self->{payload} || [];
}

=head2 C<get_error>( $self )

Получить текст ошибки.

OUT:
    строка ошибки

=cut

sub get_error { return +shift->{error} }

=head2 C<__init>( $self )

Делает запрос в БД и заполняет поля объекта значениями.

=cut

sub __init {
    my ( $self ) = @_;

    return unless $self->is_valid_address();

    my $address = $self->{address};

    my $sql = q{
        SELECT
            created,
            str
        FROM
            (
                (
                    SELECT
                        created,
                        int_id,
                        str
                    FROM
                        message
                    WHERE
                        str LIKE ? OR str LIKE ?
                    LIMIT ?
                )
                UNION
                (
                    SELECT
                        created,
                        int_id,
                        str
                    FROM
                        log
                    WHERE
                        address = ?
                    LIMIT ?
                )
            ) AS result
        ORDER BY result.int_id ASC, result.created ASC
        LIMIT ?
    };

    $self->{payload} = dbh_ro->selectall_arrayref(
        $sql,
        { Slice => {} },
        "\%$address\%",
        "\%$address",
        LIMIT + 1,
        $address,
        LIMIT + 1,
        LIMIT + 1,
    );
}

1;
