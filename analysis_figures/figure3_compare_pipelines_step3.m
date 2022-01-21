% ##### PLOT FIGURE 3 #####

% This script runs all of the analysis generates figure 3 from the 
% manuscript which compares the TEP outcomes from the three pipelines after
% step 3.

% Author: Nigel Rogasch, University of Adelaide, 2021

clear; close all; clc;

conditionName = {'FI v S','FI v M','S v M'};
% conditionName = {'S1 v S2','S1 v S3','S2 v S3'};

% Load name
loadName = 'model_comparison';

% Step No
stepNo = 'step3';

% Condition name
condName = {'FastICA','SOUND','Model'};

% Data path
pathIn = '/projects/kg98/Mana/decay/highIntensity_separateBlocks_withTMSPulse/';
pathOut = '/projects/kg98/Nigel/TMS-EEG_cleaning_pipeline/figures/';

% EEGLAB
addpath(genpath('/projects/kg98/Mana/Scripts/Toolboxes/eeglab14_1_2b/'));
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; close;

% Fieldtrip
addpath('/projects/kg98/Mana/Scripts/Toolboxes/fieldtrip-20180619');
ft_defaults;

% Load data
load([pathIn,loadName,'_',stepNo,'.mat']);

% Load example data
filename = ['121_FEF_Decaytest_withTMSPulse_step3_SOUND.set'];
EEG = pop_loadset('filename',filename,'filepath',pathIn);
EEG = pop_epoch( EEG, {  }, [-0.5 0.5], 'newname', 'Merged datasets epochs', 'epochinfo', 'yes');
EEG = pop_interp(EEG, EEG.allchan, 'spherical');
  
%%

% Plot GMFA
close all;

fig = figure('color','w');
set(gcf,'position',[250,60,850,760]);

[~,t1] = min(abs(EEG.times - -500));
[~,t2] = min(abs(EEG.times - -3));
[~,t3] = min(abs(EEG.times - 11));
[~,t4] = min(abs(EEG.times - 500));

time = EEG.times;

tp = [-50,16,28,45,66,108,200];

c = get(0, 'DefaultAxesColorOrder');

subplot(2,2,1)
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
    plot([tp(ix),tp(ix)],[-5,7],'color',[0.7,0.7,0.7]);
    if ix ==1
    elseif ix==2
            text(tp(ix),7.3,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','right');
    else 
    text(tp(ix),7.3,num2str(tp(ix)),'fontsize',8,'HorizontalAlignment','center');
    end
end

text(-120,7.3,'A','fontsize',16,'fontweight','bold');

plot([0,0],[-5,7],'k--','linewidth',2);

set(gca,'box','off','xlim',[-50,250],'ylim',[0,7],'tickdir','out','linewidth',2,'fontsize',14);
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
ti = tp1:40:tp2;
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
plot(timec,gc2,'color',c(5,:),'linewidth',2);

loggc3 = gmfaP3c<0.05;
gc3 = ones(1,length(ti))*0.2;
gc3(loggc3==0) = NaN;
plot(timec,gc3,'color',c(6,:),'linewidth',2);

lgd1 = legend([pg.h1,pg.h2,pg.h3],condName,'box','off','location','southeast','fontsize',8);
lgd1.Position = [0.36,0.63,0.1,0.05];

% Plot correlations
corrComp = {'r1','r2','r3'};

for idx = 1:size(tep.(condition{1}),3)
    for tx = 1:size(tep.(condition{1}),2)
        r.r1(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{2})(:,tx,idx));
        r.r2(idx,tx) = corr(tep.(condition{1})(:,tx,idx),tep.(condition{3})(:,tx,idx));
        r.r3(idx,tx) = corr(tep.(condition{2})(:,tx,idx),tep.(condition{3})(:,tx,idx));
    end
end

subplot(2,2,2)
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
ti = tp1:40:tp2;
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
lgd2.Position = [0.81,0.63,0.1,0.05];


% Plot topoplots

plotStruc = [];
plotStruc.time = 1;
plotStruc.dimord = 'chan';
plotStruc.label = {EEG.chanlocs.labels};

twidth = 0.11;
theight = 0.11;

for sitex = 1:length(condition)
    
    txpos = linspace(0.07,(1-0.07-twidth),length(tp));
%     typos(:,1) = flip(linspace(0.5+0.05,(1-0.09-theight),3));
%     typos(:,2) = flip(linspace(0.05,(0.5-0.09-theight),3));
    typos = flip(linspace(0.05,(0.5-0.09-theight),3));
    
    ix = 4:length(tp)*3+3;
    ix = reshape(ix,3,[]);
    
    for plotx = 1:length(tp)
        posName = ['pos',num2str(ix(1,plotx))];
        pos.(posName) = [txpos(plotx),typos(1,sitex),twidth,theight];
        subplot('position',pos.(posName))
        
        [~,tpN] = min(abs(time-tp(plotx)));
        
        % Define data point
        plotStruc.avg = mean(tep.(condition{sitex})(:,tpN,:),3);
        
        cfg = [];
        cfg.layout = 'easycapM11.mat';
        cfg.comment = 'no';
        cfg.interactive = 'no';
        cfg.zlim = [-3,3];
        cfg.markersymbol = '.';
        ft_topoplotER(cfg,plotStruc);
        
        if sitex == 1
            text(0,0.85,[num2str(tp(plotx)),' ms'],'horizontalalignment','center','fontsize',14);
        end
        
        if plotx == 1
            text(-1.35,0,condName{sitex},'fontsize',11);
        end
        
        if sitex ==1 && plotx ==1
            text(-1.3,0.85,'C','fontsize',16,'fontweight','bold');
        end
        
        if plotx == length(tp)
        cb = colorbar;
        tmpc = cb.Position;
        cb.Position = [tmpc(1)+0.06,tmpc(2)-0.03,tmpc(3),0.07];
        cb.LineWidth = 1.5;
        cb.Ticks = [cfg.zlim(1);0;cfg.zlim(2)];
        title(cb,'\muV');
        
    end
        
    end
end

saveas(fig,[pathOut,loadName,'_',stepNo,'.png']);
saveas(fig,[pathOut,'figure3.png']);