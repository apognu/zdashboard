class ContactsController < ApplicationController
  include ApplicationHelper
  include GroupsHelper

  def index
    @title = 'Contact management'
    @breadcrumbs.concat([ crumbs[:contacts] ])

    if request.post?
      params[:search].gsub!("(", "\\(")
      params[:search].gsub!(")", "\\)")
      @contacts = Contact.find(:all, :filter => "(&(|(uid=*#{params[:search]}*)(cn=*#{params[:search]}*)(mail=*#{params[:search]}*@*)))")
      render :partial => "contacts", :layout => false
    end
  end

  def new
    @title = 'Create a new contact'
    @breadcrumbs.concat([ crumbs[:contacts], 'Create a new contact' ])

    @contact = Contact.new
    @groups = ""

  end

  def save
    @title = 'Create a new contact'

    @contact = Contact.new(sanitize_dn(contact_params[:uid]))
    @contact.mail = contact_params[:mail]
    @contact.givenName = contact_params[:givenName]
    @contact.sn = contact_params[:sn]
    @contact.displayName = "#{contact_params[:givenName]} #{contact_params[:sn]}" unless contact_params[:givenName].empty? and contact_params[:sn].empty?
    @contact.commonName = @contact.displayName
    @contact.zarafaHidden = contact_params[:zarafaHidden]
    @contact.groups = []

    # Is this used?
    @contact.gidNumber = 1000;
    @contact.homeDirectory = '/dev/null'
    @contact.uidNumber = next_uidnumber

    if @contact.valid?
      if ! contact_params[:groups].nil?
        contact_params[:groups].reject! { | x | x.nil? or x.empty? or x == "all" }

        unless contact_params[:groups][0].nil?
          groups = contact_params[:groups][0].split(',')
          @contact.groups = groups.map! { | group |
            group = Group.find(group)
            group.members << @contact
          }
        end
        add_to_group_all
      end

      if @contact.save
        flash[:success] = "Contact '#{@contact.uid}' was successfully created."

        redirect_to contacts_path and return
      end
    else
      @messages[:danger] = 'Some fields are in error, unable to save the contact'
      #@messages[:danger] = @contact.errors.full_messages
    end

    render :new
  end

  def edit
    @contact = Contact.find(params[:uid], :attributes => ["+", "*"])

    groups = gid_to_select @contact.groups
    @groups = groups.to_json

    @title = "Edit contact #{@contact.uid}"
    @breadcrumbs.concat([ crumbs[:contacts], "Edit contact #{@contact.uid}" ])

  end

  def update
    @contact = Contact.find(params[:uid])
    @contact.mail = contact_params[:mail]
    @contact.givenName = contact_params[:givenName]
    @contact.sn = contact_params[:sn]
    @contact.displayName = "#{contact_params[:givenName]} #{contact_params[:sn]}"
    @contact.commonName = @contact.displayName
    @contact.zarafaHidden = contact_params[:zarafaHidden]
    @contact.groups = []

    if ! contact_params[:groups].nil?
      contact_params[:groups].reject! { | x | x.nil? or x.empty? }

      unless contact_params[:groups][0].nil?
        groups = contact_params[:groups][0].split(',')

        @contact.groups = groups.map! { | group |
          Group.find(group)
        }

        @groups = gid_to_select(@contact.groups).to_json
      end
    end

    if @contact.valid?
      if @contact.save
        flash[:success] = "Contact '#{@contact.uid}' was successfully edited."
  
        redirect_to contacts_path and return
      end
    else
      @messages[:danger] = 'Some fields are in error, unable to save the contact'
    end

    render :edit
  end

  def delete
    contact = Contact.find(params[:uid])

    # Only one group?
    group = contact.groups
    unless group.empty?
      group.each do | g |
        g.members = g.members.reject { |u| u == contact }
        g.save
      end
    end

    if contact.destroy
      flash[:success] = "Contact '#{contact.uid}' was successfully deleted."

      redirect_to contacts_path
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:uid,
                                    :givenName,
                                    :sn,
                                    :mail,
                                    :zarafaHidden,
                                    :groups => [],
    )
  end

  def next_uidnumber
    contacts = Contact.find(:all, :attribute => 'uidNumber')
    users = User.find(:all, :attribute => 'uidNumber')

    users.concat(contacts)

    users.max_by { | user | user.uidNumber }.uidNumber + 1
  end

  def crumbs
    {
      :contacts    => { :title => 'Contacts management', :link => :contacts }
    }
  end

  def add_to_group_all
    group = Group.find(:first, :attribute => "cn", :value => "all");
    group.members << @contact

    @contact.groups.push group
    @groups = gid_to_select(@contact.groups).to_json
  end
end
