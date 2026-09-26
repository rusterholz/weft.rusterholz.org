# frozen_string_literal: true

# The header's version picker: a Picker over the weft versions this site
# documents. One today, so it stands disabled; more arrive as data, not edits.
class VersionPicker < Picker
  builder_method :version_picker

  defines options: [["v#{Weft::VERSION}", "/"]],
          current: "v#{Weft::VERSION}",
          label: "weft version",
          disabled_reason: "Only one version of weft is documented so far."
end
