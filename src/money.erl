-module(money).
-export([start/1, run_customer_logic/1]).

find_bank() ->
 Index  = rand:uniform()
.

run_customer_logic(Customer) ->
  timer:sleep(200),
  RandomAmount = rand:uniform(50),
  io:format("Customer: ~p, Random Amount: ~p~n", [Customer, RandomAmount]).

%%run_bank_logic(Bank) ->
%%  receive
%%
%%  end.

customer_process_spawn(Customer) ->
  spawn(money,run_customer_logic, [Customer] ),
  io:format("~p~n", [Customer]).

bank_process_spawn(Bank) ->
  spawn(money,run_bank_logic, [Bank] ),
  io:format("~p~n", [Bank])
.

initialize_process_data(CustomerInfo, BankInfo) ->
  lists:map(fun customer_process_spawn/1, CustomerInfo),
  lists:map(fun bank_process_spawn/1, BankInfo)
.

hw()->
  io:write("").
hw(Aaa)->
  io:write("").


customer_process(CustomerTuple) ->
  timer:sleep(200),
  {CustomerName, Loan, BankProcesses} = CustomerTuple,
  CustomerData = {CustomerName, Loan},
  io:format("Customer: ~p, Loan: ~p, Banks: ~p~n", [CustomerName, Loan, BankProcesses]),
  RandomLoan = rand:uniform(50),
  Index = rand:uniform(length(BankProcesses)),
  {BankName, RandomBankProcessId} = lists:nth(index, BankProcesses),
  RandomBankProcessId ! CustomerData
%%  io:format("Tuple size: ~p~n", [Index])
  %%send loan request to that bank
.


%%bank_process(Customer) ->
%%receive loan amount
%%check if bank has that amount
%%if yes than give loan
%%.

bank_process() ->
  receive
    {From, CustomerData} ->
      % Process the received data here
      io:format("Received data: ~p~n", [CustomerData])
      % Send a reply if needed
%%      Reply = process_data(CustomerData),
%%      Reply = process_data(CustomerData),
%%      From ! {self(), Reply}
  end.




create_processes(BankInfo, CustomerInfo) ->
  BankProcesses = create_bank_processes(BankInfo),
  timer:sleep(200),
  CustomerProcesses = create_customer_processes(CustomerInfo, BankProcesses)
.

create_bank_processes(BankInfo) ->
  lists:map(fun({BankName, _}) -> {BankName, spawn_link(fun() -> hw() end)} end, BankInfo).

create_customer_processes(CustomerInfo, BankProcesses) ->
  lists:map(
    fun({CustomerName, Loan}) ->
      {CustomerName, Loan, BankProcesses, spawn_link(fun() -> customer_process({CustomerName, Loan, BankProcesses}) end)}
    end,
    CustomerInfo
  ).



start(Args) ->
  CustomerFile = lists:nth(1, Args),
  BankFile = lists:nth(2, Args),
  {ok, CustomerInfo} = file:consult(CustomerFile),
  {ok, BankInfo} = file:consult(BankFile),
  create_processes(BankInfo, CustomerInfo).
%%  io:format("~p~n", CustomerInfo),
%%  Size = length(CustomerInfo),
%%  io:format("~p~n", [Size]).








