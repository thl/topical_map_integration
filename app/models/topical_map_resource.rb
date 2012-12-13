class TopicalMapResource < ActiveResource::Base
  hostname = Socket.gethostname.downcase
  if hostname == 'sds6.itc.virginia.edu'
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'staging.subjects.thlib.org'
  elsif hostname == 'dev.thlib.org'
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'dev-subjects.thlib.org'
  elsif hostname == 'apoc.village.virginia.edu'  
    self.site = 'http://subjects.kmaps.virginia.edu'
  elsif hostname == 'e-bhutan.bt'
    self.site = 'http://www.e-bhutan.net.bt/kmaps/'
  elsif hostname.ends_with?('local') || hostname.starts_with?('vpn-user')
    self.site = 'http://localhost/thl/kmaps/'
  elsif hostname =~ /sds.+\.itc\.virginia\.edu/
    self.site = 'http://127.0.0.1/'
    headers['Host'] = 'subjects.thlib.org'
  else
    self.site = 'http://tmb.thlib.org/'
  end
  self.timeout = 100
  self.format = :xml
end