ActsAsTaggableOn::Tag.class_eval do
  searchkick callbacks: :async,
             word_start: [:name]
end