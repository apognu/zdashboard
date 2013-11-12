module UsersHelper

  def uid_to_select data
    data.nil? { return nil}
    data.reject! { | x | x.nil? }

    list = []
    data.map! { | u |
      tmp = {
        "text" => u.cn,
        "id" => u.uid
      }
      list.push(tmp)
    }
    data = list
  end

  def select_to_uid data
    data.reject! { | x | x.nil? or x.empty? }

    data = data[0].split(',')
  end

end
