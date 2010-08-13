require 'rubygems'
gem 'hoe', '>= 2.0.0'
gem 'typestrict', '>= 0.0.10'
require 'hoe'
require 'typestrict'
require 'lib/analytica'

Hoe.spec 'Analytica' do
  self.version = Analytica::VERSION
  self.name = 'analytica'
  self.author = 'Raeez Lorgat'
  self.description = 'Data Analysis wrapper for ruby arrays'
  self.email = 'raeez@mit.edu'
  self.summary = 'Analytica implements simple data analysis and graph plotting over ruby arrays'
  self.url = 'http://www.raeez.com/anlaytica'
  self.extra_deps = ['typestrict']
end

desc "Release and publish documentation"
task :repubdoc => [:release, :publish_docs]
