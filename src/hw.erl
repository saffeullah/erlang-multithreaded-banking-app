
-module(customer).
-export([create_customer_processes/3]).

return(Value) ->
  Value.


validate_loan(CustomerInfo, LoanObtained) ->
  {_, RequiredLoan} = CustomerInfo,
  RemainingLoan = RequiredLoan - LoanObtained,
  io:format("RequiredLoan= ~p , LoanObtained =  ~p~n", [RequiredLoan, LoanObtained]),

  GiveLoan = if
               RemainingLoan >= 50 ->
                 rand:uniform(50);
               RemainingLoan > 0 ->
                 rand:uniform(RemainingLoan);
               true ->
                 0
             end,
  return(GiveLoan)
.





customer_process(CustomerTuple, Pid, LoanObtained) ->

  RandomWaitTime = rand:uniform(91) + 10,
  timer:sleep(RandomWaitTime),
  {CustomerName, Loan, BankProcesses} = CustomerTuple,
  io:format("Loan Obtained till now= ~p by ~p~n", [LoanObtained, CustomerName]),
  RandomLoan = validate_loan({CustomerName, Loan}, LoanObtained),
  if
    RandomLoan == 0 ->
      io:format("~s~n", ["RandomLoan =0"]),
      exit(normal);
    true -> false
  end,
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
          customer_process({CustomerName, UpdatedLoan, BankProcesses}, Pid, RandomLoan + LoanObtained);
        false ->
          io:format("Customer ~p: Received all money. Loan objective fulfilled.~n", [CustomerName])
      end;
    {_, {BankName, rejected}} ->
%%      io:format("Customer ~p: Loan rejected by bank ~p~n", [CustomerName, BankName]),
      RemovedBanks = remove_bank(BankName, BankProcesses),
      customer_process({CustomerName, Loan, RemovedBanks}, Pid, LoanObtained)
  end

.

remove_bank(_, []) -> [];
remove_bank(BankName, [{BankName, _} | Rest]) -> remove_bank(BankName, Rest);
remove_bank(BankName, [OtherBank | Rest]) -> [OtherBank | remove_bank(BankName, Rest)].


create_customer_processes(CustomerInfo, BankProcesses, Pid) ->
  lists:map(
    fun({CustomerName, Loan}) ->
      {CustomerName, Loan, BankProcesses, spawn_link(fun() -> customer_process({CustomerName, Loan, BankProcesses}, Pid, 0) end)}
    end,
    CustomerInfo
  )
.