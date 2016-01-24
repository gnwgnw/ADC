classdef Control_base < handle
    properties
        hobj;
        model;
    end

    methods
        function obj = Control_base(hobj, model)
            obj.hobj = hobj;
            obj.model = model;
        end
    end

    methods (Abstract)
        enable(obj, status);
        % status == 'on' | 'off'
    end
end
