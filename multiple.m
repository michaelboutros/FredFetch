function [data] = multiple(dl_fcn, series, varargin)

  % Download the series individually using dl_fcn
  Nseries    = length(series);
  individual = cell(Nseries, 1);
  for s = 1:Nseries
    individual{s} = feval(dl_fcn, series{s}, varargin{:});
  end
  not_empty = find(cellfun(@(s) ~isfield(s.info, 'url'), individual));

  % Add info
  data.info      = cellfun(@(s) s.info, individual, 'un', 0);
  data.series    = series;
  data.frequency = repmat({''},Nseries,1);
  data.frequency(not_empty) = cellfun(@(s) s.info.frequency, individual(not_empty), 'un', 0);

  % Align the vintage datasets
  alldates       = cellfun(@(s) s.date, individual(not_empty), 'un', 0);
  data.date  = sort(unique(vertcat(alldates{:})));
  data.value = nan(length(data.date), Nseries);
  for n = 1:length(not_empty)
    s = not_empty(n);
    insert = arrayfun(@(t) find(data.date==t), individual{s}.date);
    data.value(insert,s) = individual{s}.value;
  end

end