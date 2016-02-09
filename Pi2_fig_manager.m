classdef Pi2_fig_manager < handle
    properties (Access = private)
        model;
        fig;

        views;
        controls;

        class_name;
    end

    properties (Access = private, Constant)
        views_adapter = {
            {'axes_XY', 'View_plot', 'T, X'}
            {'axes_XY', 'View_plot', 'T, Y'}
            {'axes_G', 'View_plot', 'X, Y'}
            {'axes_L', 'View_plot', 'T, L'}
            {'axes_P', 'View_plotyy', 'T, P, T_diff, dP'}
            {'axes_u', 'View_plot', 'T_diff, u'}
            {'text_filename', 'View_text', 'dir_path'}
            {'text_K', 'View_text', 'K_phi'}
        };

        control_adapter = {
            {'edit_model_lenght', 'Control_edit', 'model_lenght'}
            {'edit_t0', 'Control_edit', 't_0'}
            {'edit_t1', 'Control_edit', 't_1'}
            {'edit_S11_X', 'Control_edit', 'S11_X'}
            {'edit_S11_Y', 'Control_edit', 'S11_Y'}
            {'edit_S22_X', 'Control_edit', 'S22_X'}
            {'edit_S22_Y', 'Control_edit', 'S22_Y'}
            {'edit_peaks_limit_from', 'Control_edit', 'peaks_limit_from'}
            {'edit_peaks_limit_to', 'Control_edit', 'peaks_limit_to'}
        };

        button_adapter = {
            {'button_load', 'Control_button', 'on_load_callback'}
            {'button_save', 'Control_button', 'on_save_callback'}
            {'button_filter_X', 'Control_button', 'on_filter_callback'}
            {'button_filter_Y', 'Control_button', 'on_filter_callback'}
            {'button_filter_P', 'Control_button', 'on_filter_callback'}
            {'button_up', 'Control_button', 'on_shift_callback'}
            {'button_down', 'Control_button', 'on_shift_callback'}
            {'button_left', 'Control_button', 'on_shift_callback'}
            {'button_right', 'Control_button', 'on_shift_callback'}
            {'button_find_S11', 'Control_button', 'on_find_S11_callback'}
        };
    end

    methods
        function obj = Pi2_fig_manager()
            obj.fig = openfig('Pi2.fig');
            figure(obj.fig);

            obj.model = ADC_model;

            meta = metaclass(obj);
            obj.class_name = meta.Name;

            cellfun(@obj.add_view, obj.views_adapter);
            cellfun(@obj.add_control, obj.control_adapter);
            cellfun(@obj.add_button, obj.button_adapter);

            obj.equal_axis_G();

            obj.enable_control('off');
            obj.enable_button_load();
        end
    end

    methods (Access = private)
        function on_load_callback(obj, ~, ~)
            [filename, pathname] = uigetfile('out.txt', 'Select a data file');
            obj.model.load(filename, pathname);

            obj.enable_control('on');
        end
        function on_save_callback(obj, ~, ~)
            obj.model.save();
        end

        function on_filter_callback(obj, ui_handle, ~)
            component_name = strrep(ui_handle.Tag, 'button_filter_', '');
            component_name_filter = [component_name '_filter'];
            component_name_filth = [component_name '_filth'];

            obj.model.(component_name_filter) = accept_filter(obj.model.(component_name_filth), obj.model.freq);
        end

        function on_shift_callback(obj, ui_handle, ~)
            dir = strrep(ui_handle.Tag, 'button_', '');
            obj.shift(dir);
        end

        function on_find_S11_callback(obj, ~, ~)
            obj.model.find_S11();
        end

        function on_keyevent(obj, ~, event)
            res = regexp(event.Key,'(\w+)arrow','match');
            if ~isempty(res)
                dir = strrep(event.Key, 'arrow', '');
                obj.shift(dir);
            end
        end
    end

    methods (Access = private)
        function add_view(obj, adapter)
            h = findobj(obj.fig, 'Tag', adapter{1});
            v = feval(adapter{2}, h, obj.model, adapter{3});
            obj.views{end + 1} = v;
        end

        function add_control(obj, adapter)
            h = findobj(obj.fig, 'Tag', adapter{1});
            v = feval(adapter{2}, h, obj.model, adapter{3});
            obj.controls{end + 1} = v;
        end

        function add_button(obj, adapter)
            h = findobj(obj.fig, 'Tag', adapter{1});

            callback = [obj.class_name '.' adapter{3}];
            callback = str2func(callback);

            v = feval(adapter{2}, h, obj.model, @(ui,data) callback(obj,ui,data));
            obj.controls{end + 1} = v;
        end

        function shift(obj, dir)
            h = findobj(obj.fig, 'Tag', 'button_group_component');
            component = h.SelectedObject.String;
            h = findobj(obj.fig, 'Tag', 'edit_multipler');
            multipler = str2double(h.String);

            switch component
                case 'Scale Y'
                    % TODO
                case {'S11' 'S22'}
                    switch dir
                        case 'up'
                            a = 1;
                            b = 'Y';
                        case 'down'
                            a = -1;
                            b = 'Y';
                        case 'left'
                            a = -1;
                            b = 'X';
                        case 'right'
                            a = 1;
                            b = 'X';
                    end
                    component = [component, '_', b];
                    obj.model.(component) = obj.model.(component) + a * multipler;
            end
        end

        function enable_control(obj, status)
            f = @(e) e.enable(status);

            cellfun(f, obj.controls);

            switch status
                case 'on'
                    obj.fig.WindowKeyPressFcn = @obj.on_keyevent;
                case 'off'
                    obj.fig.WindowKeyPressFcn = [];
            end
        end

        function equal_axis_G(obj)
            h = obj.fig.findobj('Tag', 'axes_G');
            axes(h);
            axis equal;
        end

        function enable_button_load(obj)
            h = obj.fig.findobj('Tag', 'button_load');
            h.Enable = 'on';
        end
    end
end
