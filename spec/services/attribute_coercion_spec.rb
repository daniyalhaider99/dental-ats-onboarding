require "rails_helper"

RSpec.describe AttributeCoercion do
  describe ".iso_date" do
    it "parses an ISO date" do
      expect(described_class.iso_date("2020-06-15")).to eq(Date.new(2020, 6, 15))
    end

    it "returns nil for blank or unparseable input" do
      expect(described_class.iso_date("")).to be_nil
      expect(described_class.iso_date("not a date")).to be_nil
      expect(described_class.iso_date(nil)).to be_nil
    end
  end

  describe ".text" do
    it "strips and returns present strings" do
      expect(described_class.text("  hello ")).to eq("hello")
    end

    it "returns nil for blank" do
      expect(described_class.text("   ")).to be_nil
    end
  end

  describe ".boolean" do
    it "casts truthy and falsy values" do
      expect(described_class.boolean("true")).to be(true)
      expect(described_class.boolean(true)).to be(true)
      expect(described_class.boolean(nil)).to be(false)
      expect(described_class.boolean("0")).to be(false)
    end
  end

  describe ".integer" do
    it "parses integers and rejects junk" do
      expect(described_class.integer("7")).to eq(7)
      expect(described_class.integer("seven")).to be_nil
    end
  end

  describe ".decimal" do
    it "parses decimals and rejects junk" do
      expect(described_class.decimal("12.50")).to eq(BigDecimal("12.50"))
      expect(described_class.decimal("")).to be_nil
      expect(described_class.decimal("abc")).to be_nil
    end
  end
end
