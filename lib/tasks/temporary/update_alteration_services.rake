task update_alteration_services: :environment do
  require 'csv'

  service_ids = [
    36, 39, 40, 41, 45, 46, 47, 50, 53, 54, 60, 65, 68, 71,
    73, 82, 86, 87, 91, 95, 96, 100, 101, 133, 155, 173, 175,
    188, 198, 203, 210, 213, 215, 226, 234, 253
  ]
  tailor_ids = [11, 12]

  AlterationService.where(id: service_ids).destroy_all
  AlterationServiceTailor.where(alteration_tailor_id: tailor_ids).destroy_all
  AlterationSummaryLineItem.where(alteration_tailor_id: tailor_ids).destroy_all
  AlterationTailor.where(id: tailor_ids).destroy_all

  CSV.foreach("#{Rails.root}/tmp/alteration_services.csv", :headers => true) do |row|
    nacho_id          = AlterationTailor.find_by(name: row.headers[4]).id
    uk_tailors_id     = AlterationTailor.find_by(name: row.headers[5]).id
    bond_street_id    = AlterationTailor.find_by(name: row.headers[6]).id
    koh_id            = AlterationTailor.find_by(name: row.headers[7]).id
    quick_id          = AlterationTailor.find_by(name: row.headers[8]).id
    andrea_id         = AlterationTailor.find_by(name: row.headers[9]).id

    nacho_price       = row['Nacho']
    uk_tailors_price  = row['UK Tailors']
    bons_streed_price = row['Bond Street Tailors']
    koh_price         = row['Koh & Koh']
    quick_price       = row['Quick A Tailoring']
    andrea_price      = row['Andrea']

    service = AlterationService.find_or_initialize_by(id: row['id'])

    service.update(category_id: row['category_id'], name: row['name'], order: row['order'])
    service.alteration_service_tailors.find_or_initialize_by(alteration_tailor_id: nacho_id).update(price: nacho_price)
    service.alteration_service_tailors.find_or_initialize_by(alteration_tailor_id: uk_tailors_id).update(price: uk_tailors_price)
    service.alteration_service_tailors.find_or_initialize_by(alteration_tailor_id: bond_street_id).update(price: bons_streed_price)
    service.alteration_service_tailors.find_or_initialize_by(alteration_tailor_id: koh_id).update(price: koh_price)
    service.alteration_service_tailors.find_or_initialize_by(alteration_tailor_id: quick_id).update(price: quick_price)
    service.alteration_service_tailors.find_or_initialize_by(alteration_tailor_id: andrea_id).update(price: andrea_price)
  end

  puts 'Updated alteration services'
end
