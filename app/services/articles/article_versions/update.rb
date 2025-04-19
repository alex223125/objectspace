# require "./app/services/concerns/technologies/taggable"
# require "./app/services/concerns/technologies/memberable"
# require "./app/services/concerns/shared/owner_permissionable"
#
# module Services
#   module Articles
#     module ArticleVersions
#       class Update
#         include ::Services::Concerns::Technologies::Taggable
#         include ::Services::Concerns::Technologies::Memberable
#         include ::Services::Concerns::Shared::OwnerPermissionable
#
#         attr_reader :errors, :article, :permission
#
#         def initialize(article_version, params, target_place, creator, owner)
#           @article_version = article_version
#           @params = params
#           @target_place = target_place
#           @owner = owner
#         end
#
#         def call
#           ActiveRecord::Base.transaction do
#             binding.pry
#             # create_article
#             update_article
#
#             binding.pry
#             @article_version.save!
#           end
#         rescue ActiveRecord::RecordInvalid => e
#
#           binding.pry
#           @errors = e.message
#           Rails.logger.error(@errors)
#         end
#
#         def technology
#           @article_version
#         end
#
#         private
#
#         def update_article_version
#           binding.pry
#           @article_version.update(@params)
#         end
#
#       end
#     end
#   end
# end
