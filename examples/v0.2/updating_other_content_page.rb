# frozen_string_literal: true

class UpdatingOtherContentPage < ExamplePage
  describes contact_data: "where a visitor's contacts are kept, standing in for your ORM model",
            contacts_table: "the table the form updates from elsewhere on the page",
            new_contact_form: "the form, and the one line that brings the table along",
            updating_other_content_page: "a page to put them on (yours needs only the contacts_table and " \
                                         "new_contact_form calls; the rest is this walkthrough)"

  def walkthrough
    introduction
    live do
      contacts_table
      new_contact_form
    end
    rename_note
    how_it_works
  end

  private

  def introduction
    prose <<~TEXT
      A form adds a contact, and a contacts table elsewhere on the page, outside the form,
      updates in the same interaction. One submit, two regions refreshed.

      This is Weft's take on htmx's update-other-content example, which uses the same scenario.
      htmx's page weighs four ways to do it by hand: expanding the target, out-of-band swaps,
      events, and a path-dependencies extension, each with its own wiring to write. Weft turns
      the choice into declarations: includes ContactsTable on the form covers the common case in
      one line, and a triggers and refreshes on: pair covers the decoupled one in two.

      The contacts are yours alone. Every visitor gets their own copy of them, and it is thrown
      away a couple of hours later, so add freely.
    TEXT
  end

  def rename_note
    callout do
      prose "In weft 0.3, includes becomes brings and triggers becomes announces."
      a "Weft's Changelog", href: WEFT_NEXT_CHANGELOG_URL
    end
  end

  def how_it_works
    h2 "How It Works"
    prose <<~TEXT
      includes declares the relationship once, in the class body. includes ContactsTable says:
      whenever this form answers an action, render the table too, marked out of band. htmx gets
      one response holding two fragments. The form, rendered again, takes the form's place as
      usual, and the table, marked hx-swap-oob, goes to its own place on the page by its id,
      updating-other-content-contacts-table. One request, one response, two regions: htmx's
      out-of-band answer, with the response, the attribute and the ids all handled for you.

      The table needs no route. ContactsTable declares no params and no actions, so nothing
      fetches it on its own, and asking for it at its component path answers 404. It renders
      inside the page and travels inside the form's responses, and a companion only has to
      render.

      The action resets the form. It returns { name: nil, email: nil }, and a hash returned from
      an action becomes params for everything the response renders. Clearing the submitted
      values brings the form back empty after each add, with no reset handler, and keeps its DOM
      id, which comes from its first param, the same.

      Form fields pair with declared params. The form declares name and email, so the submitted
      fields reach the action as params.name and params.email. And since form(action: :add) also
      writes a plain action and method, the add still happens without JavaScript, though the
      response is the form on its own rather than the page around it.

      includes points one way: the form knows the table exists. When it shouldn't, because the
      components that react are many, elsewhere, or someone else's, the form can announce
      instead. triggers "contact-added" on the form puts that event in the HX-Trigger header of
      every action response, and refreshes on: "contact-added" on the table has it fetch itself
      again whenever the event fires. Neither names the other, and any number of components can
      listen. The cost is one more request per listener, and the table then needs a route, which
      declaring refreshes gives it. Reach for includes when the form naturally knows what it
      changes, and for triggers when the reactions should stay open-ended.

      Mapped onto htmx's four: expanding the target is still there, by wrapping both regions in
      one component, but rarely needed; out-of-band responses are includes; triggering events
      are triggers with refreshes on:; and the path-dependencies extension is not needed, since
      those two cover both directions of coupling.
    TEXT
  end
end
