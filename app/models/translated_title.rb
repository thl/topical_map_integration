class TranslatedTitle < TopicalMapResource
  headers['Host'] = TopicalMapResource.headers['Host'] if !TopicalMapResource.headers['Host'].blank?
  self.site = "#{self.site.to_s}#{Category.collection_name}/:#{Category.element_name}_id/"
end