
-module(customer).
-export([create_customer_processes/3]).

customer_process(CustomerTuple, Pid) ->
  RandomWaitTime = rand:uniform(91) + 10,
  timer:sleep(RandomWaitTime),
  {CustomerName, Loan, BankProcesses} = CustomerTuple,
  RandomLoan = rand:uniform(50),
%%  io:format("Length of banking array = : ~p~n", [length(BankProcesses)]),
  Index  = rand:uniform(length(BankProcesses)),
  CustomerData = {CustomerName, RandomLoan},
%%  io:format("Length of BankProcesses: ~p~n", [length(BankProcesses)]),
%%  io:format("Random Index: ~p~n", [Index]),

  {BankName, RandomBankProcessId} = lists:nth(Index, BankProcesses),
  BankMessage = "? " ++ atom_to_list(CustomerName) ++ " requests a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) from the " ++ atom_to_list(BankName) ++ " bank",
 Pid ! {bankstatus, BankMessage},
  RandomBankProcessId ! {self(), CustomerData},
  receive
    {_, {BankName, accepted}} ->

%%      io:format("Customer ~p: Loan accepted by bank ~p~n", [CustomerName, BankName]),
      UpdatedLoan = Loan - RandomLoan,
      case UpdatedLoan > 0 of
        true ->
          customer_process({CustomerName, UpdatedLoan, BankProcesses}, Pid);
        false ->
          io:format("Customer ~p: Received all money. Loan objective fulfilled.~n", [CustomerName])
      end;
    {_, {BankName, rejected}} ->
%%      io:format("Customer ~p: Loan rejected by bank ~p~n", [CustomerName, BankName]),
      RemovedBanks = remove_bank(BankName, BankProcesses),
      customer_process({CustomerName, Loan, RemovedBanks}, Pid)
  end
  .

remove_bank(_, []) -> [];
remove_bank(BankName, [{BankName, _} | Rest]) -> remove_bank(BankName, Rest);
remove_bank(BankName, [OtherBank | Rest]) -> [OtherBank | remove_bank(BankName, Rest)].


create_customer_processes(CustomerInfo, BankProcesses, Pid) ->
  lists:map(
    fun({CustomerName, Loan}) ->
      {CustomerName, Loan, BankProcesses, spawn_link(fun() -> customer_process({CustomerName, Loan, BankProcesses}, Pid) end)}
    end,
    CustomerInfo
  )
  .
