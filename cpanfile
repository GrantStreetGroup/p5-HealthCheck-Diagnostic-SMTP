use GSG::Gitc::CPANfile $_environment;

# Add your requirements here

requires 'HealthCheck::Diagnostic';
requires 'Net::SMTP';

on develop => sub {
    requires 'Dist::Zilla::PluginBundle::Author::GSG::Internal';
};
