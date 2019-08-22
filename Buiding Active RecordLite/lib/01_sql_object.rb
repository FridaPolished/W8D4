require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    #table = self.table_name
    if @columns
      @columns
    else
      dbcolumns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
      SQL

      @columns = dbcolumns.first.map do |col|
        col.to_sym
      end
      @columns
    end
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end
      define_method("#{col}=") do |value|
        self.attributes[col] = value 
      end 
    end 
    
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name 
    @table_name ||=self.to_s.tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    #raise "No parameters given"if params.empty?

    params.each do |k,v|
      if self.class.columns.include?(k.to_sym)
         self.send("#{k}=", v)
      else
        raise "unknown attribute '#{k}'"
      end
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
