# frozen_string_literal: true

class BulkUpdatePage < ExamplePage
  describes member_data: "where a visitor's members are kept, standing in for your ORM model",
            member_roster: "the whole roster as one form, its checkboxes and its status line",
            bulk_update_page: "a page to put it on (yours needs only the member_roster call; " \
                              "the rest is this walkthrough)"

  def walkthrough
    introduction
    live { member_roster }
    how_it_works
  end

  private

  def introduction
    prose <<~TEXT
      A table of team members, each row with an Active checkbox. One submit applies every change
      at once, and a line under the table says how many members were activated and how many
      deactivated.

      This is Weft's take on htmx's bulk-update example, with one difference in shape. Their form
      posts the checkboxes and puts a message in a separate slot, leaving the table as the user
      left it. Here the whole roster is one component, so the submit renders it again from what
      was saved: the checkboxes come back showing the stored state, with the status line beneath
      them.

      The members below are yours alone. Every visitor gets their own copy of them, and it is
      thrown away a couple of hours later, so change them freely.
    TEXT
  end

  def how_it_works
    h2 "How It Works"
    prose <<~TEXT
      Bracket naming turns the checkboxes into one array. Every checkbox is named active_ids[],
      and Rack folds the ticked ones into a single array under the plain key, so the declared
      active_ids param arrives as, say, ["1", "2", "4"]. The values are strings, which is why the
      members' ids are strings too. A box left unticked is simply not sent; that is the whole
      trick of the pattern.

      The default: [] matters. With no box ticked, the browser sends no active_ids at all, and
      the param falls back to its default. An empty array makes that mean "nobody is active", and
      gives the action a real array to ask include? of, never nil.

      The action compares, then reports through its return value. For each member it compares
      the stored state with the submitted array, counts the changes, and saves the new state. A
      hash returned from an action becomes params for the render that follows, so returning
      { status: ... } is how the count reaches the status line. On the first render
      params.status is nil, and the line is not there.

      The roster's DOM id stays put. Weft builds a component's DOM id from its first param, but
      only from a single value, such as a record's id: an array is left out. So the roster is
      always bulk-update-member-roster, whichever boxes are ticked, and its update lands back in
      the same place every time.

      The checkboxes show what was saved. build ticks each box from the stored member, not from
      what was submitted, so the response reflects the store. And because form(action: :update)
      also writes a plain action and method, the form still posts without JavaScript, though
      what comes back is the roster on its own rather than the page around it.
    TEXT
  end
end
