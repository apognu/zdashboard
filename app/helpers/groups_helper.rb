module GroupsHelper

  def gid_to_select data
    data.nil? { return nil}
    data.reject! { | x | x.nil? }

    data.map! do | group |
      {
        "text" => group.cn,
        "id" => group.cn
      }
    end
  end

end
