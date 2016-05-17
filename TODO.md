* add pcmk_group type
* pcmk_location add date_expressions support
* pcmk_location rules format/validation
* pcmk_resource convert complex to simple and back
* pcmk_resource add utilization support
* cleanup unused methods from pcmk_nodes provider
* unit tests for location, colocation, order autorequire functions
* change tests behaviour according to the options and test several possible options
* noop provider is not working for non-ensurable types
* colocation/location/order will prevent its primitives from being removed. remove constraints first?
* primitive should use similar functions to constraint_location_add/remove to reduce code duplication
* primitive_is_started? and primitive_is_managed don't support resource defaults and management-mode
