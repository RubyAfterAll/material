# frozen_string_literal: true

module Material
  class List < Collectible::CollectionBase
    include Conjunction::Junction
    suffixed_with "List"

    include Material::Components
    include Material::Display
    include Material::Text
    include Material::Site
    include Material::Pagination
    include Material::Mount
    include Material::Collection
    include Material::Format

    class << self
      def for(object)
        for_class(object.respond_to?(:first) ? object.first : object)&.new(object)
      end

      def for_class(object)
        object.try(:conjugate!, self)
      end
    end

    def contextualize(parent)
      @context_parent = parent
    end

    def default_parent
      @context_parent
    end

    def default_title
      (item_class.try(:model_name)&.human || item_class&.name).pluralize || self.class.name
    end
  end
end
