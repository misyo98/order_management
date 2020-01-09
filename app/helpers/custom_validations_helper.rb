module CustomValidationsHelper
  def form_grouped_dropdown_opts(category_param_values, category_params)
    category_param_values.group_by(&:category_param_id).map do |c_p_id, objs|
      param_title = category_params.find { |cp| cp.id == c_p_id }&.param_title
      next unless param_title

      [
        param_title,
        objs.map { |ob| [ob.value_title, ob.id] }
      ]
    end
  end

  def form_grouped_category_params
    category_params = CategoryParam.all
    category_params.group_by(&:category_id).map do |category_id, objs|
      category_title = category_params.find { |cp| cp.category_id == category_id }&.category_name
      next unless category_title

      [
        category_title,
        objs.map { |ob| [ob.param_title, ob.id] }
      ]
    end
  end
end
