package MojoExampleAuth::Controller::Public;
use Mojo::Base 'MojoExampleAuth::Controller', -signatures;

sub do_login ($self) {
   my $username = $self->param('username');
   my $password = $self->param('password');
   $self->log->info("username<$username> password<$password>");
   if ($self->authenticate($username, $password, {})) {
      $self->flash(message => "Successful login as $username", status => 'ok');
      return $self->redirect_to('protected_root')
   }
   $self->flash(message => 'Authentication error', status => 'error');
   return $self->redirect_to('public_root')
}

sub do_logout ($self) {
   $self->logout;
   return $self->redirect_to('/');
}

sub homepage ($self) {
   return $self->render(template => 'public/home');
}

sub other ($self) {
   return $self->render(template => 'public/other');
}

1;
