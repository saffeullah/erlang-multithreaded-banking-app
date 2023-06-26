-module(bank).
-export([create_bank_processes/2]).
create_bank_processes(BankInfo, Pid) ->
  lists:map(
    fun({BankName, BankResources}) ->
      {BankName, spawn_link(fun() -> bank_process({BankName, BankResources}, Pid) end)}

    end,
    BankInfo
  ).
%%         io:format("From Bank Process: ~p~n", [BankMessage]),
%% io:format("Bank ~p: Loan accepted for customer ~p~n", [BankName, CustomerName]),
%%          io:format("Bank ~p: Loan accepted for customer ~p~n", [BankName, CustomerName]),



bank_process(BankTuple, Pid) ->
  {BankName, BankResources} = BankTuple,
%%  io:format("Bank ~p:   from bank ~p~n", [BankName, BankResources]),
  receive
    {From, {CustomerName, RandomLoan}} ->
%%      io:format("Received data: ~p~n", [{CustomerName, RandomLoan}]),
%%      {CustomerName, RandomLoan} = CustomerData,
      case BankResources >= RandomLoan of
        true->
          UpdatedBankResources = BankResources- RandomLoan,
          BankMessage = "$ The " ++ atom_to_list(BankName) ++ " bank approves a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) to " ++ atom_to_list(CustomerName),
          ReportBankData = {BankName, UpdatedBankResources},
%%           io:format("From Bank Process ~p: UpdatedBankResources ~p~n", [BankName, UpdatedBankResources]),
          Pid ! { BankMessage, ReportBankData},
          From ! {self(), {BankName, accepted}},
          bank_process({BankName, UpdatedBankResources}, Pid);
        false ->
          % Reject the loan
%%          io:format("Bank ~p: Loan rejected for customer ~p~n", [BankName, CustomerName]),
          BankMessage = "$ The " ++ atom_to_list(BankName) ++ " bank denies a loan of " ++ integer_to_list(RandomLoan) ++ " dollar(s) to " ++ atom_to_list(CustomerName),
          Pid ! {BankMessage, BankTuple},
          From ! {self(), {BankName, rejected}},
          bank_process(BankTuple, Pid) % Continue listening for requests
      end
  end.