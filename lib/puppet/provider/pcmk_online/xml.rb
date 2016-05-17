require_relative '../pcmk_xml'

Puppet::Type.type(:pcmk_online).provide(:xml, parent: Puppet::Provider::PcmkXML) do
  desc 'Use pacemaker library to wait for the cluster to become online before trying to do something with it.'

  commands cibadmin: 'cibadmin'
  commands crm_attribute: 'crm_attribute'

  # get the cluster status
  # @return [Symbol]
  def status
    if online?
      :online
    else
      :offline
    end
  end

  # wait for the cluster to become online
  # is status is set to :online
  # @param value [Symbol]
  def status=(value)
    wait_for_online 'pcmk_online' if value == :online
  end
end
