clear all;
pkg load io;

function buy = buy_or_sell
  buy = fix(2*rand(1)) == 1;
endfunction

data = csv2cell("PETR4.csv");

close = flip(cell2mat(data(2:end, 3)));
data_size = length(close);
days = 1:data_size;

amount_per_action = 10;
stocks_amount = 100;

total_money_remaining = 10;
total_money_stocks = stocks_amount * close(1,1);
total_money = total_money_stocks + total_money_remaining;

history_days = [1];
history_progress = [total_money];
history_stocks = [stocks_amount]

subplot(1,2,1);
fig = plot(days, close);
title("Stock prices");
ylabel("price");
xlabel("day");
grid on;

subplot(1,2,2);

for i = days
  printf("day: %d\n",i);

  current_value = close(i,1)

  total_money_stocks = stocks_amount * current_value;
  total_money = total_money_stocks + total_money_remaining;

  tmp_money_remaining = total_money_remaining;
  tmp_stocks_amount = stocks_amount;
  
  buy = and(buy_or_sell(),total_money_remaining > 0);
  stock_price_per_amount = amount_per_action * current_value;


  if buy
    # when he buys, the money will leave from his wallet
    printf("Buy\n");
    tmp_money_remaining -= stock_price_per_amount;
    tmp_stocks_amount += amount_per_action;
  elseif stocks_amount > 0
    # when he sells, the money will come to his wallet (remaining)
    printf("Sell\n");
    tmp_money_remaining += stock_price_per_amount;
    tmp_stocks_amount -= amount_per_action;
  else
    printf("No solution was found!\n");
    printf("So we need to sell and pay the debt later\n");
    printf("Buy\n");
    tmp_money_remaining -= stock_price_per_amount;
    tmp_stocks_amount += amount_per_action;
  endif
  
  tmp_money_stocks = tmp_stocks_amount * current_value;
  tmp_total_money = tmp_money_stocks + tmp_money_remaining;

  accept_by_random = rand(1) <= 0.4 #40% of chance
  if or(tmp_total_money > total_money, accept_by_random) 
    printf("accepted movement\n");
    stocks_amount = tmp_stocks_amount;
    total_money_remaining = tmp_money_remaining;
    total_money = tmp_total_money;
  endif

  printf("amount of stocks: %d\n",stocks_amount);
  printf("money in wallet: %d\n",total_money_remaining);
  printf("money in stocks: %d\n",total_money_stocks);
  printf("total money: %d\n",total_money);
  printf("\n\n");

  history_days = cat(1,history_days, [i]);
  history_progress = cat(1, history_progress, [total_money]);
  history_stocks = cat(1, history_stocks, [stocks_amount]);

  plot(history_days, history_progress, history_days, history_stocks);
  title("Hill Climbing Progress");
  legend("money", "amount of stocks")
  ylabel("amount/price");
  xlabel("day");
  grid on;
  saveas(1, "plot.png");
  pause(0.1);

endfor

waitfor(fig);


