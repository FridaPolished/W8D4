require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'
# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    return "humans" if class_name == 'Human'
    class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
      @foreign_key = options[:foreign_key] || (name.to_s + "_id").to_sym 
      @primary_key = options[:primary_key] || :id 
      @class_name = options[:class_name] || name.to_s.camelize  
  end
end


class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
      @foreign_key = options[:foreign_key] || (self_class_name.to_s.underscore + "_id").to_sym 
      @primary_key = options[:primary_key] || :id 
      @class_name = options[:class_name] || name.to_s.camelize.singularize 
  end
end

module Associatable
  # Phase IIIb   
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options) 
    @assoc_options = {name => options}
    define_method(name) do 
        class_name = options.model_class  #HUman
        for_key = self.send(options.foreign_key)
        prim_key = options.primary_key 
        class_name.where({prim_key => for_key}).first 
    end
  end



  def has_many(name, options = {}) 
     options = HasManyOptions.new(name, self, options) 
     define_method(name) do 
          # debugger  
          class_name = options.model_class 
          for_key = self.send(options.primary_key) 
          prim_key = options.foreign_key 
          class_name.where({prim_key => for_key})  
        end
  end

  def assoc_options
    @assoc_options ||= {}
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
