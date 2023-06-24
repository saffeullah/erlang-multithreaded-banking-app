-module(money).
-export([start/1, run_customer_logic/1]).


run_customer_logic(Customer) ->
  timer:sleep(200),
  RandomAmount = rand:uniform(50),
  io:format("Customer: ~p, Random Amount: ~p~n", [Customer, RandomAmount]).

%%run_bank_logic(Bank) ->
%%  receive
%%    {message, Pid} ->
%%  end.

customer_process(Customer) ->
  spawn(money,run_customer_logic, [Customer] ),
  io:format("~p~n", [Customer])
  .

readyData(CustomerInfo, BankInfo) ->
  lists:map(fun customer_process/1, CustomerInfo)
%%  io:write(BankInfo),
%%  io:format("~s~n","hello")
.


start(Args) ->
%%  random:seed(now()),


  CustomerFile = lists:nth(1, Args),
  BankFile = lists:nth(2, Args),
  {ok, CustomerInfo} = file:consult(CustomerFile),
  {ok, BankInfo} = file:consult(BankFile),
  readyData(CustomerInfo, BankInfo).
%%  io:format("~p~n", CustomerInfo),
%%  Size = length(CustomerInfo),
%%  io:format("~p~n", [Size]).






