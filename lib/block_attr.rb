module BlockAttr

  def self.included klass
    klass.extend ClassMethods
  end

  module ClassMethods

    # No Convention over Configuration attributes.
    def block_attr *list
      @attributes = ((@attributes || [])+ list).uniq
      list.each do |new_method|
        instance_eval do
          define_method new_method do |argument|
            instance_variable_set "@#{new_method}", argument
          end
        end
      end
    end

  end

end
