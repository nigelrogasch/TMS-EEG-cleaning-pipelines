% ##### PIPELINE STEP 3 (SOUND ALL CHANNELS) #####

% This script uses SOUND proposed by Mutanen et al (2017) NeuroImage
% to suppress the decay artifact and correct noisy channels.

% TMS-EEG data required for this script are generated from:
% pipeline_step2_pulse_trials_allchans.m

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Participant IDs
ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% The anatomy file that Simnibs is imported to
anatomyFileName = 'tess_cortex_pial_low.mat';

for idx = 1:length(ID)
    
    % Load the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step2_allchans.set'];
    EEG = pop_loadset('filename',filename,'filepath',pathIn);
    
    % Leadfield path
    bsFolderPath = '/projects/kg98/Mana/GWM/scans/Brainstorm/GWM/';

    % Loads LF matrix from brainstorm
    load([bsFolderPath,'data',filesep, ID{idx},filesep,'FEF',filesep,'headmodel_surf_openmeeg.mat'],'Gain');
    
    % Loads Anatomy from brainstorm
    load([bsFolderPath,'anat',filesep, ID{idx},filesep,anatomyFileName],'Vertices','Faces','VertNormals');
    
    % Generate normalised lead field
    EEG_lead_field = zeros(size(Gain,1),length(VertNormals));
    for i = 1:length(VertNormals)
        EEG_lead_field(:,i) = VertNormals(i,1)*Gain(:,3*(i-1)+1)+ ...
            VertNormals(i,2)*Gain(:,3*(i-1)+2) +VertNormals(i,3)*Gain(:,3*(i-1)+3);
    end
    
    % Run SOUND on normalised leadfield
    EEG = pop_tesa_sound(EEG, 'leadfieldInVar',EEG_lead_field );
    
    % Remove bad channels
    %EEG = pop_select( EEG,'nochannel',EEG.badchannels);
    
    % Save the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step3_SOUND_allchans.set'];
    filepath = pathIn;
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    
end