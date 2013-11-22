module GroupsHelper

  def gid_to_select data
    data.nil? { return nil}
    data.reject! { | x | x.nil? }

    list = []
    data.map! { | group |
      tmp = {
        "text" => group.cn,
        "id" => group.cn
      }
      list.push(tmp)
    }
    data = list
  end

end
