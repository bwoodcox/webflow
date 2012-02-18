require "webflow/version"

# Load the basic stuff
require 'webflow/exceptions'
require 'webflow/base'
require 'webflow/session_handler'
require 'webflow/state'
require 'webflow/event'
require 'webflow/random_generator'
require 'webflow/flow_step'
require 'webflow/action_step'
require 'webflow/view_step'
#require 'webflow/plugin'

module WebFlow
  # Reserve the render user event for the Base class.
  WebFlow::Base.reserve_event :render
end
