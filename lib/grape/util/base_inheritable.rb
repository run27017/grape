module Grape
  module Util
    # Base for classes which need to operate with own values kept
    # in the hash and inherited values kept in a Hash-like object.
    class BaseInheritable
      attr_accessor :inherited_values
      attr_accessor :new_values

      # @param inherited_values [Object] An object implementing an interface
      #   of the Hash class.
      def initialize(inherited_values = {})
        @inherited_values = inherited_values
        @new_values = {}
      end

      def delete(key)
        new_values.delete key
      end

      def initialize_copy(other)
        super
        self.inherited_values = other.inherited_values
        self.new_values = other.new_values.dup
      end

      def keys
        combined = inherited_values.keys
        combined.concat(new_values.keys)
        combined.uniq!
        combined
      end
    end
  end
end