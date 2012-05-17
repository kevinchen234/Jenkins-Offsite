class App
  VERSION = 'rel-1.1.2'
  
  # Template proxy providing access to helper methods
  cattr_accessor :template
  self.template = ActionView::Base.new
  
  def self.dom_id(*args)
    template.dom_id(*args)
  end
  
  def self.it_policy_email=(email)
    @it_policy_email = email
  end

  def self.it_policy_email()
    @it_policy_email || "itpolicy@berkeley.edu"
  end
end
