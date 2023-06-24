-module(money).
-export([start/1]).
start(Args) ->
  CustomerFile = lists:nth(1, Args),
  BankFile = lists:nth(2, Args),
  {ok, CustomerInfo} = file:consult(CustomerFile),
  {ok, BankInfo} = file:consult(BankFile),