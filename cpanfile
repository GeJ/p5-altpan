requires 'perl', '5.010001';

requires 'Authen::Simple::Passwd',       '0.6';
requires 'File::Spec',                   '3.62';
requires 'File::Temp',                   '0.2304';
requires 'Kossy',                        '0.40';
requires 'OrePAN2',                      '0.44';
requires 'Plack',                        '1.0039';
requires 'Plack::Builder::Conditionals', '0.05';
requires 'Server::Starter',              '0.33';
requires 'Try::Tiny',                    '0.27';

on build => sub {
    requires 'ExtUtils::MakeMaker';
};
