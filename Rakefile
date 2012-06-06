require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = ENV['TEST'] || Dir['test/test_*.rb']
  t.verbose = true
  #t.warning = true
end

