class ImageSelector
  def self.select(tag)
    if tag.nil?
      Image.order(created_at: :desc)
    else
      Image.tagged_with(tag).order(created_at: :desc)
    end
  end
end
