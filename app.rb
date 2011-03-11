require "rubygems"
require "bundler/setup"

require "json"
require "grape"
require "redis"
require "ohm"

$:.unshift("models/")
require "definition"
require "term"

module Glossary
  class API < Grape::API
    version '1'
    
    resource :terms do
      get '/:term' do
        term = Term.find(:term => params[:term]).first
        puts term.inspect
        term
      end

      get '/' do
        # Term.all
      end
      
    end
  end  
end
