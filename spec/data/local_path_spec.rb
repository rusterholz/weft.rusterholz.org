# frozen_string_literal: true

RSpec.describe LocalPath do
  it "keeps a path on this site, query and all" do
    expect(described_class.or_home("/examples/click-to-edit?x=1")).to eq("/examples/click-to-edit?x=1")
  end

  {
    "another host" => "https://evil.example/",
    "a protocol-relative address" => "//evil.example/",
    "a backslash browsers read as a slash" => "/\\evil.example/",
    "a backslash later in the path" => "/ok\\..\\x",
    "a carriage return and line feed" => "/\r\nhttps://evil.example/",
    "a lone line feed" => "/\nhttps://evil.example/",
    "a tab" => "/\t//evil.example/",
    "a space" => "/ //evil.example/",
    "a null byte" => "/\u0000x",
    "a delete character" => "/\u007fx",
    "nothing at all" => nil,
    "an empty string" => ""
  }.each do |what, path|
    it "sends #{what} home" do
      expect(described_class.or_home(path)).to eq("/")
    end
  end
end
