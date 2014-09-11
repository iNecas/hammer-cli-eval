module HammerCLIEval

  class Context

    def initialize(hammer)
      @hammer = hammer
    end

    class AppConfig < ApipieBindings::Model::AppConfig
      def initialize
        super(HammerCLI::Connection.get("foreman").api, "Foreman")
      end

      module ScopedSearchResourceConfig
        def search_options(conditions)
          query = conditions.map do |(key, value)|
            "#{key} = \"#{value}\""
          end.join(' AND ')
          { :search => query }
        end
      end

      class DefaultConfig < ApipieBindings::Model::ResourceConfig
        @resource_configs ||= []

        def self.resource_configs
          @resource_configs + [DefaultConfig]
        end

        def self.inherited(klass)
          @resource_configs << klass
        end

        def sub_resources(data)
          api.resources.find_all do |resource|
            index_action = resource.action(:index)
            index_action && index_action.all_params.any? { |p| p.name == primary_id }
          end.map { |resource| sub_resource(resource) }
        end

        def detect_response_resource(action, params, response)
          if %w[result state label progress].all? { |key| response.key?(key) }
            # TODO: extract to foreman-tasks-cli after the resource config
            # is part of the api bindings (not just the model part)
            api.resource(:foreman_tasks)
          else
            super
          end
        end
      end

      class ForemanTasksConfig < DefaultConfig
        def confines?
          resource_name == :foreman_tasks
        end

        # @api_override
        # @return [Hash<Symbol,Proc>] names and procs to define custom methods on
        #   the resource
        def custom_methods
          { :wait => lambda do |task, _|
              HammerCLIForemanTasks::TaskProgress.new(task.id) { |id| task.reload.to_hash }.tap do |task_progress|
                task_progress.render
              end
              task
            end,
            :ready? => lambda do |task, _|
              task.state == 'stopped'
            end }
        end

      end

      class OrganizationsConfig < DefaultConfig
        include ScopedSearchResourceConfig

        def confines?
          resource_name == :organizations
        end
      end

      class ProductsConfig < DefaultConfig
        def confines?
          resource_name == :products
        end

        def unique_keys
          [%w[id],
           %w[organization_id name],
           %w[organization_id label]]
        end
      end

      class RepositoriesConfig < DefaultConfig
        def confines?
          resource_name == :repositories
        end

        def unique_keys
          [%w[id],
           %w[organization_id product_id name],
           %w[organization_id product_id label]]
        end
      end

      class RootConfig < DefaultConfig
        def confines?
          resource_name.nil?
        end

        def sub_resources(data)
          api.resources.map { |resource| sub_resource(resource) }
        end
      end

      # @api override
      def resource_config_classes
         DefaultConfig.resource_configs
      end
    end

    def foreman
      @foreman ||= AppConfig.new.app
    end

    def pry
      require 'pry'
      binding.pry
    end
  end
end
