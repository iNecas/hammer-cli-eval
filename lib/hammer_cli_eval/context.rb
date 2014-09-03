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
      end

      class OrganizationsConfig < DefaultConfig
        include ScopedSearchResourceConfig

        def confines?
          resource_name == :organizations
        end

        def sub_resources(data)
          [sub_resource(:products, { 'organization_id' => data['id'] })]
        end
      end

      class ProductsConfig < DefaultConfig
        def confines?
          resource_name == :products
        end

        def sub_resources(data)
          [sub_resource(:repositories,
                        { 'organization_id' => data['organization_id'],
                          'product_id'      => data['id']})]
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
          [sub_resource(:organizations),
           sub_resource(:hosts)]
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
