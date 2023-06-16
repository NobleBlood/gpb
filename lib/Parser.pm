=encoding utf8

=head1 NAME

Parser

=head1 DESCRIPTION

Класс для парсинга строк логов.

=cut

package Parser;

use strict;
use warnings;

use Email::Valid;

use constant {
    RECIEVING_FLAG => '<=',
    FLAGS          => [
        '<=',
        '=>',
        '->',
        '**',
        '--',
        '==',
    ],
};

=head2 C<new>( $class, $string )

Конструктор

IN:
    $string - строка лога

OUT:
    Объект Parser

=cut

sub new {
    my ( $class, $string ) = @_;

    my $self = bless { full_string => $string }, $class;

    $self->__init();

    return $self;
}

=head2 C<is_recieving_message>( $self )

Проверяет, является ли переданная строка логом получения сообщения

OUT:
    TRUE  - если оно таковое
    FALSE - в ином случае

=cut

sub is_recieving_message {
    my ( $self ) = @_;

    return $self->{flag}    &&
           $self->{address} &&
           ( $self->{flag} eq RECIEVING_FLAG );
}

=head2 C<get_payload>( $self )

Получить полезную нагрузку на основе парсинга строки

OUT:
    {
        created => timestamp создания записи
        int_id  => внутренний id
        str     => строка без timestamp
        address => email (если он есть, в кейсе получения сообщения передан не будет)
        id      => id из строки лога, есть только в кейсе получения
    }

=cut

sub get_payload {
    my ( $self ) = @_;

    my $payload = {
        created => $self->{created},
        int_id  => $self->{int_id},
        str     => $self->{str},
    };

    if ( $self->is_recieving_message() ) {
        $payload->{id} = $self->{id};
    }
    elsif( $self->{address} ) {
        $payload->{address} = $self->{address};
    }

    return $payload;
}

=head2 C<__init>( $self )

Проводит парсинг строки и инициализирует поля объекта значениями.

=cut

sub __init {
    my ( $self ) = @_;

    die 'full_string is undef!' unless $self->{full_string};

    # в логе нашелся кейс, когда после мыла сразу идет двоеточие без пробела
    # 2012-02-13 14:59:20 1Rujzc-00025m-V0 ** fwxvparobkymnbyemevz@london.com: retry timeout exceeded
    my ( $date, $time, $int_id, $flag, $address ) = split /:?\s+/,  $self->{full_string};

    my $str = $self->{full_string};
    $str    =~ s/^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\s+//;

    $self->{created} = "$date $time";
    $self->{int_id}  = $int_id;
    $self->{flag}    = __is_valid_flag( $flag )                           ? $flag  : undef;
    $self->{address} = $self->{flag} && Email::Valid->address( $address ) ? $address : undef;
    $self->{str}     = $str;

    $self->__check_and_fill_id() if $self->is_recieving_message();

    # кейс проверки
    # => :blackhole: <tpxmuwr@somehost.ru> R=blackhole_router
    $self->__check_and_fill_blackhole() unless $self->{address} && $flag ne RECIEVING_FLAG;
}

=head2 C<__check_and_fill_id>( $self )

Проверяет наличие в строке поля id и заносит его в поле id объекта.

=cut

sub __check_and_fill_id {
    my ( $self ) = @_;

    if ( $self->{str} =~ /id=(\d+)/ ) {
        $self->{id} = $1;
    }

}

=head2 C<__check_and_fill_blackhole>( $self )

Проверяет наличие в строке blackhole и заносит мыло в поле address объекта.

=cut

sub __check_and_fill_blackhole {
    my ( $self ) = @_;

    if ( $self->{str} =~ /:blackhole: <([^<>]+)>/) {
        $self->{address} = $1;
    }

}

=head2 C<__is_valid_flag>( $flag )

Проверяет валидность флага

IN:
    $flag - флаг

OUT:
    TRUE  - если флаг валиден
    FALSE - в ином случае

=cut

sub __is_valid_flag {
    my ( $flag ) = @_;

    for my $available_flag ( @{ FLAGS() } ) {
        return 1 if $flag eq $available_flag;
    }

    return;
}

1;
