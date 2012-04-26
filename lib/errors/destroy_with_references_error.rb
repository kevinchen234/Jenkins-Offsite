require 'active_support/inflector'

class DestroyWithReferencesError < StandardError

  def initialize(reference_name, reference_count)
    puts "Im here"
    super "Unable to delete: record is referenced by #{reference_count} #{reference_name} " + 'record'.pluralize(reference_count)
  end

end
