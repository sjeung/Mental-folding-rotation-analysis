% FR_Main
% configure paths to tools 
%--------------------------------------------------------------------------

% lock EEGLAB version
rmpath(genpath('P:\Sein_Jeung\Tools\eeglab_sj'))
EEGLAB_PATH = 'P:\Sein_Jeung\Project_Fold_Rotation\Dependencies\eeglab2023.1';
addpath(EEGLAB_PATH)
eeglab; 
assert(strcmp(eeg_getversion, '2023.1'),'Wrong EEGLAB version loaded. Expected v2023.1');

% list of participants 
allparticipants = 1:51;     % numerical IDs 
excluded = [6, ...          % P3 detected as bad (criterion 4.) + missing EOG
            11, ...         % too many errors
            15, ...         % insufficient trial number 
            23, ...         % insufficient trial number
            30, ...         % too many errors
            32];            % too many errors

participants = setdiff(allparticipants, excluded);

% import all data sets  
%FR_01_import

% preprocess, iterating over all participants 
for Pi = participants 
    %FR_02_preprocess(Pi)
    %FR_03_amica(Pi) 
    %FR_04_filt_clean(Pi)    
    FR_05_epoch(Pi)    
    %FR_06_ERP(Pi)
end    

% statistics 
FR_07_summary


