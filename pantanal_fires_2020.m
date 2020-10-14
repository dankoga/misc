function pantanal_fires()
% Data for Jun 1998 to Oct 2020 retrieved from:
% http://queimadas.dgi.inpe.br/queimadas/portal-static/estatisticas_estados/
% in 10/14/2020.
% Data format:
% Columns: Months; Rows: Years; Null values: No Data.


FiresHistory = [...
    0    0    0    0    0   12  206  172  542  507  162   58
  161   10   17   29  106   65  845 2988 1922 2049  743   52
   93   30   19    1    8   29   25  263  503  950  295   74
   66   62   11   36   67  219  444 2540 2264  879  175   19
  137   28   10   24   29  320  805 2934 2662 2761 2328  448
  180   48   36   40  107  170  260  517 1188  715  378   83
  185  126  141   68   15  240  384 1164 3963  191  335  155
   20  107  100  163  331  435 1259 5993 2997  933  125   73
   28   51   36   19  104  101  375  892 1024  266  254   23
    6   13   30   68  101  239  341 1858 5498 1481  189   45
   14   13   20   28   48   44  216  588 1660 1046  274  594
  380  117   71  525  815  308  311  695 1127  919  414   55
   31   47   88   87   67  247  511 1548 3072 1142  385  795
  145   22    2    2   20   42  105  309  807  562  873  643
  188   83   97   38  115  109  490 2698 2518  832  157  122
  108   55  115   51   47   17  129  440 1201  544  513  176
  103   64   23   55   16   27   90  134  375  459  184   37
   95   51   28   29   36  218  225 1025 1181  794  282  494
   37   29   18   34   59   93  542  966 2000 1066  215  125
  261   73   68   38   48   93  610 1092 2588  669  214   19
   23    8   14   19   28   46  190  275  785  120   20  163
  337  211   93   33   68  239  494 1690 2887 2430 1296  247
  265  164  602  784  313  406 1684 5935 8106 2291    0    0
];

% Calculating monthly statistics.
FiresMonthlyMax = zeros(12, 1);
FiresMonthlyMin = FiresMonthlyMax;
FiresMonthlyAvg = FiresMonthlyMax;
FiresMonthlySD  = FiresMonthlyMax;
for month = 1:12
    FiresMonth = FiresHistory(:, month)';
    FiresMonth = FiresMonth(FiresMonth > 0);
    
    FiresMonthlyMax(month) = max(FiresMonth);
    FiresMonthlyMin(month) = min(FiresMonth);
    FiresMonthlyAvg(month) = mean(FiresMonth);
    FiresMonthlySD(month)  = std(FiresMonth);
end

% Discarding Oct/2020 data from the statistics as it is incomplete.
FiresMonth = FiresHistory(1:end-1, 10);
FiresMonthlyMax(10) = max(FiresMonth);
FiresMonthlyMin(10) = min(FiresMonth);
FiresMonthlyAvg(10) = mean(FiresMonth);
FiresMonthlySD(10)  = std(FiresMonth);

% Creating color map. 1st index (null values) is black.
ColorMap = [0.0, 0.0, 0.0;
            ones(max(FiresHistory(:)), 3)];
ColorMap(2:end, 2) = linspace(0, 1, max(FiresHistory(:)));
ColorMap = hsv2rgb(ColorMap);

% Creating MonthLabel cell.
MonthLabel = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};    
    
% Creating new figure.
hf = figure('Color', 'white', ...
            'Position', [0, 0, 1800,800]);

% Creating image axis.
ha1 = axes(hf, ...
           'NextPlot', 'add', ...
           'OuterPosition', [0.0 0.0 0.4 1.0], ...
           'ColorMap', ColorMap, ...
           'XLim', [0.5, 12.5], ...
           'XTick', (1:12), ...
           'XTickLabelRotation', 90, ...
           'XTickLabel', MonthLabel, ...
           'YLim', [0.5, 23.5], ...
           'YTick', (1:23), ...
           'YTickLabel', (1998:2020));
% Plotting image. Values will be offsetted by 1 to match colormap indexes.
image(ha1, FiresHistory+1);
hc = colorbar();
hc.Ruler.Exponent = 3;

% Creating graph axis.
ha2 = axes(hf, ...
           'NextPlot', 'add', ...
           'OuterPosition', [0.3 0.0 0.75 1.0], ...
           'XLim', [1.0, 12.0], ...
           'XTick', (1:12), ...
           'XTickLabel', MonthLabel, ...
           'YLim', [0.0, max(FiresHistory(:))]);
ha2.YRuler.Exponent = 3;
ylabel('Fire Outbreaks');
% Plotting area between extremes.
fill(ha2, [(1:12)'; (12:-1:1)'], [FiresMonthlyMax; flip(FiresMonthlyMin)], ...
     hsv2rgb([1 0.2 1]), ...
     'EdgeColor', 'red');
% Plotting area between +/- 1 standard deviation.
fill(ha2, [(1:12)'; (12:-1:1)'], [FiresMonthlyAvg-FiresMonthlySD; flip(FiresMonthlyAvg+FiresMonthlySD)], ...
     hsv2rgb([0.2 0.2 1]), ...
     'EdgeColor', 'yellow');
% Plotting average.
plot(ha2, (1:12)', FiresMonthlyAvg,'-k', 'LineWidth', 1);
% Plotting last year's data.
plot(ha2, (1:12)', FiresHistory(end-1,1:12), '--+k', 'LineWidth', 1, 'MarkerFaceColor', 'k');
% Plotting current year's data.
plot(ha2, (1:9)', FiresHistory(end,1:9), '-sk', 'LineWidth', 2, 'MarkerFaceColor', 'k');
plot(ha2, (9:10)', FiresHistory(end,9:10), '--sk', 'LineWidth', 2);

legend('Extremes', ...
       '±1 Std. Deviation', ...
       'Average', ...
       '01/2019 to 12/2019 Data', ...
       '01/2020 to 09/2020 Data', ...
       '10/2020 Data (Incomplete)', ...
       'Location', 'NorthWest');
