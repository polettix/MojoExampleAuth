package MojoExampleAuth::Authentication;
use Mojo::Base qw< -base -signatures >;

# In this example we assume that our users have username (which double
# down as user identifiers too) and password.
has 'db' => sub {
   return {
      map { $_->{username} => $_ }
         { name => 'Foo Ish' => username => foo    => password => 123 },
         { name => 'Bar Ong' => username => bar    => password => 456 },
         { name => 'Baz Ing' => username => baz    => password => 789 },
         { name => 'Gal Ook' => username => galook => password => 0   },
   };
};

# the methods below might be compacted into two
# (load_user+get_user_from_db, validate_user+password_is_right) but we
# keep them separated for sake of clarity about what the plugin
# interface needs and what we need to do towards our user database

# In theory, we might keep load_user and validate_user as coded below,
# and only hack on get_user_from_db and password_is_right to adapt the
# implementation to any LDAP querying need.


# this function takes a user identifier (same as username for us) and
# returns the user's object.
sub load_user ($self, $id) {
   my $user = $self->get_user_from_db($id);
   return $user;
}

# this function takes the parameters provided and makes sure that the
# password is the right one for the username.
sub validate_user ($self, $username, $password, $extra) {
   # return the user identifier if the password check is good
   return $username if $self->password_is_right($username, $password);

   # return undef if anything seems suspicious
   return undef;
}


########################################################################
#### methods below are specific for the user database technology    ####

sub get_user_from_db ($self, $userid) {
   # In a LDAP setup, this is where we query the directory to get the
   # user's record with the attributes we're interested into.

   # But we're using a hash here, so...
   my $user = $self->db->{$userid} or return;
   return { $user->%*, password => '***' };  # protect the record
}

sub password_is_right ($self, $username, $password) {
   # In a LDAP setup, this is where we ask the directory to check the
   # provided username/password pair.
warn "password_is_right <$username>/<$password>";
   # But we're using a hash here, so...
   my $user = $self->db->{$username} or return;
warn "password_is_right <$password> vs $user->{password}>";
   return $user->{password} eq $password;
}

1;
