#--
# Copyright (c) 2007 The World in General
#
# Released under the Creative Commons Attribution-Share Alike 3.0 License.
# Licence details available at : http://creativecommons.org/licenses/by-sa/3.0/
#
# Created by Luc Boudreau ( lucboudreau at gmail )
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++


# Simply put, this module makes sure that the operations to the state
# registry associated to a user are transparent to the business logic.
#
# Session and it's flow states are all stored inside a session variable
# called ActionFlow::SessionHandler.session_flow_data_prefix followed by
# 32 random characters.
#

ActionFlow::Base.class_eval do

  private

  # Prefix of the variables which will be created in the user session
  # to store the flow data.
  @@session_flow_data_prefix = 'flow_data-'
  cattr_accessor :session_flow_data_prefix

  # Prefix of the variables which will be created in the flow's user session
  # to store the state data.
  @@session_state_data_prefix = 'state_data-'
  cattr_accessor :session_state_data_prefix

  # Name of the variables which will be created in the flow's user session
  # to store the user data.
  @@session_user_data_name = 'user_data'
  cattr_accessor :session_user_data_name

  # Used to detect flow data keys in the session hash
  Session_data_prefix_regex = /^#{session_flow_data_prefix}[0-9]{32}$/

  # Name of the key in the flow hash stored in the session which tells when was
  # this flow last executed
  @@session_timestamp_placeholder = 'updated_at'
  cattr_accessor :session_timestamp_placeholder

  # Defines for how long a flow execution data is maintained in the session
  # placeholder.
  @@session_ttl = 1.hour
  cattr_accessor :session_ttl

  # Defines where to store the name of the last executed step
  @@last_step_placeholder = 'last_step_name'
  cattr_accessor :last_step_placeholder

  # Cleans the flows data for flows which have not been executed since
  # the value defined by Session_ttl and Session_timestamp_placeholder.
  def cleanup

    # Iterate over the real session keys to find flow placeholders
    session.keys.each do |key|

      # Check if the key is a flow placeholder
      if key =~ Session_data_prefix_regex

        # Delete it if the flow has expired
        session.delete(key) if (session[key].fetch(session_timestamp_placeholder) < (Time.now - session_ttl))

      end

    end

  end


  # Saves the current flow state data and makes sure that everything will be available
  # to restore the flow state later on.
  #def serialize
  #
  #  # Update the flow timestamp
  #  update_timestamp
  #
  #  # Copy the current state data
  #  old_state = (state).deep_copy
  #
  #  # Generate a new flow id.
  #  # With old flows, we use the first 8 characters of the last execution id
  #  # but we generate 56 new ones which we append
  #  #
  #  # Fix for bug #10559 added. Collisions are prevented.
  #  continue = true
  #  while continue
  #
  #    # Generate a new state id to test
  #    new_id = ActionFlow::RandomGenerator.random_string(32)
  #
  #    # Test it
  #    continue = current_flow_data.has_key?(new_id)
  #
  #  end
  #
  #  # We can update the flow id
  #  @flow_id = @flow_id[0, 9] + new_id
  #
  #  # Initialize the flow session storage for this execution (state)
  #  init_state_session_space
  #
  #  # Copy the shadow session state into the new state to freeze it
  #  state = old_state.deep_copy
  #
  #  # Return nil
  #  nil
  #
  #end


  #
  # Cleans all data concerning the flow from the session.
  #
  def terminate

    # Destroy the flow placeholder in the session
    session.delete(flow_session_name)

    nil

  end


  # Does everything needed to store data concerning a new flow execution
  def start_new_flow_session_storage

    # With new flows, we define a completely new 32 characters id
    @flow_id = ActionFlow::RandomGenerator.random_string(32)

    # Initialize the flow session storage for the flow itself, since it will
    # then contain all the states
    init_flow_session_space

    # Initialize the flow session state storage for this execution
    init_state_session_space

    # Initialize the flow session user storage for this execution
    init_user_session_space

  end


  # Updates the timestamp for the current flow. Is to be called on each session
  # modification.
  def update_timestamp

    # Update the timestamp for the current flow
    session[flow_session_name].store session_timestamp_placeholder, Time.now

  end


  # Adds the last step name to the current flow data so we can interpret the
  # returned event correctly once the user submits data back.
  def persist_last_step_name(state_name)

    # Store the last step name in the correct placeholder
    current_flow_data.fetch(state_session_name).store(last_step_placeholder, state_name.to_s)

    # Return nil
    nil

  end


  # Adds the last step name to the current flow data so we can interpret the
  # returned event correctly once the user submits data back.
  def fetch_last_step_name

    # Fetch the last step name from the correct placeholder
    current_flow_data.fetch(state_session_name).fetch(last_step_placeholder)

  end


  # Validates that the given flow key corresponds to a stored flow data
  def validate_flow_existence

    !current_flow_data.nil? && !state.nil?

  end


  # Initializes the session variables needed to save the flow data.
  def init_flow_session_space

    # The placeholder for the flow will be named...
    flow_placeholder = flow_session_name

    # Create a new placeholder for this flow data in the real session space
    session[flow_placeholder] = HashWithIndifferentAccess.new

    # Timestamp the creation time
    update_timestamp

    # Return nil
    nil

  end


  # Initializes the session variables needed to save the state data.
  def init_state_session_space

    # Create a new placeholder for this state data in the real session space
    # reserved for this flow data
    current_flow_data.store state_session_name, HashWithIndifferentAccess.new

    # Return nil
    nil

  end


  # Initializes the session variables needed to save the user data.
  def init_user_session_space

    # Create a new placeholder for this user data in the real session space
    # reserved for this flow data
    current_flow_data.store session_user_data_name, HashWithIndifferentAccess.new

    # Return nil
    nil

  end


  # Returns the name of the variable used in the real session data hash
  # to store this flow data
  def flow_session_name
    (session_flow_data_prefix + @flow_id).to_s
  end


  # Returns the name of the variable used in the flow session data hash
  # to store this state data
  def state_session_name
    (session_state_data_prefix + @flow_id).to_s
  end


  # Returns the current flow data hash from within the
  # user session.
  def current_flow_data
    session[flow_session_name]
  end


  # Returns the current flow user data hash from within the user session.
  #
  # @returns current flow user session hash
  #
  def current_flow_user_data
    current_flow_data.fetch session_user_data_name
  end


  # Saves or updates data to the current flow session data hash.
  #
  # @params values hash containing values to be added to the flow user session
  # @params options hash containing options
  #
  # @returns nil
  #
  def store_flow_data(values, options = {})
    update = options[:update] || true

    current_flow_user_data.merge!(values) { |key, val1, val2| update ? val2 : val1 }

    update_timestamp

    nil
  end


  public

  # Returns the current flow user data hash from within the user session.
  #
  # @returns current flow user session hash
  #
  def current_flow_user_data
    current_flow_data.fetch session_user_data_name
  end

end


# Used to add a deep copy mechanism to objects
Object.class_eval do

  # Performs a deep copy of an object and returns a copy of the source and all it's sub objects
  # as copies. Useful for example when a hash contains objects and you want a copy of the Hash
  # and copies of the objects it contains and not the objects themselves
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end

end