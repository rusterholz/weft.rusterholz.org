# frozen_string_literal: true

require "securerandom"

RSpec.describe SiteData::Records do
  let(:people) do
    stub_const("Roster::People", Class.new(described_class) do
      stored_in "records_spec",
                seed: { "1" => { name: "Joe", email: "joe@example.com" },
                        "2" => { name: "Ann", email: "ann@example.com" } }
    end)
  end

  before do
    stub_const("Roster", Module.new)
    SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}"
  end

  it "finds a record by its id, reading its fields by name" do
    person = people.find("2")

    expect(person).to be_a(people)
    expect([person.id, person[:name], person[:email]]).to eq(["2", "Ann", "ann@example.com"])
  end

  it "lists every record, in the order they were kept" do
    expect(people.all.map { |person| [person.id, person[:name]] }).to eq([%w[1 Joe], %w[2 Ann]])
  end

  it "answers a missing record as not found, naming the class and the id" do
    expect { people.find("3") }.to raise_error(Weft::NotFound, /People.*"3"/)
  end

  describe "#update" do
    it "keeps the change for the next reader" do
      people.find("1").update(name: "Joseph")

      expect(people.find("1")[:name]).to eq("Joseph")
    end

    # Whoever already holds the record, such as the render after a transfer, sees the edit.
    it "changes the record it was called on, too" do
      person = people.find("1")

      person.update(name: "Joseph")

      expect(person[:name]).to eq("Joseph")
    end

    it "reads a left-out field as unchanged, not blank" do
      people.find("1").update(name: nil, email: "joseph@example.com")

      expect([people.find("1")[:name], people.find("1")[:email]]).to eq(["Joe", "joseph@example.com"])
    end

    it "ignores a field the record does not have" do
      person = people.find("1")

      person.update(admin: true)

      expect(person[:admin]).to be_nil
      expect(people.find("1")[:admin]).to be_nil
    end

    it "answers a record deleted since it was found as not found" do
      person = people.find("1")
      people.find("1").destroy

      expect { person.update(name: "Joseph") }.to raise_error(Weft::NotFound, /"1"/)
    end
  end

  describe "#destroy" do
    it "forgets the record and keeps the rest in order" do
      people.find("1").destroy

      expect(people.all.map(&:id)).to eq(%w[2])
    end

    it "answers a record already destroyed as not found" do
      person = people.find("1")
      person.destroy

      expect { person.destroy }.to raise_error(Weft::NotFound, /"1"/)
    end
  end

  describe ".create" do
    it "keeps a new record under the next id, after the rest" do
      person = people.create(name: "Kim", email: "kim@example.com")

      expect([person.id, person[:name]]).to eq(%w[3 Kim])
      expect(people.all.map(&:id)).to eq(%w[1 2 3])
      expect(people.find("3")[:email]).to eq("kim@example.com")
    end

    it "never reuses an id still held, after an earlier record is gone" do
      people.find("1").destroy

      people.create(name: "Kim")

      expect(people.all.map { |person| [person.id, person[:name]] }).to eq([%w[2 Ann], %w[3 Kim]])
    end

    it "starts from 1 when there is nothing yet" do
      people.find("1").destroy
      people.find("2").destroy

      expect(people.create(name: "Kim").id).to eq("1")
    end
  end

  it "goes back to the seed when reset" do
    people.find("1").update(name: "Joseph")
    people.create(name: "Kim")

    people.reset!

    expect(people.all.map { |person| person[:name] }).to eq(%w[Joe Ann])
  end

  it "keeps one visitor's records from the next" do
    people.find("1").update(name: "Joseph")

    SiteData::Current.visitor = "visitor-#{SecureRandom.hex(4)}"

    expect(people.find("1")[:name]).to eq("Joe")
  end
end
