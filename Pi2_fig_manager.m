classdef Pi2_fig_manager < handle
    properties (Access = private)
        model;
        fig;

        views;
        controls;

        load_button;
        filter_buttons;
        shift_buttons;
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
        };

        load_button_tag = 'button_load';

        filter_buttons_tag = {
            'button_filter_X'
            'button_filter_Y'
            'button_filter_P'
        };

        shift_buttons_tag = {
            'button_up'
            'button_down'
            'button_left'
            'button_right'
        };
    end

    methods
        function obj = Pi2_fig_manager()
            obj.fig = openfig('Pi2.fig');
            figure(obj.fig);

            obj.model = ADC_model;

            cellfun(@obj.add_view, obj.views_adapter);
            cellfun(@obj.add_control, obj.control_adapter);

            obj.init_load_button();
            obj.init_filter_buttons();
            obj.init_shift_buttons();

            obj.enable_control('off');
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

        function add_filter_button(obj, tag)
            h = findobj(obj.fig, 'Tag', tag);
            h.Callback = @obj.on_filter_callback;
            obj.filter_buttons{end + 1} = h;
        end

        function add_shift_button(obj, tag)
            h = findobj(obj.fig, 'Tag', tag);
            h.Callback = @obj.on_shift_callback;
            obj.shift_buttons{end + 1} = h;
        end

        function init_load_button(obj)
            obj.load_button = findobj(obj.fig, 'Tag', obj.load_button_tag);
            obj.load_button.Callback = @obj.on_load_callback;
        end

        function init_filter_buttons(obj)
            cellfun(@obj.add_filter_button, obj.filter_buttons_tag);
        end

        function init_shift_buttons(obj)
            cellfun(@obj.add_shift_button, obj.shift_buttons_tag);
        end

        function on_load_callback(obj, ~, ~)
            [filename, pathname] = uigetfile('out.txt', 'Select a data file');
            obj.model.load(filename, pathname);

            obj.enable_control('on');
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

        function on_keyevent(obj, ~, event)
            res = regexp(event.Key,'(\w+)arrow','match');
            if ~isempty(res)
                dir = strrep(event.Key, 'arrow', '');
                obj.shift(dir);
            end
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
            c = @(e) set(e, 'enable', status);

            cellfun(f, obj.controls);
            cellfun(c, obj.filter_buttons);
            cellfun(c, obj.shift_buttons);

            switch status
                case 'on'
                    obj.fig.WindowKeyPressFcn = @obj.on_keyevent;
                case 'off'
                    obj.fig.WindowKeyPressFcn = [];
            end
        end
    end
end
