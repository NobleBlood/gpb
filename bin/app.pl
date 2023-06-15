=encoding utf8

=head1 NAME

bin/app.pl

=head1 DESCRIPTION

Веб-приложение для отображения списка логов по заданному email.

=cut

use Mojolicious::Lite -signatures;
use Helper::LogFinder;
use Data::Dumper;

get '/' => sub ($c) {
    $c->render( 'index' );
};

post '/logs' => sub ($c) {
    my $finder = Helper::LogFinder->new( $c->param( 'address' ) );

    $c->render(
        error     => $finder->get_error(),
        overlimit => $finder->is_overlimit(),
        payload   => $finder->get_payload(),
    );
} => 'logs';

app->start;

__DATA__

@@ index.html.ep
% layout 'form';

@@ logs.html.ep
% layout 'form';

<% if ( $overlimit ) { %>
  <div class="alert alert-warning" role="alert">
    Overlimit!
  </div>
<% } %>

<% if ( $error ) { %>
  <div class="alert alert-danger" role="alert">
    <%= $error %>
  </div>
<% } %>

<% if ( scalar @$payload ) { %>
  <table class="table">
    <thead>
      <tr>
        <th scope="col">created</th>
        <th scope="col">str</th>
      </tr>
    </thead>
    <tbody>
    <% for my $row ( @$payload ) { %>
        <tr>
          <td><%= $row->{created} %></td>
          <td><%= $row->{str} %></td>
        </tr>
    <% } %>
    </tbody>
  </table>
<% } elsif( !$error ) { %>
  <div class="alert alert-warning" role="alert">
    Nothing!
  </div>
<% } %>

@@ layouts/form.html.ep
<!DOCTYPE html>
<html>
  <head>
    <title>logs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
  </head>
  <body>
    <div class="container">
      <form action="/logs" method="POST">
        <div class="form-group">
          <label for="exampleInputEmail1">Email address</label>
          <input type="email" class="form-control" id="address" name="address" aria-describedby="emailHelp" placeholder="Enter email">
        </div>
        <button type="submit" class="btn btn-primary">Submit</button>
      </form>
      <%= content %>
    </div>
  </body>
</html>