% ##### PLOT FIGURE 7 #####

% This script runs all of the analysis and generates figure 7 from the 
% manuscript which compares the TEP outcomes from the three pipelines after
% step 4 and repeating each pipeline 3 times.

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

% Step No
stepNo = 'step4';

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';
pathOut = '/projects/kg98/Nigel/TMS-EEG_cleaning_pipeline/figures/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% Fieldtrip
addpath('/projects/kg98/Mana/Scripts/Toolboxes/fieldtrip-20180619');
ft_defaults;

% Load example data
filename = ['121_FEF_Decaytest_withTMSPulse_step4_FastICA.set'];
EEG = pop_loadset('filename',filename,'filepath',pathIn);
  
%% FASTICA

% Plot GMFA
close all;

% Load name
loadName = 'model_comparison_fastica_repeat';

conditionName = {'FI1 v FI2','FI1 v FI3','FI2 v FI3'};
condName = {'FastICA1','FastICA2','FastICA3'};

% Load data
load([pathIn,loadName,'_',stepNo,'.mat']);

fig = figure('color','w');
set(gcf,'position',[250,60,850,760]);

[~,t1] = min(abs(EEG.times - -500));
[~,t2] = min(abs(EEG.times - -3));
[~,t3] = min(abs(EEG.times - 11));
[~,t4] = min(abs(EEG.times - 500));

time = EEG.times;

tp = [-50,16,28,45,66,108,200];

c = get(0, 'DefaultAxesColorOrder');

subplot(3,2,1)
for cx = 1:length(condition)
    
    gmfaM = mean(gmfa.(condition{cx}),3);
    gmfaSE = std(gmfa.(condition{cx}),[],3)./sqrt(size(gmfa.(condition{cx}),3));
    
    plot(time(t1:t2),gmfaM(t1:t2),'color',c(cx,:),'linewidth',2); hold on;
    f = fill([time(t1:t2),fliplr(time(t1:t2))],[gmfaM(t1:t2)-gmfaSE(t1:t2),fliplr(gmfaM(t1:t2)+gmfaSE(t1:t2))],c(cx,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
    pg.(['h',num2str(cx)]) = plot(time(t3:t4),gmfaM(t3:t4),'color',c(cx,:),'linewidth',2); hold on;
    f = fill([time(t3:t4),fliplr(time(t3:t4))],[gmfaM(t3:t4)-gmfaSE(t3:t4),fliplr(gmfaM(t3:t4)+gmfaSE(t3:t4))],c(cx,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
end

for ix = 1:length(tp)
    plot([tp(ix),tp(ix)],[-5,5],'color',[0.7,0.7,0.7]);
    if ix ==1
    elseif ix==2
            text(tp(ix),5.2,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','right');
    else 
    text(tp(ix),5.2,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','center');
    end
end

text(-120,5.2,'A','fontsize',16,'fontweight','bold');

plot([0,0],[-5,5],'k--','linewidth',2);

set(gca,'box','off','xlim',[-50,250],'ylim',[0,5],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('GMFA (\muV)');

% Statistics
for tx = 1:size(gmfa.(condition{1}),2)
[~,gmfaP1(tx)] = ttest(gmfa.(condition{1})(1,tx,:),gmfa.(condition{2})(1,tx,:));
[~,gmfaP2(tx)] = ttest(gmfa.(condition{1})(1,tx,:),gmfa.(condition{3})(1,tx,:));
[~,gmfaP3(tx)] = ttest(gmfa.(condition{2})(1,tx,:),gmfa.(condition{3})(1,tx,:));
end

[~,tp1] = min(abs(EEG.times - 11));
[~,tp2] = min(abs(EEG.times - 250));
ti = tp1:4:tp2;
gmfaP1c = mafdr(gmfaP1(ti),'BHFDR','true');
gmfaP2c = mafdr(gmfaP2(ti),'BHFDR','true');
gmfaP3c = mafdr(gmfaP3(ti),'BHFDR','true');

timec = time(ti);

loggc1 = gmfaP1c<0.05;
gc1 = ones(1,length(ti))*0.6;
gc1(loggc1==0) = NaN;
plot(timec,gc1,'color',c(4,:),'linewidth',2);

loggc2 = gmfaP2c<0.05;
gc2 = ones(1,length(ti))*0.4;
gc2(loggc2==0) = NaN;
plot(timec,gc2,'*','color',c(5,:),'linewidth',2);

loggc3 = gmfaP3c<0.05;
gc3 = ones(1,length(ti))*0.2;
gc3(loggc3==0) = NaN;
plot(timec,gc3,'color',c(6,:),'linewidth',2);

lgd1 = legend([pg.h1,pg.h2,pg.h3],condName,'box','off','location','southeast','fontsize',8);
lgd1.Position = [0.36,0.74,0.1,0.05];

% Plot correlations
corrComp = {'r1','r2','r3'};

for idx = 1:size(tep.(condition{1}),3)
    for tx = 1:size(tep.(condition{1}),2)
        r.r1(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{2})(:,tx,idx));
        r.r2(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{3})(:,tx,idx));
        r.r3(idx,tx) = corr(tep.(condition{2})(:,tx,idx),tep.(condition{3})(:,tx,idx));
    end
end

subplot(3,2,2)
for cx = 1:length(corrComp)
    
    gmfaM = mean(r.(corrComp{cx}),1);
    gmfaSE = std(r.(corrComp{cx}),[],1)./sqrt(size(r.(corrComp{cx}),1));
    
    plot(time(t1:t2),gmfaM(t1:t2),'color',c(cx+3,:),'linewidth',2); hold on;
    f = fill([time(t1:t2),fliplr(time(t1:t2))],[gmfaM(t1:t2)-gmfaSE(t1:t2),fliplr(gmfaM(t1:t2)+gmfaSE(t1:t2))],c(cx+3,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
    ps.(['h',num2str(cx)]) = plot(time(t3:t4),gmfaM(t3:t4),'color',c(cx+3,:),'linewidth',2); hold on;
    f = fill([time(t3:t4),fliplr(time(t3:t4))],[gmfaM(t3:t4)-gmfaSE(t3:t4),fliplr(gmfaM(t3:t4)+gmfaSE(t3:t4))],c(cx+3,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
end

for ix = 1:length(tp)
    plot([tp(ix),tp(ix)],[-5,5],'color',[0.7,0.7,0.7]);
    if ix ==1
    elseif ix==2
            text(tp(ix),1.05,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','right');
    else 
    text(tp(ix),1.05,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','center');
    end
end

text(-140,1.05,'B','fontsize',16,'fontweight','bold');

plot([-500,500],[0,0],'--','color',[0.7,0.7,0.7]);
plot([-500,500],[0.6,0.6],'--','color',[0.7,0.7,0.7]);
plot([-500,500],[0.8,0.8],'--','color',[0.7,0.7,0.7]);

plot([0,0],[-5,5],'k--','linewidth',2);

set(gca,'box','off','xlim',[-50,250],'ylim',[-0.4,1],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('Correlation (r)');


% Statistics
for t = 1:size(r.r1,2)
for idx = 1:size(r.r1,1)
    
    % Fisher's r to z transform
    z1(idx,t)=.5.*log((1+r.r1(idx,t))./(1-r.r1(idx,t)));
    z2(idx,t)=.5.*log((1+r.r2(idx,t))./(1-r.r2(idx,t)));
    z3(idx,t)=.5.*log((1+r.r3(idx,t))./(1-r.r3(idx,t)));
end

if isnan(z1(1,t))
    corrP1(t) = NaN;
    corrP2(t) = NaN;
    corrP3(t) = NaN;
else
[~,corrP1(t)] = ttest(z1(:,t));
[~,corrP2(t)] = ttest(z2(:,t));
[~,corrP3(t)] = ttest(z3(:,t));
end

end

[~,tp1] = min(abs(EEG.times - 11));
[~,tp2] = min(abs(EEG.times - 250));
ti = tp1:4:tp2;
corrP1c = mafdr(corrP1(ti),'BHFDR','true');
corrP2c = mafdr(corrP2(ti),'BHFDR','true');
corrP3c = mafdr(corrP3(ti),'BHFDR','true');

logcc1 = corrP1c<0.05;
cc1 = ones(1,length(ti))*-0.25;
cc1(logcc1==0) = NaN;
plot(timec,cc1,'color',c(4,:),'linewidth',2);

logcc2 = corrP2c<0.05;
cc2 = ones(1,length(ti))*-0.3;
cc2(logcc2==0) = NaN;
plot(timec,cc2,'color',c(5,:),'linewidth',2);

logcc3 = corrP3c<0.05;
cc3 = ones(1,length(ti))*-0.35;
cc3(logcc3==0) = NaN;
plot(timec,cc3,'color',c(6,:),'linewidth',2);

lgd2 = legend([ps.h1,ps.h2,ps.h3],conditionName,'box','off','location','southeast','fontsize',8);
lgd2.Position = [0.81,0.76,0.1,0.05];

%% SOUND

% Load name
loadName = 'model_comparison_sound_repeat';

conditionName = {'S1 v S2','S1 v S3','S2 v S3'};
condName = {'SOUND1','SOUND2','SOUND3'};

% Load data
load([pathIn,loadName,'_',stepNo,'.mat']);

[~,t1] = min(abs(EEG.times - -500));
[~,t2] = min(abs(EEG.times - -3));
[~,t3] = min(abs(EEG.times - 11));
[~,t4] = min(abs(EEG.times - 500));

time = EEG.times;

tp = [-50,16,28,45,66,108,200];

c = get(0, 'DefaultAxesColorOrder');

subplot(3,2,3)
for cx = 1:length(condition)
    
    gmfaM = mean(gmfa.(condition{cx}),3);
    gmfaSE = std(gmfa.(condition{cx}),[],3)./sqrt(size(gmfa.(condition{cx}),3));
    
    plot(time(t1:t2),gmfaM(t1:t2),'color',c(cx,:),'linewidth',2); hold on;
    f = fill([time(t1:t2),fliplr(time(t1:t2))],[gmfaM(t1:t2)-gmfaSE(t1:t2),fliplr(gmfaM(t1:t2)+gmfaSE(t1:t2))],c(cx,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
    pg.(['h',num2str(cx)]) = plot(time(t3:t4),gmfaM(t3:t4),'color',c(cx,:),'linewidth',2); hold on;
    f = fill([time(t3:t4),fliplr(time(t3:t4))],[gmfaM(t3:t4)-gmfaSE(t3:t4),fliplr(gmfaM(t3:t4)+gmfaSE(t3:t4))],c(cx,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
end

for ix = 1:length(tp)
    plot([tp(ix),tp(ix)],[-5,5],'color',[0.7,0.7,0.7]);
    if ix ==1
    elseif ix==2
            text(tp(ix),5.2,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','right');
    else 
    text(tp(ix),5.2,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','center');
    end
end

text(-120,5.2,'C','fontsize',16,'fontweight','bold');

plot([0,0],[-5,5],'k--','linewidth',2);

set(gca,'box','off','xlim',[-50,250],'ylim',[0,5],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('GMFA (\muV)');

% Statistics
for tx = 1:size(gmfa.(condition{1}),2)
[~,gmfaP1(tx)] = ttest(gmfa.(condition{1})(1,tx,:),gmfa.(condition{2})(1,tx,:));
[~,gmfaP2(tx)] = ttest(gmfa.(condition{1})(1,tx,:),gmfa.(condition{3})(1,tx,:));
[~,gmfaP3(tx)] = ttest(gmfa.(condition{2})(1,tx,:),gmfa.(condition{3})(1,tx,:));
end

[~,tp1] = min(abs(EEG.times - 11));
[~,tp2] = min(abs(EEG.times - 250));
ti = tp1:4:tp2;
gmfaP1c = mafdr(gmfaP1(ti),'BHFDR','true');
gmfaP2c = mafdr(gmfaP2(ti),'BHFDR','true');
gmfaP3c = mafdr(gmfaP3(ti),'BHFDR','true');

timec = time(ti);

loggc1 = gmfaP1c<0.05;
gc1 = ones(1,length(ti))*0.6;
gc1(loggc1==0) = NaN;
plot(timec,gc1,'color',c(4,:),'linewidth',2);

loggc2 = gmfaP2c<0.05;
gc2 = ones(1,length(ti))*0.4;
gc2(loggc2==0) = NaN;
plot(timec,gc2,'*','color',c(5,:),'linewidth',2);

loggc3 = gmfaP3c<0.05;
gc3 = ones(1,length(ti))*0.2;
gc3(loggc3==0) = NaN;
plot(timec,gc3,'color',c(6,:),'linewidth',2);

lgd1 = legend([pg.h1,pg.h2,pg.h3],condName,'box','off','location','southeast','fontsize',8);
lgd1.Position = [0.36,0.44,0.1,0.05];

% Plot correlations
corrComp = {'r1','r2','r3'};

for idx = 1:size(tep.(condition{1}),3)
    for tx = 1:size(tep.(condition{1}),2)
        r.r1(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{2})(:,tx,idx));
        r.r2(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{3})(:,tx,idx));
        r.r3(idx,tx) = corr(tep.(condition{2})(:,tx,idx),tep.(condition{3})(:,tx,idx));
    end
end

subplot(3,2,4)
for cx = 1:length(corrComp)
    
    gmfaM = mean(r.(corrComp{cx}),1);
    gmfaSE = std(r.(corrComp{cx}),[],1)./sqrt(size(r.(corrComp{cx}),1));
    
    plot(time(t1:t2),gmfaM(t1:t2),'color',c(cx+3,:),'linewidth',2); hold on;
    f = fill([time(t1:t2),fliplr(time(t1:t2))],[gmfaM(t1:t2)-gmfaSE(t1:t2),fliplr(gmfaM(t1:t2)+gmfaSE(t1:t2))],c(cx+3,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
    ps.(['h',num2str(cx)]) = plot(time(t3:t4),gmfaM(t3:t4),'color',c(cx+3,:),'linewidth',2); hold on;
    f = fill([time(t3:t4),fliplr(time(t3:t4))],[gmfaM(t3:t4)-gmfaSE(t3:t4),fliplr(gmfaM(t3:t4)+gmfaSE(t3:t4))],c(cx+3,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
end

for ix = 1:length(tp)
    plot([tp(ix),tp(ix)],[-5,5],'color',[0.7,0.7,0.7]);
    if ix ==1
    elseif ix==2
            text(tp(ix),1.05,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','right');
    else 
    text(tp(ix),1.05,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','center');
    end
end

text(-140,1.05,'D','fontsize',16,'fontweight','bold');

plot([-500,500],[0,0],'--','color',[0.7,0.7,0.7]);
plot([-500,500],[0.6,0.6],'--','color',[0.7,0.7,0.7]);
plot([-500,500],[0.8,0.8],'--','color',[0.7,0.7,0.7]);

plot([0,0],[-5,5],'k--','linewidth',2);

set(gca,'box','off','xlim',[-50,250],'ylim',[-0.4,1],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('Correlation (r)');


% Statistics
for t = 1:size(r.r1,2)
for idx = 1:size(r.r1,1)
    
    % Fisher's r to z transform
    z1(idx,t)=.5.*log((1+r.r1(idx,t))./(1-r.r1(idx,t)));
    z2(idx,t)=.5.*log((1+r.r2(idx,t))./(1-r.r2(idx,t)));
    z3(idx,t)=.5.*log((1+r.r3(idx,t))./(1-r.r3(idx,t)));
end

if isnan(z1(1,t))
    corrP1(t) = NaN;
    corrP2(t) = NaN;
    corrP3(t) = NaN;
else
[~,corrP1(t)] = ttest(z1(:,t));
[~,corrP2(t)] = ttest(z2(:,t));
[~,corrP3(t)] = ttest(z3(:,t));
end

end

[~,tp1] = min(abs(EEG.times - 11));
[~,tp2] = min(abs(EEG.times - 250));
ti = tp1:4:tp2;
corrP1c = mafdr(corrP1(ti),'BHFDR','true');
corrP2c = mafdr(corrP2(ti),'BHFDR','true');
corrP3c = mafdr(corrP3(ti),'BHFDR','true');

logcc1 = corrP1c<0.05;
cc1 = ones(1,length(ti))*-0.25;
cc1(logcc1==0) = NaN;
plot(timec,cc1,'color',c(4,:),'linewidth',2);

logcc2 = corrP2c<0.05;
cc2 = ones(1,length(ti))*-0.3;
cc2(logcc2==0) = NaN;
plot(timec,cc2,'color',c(5,:),'linewidth',2);

logcc3 = corrP3c<0.05;
cc3 = ones(1,length(ti))*-0.35;
cc3(logcc3==0) = NaN;
plot(timec,cc3,'color',c(6,:),'linewidth',2);

lgd2 = legend([ps.h1,ps.h2,ps.h3],conditionName,'box','off','location','southeast','fontsize',8);
lgd2.Position = [0.81,0.46,0.1,0.05];

%% MODEL

% Load name
loadName = 'model_comparison_frechemodelalt_repeat';

conditionName = {'M1 v M2','M1 v M3','M2 v M3'};
condName = {'MODEL1','MODEL2','MODEL3'};

% Load data
load([pathIn,loadName,'_',stepNo,'.mat']);

[~,t1] = min(abs(EEG.times - -500));
[~,t2] = min(abs(EEG.times - -3));
[~,t3] = min(abs(EEG.times - 11));
[~,t4] = min(abs(EEG.times - 500));

time = EEG.times;

tp = [-50,16,28,45,66,108,200];

c = get(0, 'DefaultAxesColorOrder');

subplot(3,2,5)
for cx = 1:length(condition)
    
    gmfaM = mean(gmfa.(condition{cx}),3);
    gmfaSE = std(gmfa.(condition{cx}),[],3)./sqrt(size(gmfa.(condition{cx}),3));
    
    plot(time(t1:t2),gmfaM(t1:t2),'color',c(cx,:),'linewidth',2); hold on;
    f = fill([time(t1:t2),fliplr(time(t1:t2))],[gmfaM(t1:t2)-gmfaSE(t1:t2),fliplr(gmfaM(t1:t2)+gmfaSE(t1:t2))],c(cx,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
    pg.(['h',num2str(cx)]) = plot(time(t3:t4),gmfaM(t3:t4),'color',c(cx,:),'linewidth',2); hold on;
    f = fill([time(t3:t4),fliplr(time(t3:t4))],[gmfaM(t3:t4)-gmfaSE(t3:t4),fliplr(gmfaM(t3:t4)+gmfaSE(t3:t4))],c(cx,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
end

for ix = 1:length(tp)
    plot([tp(ix),tp(ix)],[-5,5],'color',[0.7,0.7,0.7]);
    if ix ==1
    elseif ix==2
            text(tp(ix),5.2,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','right');
    else 
    text(tp(ix),5.2,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','center');
    end
end

text(-120,5.2,'E','fontsize',16,'fontweight','bold');

plot([0,0],[-5,5],'k--','linewidth',2);

set(gca,'box','off','xlim',[-50,250],'ylim',[0,5],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('GMFA (\muV)');

% Statistics
for tx = 1:size(gmfa.(condition{1}),2)
[~,gmfaP1(tx)] = ttest(gmfa.(condition{1})(1,tx,:),gmfa.(condition{2})(1,tx,:));
[~,gmfaP2(tx)] = ttest(gmfa.(condition{1})(1,tx,:),gmfa.(condition{3})(1,tx,:));
[~,gmfaP3(tx)] = ttest(gmfa.(condition{2})(1,tx,:),gmfa.(condition{3})(1,tx,:));
end

[~,tp1] = min(abs(EEG.times - 11));
[~,tp2] = min(abs(EEG.times - 250));
ti = tp1:4:tp2;
gmfaP1c = mafdr(gmfaP1(ti),'BHFDR','true');
gmfaP2c = mafdr(gmfaP2(ti),'BHFDR','true');
gmfaP3c = mafdr(gmfaP3(ti),'BHFDR','true');

timec = time(ti);

loggc1 = gmfaP1c<0.05;
gc1 = ones(1,length(ti))*0.6;
gc1(loggc1==0) = NaN;
plot(timec,gc1,'color',c(4,:),'linewidth',2);

loggc2 = gmfaP2c<0.05;
gc2 = ones(1,length(ti))*0.4;
gc2(loggc2==0) = NaN;
plot(timec,gc2,'*','color',c(5,:),'linewidth',2);

loggc3 = gmfaP3c<0.05;
gc3 = ones(1,length(ti))*0.2;
gc3(loggc3==0) = NaN;
plot(timec,gc3,'color',c(6,:),'linewidth',2);

lgd1 = legend([pg.h1,pg.h2,pg.h3],condName,'box','off','location','southeast','fontsize',8);
lgd1.Position = [0.36,0.14,0.1,0.05];

% Plot correlations
corrComp = {'r1','r2','r3'};

for idx = 1:size(tep.(condition{1}),3)
    for tx = 1:size(tep.(condition{1}),2)
        r.r1(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{2})(:,tx,idx));
        r.r2(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{3})(:,tx,idx));
        r.r3(idx,tx) = corr(tep.(condition{2})(:,tx,idx),tep.(condition{3})(:,tx,idx));
    end
end

subplot(3,2,6)
for cx = 1:length(corrComp)
    
    gmfaM = mean(r.(corrComp{cx}),1);
    gmfaSE = std(r.(corrComp{cx}),[],1)./sqrt(size(r.(corrComp{cx}),1));
    
    plot(time(t1:t2),gmfaM(t1:t2),'color',c(cx+3,:),'linewidth',2); hold on;
    f = fill([time(t1:t2),fliplr(time(t1:t2))],[gmfaM(t1:t2)-gmfaSE(t1:t2),fliplr(gmfaM(t1:t2)+gmfaSE(t1:t2))],c(cx+3,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
    ps.(['h',num2str(cx)]) = plot(time(t3:t4),gmfaM(t3:t4),'color',c(cx+3,:),'linewidth',2); hold on;
    f = fill([time(t3:t4),fliplr(time(t3:t4))],[gmfaM(t3:t4)-gmfaSE(t3:t4),fliplr(gmfaM(t3:t4)+gmfaSE(t3:t4))],c(cx+3,:));
    set(f,'FaceAlpha',0.3);set(f,'EdgeColor', 'none');
    
end

for ix = 1:length(tp)
    plot([tp(ix),tp(ix)],[-5,5],'color',[0.7,0.7,0.7]);
    if ix ==1
    elseif ix==2
            text(tp(ix),1.05,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','right');
    else 
    text(tp(ix),1.05,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','center');
    end
end

text(-140,1.05,'F','fontsize',16,'fontweight','bold');

plot([-500,500],[0,0],'--','color',[0.7,0.7,0.7]);
plot([-500,500],[0.6,0.6],'--','color',[0.7,0.7,0.7]);
plot([-500,500],[0.8,0.8],'--','color',[0.7,0.7,0.7]);

plot([0,0],[-5,5],'k--','linewidth',2);

set(gca,'box','off','xlim',[-50,250],'ylim',[-0.4,1],'tickdir','out','linewidth',2,'fontsize',14);
xlabel('Time (ms)');
ylabel('Correlation (r)');


% Statistics
for t = 1:size(r.r1,2)
for idx = 1:size(r.r1,1)
    
    % Fisher's r to z transform
    z1(idx,t)=.5.*log((1+r.r1(idx,t))./(1-r.r1(idx,t)));
    z2(idx,t)=.5.*log((1+r.r2(idx,t))./(1-r.r2(idx,t)));
    z3(idx,t)=.5.*log((1+r.r3(idx,t))./(1-r.r3(idx,t)));
end

if isnan(z1(1,t))
    corrP1(t) = NaN;
    corrP2(t) = NaN;
    corrP3(t) = NaN;
else
[~,corrP1(t)] = ttest(z1(:,t));
[~,corrP2(t)] = ttest(z2(:,t));
[~,corrP3(t)] = ttest(z3(:,t));
end

end

[~,tp1] = min(abs(EEG.times - 11));
[~,tp2] = min(abs(EEG.times - 250));
ti = tp1:4:tp2;
corrP1c = mafdr(corrP1(ti),'BHFDR','true');
corrP2c = mafdr(corrP2(ti),'BHFDR','true');
corrP3c = mafdr(corrP3(ti),'BHFDR','true');

logcc1 = corrP1c<0.05;
cc1 = ones(1,length(ti))*-0.25;
cc1(logcc1==0) = NaN;
plot(timec,cc1,'color',c(4,:),'linewidth',2);

logcc2 = corrP2c<0.05;
cc2 = ones(1,length(ti))*-0.3;
cc2(logcc2==0) = NaN;
plot(timec,cc2,'color',c(5,:),'linewidth',2);

logcc3 = corrP3c<0.05;
cc3 = ones(1,length(ti))*-0.35;
cc3(logcc3==0) = NaN;
plot(timec,cc3,'color',c(6,:),'linewidth',2);

lgd2 = legend([ps.h1,ps.h2,ps.h3],conditionName,'box','off','location','southeast','fontsize',8);
lgd2.Position = [0.81,0.16,0.1,0.05];

saveas(fig,[pathOut,'model_comparison_repeats','_',stepNo,'.png']);
saveas(fig,[pathOut,'figure7.png']);