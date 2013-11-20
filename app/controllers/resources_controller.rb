class ResourcesController < UsersController

  def index
    @title = 'Resource management'
    @breadcrumbs.concat([ crumbs[:resources] ])

    if request.post?
      @resources = Resource.find(:all, :filter => "(&(|(uid=*#{params[:search]}*)(cn=*#{params[:search]}*)(mail=*#{params[:search]}*))(zarafaResourceType=*))")

      render :partial => 'resources', :layout => false
    end
  end

  def new
    @title = 'Create a new resource'
    @breadcrumbs.concat([ crumbs[:resources], 'Create a new resource' ])

    @resource = Resource.new
  end

  def save
    @title = 'Create a new resource'

    params[:resource][:uid] = resource_params[:sn].parameterize('_')
    @resource = Resource.new(resource_params[:uid])
    @resource.zarafaSharedStoreOnly = 1
    @resource.userPassword = ""
    @resource.uidNumber = next_uidnumber
    @resource.zarafaResourceType = resource_params[:zarafaResourceType]
    @resource.zarafaResourceCapacity = resource_params[:zarafaResourceCapacity]
    @resource.zarafaResourceCapacity = 1 if @resource.zarafaResourceType == "room"
    @resource.zarafaAdmin = 0
    @resource.zarafaAccount = 1
    @resource.zarafaHidden = 0
    @resource.gidNumber = 1000
    @resource.homeDirectory = '/dev/null'
    @resource.displayName = @resource.givenName = @resource.sn = @resource.cn = resource_params[:sn]
    @resource.mail = resource_params[:mail]

    if @resource.valid?
      if @resource.save
        flash[:success] = "Resource '#{@resource.uid}' was successfully created."

        redirect_to resources_path and return
      end
    else
      @messages[:danger] = "Some fields are in error, unable to save the resource"
    end

    render :new
  end

  def edit
    @resource = Resource.find(params[:uid])

    @title = "Edit resource #{@resource.uid}"
    @breadcrumbs.concat([ crumbs[:resources], "Edit resource #{@resource.uid}" ])

    if request.patch?
      @resource.mail = resource_params[:mail]
      @resource.displayName = @resource.givenName = @resource.sn = @resource.cn = resource_params[:sn]
      @resource.zarafaResourceType = resource_params[:zarafaResourceType]
      @resource.zarafaResourceCapacity = resource_params[:zarafaResourceCapacity]

      if @resource.zarafaResourceType == "room" or @resource.zarafaResourceType.empty?
        @resource.zarafaResourceCapacity = 1
      end

      if @resource.valid?
        if @resource.save
          flash[:success] = "Resource '#{@resource.uid}' was successfully updated."

          redirect_to resources_path and return
        end
      else
        @messages[:danger] = 'Some fields are in error, unable to save the resource'
      end
    end
  end

  def delete
    resource = Resource.find(params[:uid])

    if resource.destroy
      flash[:success] = "Resource '#{resource.uid}' was successfully deleted."

      redirect_to resources_path
    end
  end

  private

  def resource_params
    params.require(:resource).permit(:uid,
                                     :zarafaResourceType,
                                     :zarafaResourceCapacity,
                                     :sn,
                                     :mail
    )
  end

  def crumbs
    {
      :resources    => { :title => 'Resources management', :link => :resources }
    }
  end
end
