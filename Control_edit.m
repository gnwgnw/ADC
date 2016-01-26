classdef Control_edit < Control_base
    properties
        listen_prop_name;
    end

    methods
        function obj = Control_edit(hobj, model, prop_name)
            obj@Control_base(hobj, model);

            obj.listen_prop_name = prop_name;

            obj.set_data_to_text();

            obj.init_listeners();
            obj.init_callbacks();
        end

        function enable(obj, status)
            obj.hobj.Enable = status;
        end
    end

    methods (Access = private)
        function init_listeners(obj)
            addlistener(obj.model, obj.listen_prop_name, 'PostSet', @obj.on_change);
        end

        function on_change(obj, ~, ~)
            obj.set_data_to_text();
        end

        function init_callbacks(obj)
            obj.hobj.Callback = @obj.callback;
        end

        function callback(obj,~,~)
            val = str2double(obj.hobj.String);
            obj.model.(obj.listen_prop_name) = val;
        end

        function set_data_to_text(obj)
            obj.hobj.String = obj.model.(obj.listen_prop_name);
        end
    end
end
