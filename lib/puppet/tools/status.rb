require 'rubygems'
require 'puppet'

require_relative '../provider/pcmk_xml'

# This tool is like 'pcs status'. You can use it to view
# the status of the cluster as this library sees it
# using the debug output function.
#
# You can give it a dumped cib XML file for the first argument
# id you want to debug the code without Pacemaker running.

class Puppet::Provider::PcmkXML
  [:cibadmin, :crm_attribute, :crm_node, :crm_resource, :crm_attribute].each do |tool|
    define_method(tool) do |*args|
      command = [tool.to_s] + args
      if Puppet::Util::Execution.respond_to? :execute
        Puppet::Util::Execution.execute command
      else
        Puppet::Util.execute command
      end
    end
  end

  # override debug method
  def debug(msg)
    puts msg
  end
  alias :info :debug
end

common = Puppet::Provider::PcmkXML.new
if $ARGV[0] and File.exists? $ARGV[0]
  xml = File.read $ARGV[0]
  common.cib = xml
end

common.cib
puts common.cluster_debug_report
