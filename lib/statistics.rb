module Statistics
  def percentiles(values, min_percentile, max_percentile)
    values.extend(DescriptiveStatistics)
    { max: values.percentile(max_percentile), min: values.percentile(min_percentile) }
  end
end
