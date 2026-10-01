# frozen_string_literal: true

require "uri"

module InlineValidation
  class SignupEmailField < Weft::Component
    builder_method :signup_email_field

    param :email
    param :error_message

    performs :validate do |params|
      email = params.email.to_s.strip
      unless email.match?(URI::MailTo::EMAIL_REGEXP)
        raise Weft::Unprocessable, "That doesn't look like an email address."
      end
      raise Weft::Unprocessable, "#{email} is already registered." if EmailData.taken?(email)

      nil
    end

    # A complaint is still a render: this field again, wearing the message, as a 422.
    recovers from: Weft::Unprocessable do |_params, error|
      { error_message: error.message }
    end

    # Not from the email, which changes with every check: the id a complaint lands under too.
    def weft_dom_id = "signup-email-field"

    def build(attributes = {})
      super
      form(action: :validate, trigger: :change, novalidate: true) do
        authenticity_token
        label "Email Address ", for: "email"
        input type: "email", name: "email", id: "email", value: params.email
      end
      verdict
    end

    private

    def verdict
      if params.error_message
        add_class "invalid"
        para params.error_message
      elsif params.email
        add_class "valid"
        para "#{params.email} looks good."
      end
    end
  end
end
