class TopicalMapResource < ActiveResource::Base
  hostname = Socket.gethostname.downcase
  if hostname == 'sds6.itc.virginia.edu'
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'staging.tmb.thlib.org'
  elsif hostname == 'dev.thlib.org'
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'dev.tmb.thlib.org'
  elsif hostname == 'apoc.village.virginia.edu'  
    self.site = 'http://shanti.virginia.edu/kmaps/'    
  elsif hostname.ends_with? 'local'
    self.site = 'http://localhost/master/kmaps/'
  elsif hostname =~ /sds[3-8].itc.virginia.edu/
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'tmb.thlib.org'
  else
    self.site = 'http://tmb.thlib.org/'
  end  
  self.timeout = 100
end