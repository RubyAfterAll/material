# frozen_string_literal: true

module Material
  module Attributes
    extend ActiveSupport::Concern

    included do
      delegate :head_attributes, :tail_attributes, to: :class

      memoize :attribute_values
      memoize :attribute_types
      memoize :formatted_attributes
      memoize :sorted_attribute_names
      memoize :relationship_attributes
      memoize :unique_display_attributes
    end

    class_methods do
      def head_attributes
        %w[id]
      end

      def tail_attributes
        %w[created_at updated_at]
      end
    end

    def human_attribute_value(attribute)
      formatted_attributes.fetch(attribute)
    end

    def display_attributes
      unique_display_attributes
    end

    def unique_display_attributes
      [].tap do |attrs|
        attribute_names.each do |attribute_name|
          next if relationship_attribute?(attribute_name)

          attrs << attribute_name
        end

        attrs.concat(relationship_attributes).uniq
      end
    end

    def relationship_attribute?(attribute_name)
      relationship_attributes.include?(attribute_name) || relationship_attributes.include?(attribute_name.chomp("_id"))
    end

    def attribute_values
      display_attributes.each_with_object({}) { |attribute, hash| hash[attribute] = public_send(attribute.to_sym) }
    end

    def attribute_types
      display_attributes.each_with_object({}) { |attribute, hash| hash[attribute] = type_for_attribute(attribute).type }
    end

    def formatted_attributes
      attribute_types.each_with_object({}) do |(attribute, attribute_type), hash|
        next if relationship_attribute?(attribute)
        hash[attribute] = format_by_type(attribute_values[attribute], type: attribute_type)
      end
    end

    def sorted_attribute_names
      [
        (head_attributes & display_attributes),
        (display_attributes - head_attributes - tail_attributes).sort,
        (tail_attributes & display_attributes),
      ].flatten
    end

    def relationship_attributes
      source_class.reflect_on_all_associations.map(&:name).map(&:to_s)
    end
  end
end

