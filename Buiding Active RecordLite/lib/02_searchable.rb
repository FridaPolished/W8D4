require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'
module Searchable
  def where(params)
    where_line = params.map {|k, v| "#{k} = ?" }
    where_line_str = where_line.join(" AND ")
    values = params.values

    result = DBConnection.execute(<<-SQL, *values)
    SELECT
      id
    FROM
      #{self.table_name}
    WHERE
      #{where_line_str}
    SQL
    #debugger 
    objects = []
    result.each do |object_id|
        objects << self.find(object_id["id"])
    end
    objects
  end
end

class SQLObject
  extend Searchable
end
