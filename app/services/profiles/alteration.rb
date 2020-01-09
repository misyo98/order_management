# frozen_string_literal: true

module Profiles
  class Alteration
    REMAKE_REQUESTED = 'Remake requested'
    REMAKE = :remake
    ALTERATION = :alteration

    def self.perform(*attrs)
      new(*attrs).perform
    end

    def initialize(params, profile_params, user, summary, update: false)
      @violated_validation = JSON.parse(params[:violate_validations_hash]).present? if params[:violate_validations_hash]
      @params = params
      @user = user
      @profile = Profile.find_or_initialize_by(customer_id: params[:customer_id])
      @profile_params = resolve_profile_params(profile_params, params[:save_without_changes])
      @alteration_summary = resolve_alteration_summary(summary)
      @update = update
    end

    def perform
      assign_alteration_summary

      if profile.update(profile_params)
        update_profile_category_statuses
        save_alteration_infos

        if line_item_ids.present?
          trigger_item_alter_state
          set_related_item_fields
        end

        send_emails
        save_images
      end
      { profile: profile, summary: alteration_summary }
    end

    def alteration_request_type
      if params[:requested_action] == REMAKE_REQUESTED
        REMAKE
      else
        ALTERATION
      end
    end

    private

    attr_reader :params, :user, :alteration_summary, :profile, :profile_params, :update, :violated_validation

    def resolve_alteration_summary(summary)
      return summary if summary.present?

      AlterationSummaries::CRUD.new(
        params: params[:alteration_summary].merge!({
          profile_id: profile.id,
          request_type: alteration_request_type,
          line_item_ids: line_item_ids,
          alteration_images: params[:alteration_images],
          violates_validation: violated_validation
        })
      ).create
    end

    def assign_alteration_summary
      profile_params[:measurements_attributes].each do |index, measurement|
        next unless measurement[:alterations_attributes]

        measurement[:alterations_attributes].each do |index, alteration|
          alteration.merge!(alteration_summary_id: alteration_summary.id)

          unless update || alteration[:category_id].to_i.in?(altered_category_ids)
            measurement[:alterations_attributes].delete(index)
          end
        end
      end
    end

    def line_item_ids
      @line_item_ids ||= params[:line_item_ids]&.split(' ')
    end

    def save_alteration_infos
      AlterationInfos::CRUD.new(
        params: params.merge!(alteration_summary_id: alteration_summary.id),
        altered_category_ids: altered_category_ids
      ).create
    end

    def update_profile_category_statuses
      ProfileCategories::CRUD.new(
        profile_id: profile.id,
        profile_categories: params[:profile_categories],
        user_id: user.id
      ).update_states
    end

    def trigger_item_alter_state
      event = params[:requested_action].parameterize.underscore

      line_item_ids.each do |id|
        if event == 'remake_requested'
          LineItems::TriggerRemake.(
            id,
            altered_category_names,
            user.id
          )
        else
          LineItems::TriggerState.({
            id: id,
            state_event: event,
            user_id: user.id
          })
        end
      end
    end

    def set_related_item_fields
      line_item_ids.each do |id|
        LineItems::CRUD.new(params: { id: id })
          .set_alteration_fields(
            completion_date: alteration_summary.requested_completion,
            urgent: alteration_summary.urgent,
            delivery_method: alteration_summary.delivery_method,
            non_altered_items: alteration_summary.non_altered_items
          )
      end
    end

    def save_images
      return if params[:images_attributes].blank?

      params[:images_attributes][:image].each do |image|
        profile.images.create!(image: image)
      end
    end

    def altered_category_names
      @altered_category_names ||= params[:selected_categories].split(', ')
    end

    def altered_category_ids
      @altered_category_ids ||= Category.where(name: altered_category_names).ids
    end

    def send_emails
      SendAlterationEmail.perform_async(profile.customer.id, user.id)

      if violated_validation
        send_violation_emails_to_selected if users_for_violation_emails
        send_regular_emails_to_selected if users_for_regular_emails
      else
        send_regular_emails
      end
    end

    def matching_country?
      users_for_violation_emails.detect { |user| user.country == profile.customer.billing&.country }&.present?
    end

    def send_violation_emails_to_selected
      SendAlterationViolationsEmail.perform_async(
        profile.customer.id,
        user.id,
        params[:violate_validations_hash],
        users_for_violation_emails.map(&:id)
      )
    end

    def send_regular_emails_to_selected
      maybe_users_filtered_by_country =
        matching_country? ? users_for_regular_emails.where(country: profile.customer.billing&.country).map(&:id) : users_for_regular_emails.map(&:id)

      SendNonDuplicateAlterationEmail.perform_async(
        profile.customer.id,
        user.id,
        maybe_users_filtered_by_country
      )
    end

    def send_regular_emails
      SendAlterationEmailToStaff.perform_async(
        profile.customer.id,
        user.id
      )
    end

    def users_for_violation_emails
      @users_for_violation_emails ||= User.available_for_violation_emails
    end

    def users_for_regular_emails
      @users_for_regular_emails ||= User.available_for_regular_emails.where.not(id: users_for_violation_emails.map(&:id))
    end

    def resolve_profile_params(profile_params, save_without_changes)
      if save_without_changes
        profile_params[:measurements_attributes].each do |index, measurement|
          next unless measurement[:alterations_attributes]

          if measurement[:post_alter_garment] && measurement[:post_alter_garment].to_f == 0
            measurement[:post_alter_garment] = measurement[:final_garment]
          elsif measurement[:post_alter_garment] && measurement[:post_alter_garment].to_f != 0
            measurement[:post_alter_garment] =
              (measurement[:post_alter_garment].to_f - measurement[:alterations_attributes].values.first[:value].to_f)
                .round(2)
          end
        end

        profile_params
      else
        profile_params
      end
    end
  end
end
