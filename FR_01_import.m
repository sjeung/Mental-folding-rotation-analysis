% settings
% this has to be numerical
subjects = 9;

%% general information
% general metadata shared across all modalities
generalInfo = [];
generalInfo.dataset_description.Name               = 'Mental Folding as Rotation';
generalInfo.dataset_description.BIDSVersion         = 'v1.10.1';
generalInfo.dataset_description.Authors             = {"Sein Jeung", "Klaus Gramann", "Chris Hilton"};
generalInfo.dataset_description.Acknowledgements    = 'We acknowledge help from (assistant name) for supporting data collection';
generalInfo.dataset_description.Funding             = {"?"};
generalInfo.TaskDescription                         = 'Mental folding of cube nets with different pre-folded angles';

% information about the eeg recording system
eegInfo                                     = [];
eegInfo.eeg.SamplingFrequency               = 500;

% participant information
subjectInfo.fields.nr.Description           = 'numerical ID of the participant';
subjectInfo.fields.age.Description          = 'age of the participant';
subjectInfo.fields.age.Unit                 = 'years';
subjectInfo.fields.sex.Description          = 'sex of the participant';
subjectInfo.fields.sex.Levels.M             = 'male';
subjectInfo.fields.sex.Levels.F             = 'female';

subjectInfo.cols = {'nr',   'age',  'sex' ;  };
subjectInfo.data = {1,      27,     'F'   ;...
                    2,      32,     'F'   ;...
                    3,      34,     'F'   ;...
                    4,      27,     'F'   ;...
                    5,      33,     'M'   ;...
                    6,      31,     'F'   ;...
                    7,      21,     'M'   ;...
                    8,      21,     'M'   ;...
                    9,      28,     'F'};

%% iterate over participants and run import file-by-file
studyFolder                         = 'P:\Sein_Jeung\Project_Fold_Rotation\Data\';

% loop over participants
for subject = 1:numel(subjects)
    
    subID = sprintf('%03d', subjects(subject));

    % config general and EEG
    config                          = [];                                     % reset for each loop ´
    config.bids_target_folder       = [studyFolder '\01_BIDS-data'];           % required, replace with the folder where you want to store your bids data
    config.filename                 = fullfile([studyFolder '\00-source_data\sub-' subID, '\MFRR_', subID, '.xdf']);    % required, replace with your xdf file full path
    config.subject                  = subjects(subject);
    config.eeg.stream_name          = 'BrainVision RDA';                % required, replace with the unique keyword in your eeg stream in the .xdf file
    config.task                     = 'FR'; 
   
    bemobil_xdf2bids(config,...
        'general_metadata', generalInfo,...
        'participant_metadata', subjectInfo, ...
        'eeg_metadata', eegInfo);
    
    %% configuration for bemobil bids2set
    %----------------------------------------------------------------------
    config.resample_freq            = 250;
    config.set_folder               = fullfile(studyFolder, '\02_raw-EEGLAB');
    config.session_names            = config.task;  
    
    bemobil_bids2set(config);
    
end

