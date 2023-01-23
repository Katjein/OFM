clc;
clear;
close all;

%%
% to do:
% - function for plots of trials
% - filtern?
% - force IC detection --> threshhold 2x --> save idx --> round up if subframe > 0 // stride.start(n_trial) = idx
% - parameter for end of cycle --> ankle --> stride.end(n_trials) = idx
% - cut cycles --> cycles.parameter -> preallocate nans based on max length
% - normalisation / interpolation
% - average
% - plots
% - statistics
%
% - parameter festlegen
% 
% 

%%


cd("../Measurement_20_01_2023/shoe\"); % change depending on folder name  %Katja:  ../Measurement_20_01_2023/shoe\
subject_name = 'KatjaK:'; % change depending on subject name
files_list_vicon = dir("*vicon*.csv"); % change depending on file name
files_list_force = dir("*force*.csv"); % change depending on file name
row_parameters_name = 3;
row_parameters_axes = 4;
row_parameters_units = 5;
row_parameters_data_start = 6;


vicon = struct();
vicon.raw = struct();
vicon.sorted = struct();
force = struct();
number_trials = length(files_list_force);

%% create list of parameter names for vicon data
for trial_number = 1:number_trials
   
    % load all trial files and save data in vicon and force struct
    vicon.raw.(strcat("trial_",num2str(trial_number))) = readcell(files_list_vicon(trial_number).name);
    force.(strcat("trial_",num2str(trial_number))) = readcell(files_list_force(trial_number).name);

    % write complete data in struct and create list of parameters with
    % starting column
    current_vicon_data = vicon.raw.(strcat("trial_",num2str(trial_number)));
    data_points = length(current_vicon_data(row_parameters_data_start:end, 1));
	parameters = current_vicon_data(row_parameters_name,:)';
    for j = 1:length(parameters)
        if ~ismissing(parameters{j,:})
        parameters_list{j,1,trial_number} = j; %#ok<*SAGROW> 
        new_parameter_name = erase(parameters{j,:}, subject_name);
        parameters_list{j,2,trial_number} = new_parameter_name;
        end
    end

    % read index of parameters
    para_list_size = size(parameters_list);
    index_counter = 0;
    for j = 1:para_list_size(1)
        if ~isempty(cell2mat(parameters_list(j, 1,trial_number)))
            index_counter = index_counter +1;
            index_parameters(index_counter, 1, trial_number) = cell2mat(parameters_list(j, 1,trial_number)); 
        end
    end
    index_parameters(index_counter +1, 1, trial_number) = (size(current_vicon_data, 2)); % add last comlumn of data

    % save all parameters in sorted struct
    number_parameters = size(index_parameters,1);
    vicon.sorted.(strcat("trial_",num2str(trial_number))) = struct();
    for j = 1:(number_parameters -1)
        parameter_names{j,1} = parameters_list(index_parameters(j),2);
        vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2))) = struct(); % creating struct for parameter
        current_param_column_count = index_parameters(j+1, 1, trial_number) - index_parameters(j, 1, trial_number);
        vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2))) = nan((size(current_vicon_data,1)) - row_parameters_data_start +3, (2+current_param_column_count));
        temp_parameter_axes = current_vicon_data(row_parameters_axes,index_parameters(j, 1, trial_number):(index_parameters(j+1, 1, trial_number))-1);
        temp_parameter_units = current_vicon_data(row_parameters_units,index_parameters(j, 1, trial_number):(index_parameters(j+1, 1, trial_number))-1);
        temp_parameter_data = current_vicon_data(row_parameters_data_start:end,index_parameters(j, 1, trial_number):(index_parameters(j+1, 1, trial_number))-1);
%         vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2))){1,1} = {'Frame'};
%         vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2))){1,2} = {'Sub_Frame'};
%         for h = 1:length(temp_parameter_units)
%         vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2))){1,2+h} = temp_parameter_axes(h);
%         vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2))){2,2+h} = temp_parameter_units(h);
%         end
        for k = 1:data_points
        vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2)))(k,1) = cell2mat(current_vicon_data(row_parameters_data_start -1 + k, 1));
        vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2)))(k,2) = cell2mat(current_vicon_data(row_parameters_data_start -1 + k, 2));
            for g = 1:size(temp_parameter_data,2)
            vicon.sorted.(strcat("trial_",num2str(trial_number))).(cell2mat(parameters_list(index_parameters(j),2)))(k,2+g) = temp_parameter_data{k, g};
            end
        end
    end
    disp(['trial_finished', num2str(trial_number)]);
end

save("data_sorted.mat", "vicon", "force", "parameter_names");





