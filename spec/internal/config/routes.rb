# frozen_string_literal: true

Rails.application.routes.draw do
  get 'prismic', to: 'pages#prismic'
  get 'contentful', to: 'pages#contentful'
end
