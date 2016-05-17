source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

group :test do
  gem 'rake',                                                       :require => false
  gem 'rspec-puppet',                                               :require => false
  gem 'puppet-lint',                                                :require => false
  gem 'metadata-json-lint',                                         :require => false
  gem 'rspec-puppet-facts',                                         :require => false
  gem 'rspec',                                                      :require => false
  gem 'rspec-puppet-utils',                                         :require => false
  gem 'puppet-lint-absolute_classname-check',                       :require => false
  gem 'puppet-lint-leading_zero-check',                             :require => false
  gem 'puppet-lint-trailing_comma-check',                           :require => false
  gem 'puppet-lint-version_comparison-check',                       :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check',  :require => false
  gem 'puppet-lint-unquoted_string-check',                          :require => false
  gem 'puppet-lint-variable_contains_upcase',                       :require => false
  # gem 'rubocop',                                                    :require => false, :git => 'git://github.com/bbatsov/rubocop.git'
  # gem 'puppet-strings',                                             :require => false, :git => 'git://github.com/puppetlabs/puppetlabs-strings.git'
  # gem 'unicode-display_width',                                      :require => false, :git => 'git://github.com/janlelis/unicode-display_width.git'
  # gem 'puppetlabs_spec_helper',                                     :require => false, :git => 'git://github.com/puppetlabs/puppetlabs_spec_helper.git'
  gem 'puppetlabs_spec_helper',                                     :require => false
end

group :development do
  gem 'travis',       :require => false
  gem 'travis-lint',  :require => false
  gem 'guard-rake',   :require => false
end

group :system_tests do
  gem 'beaker',                        :require => false
  if beaker_version = ENV['BEAKER_VERSION']
    gem 'beaker', *location_for(beaker_version)
  end
  if beaker_rspec_version = ENV['BEAKER_RSPEC_VERSION']
    gem 'beaker-rspec', *location_for(beaker_rspec_version)
  else
    gem 'beaker-rspec',  :require => false
  end
  gem 'beaker-puppet_install_helper',  :require => false
end



if facterversion = ENV['FACTER_GEM_VERSION']
gem 'facter', facterversion.to_s, :require => false, :groups => [:test]
else
gem 'facter', :require => false, :groups => [:test]
end

ENV['PUPPET_VERSION'].nil? ? puppetversion = '~> 3.0' : puppetversion = ENV['PUPPET_VERSION'].to_s
gem 'puppet', puppetversion, :require => false, :groups => [:test]

# vim:ft=ruby
