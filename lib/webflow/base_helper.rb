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

# This module adds helper methods to WebFlow controllers. See each method
# for a complete description of their function.

require "webflow/base"

module WebFlow
  module BaseHelper


    # Creates a submit button to send the parent form to an WebFlow controller.
    # The options array takes the same values as the standard Rails submit_tag.
    #def flow_submit_tag(value="Submit", event_name='', options={})
    #
    #  # Convert keys to strings
    #  options.stringify_keys!
    #
    #  # We can't use the disable_with option since disabling the button will
    #  # prevent some browsers from sending the submit button name along
    #  # with the form data. We need this button to send the event name.
    #  options.delete("disable_with")
    #
    #  # Generate the tag
    #  tag :input, {"type" => "submit",
    #               "name" => "#{WebFlow::Base.event_input_name_prefix}#{WebFlow::Base.event_prefix}#{event_name}",
    #               "value" => value}.update(options.stringify_keys)
    #
    #end


    # Creates a link to send an event to an WebFlow controller.
    # The method takes all the standard Rails link_to parameters
    # but needs one more : the event name to return.
    #def flow_link_to(name, event_name='', options = {}, html_options = nil, *parameters_for_method_reference)
    #
    #  # Delete the action and controller definition
    #  options.delete :action
    #  options.delete :controller
    #
    #  # Specify the 'index' action
    #  options[:action] = :index
    #
    #  # Add the flow key to the url
    #  options[WebFlow::Base.flow_execution_key_id] = @flow_id
    #
    #  # Add the event name
    #  options[WebFlow::Base.event_input_name_prefix + WebFlow::Base.event_prefix + event_name.to_s] = WebFlow::Base.event_prefix + event_name.to_s
    #
    #  # Call the standard link_to helper
    #  link_to name, options, html_options, *parameters_for_method_reference
    #
    #end


    # Creates a form tag to send data to the WebFlow controller.
    # Takes the same parameters as Rail's form_tag, but adds the flow
    # exec key hidden input. You can either declare it as a returning
    # function :
    #
    #  <%= flow_form_tag %>
    #
    # or give it a block :
    #
    #  <% flow_form_tag do |form| %>
    #
    # See end_flow_form_tag to close the first use case.
    #def flow_form_tag(options={}, &block)
    #
    #  # Init the HTML subhash if required
    #  options[:html] ||= {}
    #
    #  # Remove the action html parameter
    #  options[:html].delete(:action)
    #
    #  # There are two use cases.
    #  #
    #  # 1. The user has passed a block
    #  #      We have to extend the block to add our controls
    #  #
    #  # 2. The user hasn't passed a block
    #  #      We add our inputs at the end of the returned string
    #  #
    #  if block_given?
    #
    #    # Okay, here's the strategy. We create a 'file' variable which calls all
    #    # necessary methods. Then, we tell Rails to evaluate all this while binding
    #    # the correct Ruby context to the new block.
    #    # Thanks a million to Guy Nador at http://devblog.famundo.com/articles/2007/03/28/lost-in-binding-adventures-in-ruby-metaprogramming
    #    # for this hack.
    #
    #    @res = <<-EOF
    #
    #    #{form_tag(url_for(:action => 'index'), options[:html])}
    #
    #
    #    #{capture(&block)}
    #
    #
    #    #{tag('input', {:type => :hidden, :name => WebFlow::Base.flow_execution_key_id, :value => @flow_id})}
    #
    #    #{end_form_tag}
    #
    #    EOF
    #
    #
    #    # Finally, launch execution.
    #    eval '_erbout.concat @res', block
    #
    #
    #  else
    #
    #    # Looks like the user didn't pass a block, it's more simple like that.
    #    # We just concatenate our stuff at the end of the form_tag call
    #    result = form_tag(url_for(:action => 'index'), options[:html])
    #
    #    # Add the flow key input
    #    result << tag('input', {:type => :hidden, :name => WebFlow::Base.flow_execution_key_id, :value => @flow_id})
    #
    #    # Add the event input
    #    #result << tag( 'input', { :type => :hidden, :name => WebFlow::Base.event_input_name, :id => WebFlow::Base.event_input_name, :value => '' } )
    #
    #    return result
    #
    #  end
    #
    #
    #end


    # Allows the WebFlow framework to use AJAX form submission.
    # Takes all the same parameters as the standard Rails form_remote_tag
    # but alters the options hash to force the 'index' action to be called.
    #def flow_form_remote_tag(options = {}, &block)
    #
    #  # I don't know why to do this, they do it in form_remote_tag
    #  # and there's no documentation nor comments available... nice going.
    #  options[:form] = true
    #
    #  # Init the options hash
    #  options[:html] ||= {}
    #  options[:url] ||= {}
    #
    #  # Alter the options to change the destination url so that it points to
    #  # the index action
    #  options[:url][:action] = :index
    #  options[:action] = :index
    #
    #  # Alter the onsubmit event to create an ajax form
    #  options[:html][:onsubmit] =
    #      (options[:html][:onsubmit] ? options[:html][:onsubmit] + "; " : "") +
    #          "#{remote_function(options)}; return false;"
    #
    #  # Call the standard flow_form_tag to do it's job
    #  flow_form_tag(options, &block)
    #
    #end


    # Helper method to generate a hidden <tt>input</tt> tag for the flow execution key.
    #
    # @returns <tt>input</tt> tag with type hidden
    #
    def flow_key_tag
      hidden_field_tag WebFlow::Base.flow_exec_key, @flow_id
    end


    # TODO: Need to refactor this to get hidden tag to render inside form tag
    def flow_form_tag(url_for_options = {}, options = {}, &block)
      content =
          if block_given?
            form_tag url_for_options, options, &block
          else
            form_tag url_for_options, options
          end

      content << hidden_field_tag(WebFlow::Base.flow_exec_key, @flow_id)

      content
    end


    # Helper method to generate a button element.  This is a wrapper method for the Rails button_tag method.
    # It adds a data-remote attribute, if specified, to enable an UJS ajax submission.
    #
    # @param content_or_options
    # @param options
    # @param block
    #
    # @returns <tt>button</tt> tag
    #
    def flow_button_tag(content_or_options = nil, options = nil, &block)
      options = content_or_options if block_given? && content_or_options.is_a?(Hash)
      options ||= {}
      options.stringify_keys!

      if remote = options.delete("remote")
        options["data-remote"] = remote
      end

      if event = options.delete("event")
        options["name"] = WebFlow::Base.event_input_name_prefix + WebFlow::Base.event_prefix + event.to_s
        options["id"] = options["name"]
        options["value"] = WebFlow::Base.event_prefix + event.to_s
      end

      button_tag content_or_options, options, &block
    end


    # Helper method to generate an HTML anchor element.  This method is a wrapper for the Rails link_to method.
    #
    # @param args options, event_name, html_options
    # @param block optional block
    #
    # @returns <tt>a</tt> tag for submitting flow request
    #
    def flow_link_to(*args, &block)
      if block_given?
        options = args.first || {}
        event_name = args.second
        html_options = args.third
        flow_link_to(capture(&block), event_name, options, html_options)
      else
        name = args[0]
        event_name = args[1]
        options = args[2] || {}
        html_options = args[3]

        html_options[:method] = 'GET'
        link_to name, append_flow_params(options, event_name), html_options
      end
    end

    # Alias for Rails standard end_form_tag
    def end_flow_form_tag
      end_form_tag
    end

    #
    def get_flow_data(key)
      controller.current_flow_user_data[key]
    end


    private

    # Adds required flow params to the generated url
    #
    # @param options Either a Hash, containing appropriate values for creating a url_for, or a String containing a url.
    # @param event_name Name of the flow event to forward the request.
    #
    # @returns options, which can be a Hash or String depending on the passed parameter
    #
    def append_flow_params(options, event_name)
      case options
        when Hash
          options[:url][WebFlow::Base.flow_exec_key] = @flow_id
          options[:url][WebFlow::Base.event_input_name_prefix + WebFlow::Base.event_prefix + event_name.to_s] = WebFlow::Base.event_prefix + event_name.to_s

        when String
          options << (options.index("?").nil? ? "?" : "&")
          options << "#{WebFlow::Base.flow_exec_key}=#{@flow_id}&"
          options << "#{WebFlow::Base.event_input_name_prefix + WebFlow::Base.event_prefix + event_name.to_s}=#{WebFlow::Base.event_prefix + event_name.to_s}"
      end

      options
    end

    # Allows the WebFlow framework to use AJAX form submission.
    # Takes all the same parameters as the standard Rails form_remote_tag, but adds
    # the event name and flow id to the URL to return to the WebFlow controller.
    # The URL is also overridden to point to the 'index' action.
    #def flow_link_to_remote(name, event, options = {}, html_options = {})
    #
    #  # Alter the options to change the destination url so that it points to
    #  # the index action
    #  options[:url] ||= {}
    #  options[:url][:action] = :index
    #  options[:action] = :index
    #
    #  # Add the flow key to the url
    #  options[:url][WebFlow::Base.flow_execution_key_id] = @flow_id
    #
    #  # Add the event name
    #  options[:url][WebFlow::Base.event_input_name_prefix + WebFlow::Base.event_prefix + event.to_s] = WebFlow::Base.event_prefix + event.to_s
    #
    #  # Call the standard ajax link creation method
    #  link_to_function(name, remote_function(options), html_options)
    #
    #end

  end

end
