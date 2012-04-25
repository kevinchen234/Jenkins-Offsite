require 'rubygems'
require 'rake'
require 'echoe'
require 'hanna/rdoctask'

Echoe.new('ucb_rails_security', '2.1.1') do |p|
  p.description    = "Simplifies CAS auth and ldap authz within your rails application"
  p.url            = "http://ucbrb.rubyforge.org/ucb_rails_security"
  p.author         = "Steven Hansen, Steven Downey"
  p.email          = "runner@berkeley.edu"
  p.ignore_pattern = ["svn_user.yml", "tasks/**/**", "test/**/**", "version.yml"]
  p.runtime_dependencies = ["rubycas-client >=2.0.1", "ucb_ldap >=1.3.0", "actionpack >=2.1.2", "rspec >=1.1.5"]
  p.project = "ucbrb"
  p.rdoc_options = "-o doc --inline-source -T hanna lib/*.rb"    
  p.rdoc_pattern = ["README", "CHANGELOG", "lib/**/**", "rdoc_includes/**/**"]
end
 
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }


