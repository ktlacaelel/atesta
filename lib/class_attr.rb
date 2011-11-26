
# Dynamically define class attribute accessors
module ClassAttr

  def self.included klass
    klass.extend ClassMethods
  end

  module ClassMethods

    def class_attr *list
      list.each do |my_method|
        eval "
          def self.#{my_method}= #{my_method}
            @#{my_method} = #{my_method}
          end
          def self.#{my_method}
            @#{my_method}
          end
        "
      end
    end

  end

end
