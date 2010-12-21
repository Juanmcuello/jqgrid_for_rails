# JqgridForRails

require 'jqgrid_for_rails/core_ext'
require 'jqgrid_for_rails/controllers/helpers'

ActionController::Base.send :include, JqgridForRails::Controllers::Helpers

%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.autoload_paths << path
  ActiveSupport::Dependencies.autoload_once_paths.delete(path)
end
