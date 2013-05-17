class TopicalMapResource < ActiveResource::Base
  case InterfaceUtils::Server.environment
  when InterfaceUtils::Server::DEVELOPMENT
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'dev-subjects.thlib.org'
  when InterfaceUtils::Server::STAGING
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'staging.subjects.thlib.org'
  when InterfaceUtils::Server::PRODUCTION
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'subjects.thlib.org'
  when InterfaceUtils::Server::LOCAL
    self.site = 'http://localhost/thl/kmaps/'
  when InterfaceUtils::Server::APOC
    self.site = 'http://subjects.kmaps.virginia.edu'
  when InterfaceUtils::Server::EBHUTAN
    self.site = 'http://www.e-bhutan.net.bt/kmaps/'
  else
    self.site = 'http://subjects.thlib.org/'
  end
  
  self.timeout = 100
  self.format = :xml
end