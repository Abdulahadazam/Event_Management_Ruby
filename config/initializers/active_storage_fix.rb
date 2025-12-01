# # Fix for Rails 8 + ActiveAdmin inverse_of association error
# Rails.application.config.to_prepare do
#   # Only override the problematic inverse_of check, don't break other functionality
#   ActiveStorage::Attachment.class_eval do
#     # Clear the existing belongs_to and redefine without strict inverse checking
#     _reflections.delete('record')
#     belongs_to :record, polymorphic: true, touch: true
#   end
# end