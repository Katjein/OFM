clc;
clear;
close all;

%% CHANGE ME 
barefoot_flag = 1;
shoe_flag = 0;

cd("barefoot\"); 
load("data_sorted.mat");

start_force_data = 6;
frame_col = 1;
subframe_col = 2;
column_of_interest = 3;
number_trials = length(fieldnames(vicon.raw));
stride = struct();
cycles_complete = struct();
columns_data_cycles = [3:5]; %#ok<*NBRAK2> 

for n_trial = 1:number_trials
    current_trial_data =  force.(strcat("trial_",num2str(n_trial)));
    data_of_interest = cell2mat(current_trial_data(start_force_data:end, column_of_interest));
    [IC_idx(n_trial), ~] = find(data_of_interest ~= 0, 1, "first"); %#ok<*SAGROW> 
    IC_idx_corrected(n_trial) = IC_idx(n_trial) + start_force_data - 1;
    stride.start(n_trial, 1) = current_trial_data{IC_idx_corrected(n_trial),frame_col};
end
% clear variables that are not further accessed
clear current_trial_data data_of_interest IC_idx IC_idx_corrected


list_parameters = {'RKneeAngles'}; % list parameters that should be displayed
axes_of_interest = 3; % define axes that might be used for IC determination --> same order as parameters listed above
colors = [0.4660 0.6740 0.1880;0.8500 0.3250 0.0980;0 0.4470 0.7410]; % green/axes 3, orange/axes4, blue/axes5

stride.ICs = struct();
stride.ICs = cell(number_trials, 1);
for current_parameter = 1:length(list_parameters)
    stride.all_endpoints.(cell2mat(list_parameters(current_parameter))) = nan(number_trials,1);
    stride.IC_occurance.(cell2mat(list_parameters(current_parameter))) = nan(50,number_trials); % 50 to be sure there is enough space to store all occurances
    figure(current_parameter)
    % predefine for later
    for n_trial = 1:number_trials
        find_ICs = true;
        current_data = vicon.sorted.(strcat("trial_",num2str(n_trial))).(cell2mat(list_parameters(current_parameter)));
        stride.start(n_trial, 1) = find(current_data(:,1) == stride.start(n_trial, 1));

        % PLOT all axes and point of IC based on forceplate
        for current_axes = 1:1
            subplot(number_trials/2, 2, n_trial)
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
%      negative Steigung       
% if current_data(data_point,axes_of_interest(current_parameter)) > stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial) &&...
%                     stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial) > current_data(data_point+1,axes_of_interest(current_parameter))
%                 point_found_counter = point_found_counter +1;
%                 stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(point_found_counter, n_trial) = data_point;
            elseif current_data(data_point,axes_of_interest(current_parameter)) == stride.all_endpoints.(cell2mat(list_parameters(current_parameter)))(n_trial)
                point_found_counter = point_found_counter +1;
                stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(point_found_counter, n_trial) = data_point;
            end
        end

        % PLOT IC_occurances
        for i = 1:length(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(:,n_trial))
            if ~isnan(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(i,n_trial))
                plot(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(i,n_trial),...
                    current_data(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(i,n_trial),axes_of_interest(current_parameter)),'o','Color','r');
            end
        end
        
        current_idx = stride.start(n_trial);
        IC_counter = 0;
        end_idx = nnz(~isnan(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(:,n_trial)));
        while find_ICs
            if current_idx > stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(end_idx,n_trial)
                find_ICs = false;
            else
                IC_counter = IC_counter + 1;
                new_IC = find(stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(:,n_trial) >= current_idx,1,'first'); 
                all_ICs(IC_counter) = stride.IC_occurance.(cell2mat(list_parameters(current_parameter)))(new_IC,n_trial);
            end
            current_idx = all_ICs(IC_counter) + 90;
        end
        stride.ICs(n_trial) = {all_ICs};
    end
end
% clear variables that are not further accessed
clear current_parameter find_ICs current_axes min_value max_value point_found_counter i new_IC


%% cut cycles

for n_para = 1:length(parameter_names)
    cycles_complete.(cell2mat(parameter_names{n_para})) = cell(4,number_trials);
end

for n_trial = 1:number_trials
    current_trial = vicon.sorted.(strcat("trial_",num2str(n_trial)));
    current_idx = stride.ICs{n_trial};
    for param = 1:length(parameter_names)
    current_data = current_trial.(cell2mat(parameter_names{param}));
        for IC_counter = 1:(length(current_idx)-1)
            try
        cycles_complete.(cell2mat(parameter_names{param})){IC_counter,n_trial}...
            = current_data(current_idx(IC_counter)+1:current_idx(IC_counter +1)+1,columns_data_cycles);
            catch
                disp([num2str(n_trial),'/',num2str(param),'/', num2str(IC_counter)])
            end
        end
    end
end
% clear variables that are not further accessed
clear n_trial current_trial current_idx param IC_counter 


% plot
for j = 1:number_trials
    for i = 1:4
    temp_data = cycles_complete.RKneeAngles{i,j};
    figure(2)
    subplot(1, 2, 1)
    plot(temp_data(:,1))
    hold on;
    end
end

%% NORMALISATION i.e. interpolation & averaging(?)
for ctr_parameter = 1 : length(parameter_names)
    % skip idx37 (Arch Height Index), empty array
    if ctr_parameter == 37
        continue
    end
    % Define matrix for all interpolated cacles (adds row-wise)
    cycles_interp.(cell2mat(parameter_names{ctr_parameter})).x = [];
    cycles_interp.(cell2mat(parameter_names{ctr_parameter})).y = [];
    cycles_interp.(cell2mat(parameter_names{ctr_parameter})).z = [];

    current_parameter = cycles_complete.(cell2mat(parameter_names{ctr_parameter}));
    for ctr_trial = 1 : numel(current_parameter(1, :))
        for ctr_cycle = 1 : numel(current_parameter(:, 1))
            sample_points = transpose(1 : 1 : length(current_parameter{ctr_cycle, ctr_trial}));
            sample_values = current_parameter{ctr_cycle, ctr_trial};
            query_points = transpose(linspace(1, length(sample_points), 101));

            interp_x = interp1(sample_points, sample_values(:, 1), query_points, 'spline');
            interp_y = interp1(sample_points, sample_values(:, 2), query_points, 'spline');
            interp_z = interp1(sample_points, sample_values(:, 3), query_points, 'spline');
    
            % store in matrices
            cycles_interp.(cell2mat(parameter_names{ctr_parameter})).x = ...
                [cycles_interp.(cell2mat(parameter_names{ctr_parameter})).x, interp_x];
            cycles_interp.(cell2mat(parameter_names{ctr_parameter})).y = ...
                [cycles_interp.(cell2mat(parameter_names{ctr_parameter})).y, interp_y];
            cycles_interp.(cell2mat(parameter_names{ctr_parameter})).z = ...
                [cycles_interp.(cell2mat(parameter_names{ctr_parameter})).z, interp_z];
        end
    end
    cycles_mean.(cell2mat(parameter_names{ctr_parameter})) = ...
        [mean(cycles_interp.(cell2mat(parameter_names{ctr_parameter})).x, 2), ...
        mean(cycles_interp.(cell2mat(parameter_names{ctr_parameter})).y, 2), ...
        mean(cycles_interp.(cell2mat(parameter_names{ctr_parameter})).z, 2)];
end
% clear variables that are not further accessed
clear ctr_parameter ctr_trial ctr_cycle current_parameter sample_points sample_values query_points interp_x interp_y interp_z


%% PLOT interpolated data
for j = 1 : length(cycles_interp.RKneeAngles.x(1, :))

    temp_data = cycles_interp.RKneeAngles.x(:, j); %{i, j};
    figure(2)
    subplot(1, 2, 2)
    plot(temp_data, Color=[0.5 0.5 0.5])
    hold on;

    temp_data2 = cycles_interp.RAnkleAngles.x(:, j); %{i, j};
    figure(3)
    plot(temp_data2, Color=[0.5 0.5 0.5])
    hold on;
    
end
figure(2)
plot(cycles_mean.RKneeAngles(:, 1), LineWidth=2)
figure(3)
plot(cycles_mean.RAnkleAngles(:, 1), LineWidth=2)

%% Save data
if barefoot_flag
    barefoot = struct();
    barefoot.cycles = cycles_complete;
    barefoot.interp = cycles_interp;
    barefoot.mean = cycles_mean;
    save("normalized_data_barefoot.mat", "barefoot", "parameter_names")
elseif shoe_flag
    shoe = struct();
    shoe.cycles = cycles_complete;
    shoe.interp = cycles_interp;
    shoe.mean = cycles_mean;
    save("normalized_data_shoe.mat", "shoe", "parameter_names")
end


