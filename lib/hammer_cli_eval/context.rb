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

        def extracted_ids(data)
          data.inject({}) do |hash, (k, v)|
            case k
            when 'id'
              hash.update(primary_id => v)
            when /_id$/
              hash.update(k => v)
            else
              hash
            end
          end.reject { |k, v| v.nil? }
        end

        def primary_id
          @primary_id ||= "#{ApipieBindings::Inflector.singularize(resource_name)}_id"
        end

        def sub_resources(data)
          extracted_ids = self.extracted_ids(data)
          api.resources.find_all do |resource|
            index_action = resource.action(:index)
            index_action && index_action.all_params.any? { |p| p.name == primary_id }
          end.map do |resource|
            index_params = resource.action(:index).all_params
            related_ids = extracted_ids.keep_if do |id_name, value|
              index_params.any? { |p| p.name == id_name }
            end
            # TODO: I'm not sure why it doens't work without the dup
            sub_resource(resource.name, related_ids.dup)
          end
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
          api.resources.map { |resource| sub_resource(resource.name) }
        end
      end

      # @api override
      def resource_config_classes
         DefaultConfig.resource_configs
      end
    end

    def foreman
      @foreman ||= ApipieBindings::Model::App.new(AppConfig.new)
    end

    def pry
      require 'pry'
      binding.pry
    end
  end
end
