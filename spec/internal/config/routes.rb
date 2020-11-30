# frozen_string_literal: true

Rails.application.routes.draw do  
  get :hello, controller: :dummy, action: :dummy
end
