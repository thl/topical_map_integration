class TopicalMapResource < ActiveResource::Base
  hostname = Socket.gethostname.downcase
  if hostname == 'sds6.itc.virginia.edu'
    self.site = 'http://staging.tmb.thlib.org/'
  elsif hostname == 'dev.thlib.org'
    self.site = 'http://dev.tmb.thlib.org/'
  elsif hostname == 'apoc.village.virginia.edu'  
    self.site = 'http://shanti.virginia.edu/kmaps/'    
  elsif hostname.ends_with? 'local'
    self.site = 'http://localhost/master/kmaps/'
  else
    self.site = 'http://tmb.thlib.org/' #'http://localhost/trunk/tmb/'
  end  
  self.timeout = 100
end