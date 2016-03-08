# Class representing the file containing an EAD finding aid
#
# Should be considered immutable in principle after creation - in practice,
# there's not a simple way to render a File object immutable.
#
# Delegates most operations to File object.
class FindingAidFile < SimpleDelegator
  # Directory that processed schematron files are stored in
  FILE_DIR = File.join(Rails.root, 'public', 'finding_aids')

  # Slug to prepend to File in console description of object
  INSPECT_SLUG = 'FindingAid'

  include DigestedFile
  #@!parse include DigestedFile
  #@!parse extend DigestedFile::ClassMethods

  # Parse <eadid> for data applicable across all versions of finding aid
  #
  # @return [Hash] attributes suitable for passing to FindingAid constructor
  def faid_attr
    xml = Nokogiri::XML(self, nil, 'UTF-8') {|config| config.nonet}
    xml.remove_namespaces!
    eadid = xml.at_xpath('/ead/eadheader/eadid')
    repo = Repository.find_or_initialize_by(code: eadid.text[0..2])
    unless repo.id
      repo.name = 'unknown repository'
      repo.save!
    end

    {
      eadid: eadid.text,
      ext_id_type: 'hollis',
      ext_id: eadid['identifier'],
      repository_id: repo.id
    }
  end
end
