ActiveAdmin.register_page 'State in queue check' do
  menu parent: 'Settings', if: -> { can? :index, LineItemScope }

  content do
    render 'admin/line_item_scope_states/index', context: self
  end


  controller do
    def index
      @states = LineItemsHelper.line_item_scope_states(
        scopes: LineItemScope.select(:label, :states)
      )
    end
  end
end
