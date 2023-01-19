clc;
clear;
close all;

%%

cd("Measurement_11_01_2023\");
load("data_sorted.mat");

start_force_data = 6;
frame_col = 1;
subframe_col = 2;
column_of_interest = 5;
number_trials = length(fieldnames(vicon.raw));
stride = struct();


for n_trial = 1:number_trials
    current_trial_data =  force.(strcat("trial_",num2str(n_trial)));
    data_of_interest = cell2mat(current_trial_data(start_force_data:end, column_of_interest));
    [IC_idx, ~] = find(data_of_interest ~= 0, 1, "first");
    IC_idx_corrected(n_trial) = IC_idx + start_force_data -1;

    if current_trial_data{IC_idx_corrected(n_trial), subframe_col} == 0
        stride.start(n_trial) = IC_idx_corrected(n_trial);
    else
        subframe_list = cell2mat(current_trial_data(IC_idx_corrected(n_trial):end, subframe_col));
        [subframe_zero_idx, ~] = find( subframe_list == 0, 1, "first");
        subframe_zero_idx_corrected(n_trial) = subframe_zero_idx +  IC_idx_corrected(n_trial) -1;
        stride.start(n_trial, 1) = current_trial_data{subframe_zero_idx_corrected(n_trial), frame_col};
    end
end


list_parameters = {'RAnkleAngles'}; % list parameters that should be displayed
axes_of_interest = [3,3]; % define axes that might be used for IC determination --> same order as parameters listed above
colors = [0.4660 0.6740 0.1880;0.8500 0.3250 0.0980;0 0.4470 0.7410]; % green/axes 3, orange/axes4, blue/axes5

idx_step_width_ICs = [4];
forward_direction = 0;

for current_parameter = 1:length(list_parameters)
    stride.all_endpoints.(cell2mat(list_parameters(current_parameter))) = nan(number_trials,1);
    stride.IC_occurance.(cell2mat(list_parameters(current_parameter))) = nan(50,number_trials); % 50 to be sure there is enough space to store all occurances
    figure(current_parameter)
    find_ICs = true;
    cycle_counter = 0;
    for n_trial = 1:number_trials
        current_data = vicon.sorted.(strcat("trial_",num2str(n_trial))).(cell2mat(list_parameters(current_parameter)));
        %plot all axes and point of IC based on forceplate
        for current_axes = 1:3
            subplot(5, 2, n_trial)
            plot(current_data(:,2+current_axes),'Color',colors(current_axes,:))
            hold on;
            min_value = min(current_data(:,3:5));
            max_value = max(current_data(:,3:5));
            line([stride.start(n_trial),stride.start(n_trial)], [min(min_value), max(max_value)],'Color', 'r','LineWidth', 1.5);
        end
        % get value of IC for all parameters
        stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial) = current_data(stride.start(n_trial),axes_of_interest(current_parameter));
        text((stride.start(n_trial) +5),(max(max_value) -5),num2str(stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial)));
        text((stride.start(n_trial) +5),(min(min_value) +5),num2str(stride.start(n_trial)));
        % search vectors for points where value of IC occurs again
        point_found_counter = 0;
        for data_point = 1:(size(current_data,1) -1)
            if current_data(data_point,axes_of_interest(current_parameter)) < stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial) &&...
                    stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial) < current_data(data_point+1,axes_of_interest(current_parameter))
                point_found_counter = point_found_counter +1;
                stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(point_found_counter, n_trial) = data_point;
            elseif current_data(data_point,axes_of_interest(current_parameter)) > stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial) &&...
                    stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial) > current_data(data_point+1,axes_of_interest(current_parameter))
                point_found_counter = point_found_counter +1;
                stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(point_found_counter, n_trial) = data_point;
            elseif current_data(data_point,axes_of_interest(current_parameter)) == stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial)
                point_found_counter = point_found_counter +1;
                stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(point_found_counter, n_trial) = data_point;
            end
        end
        % plot IC_occurances
        for i = 1:length(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(:,n_trial))
            if ~isnan(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(i,n_trial))
                plot(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(i,n_trial),...
                    current_data(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(i,n_trial),axes_of_interest(current_parameter)),'o','Color','r');
            end
        end
        if forward_direction

        elseif ~forward_direction
            % change to idx_pos = find(stride.ICoccurance.param ==
            % stride.start(n_trial))
            current_idx = stride.start(n_trial);
            while find_ICs
                cycle_counter = cycle_counter +1; 
                if current_idx < 1
                    find_ICs = false;
                end
                all_ICs(cycle_counter) = current_idx;
                current_idx = current_idx - idx_step_width_ICs(current_parameter);
            end
            stride.ICs(n_trial) = {all_ICs};
        end
    end
end


