%%-module(hw).
%%-export([start/1]).
%%
%%customer_process(CustomerTuple, Pid) ->
%%  RandomWaitTime = rand:uniform(91) + 10,
%%  timer:sleep(RandomWaitTime),
%%  {CustomerName, Loan, BankProcesses} = CustomerTuple,
%%
%%%%  io:format("Customer: ~p, Loan: ~p, Banks: ~p~n", [CustomerName, Loan, BankProcesses]),
%%  RandomLoan = rand:uniform(50),
%%%%  io:format("RandomLoan: ~p~n", [CustomerName]),
%%  Index = rand:uniform(length(BankProcesses)),
%%  CustomerData = {CustomerName, RandomLoan},
%%
%%  {BankName, RandomBankProcessId} = lists:nth(Index, BankProcesses),
%%%%  io:format("Customer ~p: Requesting loan ~p from bank ~p~n", [CustomerName, Loan, BankName]),
%%%%  BankMessage = "? "++ CustomerName++"requests a  loan of "++RandomLoan++" dollar(s) from the "++BankName++" bank",
%%  BankMessage = "? " ++ atom_to_list(CustomerName) ++ " requests a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) from the " ++ atom_to_list(BankName) ++ " bank",
%%
%%
%%  Pid ! {self(), BankMessage , {ass, 111}},
%%  RandomBankProcessId ! {self(), CustomerData},
%%  receive
%%    {_, {BankName, accepted}} ->
%%
%%
%%%%      io:format("Customer ~p: Loan accepted by bank ~p~n", [CustomerName, BankName]),
%%      UpdatedLoan = Loan - RandomLoan,
%%      case UpdatedLoan > 0 of
%%        true ->
%%          customer_process({CustomerName, UpdatedLoan, BankProcesses}, Pid);
%%        false ->
%%          io:format("Customer ~p: Received all money. Loan objective fulfilled.~n", [CustomerName])
%%      end;
%%    {_, {BankName, rejected}} ->
%%      io:format("Customer ~p: Loan rejected by bank ~p~n", [CustomerName, BankName]),
%%      customer_process({CustomerName, Loan, remove_bank(BankName, BankProcesses)}, Pid)
%%  end.
%%
%%remove_bank(_, []) -> [];
%%remove_bank(BankName, [{BankName, _} | Rest]) -> remove_bank(BankName, Rest);
%%remove_bank(BankName, [OtherBank | Rest]) -> [OtherBank | remove_bank(BankName, Rest)].
%%
%%
%%
%%
%%bank_process(BankTuple, Pid) ->
%%  {BankName, BankResources} = BankTuple,
%%%%  io:format("Bank ~p:   from bank ~p~n", [BankName, BankResources]),
%%  receive
%%    {From, {CustomerName, RandomLoan}} ->
%%%%      io:format("Received data: ~p~n", [{CustomerName, RandomLoan}]),
%%%%      {CustomerName, RandomLoan} = CustomerData,
%%      case BankResources >= RandomLoan of
%%        true->
%%          UpdatedBankResources = BankResources- RandomLoan,
%%          BankMessage = "$ The " ++ atom_to_list(BankName) ++ " bank approves a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) to " ++ atom_to_list(CustomerName),
%%%%          io:format("Bank ~p: Loan accepted for customer ~p~n", [BankName, CustomerName]),
%%          ReportBankData = {BankName, UpdatedBankResources},
%%          Pid ! {self(), BankMessage, ReportBankData},
%%          From ! {self(), {BankName, accepted}},
%%          bank_process({BankName, UpdatedBankResources}, Pid);
%%        false ->
%%          % Reject the loan
%%%%          io:format("Bank ~p: Loan rejected for customer ~p~n", [BankName, CustomerName]),
%%          BankMessage = "$ The " ++ atom_to_list(BankName) ++ " bank denies a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) to " ++ atom_to_list(CustomerName),
%%          Pid ! {self(), BankMessage},
%%          From ! {self(), {BankName, rejected}},
%%          bank_process(BankTuple, Pid) % Continue listening for requests
%%      end
%%  end.
%%
%%
%%
%%
%%
%%create_processes(BankInfo, CustomerInfo, Pid) ->
%%  BankProcesses = create_bank_processes(BankInfo, Pid),
%%  timer:sleep(200),
%%  CustomerProcesses = create_customer_processes(CustomerInfo, BankProcesses,Pid)
%%.
%%
%%create_bank_processes(BankInfo, Pid) ->
%%  lists:map(
%%    fun({BankName, BankResources}) ->
%%      {BankName, spawn_link(fun() -> bank_process({BankName, BankResources}, Pid) end)}
%%
%%    end,
%%    BankInfo
%%  ).
%%
%%create_customer_processes(CustomerInfo, BankProcesses, Pid) ->
%%  lists:map(
%%    fun({CustomerName, Loan}) ->
%%      {CustomerName, Loan, BankProcesses, spawn_link(fun() -> customer_process({CustomerName, Loan, BankProcesses}, Pid) end)}
%%    end,
%%    CustomerInfo
%%  ).
%%
%%
%%
%%
%%listen_customers(BankInfo) ->
%%  receive
%%    {_, Message, ReportBank} ->
%%      io:format("~s~n", [Message]),
%%      io:format("BankReport: ~p~n", [ReportBank]),
%%      {BankName, Balance} = ReportBank,
%%      UpdatedBankInfo = add_property_if_match(BankInfo, BankName, Balance),
%%      io:format("Updated BankInfo: ~p~n", [UpdatedBankInfo]),
%%%%
%%      listen_customers(UpdatedBankInfo)
%%  after 5000 ->
%%    print_summary(BankInfo)
%%  end.
%%
%%add_property_if_match(List, BankName, Balance) ->
%%  lists:map(fun(Tuple) ->
%%    case Tuple of
%%      {MatchName, OriginalBalance} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
%%      {MatchName, OriginalBalance, _} when MatchName == BankName -> {MatchName, OriginalBalance, Balance};
%%      _ -> Tuple
%%    end
%%            end, List).
%%
%%
%%print_summary(BankInfo) ->
%%  String = "Banks: ",
%%  io:format("~s~n", [String]),
%%  lists:foreach(
%%    fun({BankName, TotalResources, RemainingAmount}) ->
%%      io:format("Bank: ~p: original: ~p, balance: ~p~n", [BankName, TotalResources, RemainingAmount])
%%    end,
%%    BankInfo
%%  ).
%%
%%
%%start(Args) ->
%%  CustomerFile = lists:nth(1, Args),
%%  BankFile = lists:nth(2, Args),
%%  {ok, CustomerInfo} = file:consult(CustomerFile),
%%  {ok, BankInfo} = file:consult(BankFile),
%%  Pid = self(),
%%  create_processes(BankInfo, CustomerInfo, Pid),
%%  listen_customers(BankInfo).
%%
%%
%%
%%
%%
%%
%%
%%
%%
%%
%%
