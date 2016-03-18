require 'rexml/document'
require 'rexml/formatters/pretty'
require 'timeout'
require 'yaml'

require_relative '../pacemaker/cib'
require_relative '../pacemaker/constraints'
require_relative '../pacemaker/constraint_colocations'
require_relative '../pacemaker/constraint_locations'
require_relative '../pacemaker/constraint_orders'
require_relative '../pacemaker/helpers'
require_relative '../pacemaker/nodes'
require_relative '../pacemaker/options'
require_relative '../pacemaker/primitives'
require_relative '../pacemaker/properties'
require_relative '../pacemaker/debug'
require_relative '../pacemaker/resource_defaults'
require_relative '../pacemaker/operation_defaults'
require_relative '../pacemaker/status'
require_relative '../pacemaker/wait'
require_relative '../pacemaker/xml'
require_relative '../pacemaker/type'

# the parent provider for all other pacemaker providers
# includes all functions from all submodules
class Puppet::Provider::PcmkXML < Puppet::Provider

  # include instance methods from the pacemaker library files
  include Pacemaker::Cib
  include Pacemaker::Constraints
  include Pacemaker::ConstraintOrders
  include Pacemaker::ConstraintLocations
  include Pacemaker::ConstraintColocations
  include Pacemaker::Helpers
  include Pacemaker::Nodes
  include Pacemaker::Options
  include Pacemaker::Primitives
  include Pacemaker::Properties
  include Pacemaker::Debug
  include Pacemaker::Resource_defaults
  include Pacemaker::Operation_defaults
  include Pacemaker::Status
  include Pacemaker::Wait
  include Pacemaker::Xml
  include Pacemaker::Type

  # include class methods from the pacemaker options
  extend  Pacemaker::Options

  # reset all mnemoization variables
  # to force pacemaker to reload all the data structures
  # @param comment [String] log file comment tag to trace calls
  def cib_reset(comment=nil)
    message = 'Call: cib_reset'
    message += " (#{comment})" if comment
    debug message

    @cib = nil

    @primitives_structure = nil
    @locations_structure = nil
    @colocations_structure = nil
    @orders_structure = nil
    @node_status_structure = nil
    @cluster_properties_structure = nil
    @nodes_structure = nil
    @resource_defaults_structure = nil
    @operation_defaults_structure = nil
  end

end

# TODO: add pcmk_group type
# TODO: pcmk_location add date_expressions support
# TODO: pcmk_location rules format/validation
# TODO: pcmk_resource convert complex to simple and back
# TODO: pcmk_resource add utilization support
# TODO: cleanup unused methods from pcmk_nodes provider
# TODO: unit tests for location, colocation, order autorequire functions
# TODO: change tests behaviour according to the options and test several possible options
# TODO: noop provider is not working for non-ensurable types
# TODO: colocation/location/order will prevent its primitives from being removed. remove constraints first?
# TODO: primitive should use similar functions to constraint_location_add/remove to reduce code duplication
