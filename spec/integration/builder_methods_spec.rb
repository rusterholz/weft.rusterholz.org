# frozen_string_literal: true

require "prism"

# Arbre defines each builder_method on one module every element shares, whatever
# namespace the class sits in, so a second class claiming a name silently takes
# it from the first. Two examples both defining a ContactsTable would each render
# whichever loaded last. Read from the files, since at run time the loser is gone.
RSpec.describe "builder method names" do
  def builder_names_in(path)
    calls = []
    queue = [Prism.parse_file(path).value]
    until queue.empty?
      node = queue.shift
      calls << node.arguments.arguments.first.unescaped if builder_method_call?(node)
      queue.concat(node.compact_child_nodes)
    end
    calls.map { |name| [name, path.delete_prefix("#{APP_ROOT}/")] }
  end

  def builder_method_call?(node)
    node.is_a?(Prism::CallNode) && node.name == :builder_method && node.receiver.nil? &&
      node.arguments&.arguments&.first.is_a?(Prism::SymbolNode)
  end

  let(:files) { Dir[File.join(APP_ROOT, "{app,examples}", "**", "*.rb")] }
  let(:claims) { files.flat_map { |path| builder_names_in(path) } }

  it "finds the builders the site and its examples declare" do
    expect(claims.map(&:first)).to include("contact_card", "people_table", "declarations")
  end

  it "gives every builder name to one class only, across the site and every example" do
    shared = claims.group_by(&:first).select { |_name, owners| owners.size > 1 }

    expect(shared.transform_values { |owners| owners.map(&:last) }).to be_empty
  end
end
