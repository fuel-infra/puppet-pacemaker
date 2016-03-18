require_relative '../pcmk_xml'

Puppet::Type.type(:service).provide(:pacemaker, :parent => Puppet::Provider::PcmkXML) do

  has_feature :enableable
  has_feature :refreshable

  commands :crm_node => 'crm_node'
  commands :crm_resource => 'crm_resource'
  commands :crm_attribute => 'crm_attribute'
  commands :cibadmin => 'cibadmin'

  # original title of the service
  # @return [String]
  def service_title
    @resource.title
  end

  # original name of the service
  # in most cases will be equal to the title
  # but can be different
  # @return [String]
  def service_name
    resource[:name]
  end

  # check if the service name is the same as service title
  # @return [true,false]
  def name_equals_title?
    service_title == service_name
  end

  # find a primitive name that is present in the CIB
  # or nil if none is present
  # @return [String,nil]
  def pick_existing_name(*names)
    names.flatten.find do |name|
      primitive_exists? name
    end
  end

  # generate a list of strings the service name could be written as
  # perhaps, one of them could be found in the CIB
  # @param name [String]
  # @return [Array<String>]
  def service_name_variations(name)
    name = name.to_s
    variations = []
    variations << name
    if name.start_with? 'p_'
      variations << name.gsub(/^p_/, '')
    else
      variations << "p_#{name}"
    end

    simple_name =  name.gsub(/^(ms-)|(clone-)/, '')
    unless simple_name == name
      variations << simple_name
      if simple_name.start_with? 'p_'
        variations << simple_name.gsub(/^p_/, '')
      else
        variations << "p_#{simple_name}"
      end
    end
    variations
  end

  # get the correct name of the service primitive
  # @return [String]
  def name
    return @name if @name
    @name = pick_existing_name service_name_variations(service_title), service_name_variations(service_name)
    if @name
      message = "Using CIB name '#{@name}' for primitive '#{service_title}'"
      message += " with name '#{service_name}'" unless name_equals_title?
      debug message
    else
      message = "Primitive '#{service_title}'"
      message += " with name '#{service_name}'" unless name_equals_title?
      message += ' was not found in CIB!'
      fail message
    end
    @name
  end

  # full name of the primitive
  # if resource is complex use group name
  # @return [String]
  def full_name
    return @full_name if @full_name
    if primitive_is_complex? name
      full_name = primitives[name]['name']
      debug "Using full name '#{full_name}' for complex primitive '#{name}'"
      @full_name = full_name
    else
      @full_name = name
    end
  end

  # name of the basic service without 'p_' prefix
  # used to disable the basic service.
  # Uses unmodified "name" property if it's not the same as title
  # because most likely it will be the real system service name
  # @return [String]
  def basic_service_name
    return service_name unless name_equals_title?
    return @basic_service_name if @basic_service_name
    if name.start_with? 'p_'
      basic_service_name = name.gsub(/^p_/, '')
      debug "Using '#{basic_service_name}' as the basic service name for primitive '#{name}'"
      @basic_service_name = basic_service_name
    else
      @basic_service_name = name
    end
  end

  # cleanup a primitive and
  # wait until cleanup finishes
  def cleanup
    cleanup_primitive full_name, hostname
    wait_for_status name
  end

  # called by Puppet to determine if the service
  # is running on the local node
  # @return [:running,:stopped]
  def status
    debug "Call: 'status' for Pacemaker service '#{name}' on node '#{hostname}'"
    cib_reset 'service_status'
    wait_for_online 'service_status'

    if pacemaker_options[:cleanup_on_status]
      if not pacemaker_options[:cleanup_only_if_failures] or primitive_has_failures? name, hostname
        cleanup
      end
    end

    if primitive_is_multistate? name
      out = service_status_mode pacemaker_options[:status_mode_multistate]
    elsif primitive_is_clone? name
      out = service_status_mode pacemaker_options[:status_mode_clone]
    else
      out = service_status_mode pacemaker_options[:status_mode_simple]
    end

    if pacemaker_options[:add_location_constraint]
      if out == :running and not service_location_exists? full_name, hostname
        debug 'Location constraint is missing. Service status set to "stopped".'
        out = :stopped
      end
    end

    disable_basic_service if pacemaker_options[:disable_basic_service]

    debug "Return: '#{out}' (#{out.class})"
    debug cluster_debug_report "#{@resource} status"
    out
  end

  # called by Puppet to start the service
  def start
    debug "Call 'start' for Pacemaker service '#{name}' on node '#{hostname}'"
    enable unless primitive_is_managed? name

    if pacemaker_options[:cleanup_on_start]
      if not pacemaker_options[:cleanup_only_if_failures] or primitive_has_failures? name, hostname
        cleanup
      end
    end

    if pacemaker_options[:add_location_constraint]
      service_location_add full_name, hostname unless service_location_exists? full_name, hostname
    end

    disable_basic_service if pacemaker_options[:disable_basic_service]

    unban_primitive name, hostname
    start_primitive name
    start_primitive full_name

    if primitive_is_multistate? name
      debug "Choose master start for Pacemaker service '#{name}'"
      wait_for_master name
    else
      service_start_mode pacemaker_options[:start_mode_simple]
    end
    debug cluster_debug_report "#{@resource} start"
  end

  # called by Puppet to stop the service
  def stop
    debug "Call 'stop' for Pacemaker service '#{name}' on node '#{hostname}'"
    enable unless primitive_is_managed? name

    if pacemaker_options[:cleanup_on_stop]
      if not pacemaker_options[:cleanup_only_if_failures] or primitive_has_failures? name, hostname
        cleanup
      end
    end

    disable_basic_service if pacemaker_options[:disable_basic_service]

    if primitive_is_multistate? name
      service_stop_mode pacemaker_options[:stop_mode_multistate]
    elsif primitive_is_clone? name
      service_stop_mode pacemaker_options[:stop_mode_clone]
    else
      service_stop_mode pacemaker_options[:stop_mode_simple]
    end
    debug cluster_debug_report "#{@resource} stop"
  end

  # called by Puppet to restart the service
  def restart
    debug "Call 'restart' for Pacemaker service '#{name}' on node '#{hostname}'"
    if pacemaker_options[:restart_only_if_local] and not primitive_is_running? name, hostname
      Puppet.info "Pacemaker service '#{name}' is not running on node '#{hostname}'. Skipping restart!"
      return
    end

    begin
      stop
    rescue
      nil
    ensure
      start
    end
  end

  # wait for the service to start using
  # the selected method.
  # @param mode [:global, :master, :local]
  def service_start_mode(mode = :global)
    if mode == :master
      debug "Choose master start for Pacemaker service '#{name}'"
      wait_for_master name
    elsif mode == :local
      debug "Choose local start for Pacemaker service '#{name}' on node '#{hostname}'"
      wait_for_start name, hostname
    elsif :global
      debug "Choose global start for Pacemaker service '#{name}'"
      wait_for_start name
    else
      fail "Unknown service start mode '#{mode}'"
    end
  end

  # wait for the service to stop using
  # the selected method.
  # @param mode [:global, :master, :local]
  def service_stop_mode(mode = :global)
    if mode == :local
      debug "Choose local stop for Pacemaker service '#{name}' on node '#{hostname}'"
      ban_primitive name, hostname
      wait_for_stop name, hostname
    elsif mode == :global
      debug "Choose global stop for Pacemaker service '#{name}'"
      stop_primitive name
      wait_for_stop name
    else
      fail "Unknown service stop mode '#{mode}'"
    end
  end

  # determine the status of the service using
  # the selected method.
  # @param mode [:global, :master, :local]
  # @return [:running,:stopped]
  def service_status_mode(mode = :local)
    if mode == :local
      debug "Choose local status for Pacemaker service '#{name}' on node '#{hostname}'"
      get_primitive_puppet_status name, hostname
    elsif mode == :global
      debug "Choose global status for Pacemaker service '#{name}'"
      get_primitive_puppet_status name
    else
      fail "Unknown service status mode '#{mode}'"
    end
  end

  # called by Puppet to enable the service
  def enable
    debug "Call 'enable' for Pacemaker service '#{name}' on node '#{hostname}'"
    manage_primitive name
  end

  # called by Puppet to disable  the service
  def disable
    debug "Call 'disable' for Pacemaker service '#{name}' on node '#{hostname}'"
    unmanage_primitive name
  end

  alias :manual_start :disable

  # called by Puppet to determine if the service is enabled
  # @return [:true,:false]
  def enabled?
    debug "Call 'enabled?' for Pacemaker service '#{name}' on node '#{hostname}'"
    out = get_primitive_puppet_enable name
    debug "Return: '#{out}' (#{out.class})"
    out
  end

  # create an extra provider instance to deal with the basic service
  # the provider will be chosen to match the current system
  # @return [Puppet::Type::Service::Provider]
  def extra_provider(provider_name = nil)
    return @extra_provider if @extra_provider
    begin
      param_hash = {}
      param_hash.store :name, basic_service_name
      param_hash.store :provider, provider_name if provider_name
      type = Puppet::Type::Service.new param_hash
      @extra_provider = type.provider
    rescue => e
      Puppet.info "Could not get extra provider for Pacemaker primitive '#{name}': #{e.message}"
      @extra_provider = nil
    end
  end

  # disable and stop the basic service
  def disable_basic_service
    # skip native-based primitive classes
    if pacemaker_options[:native_based_primitive_classes].include?(primitive_class name)
      Puppet.info "Not stopping basic service '#{basic_service_name}', since its Pacemaker primitive is using primitive_class '#{primitive_class name}'"
      return
    end

    return unless extra_provider
    begin
      if extra_provider.enableable? and extra_provider.enabled? == :true
        Puppet.info "Disable basic service '#{extra_provider.name}' using provider '#{extra_provider.class.name}'"
        extra_provider.disable
      else
        Puppet.info "Basic service '#{extra_provider.name}' is disabled as reported by '#{extra_provider.class.name}' provider"
      end
      if extra_provider.status == :running
        Puppet.info "Stop basic service '#{extra_provider.name}' using provider '#{extra_provider.class.name}'"
        extra_provider.stop
      else
        Puppet.info "Basic service '#{extra_provider.name}' is stopped as reported by '#{extra_provider.class.name}' provider"
      end
    rescue => e
      Puppet.info "Could not disable basic service for Pacemaker primitive '#{name}' using '#{extra_provider.class.name}' provider: #{e.message}"
    end
  end

end
