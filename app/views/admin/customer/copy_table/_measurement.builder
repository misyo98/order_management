context.instance_eval  do 
  tr do
    td measurement.category_field
    td measurement.param_field
    td infos[category_id].present? ? measurement.post_alter_garment_field : measurement.final_garment_field
  end
end
