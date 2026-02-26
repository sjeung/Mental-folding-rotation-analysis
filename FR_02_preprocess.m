function FR_02_preprocess(Pi)

% make sure the data is stored in double precision, large datafiles are supported, and no memory mapped objects are
% used but data is processed locally
try
    pop_editoptions( 'option_saveversion6', 0, 'option_single', 0, 'option_memmapdata', 0);
catch
    warning('Could NOT edit EEGLAB memory options!!');
end

% load configs
FR_bemobil_config;

setFileDirEEG   = fullfile(bemobil_config.study_folder, '02_raw-EEGLAB', ['sub-' num2str(Pi)]); 
setFileNameEEG  = ['sub-' num2str(Pi) '_FR_EEG.set']; 

% load data 
EEG = pop_loadset('filename', setFileNameEEG, 'filepath', setFileDirEEG);

force_recompute = 1;

disp(['Preprocessing subject #' num2str(Pi)]);

%% processing wrappers for basic processing and AMICA
% do basic preprocessing, line noise removal, and channel interpolation
bemobil_process_all_EEG_preprocessing(Pi, bemobil_config, [], EEG, [], force_recompute);

end
