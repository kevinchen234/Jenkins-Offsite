# Customizations of this class for this app only
class UCB::LDAP::Person
  def eligible_submitter?
    self.employee? || self.student? || self.valid_affiliate?
  end
  
  def eligible_user?
    self.employee? || self.student? || self.valid_affiliate?
  end
  
  def eligible_campus_official?
    self.employee? && !self.student?
  end

  def valid_affiliations
    affiliations.inject([]) do |accum, aff|
      aff =~ /AFFILIATE-TYPE.*(CONTRACTOR|CONSULTANT)/ ? accum << aff : accum
    end
  end
  
  def valid_affiliate?
    !valid_affiliations.empty?
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end


class UCB::LDAP::Org
  def self.build_department_list
    all_nodes.values.sort_by { |v| v.name }.map do |v|
      ["#{v.name} - (#{v.ou})", "#{v.name} - (#{v.ou})"]
    end
  end
end
