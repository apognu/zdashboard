module UsersHelper

  def uid_to_select data
    data.nil? { return nil}
    data.reject! { | x | x.nil? }

    data.map! { | u |
      if u.is_a? User
        {
          "text" => u.cn,
          "id" => "u:"+u.uid
        }
      elsif u.is_a? Contact
        {
          "text" => u.cn,
          "id" => "c:"+u.uid
        }
      else
        {
          "text" => u.cn,
          "id" => "g:"+u.cn
        }
      end
    }
  end

  def select_to_uid data
    data.reject! { | x | x.nil? or x.empty? }

    data = data[0].split(',')
  end

end
