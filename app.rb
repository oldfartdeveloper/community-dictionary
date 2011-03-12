$:.unshift File.dirname(__FILE__) + "/lib/"

require "init"

module Glossary
  class API < Grape::API
    version '1'
    
    helpers do
      def find_error!(klass_name)
        error!("Unable to locate #{klass_name}", 404)
      end
    end

    resources :terms do
      get '/:term/definitions' do
        term = Term.find(:term => params[:term]).first || find_error!("term")
        term.definitions.all
      end
      
      post '/:term/definitions' do
        term = Term.find(:term => params[:term]).first || find_error!("term")
        definition = Definition.create(:blurb => params[:blurb], :detail => params[:detail])
        term.add_definition(definition)
        definition
      end

      get '/:term' do
        Term.find(:term => params[:term]).first || find_error!("term")
      end
      
      get '/' do
        Term.all.all
      end

      post '/' do
        Term.create(:term => params[:term])
      end
    end

    resources :definitions do
      get '/:id' do
        Definition[params[:id]] || find_error!("definition")
      end
    end
    
    resources :users do
      get '/' do
        User.all.all
      end
      
      get '/:id' do
        User[params[:id]] || find_error!("user")
      end
      
      post '/' do
        User.create(:name => params[:name], :email => params[:email])
      end
      
      put '/:id' do
        user = User[params[:id]] || find_error!("user")
        user.name = params[:name] if params[:name]
        user.email = params[:email] if params[:email]
        user.save
      end
      
      delete '/:id' do
        user = User[params[:id]] || find_error!("user")
        user.delete
      end
    end
    
    resources :votes do
      put "/definitions/:definition_id/user/:user_id" do
        # TODO move this to model and catch exception
        if User[params[:user_id]] && Definition[params[:definition_id]] 
          Vote.create_or_update(:value => params[:value], :user_id => params[:user_id],
                                :definition_id => params[:definition_id])
        end
      end
    end
  end  
end
