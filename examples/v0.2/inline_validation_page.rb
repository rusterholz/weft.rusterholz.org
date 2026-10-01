# frozen_string_literal: true

class InlineValidationPage < ExamplePage
  describes email_data: "the addresses already registered, standing in for your database's uniqueness check",
            signup_email_field: "the field, its check, and its verdict",
            inline_validation_page: "a page to put it on (yours needs only the signup_email_field call; " \
                                    "the rest is this walkthrough)"

  def walkthrough
    introduction
    live { signup_email_field }
    how_it_works
  end

  private

  def introduction
    prose <<~TEXT
      A signup form's email field that checks itself. Leave the field, and a moment later there
      is either an all-clear or a specific complaint, straight from the server, before anyone
      reaches a submit button.

      This is Weft's take on htmx's inline-validation example, and the shape is the same: the
      field posts its value when it changes, the server decides, and the field's corner of the
      page renders again with the verdict. In Weft the field is a small component that owns the
      whole story: the check, the complaint and the all-clear sit next to the markup they
      decorate.

      Try an address that is not one, then taken@example.com, which is already registered, then
      one of your own. Nothing you type is kept.
    TEXT
  end

  def how_it_works
    h2 "How It Works"
    prose <<~TEXT
      The field is a component, and the form belongs to the field. form(action: :validate,
      trigger: :change) wires the POST like any action form, but trigger: fires it on change
      rather than on submit. Change events bubble up from the input, so the request goes the
      moment you leave the field, carrying the typed email as params.email.

      Put the action on the form, not the input. On an element that is not a form, action: sends
      the component's declared params along with the request, and htmx lets those win over the
      element's own value, so the check would see the email from the last render instead of what
      you just typed. A one-field form sends exactly what is in the field.

      novalidate on the form leaves the checking to the server. A browser checks an email field
      on its own, and htmx sends nothing the browser has rejected, so the last verdict would sit
      beside the new text and the server's complaint would never come.

      A complaint is still a render. Bad input raises Weft::Unprocessable, and the recovers block
      catches it and returns { error_message: error.message }, which becomes params for rendering
      the field again. The response goes out as a 422 Unprocessable Content whose body is this
      same field, carrying its complaint. A good address reaches the nil at the end and renders
      the all-clear at a plain 200.

      The field names itself. Weft would take the component's DOM id from its first param, the
      email, which changes with every check. So the field defines weft_dom_id as
      signup-email-field, and Weft uses that name wherever it would have used the derived one: on
      the field's element, as where the check's response lands, and on a complaint that comes
      back in its place.

      The field gives back what you typed. The response replaces the whole component, input
      included, so value: params.email puts the typed text back in the fresh input, and a
      complaint never empties the field.

      The verdict is a class on the field itself, valid or invalid, and the stylesheet colors the
      message from that.
    TEXT
  end
end
