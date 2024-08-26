#!/usr/bin/env perl

package MojoExampleAuth;
use v5.24;
use Mojo::Base qw< Mojolicious -signatures >;
use MojoExampleAuth::Authentication;

sub startup ($self) {

   # in this example, we have a class that is devoted to handling our
   # authentication calls.
   my $authn = MojoExampleAuth::Authentication->new;

   # we use this class to provide the two callbacks required by the
   # Authentication plugin, namely load_user and validate_user. The two
   # sub:s close on lexical variable $authn, keeping it alive after we
   # exit from this "startup" method.
   $self->plugin(
      Authentication => {
         load_user     => sub ($a, $x) { $authn->load_user($x)     },
         validate_user => sub ($c, @A) { $authn->validate_user(@A) },
      },
   );

   # let's deal with routes like this:
   # - /login and /logout do what they imply and are not subject to
   #   authentication checks
   # - anything under /public is... public and not subject to
   #   authentication checks
   # - anything else under / is protected
   # - anything not dealt with explicitly is a 404
   my $root           = $self->routes;

   # let's attach login/logout route to the main routes root, without
   # the need to check credentials before they are accessed.
   $root->post('/login')->to('public#do_login');
   $root->get('/logout')->to('public#do_logout');
   $root->post('/logout')->to('public#do_logout');

   # public routes: a home page and some other page
   my $public_root = $root->any('/public');
   $public_root->get('/')->to('public#homepage')->name('public_root');
   $public_root->get('/other')->to('public#other');

   # everything else under '/' will be protected. We make sure this will
   # be the case by attaching any following route "under" a common
   # ancestor that will perform the authentication check and redirect to
   # the homepage if it has not been performed correctly.
   my $protected_root = $root->under(
      '/' => sub ($c) {
         return 1 if $c->is_user_authenticated;

         $c->log->debug('not authenticated, bouncing to public home');
         $c->redirect_to('public_root');
         return 0;
      }
   );
   $protected_root->get('/')->to('protected#homepage')->name('protected_root');
   $protected_root->get('/other')->to('protected#other');

   # default to 404 for anything that has not been handled explicitly.
   # This is probably reinventing a wheel already present in Mojolicious
   my $nf = sub ($c) {$c->render(template => 'not_found', status => 404)};
   $public_root->any($_ => $nf) for qw< * / >;
   $protected_root->any($_ => $nf) for qw< * / >;

   $self->controller_class('MojoExampleAuth::Controller');
   $self->defaults(layout => 'default');
   $self->log->info('startup complete');
   return $self;
}

1;
