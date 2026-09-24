# frozen_string_literal: true

class ClickToEditPage < ExamplePage
  def walkthrough
    introduction
    contact_card contact_id: "1"
    how_it_works
  end

  private

  def introduction
    para "A read-only view of a record with an Edit button. Clicking swaps an editable form into " \
         "its place; saving, or canceling, swaps the read-only view back. No page navigation, and " \
         "no JavaScript beyond what Weft already ships."
    para "This is Weft's take on htmx's click-to-edit example, and the shape is the same: the UI " \
         "moves between two states, and each state is a server-rendered fragment. In Weft, each " \
         "state is simply a component."
    para "The contact below is yours alone. Every visitor gets their own copy of it, and it is " \
         "thrown away a couple of hours later, so edit it freely."
  end

  def how_it_works
    h2 "How It Works"
    para "Reads and writes get different verbs. Opening the editor changes nothing on the server, " \
         "so the Edit button is a loads:, a plain GET that fetches the editor component and swaps " \
         "it over the card. Cancel is the same thing pointed back at the card. Saving does change " \
         "something, so it is a transfers: a POST that runs the write, then renders the card, " \
         "which is the natural thing to see after saving, in the editor's place."
    para "target: self pins the swap to the component. Inside build, self is the component " \
         "instance, and a component reference as a target resolves to its DOM id, so each " \
         "fragment replaces the whole card or editor element wherever it sits in the page."
    para "The two components reference each other without a cycle. transfers :save, to: " \
         "ContactCard runs in the class body, so ContactCard has to be defined already; but " \
         "loads: ContactEditor is not evaluated until render. Defining the display component " \
         "first therefore breaks the loop with no forward declarations."
    para "Form fields pair with declared params. The editor declares first_name, last_name and " \
         "email so its fields reach the save callable as params.first_name and friends, while " \
         "contact_id rides along as a hidden input, because it is part of the component's " \
         "identity rather than something the user edits."
    para "It still works without JavaScript. form(action: :save) emits plain action and method " \
         "attributes alongside the htmx wiring, so the save degrades to an ordinary POST. Note " \
         "type: \"button\" on Cancel: inside a form, a bare button is a submit button."
  end
end
