

%% API
-export([]).

customer_process(CustomerTuple, Pid) ->
  RandomWaitTime = rand:uniform(91) + 10,
  timer:sleep(RandomWaitTime),
  {CustomerName, Loan, BankProcesses} = CustomerTuple,

%%  io:format("Customer: ~p, Loan: ~p, Banks: ~p~n", [CustomerName, Loan, BankProcesses]),
  RandomLoan = rand:uniform(50),
%%  io:format("RandomLoan: ~p~n", [CustomerName]),
  Index = rand:uniform(length(BankProcesses)),
  CustomerData = {CustomerName, RandomLoan},

  {BankName, RandomBankProcessId} = lists:nth(Index, BankProcesses),
%%  io:format("Customer ~p: Requesting loan ~p from bank ~p~n", [CustomerName, Loan, BankName]),
%%  BankMessage = "? "++ CustomerName++"requests a  loan of "++RandomLoan++" dollar(s) from the "++BankName++" bank",
  BankMessage = "? " ++ atom_to_list(CustomerName) ++ " requests a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) from the " ++ atom_to_list(BankName) ++ " bank",


  Pid ! {self(), BankMessage},
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
      io:format("Customer ~p: Loan rejected by bank ~p~n", [CustomerName, BankName]),
      customer_process({CustomerName, Loan, remove_bank(BankName, BankProcesses)}, Pid)
  end.

remove_bank(_, []) -> [];
remove_bank(BankName, [{BankName, _} | Rest]) -> remove_bank(BankName, Rest);
remove_bank(BankName, [OtherBank | Rest]) -> [OtherBank | remove_bank(BankName, Rest)].