module Ym4r
  module GmPlugin
    class GMapsAPIKeyConfigFileNotFoundException < StandardError
    end
        
    class AmbiguousGMapsAPIKeyException < StandardError
    end
    
    #Class fo the manipulation of the API key
    class ApiKey

      def self.load_key
        unless File.exist?(Rails.root.join("config","gmaps_api_key.yml"))
          raise GMapsAPIKeyConfigFileNotFoundException.new("File config/gmaps_api_key.yml not found")
        else
          env = ENV['RAILS_ENV'] || Rails.env
          gmaps_api_key = YAML.load_file(Rails.root.join("config","gmaps_api_key.yml"))[env]
        end
      end

      def self.gmaps_api_key
        @gmaps_api_key = load_key
      end

      def self.get(options = {})
        if options.has_key?(:key)
          options[:key]
        elsif gmaps_api_key.is_a?(Hash)
          #For this environment, multiple hosts are possible.
          #:host must have been passed as option
          if options.has_key?(:host)
            gmaps_api_key[options[:host]]
          else
            raise AmbiguousGMapsAPIKeyException.new(gmaps_api_key.keys.join(","))
          end
        else
          #Only one possible key: take it and ignore the :host option if it is there
          gmaps_api_key
        end
      end
    end
  end
end
