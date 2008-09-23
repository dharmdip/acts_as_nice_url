module Bounga
  module Acts
    module NiceUrl
      def self.included(base)
        base.extend ClassMethods
      end
      
      # This acts_as extension provides the capabilities for creating a nice url based on an attribute of the current object.
      # You can set / unset the object id in front of the URL and choose the object attribute to use to generate the URL.
      #
      # Author example:
      #
      #   class Author < ActiveRecord::Base
      #     acts_as_nice_url :id => false, :title => :full_name
      #   end
      module ClassMethods
        # Configuration options are:
        #
        # * +id+ - specifies if the object id has to be in front of the URL or not (default: +true+)
        # * +title+ - specifies the object attribute to use to generate the URL. You can use a symbol 
        # or a string (default: +title+)
        def acts_as_nice_url(options = {})
          include Bounga::Acts::NiceUrl::InstanceMethods
          
          configuration = { :id => true, :title => :title }
          configuration.update(options) if options.is_a?(Hash)
          
          class_eval <<-EOV
            def nice_title
              #{configuration[:title]}
            end

            def nice_id
              #{configuration[:id]}
            end
          EOV
        end
      end

      # All the methods available to a record that has had <tt>acts_as_nice_url</tt> specified.
      module InstanceMethods
        def to_param
          str = Iconv.new('us-ascii//TRANSLIT', 'utf-8').iconv(nice_title.to_s).strip.downcase
          str = str.gsub(/\s+/, '-').gsub(/[^a-z0-9\-\.,\*]/, '').gsub(/([\-\.,\*]){2,}/, '\1')
          if nice_id
            str = [self.id, str].join('-')
          end
          
          str
        end
      end
    end
  end
end


