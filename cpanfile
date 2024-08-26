requires 'perl', '5.024000';
requires 'IO::Socket::SSL';
requires 'Mojolicious';
requires 'Module::Runtime';
requires 'Net::SAML2';
requires 'Ouch';
requires 'Try::Catch';



# requires 'DBI';
# requires 'Mojo::SQLite';
# requires 'Mojo::Pg';

# requires 'Minion';
# requires 'Minion::Backend::SQLite';

requires 'Mojolicious::Plugin::Authentication';
requires 'Mojolicious::Plugin::Passphrase';
requires 'Crypt::Passphrase';
requires 'Crypt::Passphrase::Argon2';

on test => sub {
   requires 'Path::Tiny',      '0.084';
};

on develop => sub {
   requires 'Path::Tiny',          '0.084';
   requires 'Template::Perlish',   '1.52';
   requires 'Test::Pod::Coverage', '1.04';
   requires 'Test::Pod',           '1.51';
};
