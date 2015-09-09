require 'facter'

Facter.add('pcmk_node_name') do
  setcode do
    Facter::Util::Resolution.exec 'crm_node -n'
  end
end
