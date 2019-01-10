cd .\04_BackPain\data\test_data
%%
fnames = filenames('*.dat')
create_figure('avgs', 1, 1)

for i=1:length(fnames)
    
    inflation = csvimport(['.\' deblank(fnames{i})]);
    test.inflation_median(i) = median(cell2mat(inflation(2:end,1)));
    test.inflation_std(i) = std(cell2mat(inflation(30:end,1)));
    test.inflation_table{i} = inflation;
end
stim1 = test.inflation_median(1:4);
stim2 = test.inflation_median(5:8);
barplot_columns({stim1, stim2}, 'ind');


create_figure( 'Over Time', 8/2, 2);

    for j=1:ntrials
        subplot(ntrials/2,2,j);
        a = cell2table(test.inflation_table{j}(2:end,1))
        plot(a.Var1);%, 'color', color)
        yPos = (mean(a.Var1));
        if j < 5
            should = 0.08;
        else
            should = 0.15;
        end
        title({sprintf('Should be: %.2f', should);sprintf('Actual mean: %.2f', yPos)});
        plot(get(gca,'xlim'), [yPos yPos]);
        %x(:,j) = p.out.inflation_table{j}.Pressure_kg_cm2_;
    end