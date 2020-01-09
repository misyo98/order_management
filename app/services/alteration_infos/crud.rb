module AlterationInfos
  class CRUD

    def initialize(params: {}, altered_category_ids: [])
      @params = params
      @alteration_infos     = params.fetch :alteration_infos, {}
      @altered_category_ids = altered_category_ids
      @info_objects         = []
    end

    def create
      perform
    end

    private

    attr_reader   :alteration_infos, :altered_category_ids, :params
    attr_accessor :info_objects

    def perform
      alteration_infos.each do |index, param_hash|
        info_objects << AlterationInfo.new(
          id:                     param_hash[:id],
          profile_id:             param_hash[:profile_id],
          category_id:            param_hash[:category_id],
          author_id:              param_hash[:author_id],
          alteration_summary_id:  params[:alteration_summary_id],
          manufacturer_code:      param_hash[:manufacturer_code],
          comment:                resolve_comment(param_hash[:comment]),
          lapel_flaring:          param_hash[:lapel_flaring],
          shoulder_fix:           param_hash[:shoulder_fix],
          move_button:            param_hash[:move_button],
          square_back_neck:       param_hash[:square_back_neck],
          armhole:                param_hash[:armhole]
          )
      end
      save if submitted?
    end

    def reject_unaltered_infos
      info_objects.reject! { |info| !info.category_id.in? altered_category_ids }
    end

    def submitted?
      return false unless info_objects.any?
      object = info_objects.first
      !object.profile.categories.find_by(category_id: object.category_id)&.unsubmitted_status?
    end

    def save
      AlterationInfo.import info_objects, on_duplicate_key_update: [:manufacturer_code, :comment, :lapel_flaring, :shoulder_fix,
        :move_button, :square_back_neck, :armhole]
    end

    private

    def resolve_comment(comment)
      if params[:save_without_changes]
        comment + ' - Saved without changes to final profile.'
      else
        comment
      end
    end
  end
end
