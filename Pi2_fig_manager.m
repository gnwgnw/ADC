classdef Pi2_fig_manager < handle
    properties (Access = private)
        model;
        fig;

        views;
        controls;

        load_button;
        filter_buttons;
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

        function init_load_button(obj)
            obj.load_button = findobj(obj.fig, 'Tag', obj.load_button_tag);
            obj.load_button.Callback = @obj.on_load_callback;
        end

        function init_filter_buttons(obj)
            cellfun(@obj.add_filter_button, obj.filter_buttons_tag);
        end

        function on_load_callback(obj, ~, ~)
            [filename, pathname] = uigetfile('out.txt', 'Select a data file');
            obj.model.load(filename, pathname);
        end

        function on_filter_callback(obj, ui_handle, ~)
            component_name = strrep(ui_handle.Tag, 'button_filter_', '');
            component_name_filter = [component_name '_filter'];

            obj.model.(component_name_filter) = accept_filter(obj.model.(component_name), obj.model.freq);
        end
    end
end
