# Run unit tests in files ending in "*_spec.rb".
test_dir = File.dirname(__FILE__)
Dir["#{test_dir}/*_spec.rb"].each do |file|
  require file
end