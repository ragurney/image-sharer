class EnforceTagAssociationAndAddDefaults < ActiveRecord::Migration[5.0]
  def change
    tag_id = insert_default_tag

    image_ids_without_tags = ActiveRecord::Base.connection.execute(
      'select id from images where id not in (select taggable_id from taggings)'
    )

    image_ids_without_tags.each do |image_id|
      ActiveRecord::Base.connection.execute(
        "insert into taggings (tag_id, taggable_type, taggable_id, context, created_at)
         values(#{tag_id}, 'Image', #{image_id['id']}, 'tags', '#{Time.zone.now.to_s(:db)}')"
      )
    end
  end

  def insert_default_tag
    ActiveRecord::Base.connection.execute("insert into tags (name) values ('default')")
    ActsAsTaggableOn::Tag.last.id
  end
end
