$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'nice_url'
ActiveRecord::Base.send(:include, Bounga::Acts::NiceUrl)
