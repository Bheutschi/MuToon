# frozen_string_literal: true

require 'bundler/setup'
require 'zeitwerk'
require 'mongo'

loader = Zeitwerk::Loader.new

root = __dir__ || Dir.pwd

app_dir = File.join(root, 'app')

unless Dir.exist?(app_dir)
  raise "CRITICAL ERROR: The 'app' directory cannot be found here: #{app_dir}"
end

loader.push_dir(app_dir)

repo_dir = File.join(app_dir, 'repositories')
if Dir.exist?(repo_dir)
  loader.collapse(repo_dir)
end

loader.setup