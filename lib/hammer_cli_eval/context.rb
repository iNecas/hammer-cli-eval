module HammerCLIEval

  class Context

    def initialize(hammer)
      @hammer = hammer
    end

    class AppConfig < ApipieBindings::Model::AppConfig
      def initialize
        super(HammerCLI::Connection.get("foreman").api, "Foreman")
      end

      # TODO: ResoruceConfig

      def sub_resources(resource_name, data)
        case resource_name
        when nil
          [sub_resource(:organizations),
           sub_resource(:hosts)]
        when :organizations
          [sub_resource(:products,
                        { 'organization_id' => data['id'] })]
        when :products
          [sub_resource(:repositories,
                        { 'organization_id' => data['organization_id'],
                          'product_id'      => data['id']})]
        else
          []
        end
      end

      def search_options(resource_name, conditions)
        if scoped_search_resource?(resource_name)
          query = conditions.map do |(key, value)|
            "#{key} = \"#{value}\""
          end.join(' AND ')
          { :search => query }
        else
          super
        end
      end

      def unique_keys(resoruce_name)
        case resoruce_name
        when :products
          [%w[id],
           %w[organization_id name],
           %w[organization_id label]]
        when :repositories
          [%w[id],
           %w[organization_id product_id name],
           %w[organization_id product_id label]]
        else
          super
        end
      end

      private

      def scoped_search_resource?(name)
        [:organizations].include?(name)
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
