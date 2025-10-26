# frozen_string_literal: true

# config/importmap.rb

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'modal', to: 'modal.js'
pin "posts", to: "posts.js"
pin "post_form", to: "post_form.js"
