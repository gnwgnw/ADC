classdef Control_base < View_base
    methods
        function obj = Control_base(hobj, model)
            obj@View_base(hobj, model);
        end
    end

    methods (Abstract)
        enable(obj, status);
        % status == 'on' | 'off'
    end
end
