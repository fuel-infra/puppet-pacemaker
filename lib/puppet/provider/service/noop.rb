require_relative '../pcmk_noop'

Puppet::Type.type(:service).provide(:noop, parent: Puppet::Provider::PcmkNoop) do
  # disable this provider
  confine(true: false)
end
