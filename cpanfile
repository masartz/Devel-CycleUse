requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Pretty', '0.27';
    requires 'Test::Exception', '0.32';
    requires 'Test::MockModule', '0.05';
};

