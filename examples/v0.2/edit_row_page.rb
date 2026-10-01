# frozen_string_literal: true

class EditRowPage < ExamplePage
  describes person_data: "where a visitor's people are kept, standing in for your database",
            people_table: "the table, handing each row the person it shows",
            person_row: "one person at rest, and the button that opens the row for editing",
            person_row_editor: "the row in its editable state, its fields tied to a form in the last cell",
            edit_row_page: "a page to put it on (yours needs only the people_table call; " \
                           "the rest is this walkthrough)"

  def walkthrough
    introduction
    live { people_table }
    log_warning
    how_it_works
  end

  private

  def introduction
    prose <<~TEXT
      A table where each row can switch into an editable state. Edit swaps the row for a row of
      inputs; Save writes the change and swaps the display row back; Cancel backs out without
      saving.

      This is Weft's take on htmx's edit-row example: Click to Edit, once per row. Their version
      uses hyperscript to keep a single row in edit mode at a time. Here each row is its own pair
      of components, so several rows can be open at once, and allowing only one is a policy your
      app can add on top. And where their editor gathers its inputs with hx-include="closest tr",
      this one leans on plain HTML.

      The people below are yours alone. Every visitor gets their own copy of them, and it is
      thrown away a couple of hours later, so edit them freely.
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
      Each row is a component that renders as a table row. PersonRow and PersonRowEditor both
      set their tag_name to tr, and each takes its DOM id from person_id, its first param, so
      every row can be addressed on its own.

      The table hands each row its person. Every row needs a different person_id, so PeopleTable
      passes each one in with person_row person_id: person.id, which is what receives is for: a
      value shared down the render tree would be the same for every row. PersonRow declares
      person_id as a param as well, so its Edit button carries the id, and the row can render on
      its own.

      The buttons hand the row back and forth, as in Click to Edit. The display row's Edit
      transfers to the editor, and the editor's Save and Cancel transfer back to the display row.
      Save updates the person first, so the row it hands back shows the edit. Edit and Cancel
      change nothing on the server, so they declare method: :get and are honest GETs.

      The editor is never in the table's first render. It arrives through Edit, whose request
      carries person_id, and it declares person_id as a param so its own Save and Cancel carry
      the id onward.

      A form cannot wrap table cells, so the cells point at the form. HTML does not let a form
      span the cells of a row, so the editor puts its form in the last cell, and the name and
      email inputs in the other cells join it through the standard form attribute. Fields joined
      that way are submitted with the form, so htmx sends all three, and so does a plain submit
      without JavaScript.

      Rows edit independently. Each row has ids of its own (edit-row-person-row-2,
      save-person-2, and so on), so opening one editor leaves the others as they are.
    TEXT
  end
end
