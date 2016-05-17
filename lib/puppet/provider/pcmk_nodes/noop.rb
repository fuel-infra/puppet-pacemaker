require_relative '../pcmk_noop'

Puppet::Type.type(:pcmk_nodes).provide(:noop, parent: Puppet::Provider::PcmkNoop) do
  # disable this provider
  confine(true: false)
end
