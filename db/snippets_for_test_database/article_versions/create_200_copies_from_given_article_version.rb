algorithm_version = Algorithms::AlgorithmVersion.last

raise "No AlgorithmVersion records found" unless algorithm_version

algorithm = algorithm_version.algorithm

raise "AlgorithmVersion has no algorithm" unless algorithm

user = algorithm.owner

raise "Algorithm owner/user not found" unless user

puts "Using user: ##{user.id} - #{user.inspect}"

Articles::Article.transaction do
  200.times do |i|
    number = i + 1

    article = Articles::Article.new(
      title: "Infinite Scroll Test Article #{number}",
      visibility_status: number.even? ? 1 : 0,
      source_page_description:
        "Test article #{number} created for testing infinite scrolling.",
      ownerable: user,
      creator: user
    )

    content = [
      "<h2>Infinite Scroll Test Article #{number}</h2>",
      "",
      "<p>This is unique test content for Article #{number}.</p>",
      "",
      "<p>This article was generated automatically for testing " \
        "infinite scrolling, loading states and dynamic article lists.</p>",
      "",
      "<p>Article number: #{number}</p>",
      "",
      "<p>Unique content identifier: test-article-#{number}</p>",
      "",
      "<p>#{("Test content for article #{number}. " * ((number % 10) + 5)).strip}</p>",
      "",
      "<p>This is additional unique content for test article #{number}. " \
        "It should make this record different from the other generated " \
        "records when testing searching and infinite scrolling.</p>"
    ].join("\n")

    additional_information = [
      "Automatically generated test article.",
      "",
      "Article number: #{number}",
      "Purpose: Infinite scroll testing",
      "User ID: #{user.id}",
      "Generated at: #{Time.current}"
    ].join("\n")

    version = article.article_versions.new(
      title: "Infinite Scroll Test Article #{number} - Version 1",
      content: content,
      sources: "Generated test source for article #{number}",
      additional_information: additional_information
    )
    #
    # # Make the newly created version the default version.
    # article.update!(
    #   default_version_id: version.id
    # )

    version.save!

    article.default_version_id = version.id
    article.save!

    puts(
      "Created #{number}/200 - " \
        "Article ##{article.id} - " \
        "ArticleVersion ##{version.id}"
    )
  end
end

# Reindex all articles after creation.
Articles::Article.reindex
# Articles::ArticleVersion.reindex

puts "Done! Created 200 Articles with 200 ArticleVersions."