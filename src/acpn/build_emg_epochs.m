function epochs = build_emg_epochs(emg, eventStart, eventEnd)
%BUILD_EMG_EPOCHS Build pre/event/post and contiguous event-free epochs.

emg = double(emg(:));
eventStart = round(eventStart(:)); eventEnd = round(eventEnd(:));
valid = eventStart>=1 & eventEnd>=eventStart & eventStart<=numel(emg);
eventStart = eventStart(valid); eventEnd = min(eventEnd(valid),numel(emg));
[eventStart,order] = sort(eventStart); eventEnd = eventEnd(order);

nEvents = numel(eventStart);
pre = cell(nEvents,1); event = cell(nEvents,1); post = cell(nEvents,1); normal = cell(nEvents,1);
excluded = false(numel(emg),1);
preStart = zeros(nEvents,1); postEnd = zeros(nEvents,1);
for k = 1:nEvents
    duration = eventEnd(k)-eventStart(k)+1;
    preStart(k)=max(1,eventStart(k)-duration);
    postEnd(k)=min(numel(emg),eventEnd(k)+duration);
    excluded(preStart(k):postEnd(k))=true;
    if eventStart(k)>preStart(k)
        pre{k}=emg(preStart(k):eventStart(k)-1);
    else
        pre{k}=zeros(0,1);
    end
    event{k}=emg(eventStart(k):eventEnd(k));
    if eventEnd(k)<postEnd(k)
        post{k}=emg(eventEnd(k)+1:postEnd(k));
    else
        post{k}=zeros(0,1);
    end
end

available = ~excluded;
[runStart,runEnd] = logical_runs(available);
used = false(size(available));
for k = 1:nEvents
    target = numel(pre{k})+numel(event{k})+numel(post{k});
    chosen = [];
    for r = 1:numel(runStart)
        candidates = runStart(r):runEnd(r);
        candidates = candidates(~used(candidates));
        if numel(candidates)>=target && all(diff(candidates(1:target))==1)
            chosen=candidates(1:target); break;
        end
    end
    if ~isempty(chosen)
        normal{k}=emg(chosen); used(chosen)=true;
    else
        normal{k}=zeros(0,1);
    end
end

epochs = struct('pre',{pre},'event',{event},'post',{post},'normal',{normal}, ...
    'eventStart',eventStart,'eventEnd',eventEnd);
end

function [starts,ends] = logical_runs(mask)
d = diff([false;logical(mask(:));false]);
starts=find(d==1); ends=find(d==-1)-1;
end
