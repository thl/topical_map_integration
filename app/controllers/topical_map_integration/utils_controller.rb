class TopicalMapIntegration::UtilsController < ApplicationController
  
  def proxy
    
    # We want to grab params that are part of the requested URL, but ignore ones that are supplied by Rails
    ignored_params = ["proxy_url", "action", "controller"]
    url_params = params.reject{|param, val| ignored_params.include?(param) }.collect{ |param, val| param + '=' + CGI.escape(val) }.join('&')
    
    url = params[:proxy_url]
    url += '&' + url_params unless url_params.blank?
    
    # Parse the URL with URI.parse() so we can work with its parts more easily
    uri = URI.parse(URI.encode(url));
    headers = {}
    
    # Check to see if the request is for a URL on thlib.org or a subdomain; if so, and if
    # this is being run on sds[3-8], make the appropriate changes to headers and uri.host
    
    if [InterfaceUtils::Server::DEVELOPMENT, InterfaceUtils::Server::STAGING, InterfaceUtils::Server::PRODUCTION].include?(InterfaceUtils::Server.environment)
      headers = { 'Host' => uri.host }
      uri.host = '127.0.0.1'
    end
    
    
    # Required for requests without paths (e.g. http://www.google.com)
    uri.path = "/" if uri.path.empty?
    
    path = uri.query.blank? ? uri.path : uri.path + '?' + uri.query 
    request = Net::HTTP::Get.new(path, headers)
    result = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(request)
    }
    
    render :text => result.body
    
  end
  
end