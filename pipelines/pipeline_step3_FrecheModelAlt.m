% ##### PIPELINE STEP 3 (FRECHE MODEL ALTERNATIVE) #####

% This script uses the model proposed by Freche et al (2018) Plos Comp Biol
% to fit the decay artifact and then subtract the model fit from the data.
% The script uses parameters better optimised for fitting the decay
% artifact in this data set.

% TMS-EEG data required for this script are generated from:
% pipeline_step2_pulse_trials_channels_reref.m

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Participant IDs
%ID = {'121','123','126','127','129','137','138','139','142','143','145','146','147','148'};
ID = {'123','126','127','129','137','138','139','142','143','145','146','147','148'};


% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% Settings (taken from Fig. 11 script from manuscript)
% Reconstruct artifacts (in samples)
% For further explanation of the parameters, see fitartifactmodel.m
tPulse = 10001;
tPulseDuration = 20;
tSkip   = 81;
tSelect = 120;

t_fitmodel_p = [];
t_fitmodel_n = [];
t_fitmodel_p{1} = 0:600;
t_fitmodel_n{1} = 0:600;

t_lincomb = 0:1000;

% Epoching settings (in samples)
tPrePulse  = -5000:-1;
tSkipped   = 1:tSkip-1;
tPostPulse = 0:4898;

for idx = 1:length(ID)
    
    % Load the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step2.set'];
    EEG = pop_loadset('filename',filename,'filepath',pathIn);
    
    
    % Remove bad channels
    EEG = pop_select( EEG,'nochannel',EEG.badchannels);
    
    elecNo  = size(EEG.data,1);
    trialNo = size(EEG.data,3);
    
    samplerate = EEG.srate; % in Hz
    
    %%
    
    dataOut = [];
    modelOut = [];
    
    % iT = number of trial to be analyzed (ranging from 1 to trialNo )
    % *** choose trial for analysis ***
    for iT = 1:trialNo
        
        
        electrodeLst = 1:elecNo;
        % traces_50Hz = [4 6 10 13 47];
        % traces_drifting = [11 12];
        
        %%% *** uncomment the following line *** to exclude bad EEG traces (50Hz, drifting) from the analysis
        % electrodeLst([traces_50Hz traces_drifting]) = []; % exclude bad EEG traces
        
        EEGdata = double( EEG.data(electrodeLst,:,iT) );
        
        %%% *** uncomment the following line *** to subtract common mode signal (subtract average of all electrodes)
        % EEGdata = EEGdata - mean(EEGdata,1);
        
        [ V, u, PrepulseOfs ] = ...
            fitartifactmodel(EEGdata, tPulse, tPulseDuration, tSkip, tSelect, t_fitmodel_p, t_fitmodel_n, t_lincomb, samplerate);
        
        A = V(tPostPulse,1:size(u,1)); % reconstructed artifacts for time range tPostPulse
        
        y1 = [];
        y2 = [];
        y3 = [];
        y4 = [];
        mOut = [];
        for iE = 1:size(EEGdata,1)
            % pre-pulse data
            t1 = tPrePulse;
            y1(iE,:) = EEGdata(iE,tPulse + t1);
            
            t2 = 0:tPulseDuration;
            y2(iE,:) = EEGdata(iE,tPulse + t2);
            
            t3 = tPulseDuration + tSkipped;
            y3(iE,:) = EEGdata(iE,tPulse + t3);
            
            % subtract reconstructed artifact
            t4 = tPulseDuration + tSkip + tPostPulse;
            y4(iE,:) = EEGdata(iE,tPulse + t4)' - A*u(:,iE);
            mOut(iE,:) = A*u(:,iE);
        end
        
        timeOut = [t1,t2,t3,t4]*1000/samplerate;
        dataOut(:,:,iT) = [y1,y2,y3,y4];
        modelOut(:,:,iT) = mOut;
        modelTime = tPulse+t4;
   
    end
    
    % Epoch data to match corrected data
    EEG = pop_epoch( EEG, {  }, [-0.5 0.5], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
    
    % Replace data with corrected data
    EEG.data = dataOut;
    EEG.modelOutput = modelOut;
    EEG.modelTime = modelTime;
    
    % Save the data
    filename = [ID{idx},'_FEF_Decaytest_withTMSPulse_step3_FrecheModelAlt.set'];
    filepath = pathIn;
    EEG = pop_saveset( EEG, 'filename',filename,'filepath',filepath);
    
end