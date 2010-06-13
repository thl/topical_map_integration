class Category < TopicalMapResource
  headers['Host'] = TopicalMapResource.headers['Host'] if !TopicalMapResource.headers['Host'].blank?
  
  acts_as_active_resource_tree
  
  def self.find_by_title(title)
    # Since its going as part of the url, space is not welcome on the rails side as a '+'. Should be %20 instead.
    self.find(:first, :from => "#{prefix}#{collection_name}/by_title/#{CGI::escape(title).gsub(/\+/, '%20')}.xml")
  end
end