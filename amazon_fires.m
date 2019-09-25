function amazon_fires()
% Data for Jun 1998 to Sep 2019 retrieved from:
% http://queimadas.dgi.inpe.br/queimadas/portal-static/estatisticas_estados_light/grafico_historico_estado_amazonia_legal_titulo.html
% in 23/9/2019.
% Data format:
% Columns: Months; Rows: Years; Null values: No Data.


FiresHistory = [...
     0      0      0      0       0   2620   5706  29683  29627  13160   4178   2640
   221    385    153    116     764   2401   5681  29133  24604  17826   4999   1782
   133    202    463    123    1371   4848   2657  16813  15473  14525   6207   3310
   228    733   1137    711    1283   7117   3715  23902  25897  19264   9054   4402
   720    765    989    761    2769   8794  11661  53377  64827  35967  27519  10014
  4139   1819   2208   1556    3539  11394  22480  40505  63683  33799  22282  14866
  2356    958   1408   1542    5155  14493  24899  49930  91745  33323  31697  18139
  4618   1427    967   1343    2881   5177  24071  73683  85108  37464  19488   7767
  2444   1056   1095    897    1492   4602  10456  40473  60858  22717  20800   9218
  2269   1879   1896   1254    2718   7552  11785  67774 101817  40605  17925   5921
  1111    637    979    799     963   2975   8693  26274  34735  32389  18065   6873
  1575    510    784    610    1038   2055   4764  13170  25876  22393  21596   6889
  2060   1413   1636   1572    2529   5928  13228  67077  77295  21603  15105   6329
   964    350    573    819    1227   2930   4846  12653  28347  14375  11715   8483
  1370    576    766    998    1883   4169   8364  35263  40325  22694  14155   6087
  1408    579   1063    889    1593   3195   5415  14780  24511  14873   8057   8658
  1820    585   1216   1138    1687   4213   6427  29861  28729  20593  13923   8443
  2611   1251    858   1153    1202   3610   5808  28589  40452  29112  19055  12665
  4868   2188   2497   2049    2061   3831  12050  27391  28295  19771  13529   5516
  1056    522   1121   1100    1792   3615  11779  27712  55994  20464  15711   8545
  1720    992   1764    828    1909   3846   7572  15001  31140  13322   9948   2366
  1852   1675   3943   2193    2141   4838   8567  39177  28605      0      0      0
];

% Calculating monthly statistics.
FiresMonthlyMax = max(FiresHistory)';
FiresMonthlyMin = zeros(12, 1);
FiresMonthlyAvg = FiresMonthlyMin;
FiresMonthlySD  = FiresMonthlyMin;
for month = 1:12
    FiresMonth = FiresHistory(:, month)';
    FiresMonth = FiresMonth(FiresMonth > 0);
    
    FiresMonthlyMin(month) = min(FiresMonth);
    FiresMonthlyAvg(month) = mean(FiresMonth);
    FiresMonthlySD(month)  = std(FiresMonth);
end

% Discarding Sep/2019 data from the statistics as it is incomplete.
FiresMonth = FiresHistory(1:end-1, 9);
FiresMonthlyMin(9) = min(FiresMonth);
FiresMonthlyAvg(9) = mean(FiresMonth);
FiresMonthlySD(9)  = std(FiresMonth);

% Creating color map. 1st index (null values) is black.
ColorMap = [0.0, 0.0, 0.0;
            ones(max(FiresHistory(:)), 3)];
ColorMap(2:end, 2) = linspace(0, 1, max(FiresHistory(:)));
ColorMap = hsv2rgb(ColorMap);

% Creating MonthLabel cell.
MonthLabel = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};

% Extrapolating data using a simple prediction.
% The model used is just the monthly average scaled and offsetted.
% (Yup, not scientific at all...)
funError = @(C) (C(1)*FiresMonthlyAvg(1:8) + C(2) - FiresHistory(end, 1:8)')' * ...
                (C(1)*FiresMonthlyAvg(1:8) + C(2) - FiresHistory(end, 1:8)');
C = fminsearch(funError, [1, 0]);

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
           'YLim', [0.5, 22.5], ...
           'YTick', (1:22), ...
           'YTickLabel', (1998:2019));
% Plotting image. Values will be offsetted by 1 to match colormap indexes.
image(ha1, FiresHistory+1);
colorbar();

% Creating graph axis.
ha2 = axes(hf, ...
           'NextPlot', 'add', ...
           'OuterPosition', [0.3 0.0 0.75 1.0], ...
           'XLim', [1.0, 12.0], ...
           'XTick', (1:12), ...
           'XTickLabel', MonthLabel, ...
           'YLim', [0.0, max(FiresHistory(:))]);
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
% Plotting current year's data.
plot(ha2, (1:8)', FiresHistory(end,1:8), '-sk', 'LineWidth', 2, 'MarkerFaceColor', 'k');
plot(ha2, (8:9)', FiresHistory(end,8:9), '--sk', 'LineWidth', 2);
% Plotting simple prediction.
plot(ha2, (1:12)', C(1)*FiresMonthlyAvg + C(2), '--b', 'LineWidth', 2);
legend('Extremes', '±1 Std. Deviation', 'Average', '01/2019 to 08/2019 Data', '09/2019 Data (Incomplete)', 'Simple Prediction', ...
       'Location', 'NorthWest');
