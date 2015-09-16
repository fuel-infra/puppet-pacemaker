require 'rexml/document'
require 'rexml/formatters/pretty'
require 'timeout'
require 'yaml'

base = File.expand_path File.dirname(__FILE__)

require File.join base, 'cib'
require File.join base, 'constraints'
require File.join base, 'constraint_colocations'
require File.join base, 'constraint_locations'
require File.join base, 'constraint_orders'
require File.join base, 'helpers'
require File.join base, 'nodes'
require File.join base, 'options'
require File.join base, 'resources'
require File.join base, 'properties'
require File.join base, 'debug'
require File.join base, 'resource_defaults'
require File.join base, 'operation_defaults'
require File.join base, 'status'
require File.join base, 'wait'
require File.join base, 'xml'

class Puppet::Provider::Pacemaker < Puppet::Provider

  include ::Pacemaker::Cib
  include ::Pacemaker::Constraints
  include ::Pacemaker::ConstraintOrders
  include ::Pacemaker::ConstraintLocations
  include ::Pacemaker::ConstraintColocations
  include ::Pacemaker::Helpers
  include ::Pacemaker::Nodes
  include ::Pacemaker::Options
  include ::Pacemaker::Resources
  include ::Pacemaker::Properties
  include ::Pacemaker::Debug
  include ::Pacemaker::Resource_defaults
  include ::Pacemaker::Operation_defaults
  include ::Pacemaker::Status
  include ::Pacemaker::Wait
  include ::Pacemaker::Xml

  #def initialize(*args)
  #  cib_reset 'initialize'
  #  super
  #end

  # reset all saved variables to obtain new data
  def cib_reset(comment=nil)
    message = 'Call: cib_reset'
    message += " (#{comment})" if comment
    debug message

    @raw_cib = nil
    @cib_file = nil
    @cib = nil

    @primitives_structure = nil
    @locations_structure = nil
    @colocations_structure = nil
    @orders_structure = nil
    @node_status_structure = nil
    @cluster_properties_structure
    @nodes_structure = nil
    @resource_defaults_structure = nil
    @operation_defaults_structure = nil
  end

end

# TODO: groups
# TODO: resource <-> constraint autorequire/autobefore
# TODO: constraint fail is resource missing
# TODO: resource refuse to delete if constrains present or remove them too
# TODO: refactor status-metadata processing
# TODO: refactor options
# TODO: options and rules arrays sort? sets?
# TODO: should_to_s and is_to_s for array/hash params of some types
