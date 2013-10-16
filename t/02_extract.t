use strict;
use warnings;
use Test::More;

my $class = "Devel::CycleUse";

use Devel::CycleUse;

subtest 'extracting normal module' => sub {
    my $content = <<MODULE;
package Hoge;
use 5.008_001;
use strict;
use warnings;
use utf8;
use Fuga;

1;
MODULE
    matcher($content, "Hoge", [qw(Fuga)]);
};

subtest 'extracting pause hack module' => sub {
    my $content = <<MODULE;
package Hoge;
use strict;
use warnings;
use Fuga;

use Piyo::
        Hiko;

1;
MODULE
    matcher($content, "Hoge", [qw(Fuga)]);
};

subtest 'extract using modules when using import module methods' => sub {
    my $content = <<MODULE;
package Hoge;
use strict;
use warnings;
use Fuga qw(base_method);
use Piyo -checker => 'strict';

1;
MODULE

    matcher($content, "Hoge", [qw(Fuga Piyo)]);
};

subtest 'extract using modules when using inheritance' => sub {
    subtest 'use base' => sub {
        my $content = <<MODULE;
package Hoge;
use strict;
use warnings;
use base qw(FooBar);
use Fuga qw(base_method);
use Piyo -checker => 'strict';

1;
MODULE
        matcher($content, "Hoge", [qw(Fuga Piyo)]);
    };

    subtest 'use parent' => sub {
        my $content = <<MODULE;
package Hoge;
use strict;
use warnings;
use parent qw(FooBar);
use Fuga qw(base_method);
use Piyo -checker => 'strict';

1;
MODULE
        matcher($content, "Hoge", [qw(Fuga Piyo)]);
    };
};

subtest 'extract using modules when using same module some times' => sub {
    my $content = <<MODULE;
package Hoge;
use 5.008_001;
use strict;
use warnings;
use utf8;
use constant {
    Hoge => "Fuga",
};
use constant PI => 3.14;
use Fuga;
use Fuga;

1;
MODULE
    matcher($content, "Hoge", [qw(Fuga)]);
};

subtest 'extract using modules when multiple package in same file' => sub {
    my $content = <<MODULE;
package Hoge;
use 5.008_001;
use strict;
use warnings;
use utf8;
use constant {
    Hoge => "Fuga",
};
use constant PI => 3.14;
use Fuga;
use Fuga;

package Foo;
use strict;
use warnings;
use Bar;

1;
MODULE
    matcher($content, "Hoge", [qw(Fuga)], "Foo", [qw(Bar)]);
};

done_testing;

sub matcher {
    my ($content, @match_target) = @_;

    my @result = $class->__extract_using_modules(split("\n", $content));
    while (@result) {
        my $result_package = shift @result;
        my $result_modules = shift @result;
        my $package = shift @match_target;
        my $using_modules = shift @match_target;
        is $result_package, $package, "should be package name";
        is_deeply $result_modules, $using_modules, "should be list of using modules";
    }
}
