-module(money).
-export([start/1]).


%%bank_process(Customer) ->
%%receive loan amount
%%check if bank has that amount
%%if yes than give loan
%%.

customer_process(CustomerTuple) ->
  RandomWaitTime = rand:uniform(91) + 10,
  timer:sleep(RandomWaitTime),
  {CustomerName, Loan, BankProcesses} = CustomerTuple,

%%  io:format("Customer: ~p, Loan: ~p, Banks: ~p~n", [CustomerName, Loan, BankProcesses]),
  RandomLoan = rand:uniform(50),
  Index = rand:uniform(length(BankProcesses) - 1) + 1,
  CustomerData = {CustomerName, RandomLoan},
  {BankName, RandomBankProcessId} = lists:nth(Index, BankProcesses),
  io:format("Customer ~p: Requesting loan ~p from bank ~p~n", [CustomerName, Loan, BankName]),
  RandomBankProcessId ! CustomerData,
  receive
    {_, {BankName, accepted}} ->
      io:format("Customer ~p: Loan accepted by bank ~p~n", [CustomerName, BankName]),
      UpdatedLoan = Loan - RandomLoan,
      case UpdatedLoan > 0 of
        true ->
        customer_process({CustomerName, UpdatedLoan, BankProcesses});
        false ->
        io:format("Customer ~p: Received all money. Loan objective fulfilled.~n", [CustomerName])
      end;
    {_, {BankName, rejected}} ->
      io:format("Customer ~p: Loan rejected by bank ~p~n", [CustomerName, BankName]),
      customer_process({CustomerName, Loan, remove_bank(BankName, BankProcesses)})
  end.






bank_process(BankTuple) ->
  {BankName, BankResources} = BankTuple,
  io:format("Bank ~p:   from bank ~p~n", [BankName, BankResources]),
  receive
    {From, CustomerData} ->
%%      io:format("Received data: ~p~n", [CustomerData]),
      {CustomerName, LoanAmount} = CustomerData,
      case BankResources >= LoanAmount of
        true->
          UpdatedBankResources = BankResources- LoanAmount,
          io:format("Bank ~p: Loan accepted for customer ~p~n", [BankName, CustomerName]),
          From ! {self(), {BankName, accepted}},
          bank_process({BankName, UpdatedBankResources});
        false ->
          % Reject the loan
          io:format("Bank ~p: Loan rejected for customer ~p~n", [BankName, CustomerName]),
          From ! {self(), {BankName, rejected}},
          bank_process(BankTuple) % Continue listening for requests
      end
  end.




create_processes(BankInfo, CustomerInfo) ->
  BankProcesses = create_bank_processes(BankInfo),
  timer:sleep(200),
  CustomerProcesses = create_customer_processes(CustomerInfo, BankProcesses)
.

create_bank_processes(BankInfo) ->
  lists:map(fun({BankName, BankResources}) -> {BankName, spawn_link(fun() -> bank_process({BankName, BankResources}) end)} end, BankInfo).

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









