classdef (Abstract) View_base < handle
    properties
        hobj;
        model;
    end

    methods 
        function obj = View_base(hobj, model)
            obj.hobj = hobj;
            obj.model = model;
        end
    end
end
