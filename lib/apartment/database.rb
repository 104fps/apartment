require 'active_support/core_ext/module/delegation'

module Apartment
	module Database
	  
	  extend self

    # pass these methods to our adapter
    delegate :create, :current_database, :drop, :process, :process_excluded_models, :reset, :seed, :switch, :to => :adapter
    
    # allow for config dependency injection
    attr_writer :config

    def adapter
	    @adapter ||= begin
		    adapter_method = "#{config[:adapter]}_adapter"
		    
		    begin
          require "apartment/adapters/#{adapter_method}"
        rescue LoadError => e
          raise "The adapter `#{config[:adapter]}` is not yet supported"
        end

        unless respond_to?(adapter_method)
          raise AdapterNotFound, "database configuration specifies nonexistent #{config[:adapter]} adapter"
        end
      
        send(adapter_method, config)
      end
    end
    
    # Call init to establish a connection to the public schema on all excluded models
    # This must be done before creating any new schemas or switching
	  def init
	    process_excluded_models
    end
    
    def reload!
      @adapter = nil
      @config = nil
    end
    
	private
  
    def config
      @config ||= Rails.configuration.database_configuration[Rails.env].symbolize_keys
    end
  end
	
end