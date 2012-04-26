class DestroyWithReferencesError < StandardError

  def initialize(reference_name, reference_count)
    super "Unable to delete: record is referenced by #{reference_count} #{reference_name} " + pluralize(reference_count, 'record')
  end

end
