#!/usr/bin/env ruby
require 'sinatra'
require 'net/http'
require 'json'
require 'resolv'

set :bind, '0.0.0.0'
set :port, 80

# The main web page.
get '/' do
  redirect '/index.html'
end

# The URI to do the stock symbol lookup.
# Returns a JSON document with stock name and price.
get '/stock/:symbol' do
  lookup_stock(params['symbol'])
end

# The URI for the health check
get '/health' do
  "OK"
end

# The function to lookup stock price for a particular symbol.
# Looks up the 'stock-price' microservice and returns JSON doc
def lookup_stock(stock)
  address, port = lookup_service('stocks')
  uri = URI.parse(URI.encode("http://#{address}:#{port}/stock/#{stock}"))
  res = Net::HTTP.get_response(uri)
  res.body if res.is_a?(Net::HTTPSuccess)
end

# Function to return an IP address and port number for a given service name
# Assumes Consul agent is running locally and acting as the default DNS resolver
def lookup_service(service_name)
  service_name = service_name + ".apps.gureu.me"
  resolver = Resolv::DNS.open
  record = resolver.getresource(service_name, Resolv::DNS::Resource::IN::A)
  #return resolver.getaddress(record.target), record.port
  return service_name, 80
end
