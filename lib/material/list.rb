# frozen_string_literal: true

module Material
  class List < Collectible::CollectionBase
    include Material::Components
    include Material::Display
    include Material::Text
    include Material::Site
    include Material::For
    include Material::Pagination
    include Material::Mount
    include Material::Collection

    class << self
      def for(object)
        material_class = material_class_for(object, "List")
        material_class.new if material_class.present?
      end
    end

    def default_title
      (item_class.try(:model_name)&.human || item_class&.name).pluralize || self.class.name
    end
  end
end
