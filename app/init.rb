# frozen_string_literal: false

folders = %w[application infrastructure presentation]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
