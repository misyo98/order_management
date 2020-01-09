class EstimatedCog < ActiveRecord::Base
  CATEGORIES = %w(SUITS SHIRTS CHINOS WAISTCOATS TROUSERS JACKETS OVERCOATS).freeze
  CANVAS_OPTIONS = %w(Full\ Canvas Half\ Canvas Fused\ Canvas).freeze
end
