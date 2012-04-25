class UcbSecurity::Builder < ActionView::Helpers::FormBuilder
  
  def text_field(label, method, options = {}, html_options = {})
    field = super(method, html_options)
    format_field(label, method, options, field)
  end
  
  def text_area(label, method, options = {}, html_options = {})
    field = super(method, html_options)
    format_field(label, method, options, field)
  end
  
  def text(label, method, options = {}, html_options = {})
    format_field(label, method, options, "#{@object.send(method)}")
  end
  
  def format_field(label, method, options, field)
    label = "* ".concat(label) if options[:required] == true
    
    @template.content_tag(:p,
      "#{@template.content_tag(:label, label, :for => "#{@object_name}_#{method}")} #{field}"
    )
  end

end
