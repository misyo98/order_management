ActiveAdmin.register FabricManager do
  decorate_with FabricManagerDecorator

  menu false

  permit_params :id, :manufacturer_fabric_code, :status, :estimated_restock_date

  controller do
    respond_to :html, :json, :js

    def create
      authorize! :index, FabricManager

      @fabric_manager = FabricManagers::CreateFabricManager.(permitted_params[:fabric_manager])

      FabricNotification.create(
        manufacturer_fabric_code: @fabric_manager.manufacturer_fabric_code, fabric_code: @fabric_manager.fabric_infos.last&.fabric_code,
        fabric_book_title: @fabric_manager.fabric_book&.title, fabric_brand_title: @fabric_manager.fabric_brand&.title, event: :added
      )

      @q = FabricManager.includes(:fabric_infos, :fabric_brand, :fabric_book).ransack(params[:q])
      @fabric_managers = @q.result
    end

    def update
      authorize! :index, FabricManager

      @fabric_manager = FabricManager.find(params[:id])

      respond_to do |format|
        if @fabric_manager.update_attributes(permitted_params[:fabric_manager])
          FabricNotification.create(
            manufacturer_fabric_code: @fabric_manager.manufacturer_fabric_code, fabric_code: @fabric_manager.fabric_infos.last&.fabric_code,
            fabric_book_title: @fabric_manager.fabric_book&.title, fabric_brand_title: @fabric_manager.fabric_brand&.title, event: :updated
          )

          format.html { redirect_to @fabric_manager, notice: 'Successfully updated.' }
          format.json { respond_with_bip(@fabric_manager) }
        else
          format.html { render :edit }
          format.json { respond_with_bip(@fabric_manager) }
        end
      end
    end

    def destroy
      authorize! :index, FabricManager

      fabric_manager = FabricManager.find(params[:id])

      FabricNotification.create(
        manufacturer_fabric_code: fabric_manager.manufacturer_fabric_code, fabric_code: fabric_manager.fabric_infos.last&.fabric_code,
        fabric_book_title: fabric_manager.fabric_book&.title, fabric_brand_title: fabric_manager.fabric_brand&.title, event: :removed
      )

      fabric_manager.destroy

      @q = FabricManager.includes(:fabric_infos, :fabric_brand, :fabric_book).ransack(params[:q])
      @fabric_managers = @q.result
    end

    def fabric_management
      authorize! :index, FabricManager

      @page_title = 'Fabrics OOS/Discontinued'
      @q = FabricManager.includes(:fabric_infos, :fabric_brand, :fabric_book).ransack(params[:q])
      @fabric_managers = @q.result
    end
  end
end
