require File.join File.dirname(__FILE__), 'pacemaker'

module Puppet
  newtype(:pcmk_location) do
    desc %q(Type for manipulating corosync/pacemaker location.  Location
      is the set of rules defining the place where resource will be run.
      More information on Corosync/Pacemaker location can be found here:
      * http://www.clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Clusters_from_Scratch/_ensuring_resources_run_on_the_same_host.html)

    ensurable
    include Puppet::Type::Pacemaker

    newparam(:name) do
      desc %q(Identifier of the location entry.  This value needs to be unique
        across the entire Corosync/Pacemaker configuration since it doesn\'t have
        the concept of name spaces per type.)
      isnamevar
    end

    newproperty(:primitive) do
      desc %q(Corosync primitive being managed.)
    end

    newparam(:cib) do
      desc %q(Corosync applies its configuration immediately. Using a CIB allows
        you to group multiple primitives and relationships to be applied at
        once. This can be necessary to insert complex configurations into
        Corosync correctly.

        This paramater sets the CIB this location should be created in. A
        cs_shadow resource with a title of the same name as this value should
        also be added to your manifest.)
    end

    newproperty(:score) do
      desc %q(The score for the node)

      validate do |value|
        break if %w(inf INFINITY -inf -INFINITY).include? value
        break if value.to_i.to_s == value
        fail 'Score parameter is invalid, should be +/- INFINITY(or inf) or Integer'
      end

      munge do |value|
        value.gsub 'inf', 'INFINITY'
      end
    end

    newproperty(:rules, :array_matching => :all) do
      desc %q(Specify rules for location)

      munge do |rule|
        resource.stringify_data rule
        if @rule_number
          @rule_number += 1
        else
          @rule_number = 0
        end
        resource.munge_rule rule, @rule_number, @resource[:name]
      end

      def insync?(is)
        resource.insync_debug is, should, 'rules'
        super
      end
    end

    newproperty(:node) do
      desc %q(The node for which to apply node score)
    end

    autorequire(:pcmk_shadow) do
      [parameter(:cib).value] if parameter :cib
    end

    autorequire(:service) do
      ['corosync']
    end

    autorequire(:pcmk_resource) do
      [parameter(:primitive).value] if parameter :primitive
    end

  end
end
