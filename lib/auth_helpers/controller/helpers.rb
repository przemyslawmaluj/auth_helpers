module AuthHelpers
  module Controller
    module Helpers

      def self.included(base)
        base.extend ClassMethods
        base.respond_to :html
      end

      module ClassMethods
        protected

          # Writes the inherited hook for the included class based on its name.
          #
          def inherited(base) #:nodoc:
            super

            base.send :cattr_accessor, :resource_class, :instance_name, :route_name, :instance_writter => false

            # Converts:
            #
            #   Mockable::ConfirmationsController #=> mockable
            #   MockablePasswordsController       #=> mockable
            #
            resource = base.controller_path.gsub('/', '_').split('_')[0..-2].join('_')

            begin
              base.resource_class = resource.classify.constantize
              base.route_name     = resource.singularize
              base.instance_name  = resource.singularize
            rescue NameError
              nil
            end
          end

          def set_class_accessors_with_class(klass)
            self.resource_class = klass
            self.instance_name  = klass.name.downcase
            self.route_name     = klass.name.downcase
          end
      end

      protected

        # Try to call a url using resource object and the scope, for example:
        #
        #   new_account_session_url
        #   new_account_password_url
        #
        def url_by_name_and_scope(scope) #:nodoc:
          send("new_#{self.route_name}_#{scope}_url")
        end

        # Try to get the instance variable, otherwise send the args given to
        # the resource class and store the result in the same instance variable.
        #
        def get_or_set_with_send(*args) #:nodoc:
          instance_variable_get("@#{self.instance_name}") || instance_variable_set("@#{self.instance_name}", resource_class.send(*args))
        end

        # Wraps around dual blocks with default behavior for html.
        #
        def respond_with_scoped_redirect(object, options, success, block)
          respond_with_dual_blocks(object, options, success, block) do |format|
            format.html { redirect_to(options[:location] || url_by_name_and_scope(:session)) }
          end
        end

    end
  end
end

