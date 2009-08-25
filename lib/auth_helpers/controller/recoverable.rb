module AuthHelpers
  module Controller
    class Recoverable < ::ApplicationController
      unloadable

      include ::InheritedResources::BaseHelpers
      include ::AuthHelpers::Controller::Helpers

      class << self
        alias :has_recoverable :set_class_accessors_with_class
      end

      # GET /account/password/new
      def new(&block)
        object = get_or_set_with_send(:new)
        respond_with(object, &block)
      end
      alias :new! :new

      # POST /account/password
      # POST /account/password.xml
      def create(options={}, &block)
        object = get_or_set_with_send(:find_and_send_reset_password_instructions, params[self.instance_name])

        if object.errors.empty?
          set_flash_message!(:notice, 'We sent instruction to reset your password, please check your inbox.')
          respond_with_scoped_redirect(object, options, true, block)
        else
          set_flash_message!(:error)
          respond_with_dual_blocks(object, options, false, block)
        end
      end
      alias :create! :create

      # GET /account/password/edit?account[perishable_token]=xxxx
      def edit(&block)
        object = get_or_set_with_send(:new)
        object.perishable_token = params[self.instance_name].try(:fetch, :perishable_token)
        respond_with(object, &block)
      end
      alias :edit! :edit

      # PUT /account/password
      # PUT /account/password.xml
      def update(options={}, &block)
        object = get_or_set_with_send(:find_and_reset_password, params[self.instance_name])

        if object.errors.empty?
          set_flash_message!(:notice, 'Your password was successfully reset.')
          respond_with_scoped_redirect(object, options, true, block)
        else
          set_flash_message!(:error)
          respond_with_dual_blocks(object, options, false, block)
        end
      end
      alias :update! :update

      protected :new!, :create!, :edit!, :update!
    end
  endend

