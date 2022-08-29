# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_06_08_130634) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bulk_upload_objects", force: :cascade do |t|
    t.integer "obj_type"
    t.integer "obj_id"
    t.boolean "run"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_carts_on_group_id"
  end

  create_table "contact_submissions", force: :cascade do |t|
    t.string "email"
    t.string "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "topic"
    t.integer "topic_id"
    t.string "topic_text"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "document_links", force: :cascade do |t|
    t.bigint "document_id"
    t.integer "obj_type_dep"
    t.integer "obj_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "obj_type"
    t.index ["document_id"], name: "index_document_links_on_document_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "group_id"
    t.string "serial"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "forge_object_id"
    t.string "forge_status"
    t.string "forge_urn"
    t.index ["group_id"], name: "index_documents_on_group_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.text "address_line1"
    t.text "address_line2"
    t.string "city"
    t.string "state"
    t.integer "zipcode"
    t.string "name"
    t.bigint "group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_facilities_on_group_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "user"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "elevation"
    t.string "addressShipping"
    t.string "addressBilling"
    t.string "phone"
    t.float "taxrate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "description"
    t.bigint "order_id"
    t.boolean "locked"
    t.index ["order_id"], name: "index_invoices_on_order_id"
  end

  create_table "line_item_instances", force: :cascade do |t|
    t.integer "order_id"
    t.integer "group_id"
    t.integer "line_item_id"
    t.string "description"
    t.decimal "cost", precision: 20, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.decimal "price_per_unit", precision: 20, scale: 2
    t.decimal "shipping_per_unit", precision: 20, scale: 2
    t.decimal "quantity", precision: 20, scale: 2
    t.boolean "taxable"
    t.bigint "object_type"
    t.bigint "object_id"
    t.bigint "invoice_id"
    t.string "referenceable_type", null: false
    t.bigint "referenceable_id", null: false
    t.index ["invoice_id"], name: "index_line_item_instances_on_invoice_id"
    t.index ["order_id"], name: "index_line_item_instances_on_order_id"
    t.index ["referenceable_type", "referenceable_id"], name: "line_item_instance_idx"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "groups_id"
    t.string "description"
    t.decimal "cost", precision: 20, scale: 2
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.boolean "taxable"
    t.index ["groups_id"], name: "index_line_items_on_groups_id"
  end

  create_table "login_activities", force: :cascade do |t|
    t.string "scope"
    t.string "strategy"
    t.string "identity"
    t.boolean "success"
    t.string "failure_reason"
    t.string "user_type"
    t.bigint "user_id"
    t.string "context"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "city"
    t.string "region"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.index ["identity"], name: "index_login_activities_on_identity"
    t.index ["ip"], name: "index_login_activities_on_ip"
    t.index ["user_type", "user_id"], name: "index_login_activities_on_user_type_and_user_id"
  end

  create_table "m_instances", force: :cascade do |t|
    t.string "serial"
    t.datetime "installDate"
    t.string "name"
    t.string "description"
    t.bigint "facility_id"
    t.bigint "machine_id"
    t.bigint "group_id"
    t.bigint "manufacturer_id"
    t.bigint "brand_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "archive", default: false
    t.string "forge_object_id"
    t.string "forge_status"
    t.string "forge_urn"
    t.index ["facility_id"], name: "index_m_instances_on_facility_id"
    t.index ["group_id"], name: "index_m_instances_on_group_id"
    t.index ["machine_id"], name: "index_m_instances_on_machine_id"
  end

  create_table "m_manifests", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "cart_id"
    t.integer "m_instance_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cart_id"], name: "index_m_manifests_on_cart_id"
    t.index ["order_id"], name: "index_m_manifests_on_order_id"
  end

  create_table "machines", force: :cascade do |t|
    t.integer "manufacturer_id"
    t.integer "brand_id"
    t.string "name"
    t.text "description"
    t.bigint "group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "forge_object_id"
    t.string "forge_status"
    t.string "forge_urn"
    t.index ["group_id"], name: "index_machines_on_group_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id"
    t.integer "sender_id"
    t.integer "read_status"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "notification_mailer_stores", force: :cascade do |t|
    t.bigint "notification_id", null: false
    t.boolean "sent", null: false
    t.integer "bulk_sent_id", default: -1, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["notification_id"], name: "index_notification_mailer_stores_on_notification_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "obj_type", null: false
    t.integer "obj_id", null: false
    t.integer "notification_type", null: false
    t.boolean "read", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "mail_sent", default: false
    t.index ["group_id"], name: "index_notifications_on_group_id"
  end

  create_table "onboarding_links", force: :cascade do |t|
    t.bigint "onboarding_id"
    t.string "serial"
    t.integer "obj_type"
    t.integer "obj_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["onboarding_id"], name: "index_onboarding_links_on_onboarding_id"
  end

  create_table "onboardings", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "creator_id"
    t.string "token"
    t.datetime "expiration_date"
    t.boolean "consumed"
    t.string "email"
    t.text "custom_email_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "sent", default: false
    t.index ["user_id"], name: "index_onboardings_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "vendor_id"
    t.integer "purchaser_id"
    t.integer "shipping_status"
    t.integer "maint_status"
    t.integer "requested_date"
    t.datetime "request_date"
    t.datetime "scheduled_date"
    t.text "description"
    t.datetime "shipped_date"
    t.string "po"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "p_instances", force: :cascade do |t|
    t.bigint "m_instance_id"
    t.bigint "part_id"
    t.integer "quantity"
    t.datetime "serviceDate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["m_instance_id"], name: "index_p_instances_on_m_instance_id"
    t.index ["part_id"], name: "index_p_instances_on_part_id"
  end

  create_table "p_manifests", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "cart_id"
    t.bigint "part_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["cart_id"], name: "index_p_manifests_on_cart_id"
    t.index ["order_id"], name: "index_p_manifests_on_order_id"
    t.index ["part_id"], name: "index_p_manifests_on_part_id"
  end

  create_table "part_quotes", force: :cascade do |t|
    t.bigint "p_instance_id", null: false
    t.integer "duration"
    t.datetime "quote_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "amount", precision: 10, scale: 2
    t.bigint "group_id", null: false
    t.bigint "part_id", null: false
    t.bigint "purchaser_id", null: false
    t.boolean "apply_all", default: false
    t.decimal "shipping", precision: 10, scale: 2
    t.index ["group_id"], name: "index_part_quotes_on_group_id"
    t.index ["p_instance_id"], name: "index_part_quotes_on_p_instance_id"
    t.index ["part_id"], name: "index_part_quotes_on_part_id"
  end

  create_table "parts", force: :cascade do |t|
    t.bigint "group_id"
    t.integer "manufacturer_id"
    t.integer "brand_id"
    t.string "name"
    t.text "description"
    t.string "qrHash"
    t.integer "priority", default: 0
    t.float "cost"
    t.string "mfr_string"
    t.integer "timeToService"
    t.integer "warrantyDuration"
    t.integer "recommendedStock"
    t.decimal "orderPricePerUnit", precision: 15, scale: 10
    t.decimal "orderShippingPerUnit", precision: 15, scale: 10
    t.integer "orderMinQuantity"
    t.integer "orderDeliveryTime"
    t.integer "orderLeadTime"
    t.string "drawing_number"
    t.string "part_number"
    t.string "warehouse_location"
    t.string "vendor_name"
    t.string "vendor_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "video_url"
    t.index ["group_id"], name: "index_parts_on_group_id"
  end

  create_table "parts_in_machines", force: :cascade do |t|
    t.bigint "machine_id"
    t.bigint "part_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["machine_id"], name: "index_parts_in_machines_on_machine_id"
    t.index ["part_id"], name: "index_parts_in_machines_on_part_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "user_id", null: false
    t.integer "transaction_type"
    t.boolean "accepted"
    t.string "ref_num"
    t.string "transaction_status"
    t.string "response"
    t.string "request"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "invoice_id", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "recurring_manifests", force: :cascade do |t|
    t.bigint "recurring_order_id", null: false
    t.string "obj_type"
    t.bigint "obj_id"
    t.integer "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["obj_type", "obj_id"], name: "index_recurring_manifests_on_obj_type_and_obj_id"
  end

  create_table "recurring_orders", force: :cascade do |t|
    t.string "purchase_order"
    t.bigint "purchaser_id", null: false
    t.bigint "vendor_id", null: false
    t.boolean "active"
    t.string "name"
    t.datetime "next_order_date"
    t.integer "days_between_orders"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string "file_loc"
    t.bigint "group_id"
    t.string "name"
    t.boolean "process_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_reports_on_group_id"
  end

  create_table "revisions", force: :cascade do |t|
    t.integer "object_type"
    t.integer "object_id"
    t.text "object_state"
    t.integer "user_id"
    t.integer "group_id"
    t.integer "modification_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stripe_integrations", force: :cascade do |t|
    t.bigint "group_id"
    t.text "stripe_uuid"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_stripe_integrations_on_group_id"
  end

  create_table "stripe_logs", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "event"
  end

  create_table "tracking_infos", force: :cascade do |t|
    t.bigint "order_id"
    t.string "tracking"
    t.datetime "estimated_delivery_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_tracking_infos_on_order_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "phone"
    t.bigint "group_id", default: 0
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "time_zone", default: "UTC"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "subscription_status"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["group_id"], name: "index_users_on_group_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "part_quotes", "groups"
  add_foreign_key "part_quotes", "p_instances"
  add_foreign_key "part_quotes", "parts"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "users"
  add_foreign_key "users", "groups"
end
