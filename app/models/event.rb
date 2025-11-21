class Event < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "description", "date", "location", "created_at", "updated_at"]
  end

  has_many :registrations, dependent: :destroy
  has_many :attendees, through: :registrations, source: :user
  def self.ransackable_associations(auth_object = nil)
    ["registrations", "category"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["title", "date", "location", "description", "created_at"]
  end

  def attendees_count
    registrations.sum(:tickets) 
  end

has_one_attached :banner


  ActiveAdmin.register Event do
  permit_params :title, :description, :date, :location, :price, :category_id, :image_url

  index do
    selectable_column
    id_column
    column :title
    column :category
    column :date
    column :location
    column "Attendees" do |e|
      e.attendees_count
    end
    actions
  end

  filter :title
  filter :category, as: :select, collection: -> { Category.all.pluck(:name, :id) }
  filter :date
  filter :location

  show do
    attributes_table do
      row :id
      row :title
      row :category
      row :description
      row :date
      row :location
      row "Attendees" do |e|
        e.registrations.map { |r| "#{r.user&.email} (#{r.tickets || 1})" }.join(", ").html_safe
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Event Details" do
      f.input :title
      f.input :category, as: :select, collection: Category.all.pluck(:name, :id), include_blank: true
      f.input :description
      f.input :date, as: :datepicker
      f.input :location
      f.input :price
      f.input :image_url
    end
    f.actions
  end
end


   belongs_to :category, optional: true   
  def self.ransackable_attributes(auth_object = nil)
    %w[id title description date location created_at updated_at category_id price]
  end

  def registered?(user)
    return false unless user
    registrations.exists?(user_id: user.id)
  end
end
