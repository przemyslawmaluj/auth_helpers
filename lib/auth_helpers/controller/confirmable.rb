module AuthHelpers
  module Controller
    class Confirmable < ::ApplicationController
      unloadable

      include ::InheritedResources::BaseHelpers
      include ::AuthHelpers::Controller::Helpers

      class << self
        alias :has_confirmable :set_class_accessors_with_class
      end

      # GET /account/confirmation/new
      def new(&block)
        object = get_or_set_with_send(:new)
        respond_with(object, &block)
      end
      alias :new! :new

      # POST /account/confirmation
      # POST /account/confirmation.xml
      def create(options={}, &block)
        object = get_or_set_with_send(:find_and_resend_confirmation_instructions, params[self.instance_name])

        if object.errors.empty?
          set_flash_message!(:notice, 'We sent confirmation instructions to your email, please check your inbox.')
          respond_with_scoped_redirect(object, options, true, block)
        else
          set_flash_message!(:error)
          respond_with_dual_blocks(object, options, false, block)
        end
      end
      alias :create! :create

      # GET /account/confirmation?account[perishable_token]=xxxx
      # POST /account/confirmation.xml?account[perishable_token]=xxxx
      def show(options={}, &block)
        object = get_or_set_with_send(:find_and_confirm, params[self.instance_name])

        if object.errors.empty?
          set_flash_message!(:notice, '{{resource_name}} was successfully confirmed.')
          respond_with_scoped_redirect(object, options, true, block)
        else
          set_flash_message!(:error, object.errors.on(:perishable_token))
          respond_with_dual_blocks(object, options, false, block) do |format|
            format.html { render :action => "new" }
          end
        end
      end
      alias :show! :show

      protected :show!, :new!, :create!
    end
  end
end
