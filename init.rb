# frozen_string_literal: false

folders = %w[lib]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
