context.instance_eval  do  
  tr do
    td category_param.category.visible ? category_param.category_name : ''
    td class: 'measurement-td' do 
      category_param.param_title
    end
  end
end