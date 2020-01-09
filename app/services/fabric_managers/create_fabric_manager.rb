module FabricManagers
  class CreateFabricManager
    def self.call(*attrs)
      new(*attrs).call
    end

    def initialize(params)
      @params = params
      @fabric_info = FabricInfo.unscoped.where(manufacturer_fabric_code: params[:manufacturer_fabric_code]).last
    end

    def call
      FabricManager.create(resolve_params)
    end

    private

    attr_reader :params, :fabric_info

    def resolve_params
      if fabric_info
        params.merge(fabric_brand_id: fabric_info.fabric_brand_id, fabric_book_id: fabric_info.fabric_book_id)
      else
        params
      end
    end
  end
end
