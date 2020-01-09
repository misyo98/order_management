task remove_old_alteration_services: :environment do
  service_ids = [
    200, 192, 202, 199, 197, 196, 195, 194, 193, 191, 156, 154, 152, 151, 149, 158, 159, 153, 164,
    163, 162, 160, 147, 241, 240, 239, 238, 237, 236, 235, 242, 243, 244, 256, 255, 252, 251, 249,
    247, 246, 233, 232, 214, 212, 211, 209, 207, 216, 221, 231, 229, 228, 225, 224, 223, 222, 205,
    146, 85, 145, 143, 141, 140, 138, 135, 134, 88, 75, 77, 78, 37, 42, 43, 48
  ]
  tailor_ids = [6, 7]

  AlterationService.where(id: service_ids).destroy_all
  AlterationServiceTailor.where(price: 0).update_all(price: nil)
  AlterationSummaryLineItem.where(alteration_tailor_id: tailor_ids).destroy_all
  AlterationTailor.where(id: tailor_ids).destroy_all

  puts 'removed old alteration services and alteration tailors'
end
