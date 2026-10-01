# frozen_string_literal: true

module ResetUserInput
  class CommentSection < Weft::Component
    builder_method :comment_section

    param :author
    param :body

    # Cleared on the way out: the section renders again with empty fields, and
    # keeps the DOM id the first param would otherwise have changed.
    performs :post do |params|
      author = params.author.to_s.strip
      body = params.body.to_s.strip
      CommentData.create(author: author, body: body) unless author.empty? || body.empty?
      { author: nil, body: nil }
    end

    def build(attributes = {})
      super
      ul do
        CommentData.all.each do |comment|
          li do
            strong "#{comment[:author]}: "
            text_node comment[:body]
          end
        end
      end
      form(action: :post) do
        authenticity_token
        text_field "Name ", :author
        text_field "Comment ", :body
        input type: "submit", value: "Add Comment"
      end
    end

    private

    # No value: the reset is that every render starts empty.
    def text_field(label_text, key)
      div do
        label label_text, for: key
        input type: "text", name: key, id: key
      end
    end
  end
end
