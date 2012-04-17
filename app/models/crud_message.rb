class CrudMessage
  class << self
    def msg_errors(_obj)
      _obj.errors.full_messages {}
    end
    
    def msg_created(_obj)
      "#{msg_prefix(_obj)} created."
    end

    def msg_destroyed(_obj)
      "#{msg_prefix(_obj)} deleted."    
    end

    def msg_updated(_obj)
      "#{msg_prefix(_obj)} updated."
    end
    
    def msg_prefix(_obj)
      "#{_obj.instance_of?(String) ? _obj : _obj.class.to_s} successfully"
    end
  end
end
