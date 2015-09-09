require File.join File.dirname(__FILE__), '../pacemaker/provider'

Puppet::Type.type(:pcmk_operation_default).provide(:ruby, :parent => Puppet::Provider::Pacemaker) do
  desc 'Specific operation_default for a rather specific type since I currently have no plan to
        abstract corosync/pacemaker vs. keepalived. This op_defaults will check the state
        of Corosync cluster configuration properties.'

  commands :cibadmin => 'cibadmin'
  commands :crm_attribute => 'crm_attribute'
  commands :crm_node => 'crm_node'
  commands :crm_resource => 'crm_resource'
  commands :crm_attribute => 'crm_attribute'

  #TODO instances
  #TODO prefetch

  attr_accessor :property_hash
  attr_accessor :resource

  def exists?
    debug "Call: exists? on '#{resource}'"
    out = operation_default_defined? resource[:name]
    debug "Return: #{out}"
    out
  end

  def create
    debug "Call: create on '#{resource}'"
    self.value = resource[:value]
  end

  def destroy
    debug "Call: destroy on '#{resource}'"
    operation_default_delete resource[:name]
  end

  def value
    debug "Call: value on '#{resource}'"
    out = operation_default_value resource[:name]
    debug "Return: #{out}"
    out
  end

  def value=(should)
    debug "Call: value=#{should} on '#{resource}'"
    operation_default_set resource[:name], should
  end

end
