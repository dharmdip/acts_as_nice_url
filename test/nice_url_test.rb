require 'test/unit'

require 'rubygems'
require 'active_record'
require 'iconv'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :authors do |t|
      t.string :name, :title
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Mixin < ActiveRecord::Base
  def self.table_name() "authors" end
end

class AuthorDefault < Mixin
  acts_as_nice_url
end

class AuthorWithoutId < Mixin
  acts_as_nice_url :id => false
end

class AuthorTuned < Mixin
  acts_as_nice_url :title => :name
end

class AuthorTunedWithoutId < Mixin
  acts_as_nice_url :id => false, :title => :name
end

class AuthorString < Mixin
  acts_as_nice_url :title => 'name'
end

class NiceUrlTest < Test::Unit::TestCase

  def setup
    setup_db
    Mixin.create! :name => 'Nicolas Cavigneaux', :title => 'Rails lover'
  end

  def teardown
    teardown_db
  end

  def test_defaults
    assert_equal "1-rails-lover", AuthorDefault.find(:first).to_param
  end
  
  def test_without_id
    assert_equal "rails-lover", AuthorWithoutId.find(:first).to_param
  end
  
  def test_tuned
    assert_equal "1-nicolas-cavigneaux", AuthorTuned.find(:first).to_param
  end
  
  def test_tuned_without_id
    assert_equal "nicolas-cavigneaux", AuthorTunedWithoutId.find(:first).to_param
  end
  
  def test_string
    assert_equal "1-nicolas-cavigneaux", AuthorString.find(:first).to_param
  end
  
  def test_non_ascii_char
    author = AuthorDefault.find(:first)
    author.title = "Réalisation de tests"
    assert_equal "1-realisation-de-tests", author.to_param
  end
  
  def test_reserved_char
    author = AuthorDefault.find(:first)
    author.title = "Rails lover%/...#?*!"
    assert_equal "1-rails-lover", author.to_param
  end
  
  def test_multiple_dashes
    author = AuthorDefault.find(:first)
    author.title = "Rails ---lover"
    assert_equal "1-rails-lover", author.to_param
  end
  
  def test_end_dashes
    author = AuthorDefault.find(:first)
    author.title = "Rails lover---"
    assert_equal "1-rails-lover", author.to_param
  end
end