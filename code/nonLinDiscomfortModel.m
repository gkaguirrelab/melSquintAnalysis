discomfortStruct = loadDiscomfortRatings();

groups = {'control','mwa','mwoa'};
colors = {'k','b','r'};
params = {'melScale','mikowski','slope','intercept'};
BinWidths = [0.025,0.1,0.1,0.25];
nBoots = 1000;
figure
options = optimset('fmincon');
options.Display = 'off';

p =[];
pB = [];

for ii = 1:length(groups)
    
    dVeridcal = [];
    Mc = [];
    Lc = [];
    
    % Assemble the melanopsin and cone contrasts for each discomfort rating.
    % We treat light flux stimuli as having equal contrast on the mel and LMS
    % photoreceptor pools.
    Mc = [ ...
        repmat(100,1,20); ...
        repmat(200,1,20); ...
        repmat(400,1,20); ...
        repmat(0,1,20); ...
        repmat(0,1,20); ...
        repmat(0,1,20); ...
        repmat(100,1,20); ...
        repmat(200,1,20); ...
        repmat(400,1,20); ...
        ];
    
    Mc = reshape(Mc,1,180);
    
    Lc = [ ...
        repmat(0,1,20); ...
        repmat(0,1,20); ...
        repmat(0,1,20); ...
        repmat(100,1,20); ...
        repmat(200,1,20); ...
        repmat(400,1,20); ...
        repmat(100,1,20); ...
        repmat(200,1,20); ...
        repmat(400,1,20); ...
        ];
    
    Lc = reshape(Lc,1,180);
    
    % Assemble the discomfort ratings
    groupField = [groups{ii} 'Discomfort'];
    dVeridical = [ ...
        discomfortStruct.(groupField).Melanopsin.Contrast100; ...
        discomfortStruct.(groupField).Melanopsin.Contrast200; ...
        discomfortStruct.(groupField).Melanopsin.Contrast400; ...
        discomfortStruct.(groupField).LMS.Contrast100; ...
        discomfortStruct.(groupField).LMS.Contrast200; ...
        discomfortStruct.(groupField).LMS.Contrast400; ...
        discomfortStruct.(groupField).LightFlux.Contrast100; ...
        discomfortStruct.(groupField).LightFlux.Contrast200; ...
        discomfortStruct.(groupField).LightFlux.Contrast400; ...
        ];
    
    % Anonymous functions for the model
    myModel = @(k) ((k(1).*Mc).^k(2) + Lc.^k(2)).^(1/k(2));
    myLogLinFit = @(k,m) m(1).*log10(myModel(k))+m(2);
        
    %% Bootstrap
    for bb = 1:nBoots
        
        % Resample across columns (subjects) with replacement
        d = dVeridical(:,datasample(1:20,20));
        
        % Reshape d to a vector
        d = reshape(d,1,180);
        
        % Objective function
        myObj = @(p) sqrt(sum( (d - myLogLinFit(p(1:2),p(3:4))).^2 ));
        
        % Fit that sucker
        pB(ii,bb,:) = fmincon(myObj,[1 1 1 1],[],[],[],[],[0.1 1 0 -10],[2 5 Inf 10],[],options);
       
    end
    
    % Obtain the p values and plot these
    p = median(squeeze(pB(ii,:,:)));    
    subplot(1,3,ii)
    plot(log10(myModel(p(1:2))),d,['*' colors{ii}])
    hold on
    refline(p(3),p(4))
    ylim([0 10]);
    title(groups{ii});
    
end

% Plot a histogram of the parameter values by groups across bootstraps
figure
for pp=1:4
    subplot(2,2,pp);
    histogram(squeeze(pB(1,:,pp)),'FaceColor',colors{1},'EdgeColor','none','BinWidth',BinWidths(pp))
    hold on
    histogram(squeeze(pB(2,:,pp)),'FaceColor',colors{2},'EdgeColor','none','BinWidth',BinWidths(pp))
    histogram(squeeze(pB(3,:,pp)),'FaceColor',colors{3},'EdgeColor','none','BinWidth',BinWidths(pp))
    title(params{pp});

    outline = [params{pp} ' [95 CI] --- '];
    for ii = 1:3
        vals = sort(squeeze(pB(ii,:,pp)));
        p = median(vals);
        p95low = vals(round(nBoots*0.05));
        p95hi = vals(round(nBoots*0.95));
        outline = sprintf([outline groups{ii} ': %2.2f [%2.2f - %2.2f]; '],p,p95low,p95hi);
    end
    fprintf([outline '\n']);
    
end

