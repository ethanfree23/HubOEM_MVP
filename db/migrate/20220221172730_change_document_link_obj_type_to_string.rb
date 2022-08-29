class ChangeDocumentLinkObjTypeToString < ActiveRecord::Migration[6.0]
  def change
    rename_column :document_links, :obj_type, :obj_type_dep
    add_column :document_links, :obj_type, :string

    DocumentLink.all.each do |document_link|
      document_link.obj_type = ObjectLink.type_hash[document_link.obj_type_dep].name
      document_link.save!
    end
  end
end
