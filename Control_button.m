classdef Control_button < Control_base    
    methods
        function obj = Control_button(hobj, model, callback)
            obj@Control_base(hobj, model);

            obj.hobj.Callback = callback;
        end

        function enable(obj, status)
            obj.hobj.Enable = status;
        end
    end
end
