# frozen_string_literal: true

class DeleteRowPage < ExamplePage
  describes contact_data: "where a visitor's contacts are kept, standing in for your ORM model",
            contact_book_table: "the table, handing each row the contact it shows",
            contact_row: "one contact, and the button that deletes it",
            delete_row_page: "a page to put it on (yours needs only the contact_book_table call; " \
                             "the rest is this walkthrough)"

  def walkthrough
    introduction
    live { contact_book_table }
    how_it_works
  end

  private

  def introduction
    prose <<~TEXT
      A table of contacts, each row with a Delete button. Clicking it asks the browser's own
      "Are you sure?", deletes the contact on the server, and removes the row from the table.

      This is Weft's take on htmx's delete-row example. Their version puts the htmx attributes on
      the tbody and lets every row inherit them; in Weft each row is a component that carries its
      own wiring, generated from its own declaration. Their original also fades the row out
      before removing it, which is a CSS transition plus a swap delay and carries over unchanged
      if you want it. This one removes the row at once.

      The contacts below are yours alone. Every visitor gets their own copy of them, and it is
      thrown away a couple of hours later, so delete freely: Reset This Example brings them back.
    TEXT
  end

  def how_it_works
    h2 "How It Works"
    prose <<~TEXT
      The row is the component. ContactRow sets its tag_name to tr, so each contact renders as a
      real table row, and it takes its DOM id from contact_id, its first param. The first
      contact's row is delete-row-contact-row-1, which is exactly what its delete removes.

      The table hands each row its contact with contact_row contact_id: contact.id, since every
      row needs a different value, which is what receives is for. ContactRow declares contact_id
      as a param too, so the id rides along with its Delete button.

      The confirmation is one keyword. confirm: has htmx show the browser's own confirm dialog
      before sending anything, and choosing Cancel sends nothing at all.

      dismisses is the delete-shaped verb: an action that sends a DELETE and, when it succeeds,
      removes its component from the page. The button names it with action: :destroy, the block
      deletes the contact, and htmx takes the row out. The row's contact_id travels with the
      button, because an action button carries its component's params. Plain HTML has no DELETE,
      so this one needs JavaScript; that is the nature of the pattern.

      A successful delete answers with nothing. htmx removes the row itself, so Weft does not
      render the component it just helped remove, and build never has to cope with a contact
      that is gone. If the block raises, Weft keeps the row in place and shows the error there,
      itself a table row, so it fits in the table.

      A delete can still bring other components along: one declared with includes rides the
      response, so a count beside the table could shrink with it. That is why the block ends
      with nil: a hash returned from an action becomes params for everything the response
      renders, companions included, so a block run only for what it changes returns nothing.
      In weft 0.3, includes becomes brings.

      This site sends every htmx request the visitor's CSRF token as a header, and that is how
      the DELETE carries it, with no form to hold a field. An app of your own needs the same, or
      the delete is refused.
    TEXT
  end
end
