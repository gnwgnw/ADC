classdef View_text < View_base
    properties (Access = protected)
        listen_prop_name;
    end
    
    methods
        function obj = View_text(hobj, model, prop_name)
            obj@View_base(hobj, model);
            
            obj.listen_prop_name = prop_name;
            
            obj.init_listeners();
        end
    end   
    
    methods (Access = private)
        function init_listeners(obj)
            addlistener(obj.model, obj.listen_prop_name, 'PostSet', @obj.on_change);
        end
        
        function on_change(obj, ~, ~)
            obj.hobj.String = obj.model.(obj.listen_prop_name);
        end
    end
end
