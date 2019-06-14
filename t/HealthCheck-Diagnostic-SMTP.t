use strict;
use warnings;

use Test::More;

BEGIN { use_ok('HealthCheck::Diagnostic::SMTP') };

diag(qq(HealthCheck::Diagnostic::SMTP Perl $], $^X));

done_testing;
