function events = read_ucddb_events(eventFile,cfg)
%READ_UCDDB_EVENTS Read respiratory-event annotations from a text/CSV table.

if ~isfile(eventFile),error('Event file not found: %s',eventFile);end
T=readtable(eventFile,'TextType','string','VariableNamingRule','preserve');
vars=string(T.Properties.VariableNames);
required=[cfg.ucddb.eventTimeColumn,cfg.ucddb.eventTypeColumn];
if ~all(ismember(required,vars)),error('Event file is missing configured time/type columns.');end
type=string(T.(cfg.ucddb.eventTypeColumn));
keep=false(height(T),1);
for pattern=cfg.ucddb.eventTypePatterns,keep=keep|contains(lower(type),lower(pattern));end
T=T(keep,:); type=type(keep);
timeValue=T.(cfg.ucddb.eventTimeColumn);
secondsFromStart=to_seconds(timeValue);
durationSec=nan(height(T),1);
if ismember(cfg.ucddb.eventDurationColumn,vars)
    durationSec=to_seconds(T.(cfg.ucddb.eventDurationColumn));
end
events=table(secondsFromStart,type,durationSec,'VariableNames',{'TimeSec','Type','DurationSec'});
end

function secondsValue=to_seconds(value)
if isduration(value),secondsValue=seconds(value);return;end
if isnumeric(value),secondsValue=double(value);return;end
text=string(value);secondsValue=nan(numel(text),1);
for k=1:numel(text)
    try
        secondsValue(k)=seconds(duration(text(k),'InputFormat','hh:mm:ss'));
    catch
        secondsValue(k)=str2double(text(k));
    end
end
end
