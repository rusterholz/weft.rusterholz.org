# frozen_string_literal: true

class ResetUserInputPage < ExamplePage
  describes comment_data: "where a visitor's comments are kept, standing in for your ORM model",
            comment_section: "the list and the form beneath it, one component",
            reset_user_input_page: "a page to put it on (yours needs only the comment_section call; " \
                                   "the rest is this walkthrough)"

  def walkthrough
    introduction
    live { comment_section }
    how_it_works
  end

  private

  def introduction
    prose <<~TEXT
      An add-a-comment form beneath a list of comments. Submit, and the new comment appears in
      the list while the form comes back empty, ready for the next one. Nothing resets the form:
      a new one arrives.

      This is Weft's take on htmx's reset-user-input example, though "take on" oversells it.
      htmx needs an hx-on handler to reset the form after the request, because the form that
      posted is still on the page, holding what was typed. A Weft action renders the whole
      component again on the server, so the form that arrives never had text in it. There is
      nothing to do, and this page is about why.

      The comments are yours alone. Every visitor gets their own copy of them, and it is thrown
      away a couple of hours later, so add freely.
    TEXT
  end

  def how_it_works
    h2 "How It Works"
    prose <<~TEXT
      The response replaces the form, typed text and all. build renders the list from the store
      and the inputs with no value at all, so every render of this component has empty fields.
      The action's swap replaces the old elements whole: the inputs holding the typed text leave
      the page, and fresh, empty ones arrive in the same response that shows the new comment in
      the list.

      Clearing the params in the return keeps the identity stable. The action ends with
      { author: nil, body: nil }, and a hash returned from an action becomes params for the
      render that follows. Weft takes a component's DOM id from its first param, so cleared, the
      section comes back as the same reset-user-input-comment-section the wiring aims at; left as
      submitted, the name would end up in its id.

      Blank submits are the action's to handle, and it does. The browser happily posts an empty
      name or comment; the check adds nothing, and the response is the list as it stands. A
      required attribute on the inputs would be a courtesy on top, but the check on the server is
      the one that holds.

      The reset needs no JavaScript either. form(action: :post) also writes a plain action and
      method, so without htmx the same POST works as a full-page submit, and the fresh page has
      empty fields for the same reason the fragment does.
    TEXT
  end
end
