%% Model of bacterial chemo-sensing
S = logspace(-6,3,9);
m = ssBacteriaModel;
m.stimulus = S;
m.live_update = true;
m.manipulate;


%% Dynamical Adaptation Model
m = DAmodel;
m.live_update = true;
S = exp(randn(1e4,1));
m.stimulus = S;
m.time = 1e-3*(1:length(S));


%% interactive t-SNE
n = 3e2; T = 50;
S = zeros(T,n);
w = [ones(n/2,1); 2*ones(n/2,1)] + .1*randn(n,1);
for i = 1:n
	S(:,i) = sin((1:50)/w(i));
end

m = itsne; m.stimulus = S; m.manipulate;