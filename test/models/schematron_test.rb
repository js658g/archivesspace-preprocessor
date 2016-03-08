require 'test_helper'

class SchematronTest < ActiveSupport::TestCase
  before do
    @population = SchematronFile.all.count
    @sf = SchematronFile.new( IO.read(File.join(Rails.root, 'test', 'test_data', 'test_schematron.xml')) )
    @schematron = Schematron.create( digest: @sf.digest, issues_attributes: @sf.issue_attrs )
  end

  describe Schematron do
    it "can save a schematron" do
      stron = Schematron.find(@schematron.id)
      stron.touch
      assert stron.save, "Schematron failed with: #{stron.errors.keys.join(', ')}"
    end
  end

  after do
    @schematron.destroy!
    unless Dir[File.join(SchematronFile::FILE_DIR, '*.xml')].count == @population
      raise "Detritus SchematronFiles left by test"
    end
  end
end
