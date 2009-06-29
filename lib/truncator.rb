module Truncator
  
  # Extend Active record to include a truncate method to clear out tables
  def self.included(base)
    ActiveRecord::Base.send(:include, ActiveRecordExtensions)
  end
    
  # Add a truncate method to Rspec to take an array of table names or :all
  def truncate_tables(*tables)
  
    if tables.include?(:all)
      tables = ActiveRecord::Base.connection.tables - %w{schema_migrations}
    end

    tables.each do |table|
      begin
        table.classify.constantize.truncate
      rescue
        RAILS_DEFAULT_LOGGER.error "Unable to truncate table #{table}"
      end
    end

  end
  
  module ActiveRecordExtensions

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      # Truncates the table for this model
      def truncate
        connection_pool.with_connection do |connection|
          connection.execute("TRUNCATE TABLE #{table_name};")
        end
      end

    end

  end
  
  
end
