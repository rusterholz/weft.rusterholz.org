# frozen_string_literal: true

class ClickToEditPage < ExamplePage
  describes contacts: "where a visitor's contact is kept, standing in for your database",
            contact_card: "the contact at rest, and the button that opens it for editing",
            contact_editor: "the form in its editable expanded view",
            click_to_edit_page: "a page to put it on (yours needs only the contact_card call; " \
                                "the rest is this walkthrough)"

  def walkthrough
    introduction
    live { contact_card contact_id: "1" }
    log_warning
    how_it_works
    worth_noticing
  end

  private

  def introduction
    prose <<~TEXT
      A read-only view of a record with an Edit button. Clicking swaps an editable form into
      its place; saving, or canceling, swaps the read-only view back. No page navigation, and
      no JavaScript beyond what Weft already ships.

      This is Weft's take on htmx's click-to-edit example, and the shape is the same: the UI
      moves between two states, and each state is a server-rendered fragment. In Weft, each
      state is simply a component.

      The contact below is yours alone. Every visitor gets their own copy of it, and it is
      thrown away a couple of hours later, so edit it freely.
    TEXT
  end

  def log_warning
    callout do
      prose <<~TEXT
        If you run this example yourself, Weft logs a warning the first time you click Edit, Cancel
        or Save, and on every click in development, where classes reload. It's harmless, and Weft
        plans to improve how this case is handled.
      TEXT
    end
  end

  def how_it_works
    h2 "How It Works"
    prose <<~TEXT
      Every button here hands this piece of the page to another component, and that is what
      transfers declares. The card's Edit button transfers to the editor; the editor's Save
      and Cancel transfer back to the card. The server renders the component taking over, and
      it replaces the one that declared the transfer, wherever that sits in the page.

      Saving also writes. The editor's transfers :save block updates the contact first, so the
      card it hands back to shows the edit. Edit and Cancel change nothing on the server, so
      they declare method: :get and are honest GETs, while save keeps the default, a POST.

      A button or a form names its transfer with action:, and Weft fills in the rest: the URL,
      the verb and where the response lands, and for a button, the params too. That is why
      nothing here spells out a URL or a target.
    TEXT
  end

  def worth_noticing
    h2 "Worth Noticing"
    prose <<~TEXT
      Form fields pair with declared params. The editor declares first_name, last_name and
      email so its fields reach the save callable as params.first_name and friends, while
      contact_id rides along as a hidden input, because it is part of the component's
      identity rather than something the user edits.

      Note type: "button" on Cancel: inside a form, a bare button is a submit button.
    TEXT
  end
end
