require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns
      @columns
    else
      dbcolumns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
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
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
     #{self.table_name}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    all_objects = []
    results.each do |params|
      all_objects << self.new(params)
    end
    all_objects
  end

  def self.find(id)
   
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
     #{self.table_name}
    WHERE
      #{self.table_name}.id = ?
    LIMIT
      1
    SQL
     
    return nil if result.empty?
    self.parse_all(result).first 
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
    atr_vals = self.class.columns
      atr_vals.map! do |val|
          self.send(val)
      end
  end

  def insert
    col = self.class.columns
    values = self.attribute_values
    result = DBConnection.execute(<<-SQL, *values)
    INSERT INTO
     #{self.table_name} ()
    VALUES
      ?
    SQL
    result 
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
